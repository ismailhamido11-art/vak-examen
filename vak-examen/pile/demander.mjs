#!/usr/bin/env node
// Pose une question à l'assistant de la pile d'examen, en tant que A ou B, par le protocole HTTP public de vak
// (packages/agent/docs/HTTP.md) : connexion, accord (texte relu, fournisseurs tels quels), POST chat. Rend du JSON :
// { compte, conversation, question, texte, outils: [{ nom, entree, sortie }], erreur? }.
// Usage : node demander.mjs <pile.json> <A|B> "<question>" [--conversation <id>]
import { execFileSync } from "node:child_process";
import { randomUUID } from "node:crypto";
import { readFileSync } from "node:fs";

const [fichier, qui, question, ...reste] = process.argv.slice(2);
if (!fichier || !qui || !question) {
  console.error('usage : node demander.mjs <pile.json> <A|B> "<question>" [--conversation <id>]');
  process.exit(2);
}
const pile = JSON.parse(readFileSync(fichier, "utf8"));
const compte = pile.comptes[qui];
if (!compte) throw new Error(`compte inconnu : ${qui} (A ou B)`);
const conversation = reste[0] === "--conversation" && reste[1] ? reste[1] : `examen-${randomUUID()}`;

const connexion = await fetch(`${pile.relais}/auth/v1/token?grant_type=password`, {
  method: "POST",
  headers: { apikey: pile.anon, "content-type": "application/json" },
  body: JSON.stringify({ email: compte.email, password: compte.password }),
});
const { access_token: jeton } = await connexion.json();
if (!jeton) throw new Error(`connexion de ${qui} refusée (${connexion.status})`);
const h = { apikey: pile.anon, authorization: `Bearer ${jeton}`, "content-type": "application/json" };

const accord = await (await fetch(`${pile.fonction}/consent`, { headers: h })).json();
if (!accord.granted) {
  const r = await fetch(`${pile.fonction}/consent`, { method: "POST", headers: h, body: JSON.stringify({ granted: true, providers: accord.providers }) });
  if (r.status !== 200) throw new Error(`accord refusé (${r.status}) : ${(await r.text()).slice(0, 200)}`);
}

// Le quota de l'app n'est pas ce que mesure le point 5 (budget_app_3, 07/10 : 10 messages par jour, 12 questions du
// juge, réponses 429) : le compteur de vak du compte est remis à zéro avant chaque question.
if (pile.db) {
  const sql = "select to_regclass('public.vak_usage') is not null as vak \\gset\n\\if :vak\ndelete from public.vak_usage where user_id = :'u';\n\\endif\n";
  execFileSync("psql", ["-X", "-q", "-v", "ON_ERROR_STOP=1", "-v", `u=${compte.id}`, pile.db], { input: sql, stdio: ["pipe", "ignore", "pipe"] });
}

const reponse = await fetch(`${pile.fonction}/chat`, {
  method: "POST",
  headers: h,
  body: JSON.stringify({ id: conversation, message: { id: randomUUID(), role: "user", parts: [{ type: "text", text: question }] }, client: { tools: [] } }),
});
const brut = await reponse.text();
const morceaux = brut
  .split("\n")
  .filter((l) => l.startsWith("data: ") && l.trim() !== "data: [DONE]")
  .flatMap((l) => {
    try {
      return [JSON.parse(l.slice(6))];
    } catch {
      return [];
    }
  });
// Un bloc par partie de texte (son `id`), séparés comme l'interface de vak les affiche (src/web/message.tsx) : recollés,
// « Je regarde ça. » puis « Deux invitations » donnaient « ça.Deux », que le juge ne lit pas (equipe_9, 10/10).
const parties = new Map();
for (const m of morceaux) if (m.type === "text-delta") parties.set(m.id ?? "", (parties.get(m.id ?? "") ?? "") + String(m.delta ?? ""));
const texte = [...parties.values()].join("\n\n");
const entrees = new Map(morceaux.filter((m) => m.type === "tool-input-available").map((m) => [m.toolCallId, { nom: m.toolName, entree: m.input }]));
const outils = morceaux.filter((m) => m.type === "tool-output-available").map((m) => ({ ...(entrees.get(m.toolCallId) ?? {}), sortie: m.output }));
const erreur = reponse.status !== 200 ? `${reponse.status} ${brut.slice(0, 300)}` : morceaux.find((m) => m.type === "error")?.errorText;
console.log(JSON.stringify({ compte: qui, conversation, question, texte, outils, ...(erreur ? { erreur } : {}) }, null, 2));
