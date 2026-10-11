#!/usr/bin/env node
// Variante d'eprouver.mjs (10/10, deuxième examen) : la base neuve est celle de la pile des essais (pile/pile.sh), faite
// par `vak localdb` de l'archive de vak, au lieu du minimum figé supabase-minimum.sql. Raison : ce minimum n'a ni la
// publication supabase_realtime ni le schéma storage, que demandent les migrations 0005 et 0006 d'expense_sharing ; la
// pile, elle, les a. Les vérifications sont celles d'eprouver.mjs, à la lettre.
// Usage : VAK_CLI=<archive extraite>/package/bin/vak.mjs node graines/eprouver-pile.mjs [app ...]
// `vak localdb` cherche supabase/config.toml : il est créé s'il manque dans apps/<app> (clone jetable), comme `vak init`.
import { execFileSync } from "node:child_process";
import { randomUUID, randomBytes } from "node:crypto";
import { readdirSync, readFileSync, existsSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const ici = dirname(fileURLToPath(import.meta.url));
const racine = dirname(ici);
const H = ["-h", "127.0.0.1", "-p", "5432", "-U", "root"];
const psql = (db, args, opts = {}) =>
  execFileSync("psql", [...H, "-d", db, "-X", "-q", "-v", "ON_ERROR_STOP=1", ...args], { encoding: "utf8", ...opts });
const ident = (t) => t.split(".").map((p) => `"${p.replace(/"/g, '""')}"`).join(".");
const apps = process.argv.slice(2).length ? process.argv.slice(2) : readdirSync(ici, { withFileTypes: true }).filter((e) => e.isDirectory()).map((e) => e.name).sort();

const VAK = process.env.VAK_CLI ?? "";
if (!existsSync(VAK)) throw new Error("VAK_CLI : chemin de bin/vak.mjs de l'archive de vak extraite");
let echecs = 0;
for (const app of apps) {
  const db = `graine_${app}_${randomBytes(3).toString("hex")}`;
  const verifs = [];
  const ok = (c, msg) => { verifs.push(`${c ? "ok  " : "ÉCHEC"} ${msg}`); if (!c) echecs++; };
  console.log(`\n=== ${app} (base ${db})`);
  const appDir = join(racine, "apps", app);
  if (!existsSync(join(appDir, "supabase", "config.toml"))) writeFileSync(join(appDir, "supabase", "config.toml"), `project_id = "${app}"\n`);
  execFileSync("node", [VAK, "localdb", "--db-name", db], { cwd: appDir, encoding: "utf8" });
  try {
    const a = randomUUID(), b = randomUUID();
    psql(db, ["-c", `insert into auth.users (id, email) values ('${a}', 'a-${a.slice(0, 8)}@example.test'), ('${b}', 'b-${b.slice(0, 8)}@example.test')`]);
    psql(db, ["-v", `a=${a}`, "-v", `b=${b}`, "-f", join(ici, app, "graine.sql")]);
    const attendu = JSON.parse(readFileSync(join(ici, app, "attendu.json"), "utf8"));
    const dump = execFileSync("pg_dump", [...H, "-d", db, "--data-only", "--schema=public"], { encoding: "utf8", maxBuffer: 1 << 26 });
    const sousA = (sql) =>
      psql(db, ["-At", "-c", `begin; set local role authenticated; select set_config('request.jwt.claims', '${JSON.stringify({ sub: a, role: "authenticated" })}', true); ${sql}; rollback`])
        .split("\n").filter(Boolean).pop();
    for (const t of attendu) {
      const n = Number(sousA(`select count(*) from ${ident(t.table)} where ${ident(t.colonne)} = '${a}'`));
      ok(n === t.a, `${t.table} : ${n} lignes de A sous ${t.colonne} (attendu.json : ${t.a})`);
      ok(Number.isInteger(t.a) && t.a > 0, `${t.table} : a > 0`);
      const [s, tn] = t.table.split(".");
      const rls = psql(db, ["-At", "-c", `select relrowsecurity from pg_class c join pg_namespace n on n.oid = c.relnamespace where n.nspname = '${s}' and c.relname = '${tn}'`]).trim() === "t";
      const fuites = Number(sousA(`select count(*) from ${ident(t.table)} x where x::text ilike '%MARQUEUR-B-%'`));
      const miens = Number(psql(db, ["-At", "-c", `select count(*) from ${ident(t.table)} x where x.${ident(t.colonne)} = '${a}' and x::text ilike '%MARQUEUR-%'`]).trim());
      ok(miens === 0, `${t.table} : aucune ligne de A ne porte de marqueur`);
      if (rls) ok(fuites === 0, `${t.table} : A ne voit aucun marqueur de B (RLS active)`);
      else verifs.push(`note  ${t.table} : sans RLS dans l'app, A voit ${fuites} ligne(s) marquée(s) de B (défaut de l'app, pas de la graine)`);
      for (const m of t.marqueurs_b) ok(dump.toLowerCase().includes(m.toLowerCase()), `${m} présent dans la base`);
      ok(/^MARQUEUR-B-[A-Za-z0-9]{8}$/.test(t.marqueurs_b[0] ?? "MARQUEUR-B-00000000"), `${t.table} : forme des marqueurs`);
    }
    const tous = attendu.flatMap((t) => t.marqueurs_b);
    ok(new Set(tous.map((m) => m.toLowerCase())).size === tous.length, "marqueurs tous distincts");
    const dansDump = [...new Set(dump.match(/MARQUEUR-B-[A-Za-z0-9]{8}/gi))];
    const connus = new Set(tous.map((m) => m.toLowerCase()));
    ok(dansDump.length > 0, `${dansDump.length} marqueurs distincts dans la base (dont ${dansDump.filter((m) => !connus.has(m.toLowerCase())).length} hors tables « à moi », ex. chantiers)`);
    ok(!/MARQUEUR-(?!B-)/i.test(dump), "aucun autre motif MARQUEUR- dans la base");
  } finally {
    execFileSync("node", [VAK, "localdb", "--drop", "--db-name", db], { cwd: appDir, encoding: "utf8" });
  }
  console.log(verifs.join("\n"));
}
console.log(echecs ? `\n${echecs} échec(s)` : "\ntout est conforme");
process.exit(echecs ? 1 : 0);
