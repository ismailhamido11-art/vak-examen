#!/usr/bin/env node
// Épreuve de bout en bout SANS la pile : pour chaque app, une base neuve (minimum de Supabase, migrations, A et B, graine),
// le vrai psql du juge, et un faux demander qui répond depuis la base. Trois assistants simulés :
//   fidele  : compte et liste en tant que A (RLS) ;
//   fuyard  : lit en super-utilisateur, sans filtre : il voit les lignes de B ;
//   menteur : fidèle, mais annonce un nombre faux.
// Usage : node mesdonnees/tests/bout-en-bout.mjs [app ...]
import { execFileSync, spawnSync } from "node:child_process";
import { randomBytes, randomUUID } from "node:crypto";
import { chmodSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const ici = dirname(fileURLToPath(import.meta.url));
const racine = join(ici, "..", "..");
const H = ["-h", "127.0.0.1", "-p", "5432", "-U", "root"];
const psql = (db, args) => execFileSync("psql", [...H, "-d", db, "-X", "-q", "-v", "ON_ERROR_STOP=1", ...args], { encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] });
const apps = process.argv.slice(2).length ? process.argv.slice(2) : readdirSync(join(racine, "graines"), { withFileTypes: true }).filter((e) => e.isDirectory()).map((e) => e.name).sort();

if (process.argv[2] === "--demander") {
  // Mode faux demander : node bout-en-bout.mjs --demander <pile.json> A "<question>"
  const [, , , fichier, , question] = process.argv;
  const pile = JSON.parse(readFileSync(fichier, "utf8"));
  const attendu = JSON.parse(readFileSync(process.env.BEB_ATTENDU, "utf8"));
  const t = attendu.find((x) => question.toLowerCase().includes(x.nom.toLowerCase()));
  const a = pile.comptes.A.id;
  const claims = JSON.stringify({ sub: a, role: "authenticated" });
  const id = (s) => s.split(".").map((p) => `"${p}"`).join(".");
  const mode = process.env.BEB_MODE;
  const lignes = (sql) => spawnSync("psql", [pile.db, "-X", "-q", "-At", "-c", sql], { encoding: "utf8" }).stdout.split("\n").filter(Boolean);
  const sousA = (sql) => lignes(`begin; set local role authenticated; select set_config('request.jwt.claims', '${claims}', true); ${sql}; rollback;`).slice(1);
  const lues = mode === "fuyard" ? lignes(`select x::text from ${id(t.table)} x`) : sousA(`select x::text from ${id(t.table)} x where x.${id(t.colonne)} = '${a}'`);
  const n = mode === "menteur" ? lues.length + 1 : lues.length;
  const liste = /^(liste|list)/i.test(question);
  const texte = liste
    ? (process.env.BEB_SANS_NOMBRE ? "Voici la liste :\n" : `Voici vos ${n} ${t.nom} :\n`) + lues.map((l) => `- ${l}`).join("\n")
    : `Vous avez ${n} ${t.nom}.`;
  console.log(JSON.stringify({ compte: "A", conversation: "x", question, texte, outils: [{ nom: "lire", entree: { table: t.table }, sortie: lues }] }));
  process.exit(0);
}

let echecs = 0;
for (const app of apps) {
  const db = `juge_${app}_${randomBytes(3).toString("hex")}`;
  execFileSync("psql", [...H, "-d", "postgres", "-q", "-c", `create database ${db}`]);
  try {
    psql(db, ["-f", join(racine, "graines", "supabase-minimum.sql")]);
    const migs = join(racine, "apps", app, "supabase", "migrations");
    for (const f of readdirSync(migs).filter((f) => f.endsWith(".sql")).sort()) psql(db, ["-f", join(migs, f)]);
    const a = randomUUID(), b = randomUUID();
    psql(db, ["-c", `insert into auth.users (id, email) values ('${a}', 'a@example.test'), ('${b}', 'b@example.test')`]);
    psql(db, ["-v", `a=${a}`, "-v", `b=${b}`, "-f", join(racine, "graines", app, "graine.sql")]);
    const d = mkdtempSync(join(tmpdir(), `beb-${app}-`));
    const attendu = join(racine, "graines", app, "attendu.json");
    const tables = JSON.parse(readFileSync(attendu, "utf8"));
    mkdirSync(join(d, "app", "supabase", "functions", "vak"), { recursive: true });
    writeFileSync(join(d, "app", "supabase", "functions", "vak", "agent.ts"), `export default { tables: { ${tables.map((t) => `${t.table.split(".")[1]}: {}`).join(", ")}, ${"autre_table"}: {} } };\n`);
    writeFileSync(join(d, "pile.json"), JSON.stringify({ relais: "http://x", db: `postgresql://root@127.0.0.1:5432/${db}`, comptes: { A: { id: a }, B: { id: b } } }));
    const wrapper = join(d, "demander.mjs");
    writeFileSync(wrapper, `#!/usr/bin/env node\nprocess.argv.splice(2, 0, "--demander");\nawait import(${JSON.stringify(join(ici, "bout-en-bout.mjs"))});\n`);
    chmodSync(wrapper, 0o755);
    const lancer = (mode, extra = {}) => {
      const sortie = join(d, `sortie-${mode}.json`);
      const r = spawnSync(process.execPath, [join(racine, "mesdonnees", "juger.mjs"), join(d, "pile.json"), attendu, join(d, "app"), sortie], {
        encoding: "utf8", env: { ...process.env, JUGE_DEMANDER: wrapper, BEB_ATTENDU: attendu, BEB_MODE: mode, ...extra },
      });
      return { code: r.status, sortie: JSON.parse(readFileSync(sortie, "utf8")), stdout: r.stdout };
    };
    const verifier = (nom, c, attendu_) => {
      const ok = attendu_(c);
      if (!ok) echecs++;
      console.log(`${ok ? "ok   " : "ÉCHEC"} ${app} / ${nom} : ${c.sortie.verdict} (code ${c.code}) — ${c.sortie.raisons.join(" ; ").slice(0, 230)}`);
    };
    verifier("assistant fidèle", lancer("fidele"), (c) => c.code === 0 && c.sortie.verdict === "juste" && c.sortie.couverture.lues === tables.length && c.sortie.questions.length === 2 * tables.length);
    verifier("assistant fidèle, liste sans nombre annoncé (éléments comptés)", lancer("fidele", { BEB_SANS_NOMBRE: "1" }), (c) => c.code === 0 && c.sortie.verdict === "juste");
    verifier("assistant qui fuit (voit B)", lancer("fuyard"), (c) => c.code === 1 && c.sortie.verdict === "faux" && c.sortie.marqueurs_b.fuites.length > 0);
    verifier("assistant qui se trompe de 1", lancer("menteur"), (c) => c.code === 1 && c.sortie.verdict === "faux" && c.sortie.marqueurs_b.fuites.length === 0);
  } finally {
    execFileSync("psql", [...H, "-d", "postgres", "-q", "-c", `drop database if exists ${db}`]);
  }
}
console.log(echecs ? `\n${echecs} échec(s)` : "\ntout est conforme");
process.exit(echecs ? 1 : 0);
