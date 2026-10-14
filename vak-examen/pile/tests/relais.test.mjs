// Le relais de la pile signe des jetons comme Supabase Auth après une connexion par mot de passe (13/10 ; examen du
// 11/10 : la RLS de supabase_nextjs_template lit le niveau MFA, aal). Usage : node --test vak-examen/pile/tests/relais.test.mjs
import { spawn } from "node:child_process";
import { mkdtempSync, writeFileSync } from "node:fs";
import { createServer } from "node:net";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import assert from "node:assert/strict";

const port = () => new Promise((ok) => { const s = createServer().listen(0, "127.0.0.1", () => { const p = s.address().port; s.close(() => ok(p)); }); });

test("connexion par mot de passe : aal1, amr password, session_id, is_anonymous false ; mauvais mot de passe refusé", async () => {
  const dir = mkdtempSync(join(tmpdir(), "relais-"));
  const config = { port: await port(), postgrest: "http://127.0.0.1:1", fonction: "http://127.0.0.1:1", secret: "secret-de-test",
    comptes: { "a@examen-vak.test": { id: "00000000-0000-0000-0000-00000000000a", password: "mdp" } } };
  writeFileSync(join(dir, "config.json"), JSON.stringify(config));
  const relais = spawn(process.execPath, [new URL("../relais.mjs", import.meta.url).pathname, join(dir, "config.json")], { stdio: ["ignore", "pipe", "inherit"] });
  try {
    await new Promise((ok) => relais.stdout.once("data", ok));
    const login = (password) => fetch(`http://127.0.0.1:${config.port}/auth/v1/token?grant_type=password`, { method: "POST",
      headers: { "content-type": "application/json" }, body: JSON.stringify({ email: "a@examen-vak.test", password }) });
    assert.equal((await login("faux")).status, 400);
    const { access_token } = await (await login("mdp")).json();
    const claims = JSON.parse(Buffer.from(access_token.split(".")[1], "base64url").toString("utf8"));
    assert.equal(claims.sub, config.comptes["a@examen-vak.test"].id);
    assert.equal(claims.role, "authenticated");
    assert.equal(claims.aal, "aal1");
    assert.deepEqual(claims.amr.map((m) => m.method), ["password"]);
    assert.match(claims.session_id, /^[0-9a-f-]{36}$/);
    assert.equal(claims.is_anonymous, false);
    const user = await fetch(`http://127.0.0.1:${config.port}/auth/v1/user`, { headers: { authorization: `Bearer ${access_token}` } });
    assert.equal((await user.json()).id, claims.sub);
  } finally {
    relais.kill();
  }
});
