#!/usr/bin/env node
// Relais « Supabase local » de la pile d'examen, sans dépendance (node:http, node:crypto) :
//  - /rest/v1/*            → PostgREST (qui vérifie lui-même le jeton) ;
//  - /auth/v1/token        → connexion par mot de passe des comptes d'essai, jeton HS256 signé en local ;
//  - /auth/v1/user         → l'utilisateur du jeton (ce que fait getClaims → getUser en HS256) ;
//  - /functions/v1/*       → la fonction vak servie par Deno, réponse relayée en flux.
// Usage : node relais.mjs <config.json> ; écrit « relais prêt : <url> » quand il écoute.
// config : { port, postgrest, fonction, secret, comptes: { "<adresse>": { id, password } } }
import { createHmac, timingSafeEqual } from "node:crypto";
import { readFileSync } from "node:fs";
import { createServer } from "node:http";
import { Readable } from "node:stream";

const config = JSON.parse(readFileSync(process.argv[2], "utf8"));
const now = () => Math.floor(Date.now() / 1000);
const b64url = (x) => Buffer.from(x).toString("base64url");

function signer(claims) {
  const unsigned = `${b64url(JSON.stringify({ alg: "HS256", typ: "JWT" }))}.${b64url(JSON.stringify({ iat: now(), ...claims }))}`;
  return `${unsigned}.${createHmac("sha256", config.secret).update(unsigned).digest("base64url")}`;
}

function verifier(token) {
  const [h, p, s] = String(token).split(".");
  if (!h || !p || !s) return null;
  const attendu = Buffer.from(createHmac("sha256", config.secret).update(`${h}.${p}`).digest("base64url"));
  const recu = Buffer.from(s);
  if (attendu.length !== recu.length || !timingSafeEqual(attendu, recu)) return null;
  try {
    const claims = JSON.parse(Buffer.from(p, "base64url").toString("utf8"));
    return typeof claims.exp === "number" && claims.exp < now() ? null : claims;
  } catch {
    return null;
  }
}

const envoyer = (res, status, corps) => {
  res.writeHead(status, { "content-type": "application/json" });
  res.end(JSON.stringify(corps));
};

async function lire(req) {
  const morceaux = [];
  for await (const m of req) morceaux.push(m);
  return Buffer.concat(morceaux);
}

function entetes(req, sans) {
  const h = new Headers();
  for (const [nom, val] of Object.entries(req.headers)) {
    if (val === undefined || sans.includes(nom)) continue;
    h.set(nom, Array.isArray(val) ? val.join(", ") : val);
  }
  return h;
}

async function relayer(req, res, cible) {
  const corps = req.method === "GET" || req.method === "HEAD" ? undefined : await lire(req);
  const amont = await fetch(cible, { method: req.method, headers: entetes(req, ["host", "connection", "content-length"]), body: corps });
  const sortie = {};
  amont.headers.forEach((val, nom) => {
    if (!["content-encoding", "content-length", "transfer-encoding", "connection"].includes(nom)) sortie[nom] = val;
  });
  res.writeHead(amont.status, sortie);
  if (amont.body) Readable.fromWeb(amont.body).pipe(res);
  else res.end();
}

async function traiter(req, res) {
  const url = req.url ?? "/";
  if (url.startsWith("/auth/v1/token")) {
    const { email, password } = JSON.parse((await lire(req)).toString("utf8") || "{}");
    const compte = email ? config.comptes[email] : undefined;
    if (!compte || compte.password !== password) return envoyer(res, 400, { error: "invalid_grant", error_description: "Invalid login credentials" });
    const jeton = signer({ sub: compte.id, role: "authenticated", aud: "authenticated", email, exp: now() + 3600 });
    return envoyer(res, 200, { access_token: jeton, token_type: "bearer", expires_in: 3600, user: { id: compte.id, email } });
  }
  if (url.startsWith("/auth/v1/user")) {
    const claims = verifier((req.headers.authorization ?? "").replace(/^Bearer /, ""));
    if (!claims || typeof claims.sub !== "string") return envoyer(res, 401, { code: 401, error_code: "bad_jwt", msg: "invalid JWT" });
    return envoyer(res, 200, {
      id: claims.sub,
      aud: "authenticated",
      role: claims.role,
      email: claims.email,
      is_anonymous: false,
      app_metadata: {},
      user_metadata: {},
      created_at: new Date(0).toISOString(),
    });
  }
  if (url.startsWith("/auth/v1/.well-known/jwks.json")) return envoyer(res, 200, { keys: [] });
  if (url.startsWith("/functions/v1/")) return relayer(req, res, config.fonction + url.slice("/functions/v1".length));
  if (url.startsWith("/rest/v1/")) return relayer(req, res, config.postgrest + url.slice("/rest/v1".length));
  return envoyer(res, 404, { message: `route inconnue du relais : ${url}` });
}

const serveur = createServer((req, res) => {
  traiter(req, res).catch((err) => {
    if (!res.headersSent) envoyer(res, 502, { message: err instanceof Error ? err.message : String(err) });
    else res.end();
  });
});
// Une ligne JSON quand il écoute : son adresse et la clé publique (rôle anon) signée avec le même secret.
serveur.listen(config.port, "127.0.0.1", () =>
  console.log(JSON.stringify({ relais: `http://127.0.0.1:${config.port}`, anon: signer({ role: "anon", iss: "supabase", exp: now() + 30 * 24 * 3600 }) })),
);
