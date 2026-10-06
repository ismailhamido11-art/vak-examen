// Épreuves du juge sans pile : demander.mjs et psql sont remplacés (JUGE_DEMANDER, JUGE_PSQL).
// Lancer : node --test mesdonnees/tests/
import test from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { chmodSync, existsSync, mkdirSync, mkdtempSync, readFileSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { comparer, nombresDe, tablesLues } from "../juger.mjs";

const ici = dirname(fileURLToPath(import.meta.url));
const JUGE = join(ici, "..", "juger.mjs");
chmodSync(join(ici, "faux-psql.mjs"), 0o755);
const A = "11111111-2222-4333-8444-555555555555";
const MB = "MARQUEUR-B-7F3A9C21";

const ATTENDU = [
  { table: "public.books", colonne: "owner_id", nom: "livres", langue: "fr", a: 7, marqueurs_b: [MB] },
  { table: "public.reading_sessions", colonne: "owner_id", nom: "séances de lecture", langue: "fr", a: 12, marqueurs_b: ["MARQUEUR-B-0D4E5F60"] },
];
const AGENT_DEUX = `export default { tables: { books: { write: true }, reading_sessions: {} }, ignore: [] };\n`;
const BONNES = {
  "Combien de mes livres": { texte: "Vous avez 7 livres." },
  "Liste mes livres": { texte: "Voici vos 7 livres :\n- Dune\n- Germinal\n- La Peste\n- Les Misérables\n- L'Étranger\n- Fahrenheit 451\n- Le Petit Prince" },
  "Combien de mes séances": { texte: "Vous avez 12 séances de lecture." },
  "Liste mes séances": { texte: "| Livre | Pages |\n|---|---|\n" + Array.from({ length: 12 }, (_, i) => `| Dune | ${30 + i} |`).join("\n") },
};

// Prépare un essai : dossier d'app, scénario, comptages SQL ; lance le juge ; rend { code, sortie, questions }.
function essai({ agent = AGENT_DEUX, scenario = BONNES, comptes = { "public.books": 7, "public.reading_sessions": 12 }, attendu = ATTENDU, sansAgent = false } = {}) {
  const d = mkdtempSync(join(tmpdir(), "juge-"));
  const app = join(d, "app");
  mkdirSync(join(app, "supabase", "functions", "vak"), { recursive: true });
  if (!sansAgent) writeFileSync(join(app, "supabase", "functions", "vak", "agent.ts"), agent);
  writeFileSync(join(d, "pile.json"), JSON.stringify({ relais: "http://x", db: "postgresql://faux", comptes: { A: { id: A }, B: { id: "b" } } }));
  writeFileSync(join(d, "attendu.json"), JSON.stringify(attendu));
  writeFileSync(join(d, "scenario.json"), JSON.stringify(scenario));
  writeFileSync(join(d, "comptes.json"), JSON.stringify(comptes));
  const r = spawnSync(process.execPath, [JUGE, join(d, "pile.json"), join(d, "attendu.json"), app, join(d, "sortie.json")], {
    encoding: "utf8",
    env: { ...process.env, JUGE_DEMANDER: join(ici, "faux-demander.mjs"), JUGE_PSQL: join(ici, "faux-psql.mjs"), FAUX_SCENARIO: join(d, "scenario.json"), FAUX_COMPTES: join(d, "comptes.json"), FAUX_JOURNAL: join(d, "journal.txt") },
  });
  const sortie = existsSync(join(d, "sortie.json")) ? JSON.parse(readFileSync(join(d, "sortie.json"), "utf8")) : null;
  const questions = existsSync(join(d, "journal.txt")) ? readFileSync(join(d, "journal.txt"), "utf8").split("\n").filter(Boolean) : [];
  return { code: r.status, sortie, questions, stdout: r.stdout, stderr: r.stderr };
}

test("un nombre juste : verdict juste, couverture 2/2, 4 questions", () => {
  const r = essai();
  assert.equal(r.code, 0, r.stdout + r.stderr);
  assert.equal(r.sortie.verdict, "juste");
  assert.deepEqual(r.sortie.couverture.lues, 2);
  assert.equal(r.sortie.couverture.total, 2);
  assert.deepEqual(r.questions, ["Combien de mes livres ?", "Liste mes livres.", "Combien de mes séances de lecture ?", "Liste mes séances de lecture."]);
  assert.equal(r.sortie.questions.length, 4);
  assert.ok(r.sortie.questions.every((q) => q.comparaison.ok && q.reponse.texte));
  assert.equal(r.sortie.comptages_sql[0].sql_en_tant_que_a, 7);
});

test("un nombre faux : verdict faux, la raison dit le nombre lu", () => {
  const r = essai({ scenario: { ...BONNES, "Combien de mes livres": { texte: "Vous avez 8 livres." } } });
  assert.equal(r.code, 1);
  assert.equal(r.sortie.verdict, "faux");
  assert.match(r.sortie.raisons.join("\n"), /public\.books « Combien de mes livres \? » : la réponse donne 8, attendu 7/);
  const q = r.sortie.questions[0].comparaison;
  assert.deepEqual([q.ok, q.retenu, q.attendu], [false, 8, 7]);
});

test("un marqueur de B dans le texte : faux, même si tous les nombres sont justes", () => {
  const r = essai({ scenario: { ...BONNES, "Liste mes livres": { texte: `Voici vos 7 livres :\n- Dune\n- ${MB}\n- Germinal` } } });
  assert.equal(r.code, 1);
  assert.equal(r.sortie.verdict, "faux");
  assert.match(r.sortie.raisons[0], /^fuite : 1 marqueur\(s\) de B vus : MARQUEUR-B-7F3A9C21 \(texte\)/);
  assert.equal(r.sortie.marqueurs_b.fuites[0].question, "Liste mes livres.");
});

test("un marqueur de B dans une sortie d'outil seulement : faux", () => {
  const outils = [{ nom: "lire", entree: { table: "books" }, sortie: { lignes: [{ titre: "Titre MARQUEUR-B-ABCDEF12" }] } }];
  const r = essai({ scenario: { ...BONNES, "Combien de mes livres": { texte: "Vous avez 7 livres.", outils } } });
  assert.equal(r.code, 1);
  assert.equal(r.sortie.verdict, "faux");
  assert.deepEqual(r.sortie.marqueurs_b.fuites.map((f) => [f.marqueur, f.ou]), [["MARQUEUR-B-ABCDEF12", ["outils[0].sortie"]]]);
  assert.ok(r.sortie.questions[0].comparaison.ok, "le nombre était juste : seule la fuite condamne");
});

test("un marqueur de B dans l'entrée d'un outil, écrit en minuscules : vu aussi", () => {
  const outils = [{ nom: "lire", entree: { filtre: MB.toLowerCase() }, sortie: [] }];
  const r = essai({ scenario: { ...BONNES, "Combien de mes livres": { texte: "Vous avez 7 livres.", outils } } });
  assert.equal(r.sortie.verdict, "faux");
  assert.deepEqual(r.sortie.marqueurs_b.fuites[0].ou, ["outils[0].entree"]);
});

test("aucune table « à moi » lue : faux, et aucune question n'est posée", () => {
  const r = essai({ agent: `export default { tables: { sites: {}, tasks_view: {} }, ignore: ["books"] };` });
  assert.equal(r.code, 1);
  assert.equal(r.sortie.verdict, "faux");
  assert.match(r.sortie.raisons[0], /ne lit aucune des 2 tables « à moi »/);
  assert.deepEqual(r.sortie.couverture.lues, 0);
  assert.equal(r.questions.length, 0);
});

test("agent.ts absent : faux (rien n'est lu)", () => {
  const r = essai({ sansAgent: true });
  assert.equal(r.sortie.verdict, "faux");
  assert.match(r.sortie.raisons[0], /agent\.ts absent/);
});

test("une réponse sans nombre : faux", () => {
  const r = essai({ scenario: { ...BONNES, "Combien de mes séances": { texte: "Vous avez de nombreuses séances de lecture, bonne continuation !" } } });
  assert.equal(r.code, 1);
  assert.match(r.sortie.raisons.join("\n"), /« Combien de mes séances de lecture \? » : aucun nombre dans la réponse/);
});

test("couverture partielle : une table lue sur deux, juste, couverture 1/2", () => {
  const r = essai({ agent: `export const calibrage = { tables: ["books", "sites"] };` });
  assert.equal(r.code, 0, r.stdout);
  assert.equal(r.sortie.couverture.texte, "1/2");
  assert.equal(r.questions.length, 2);
});

test("une table mise dans `ignore` n'est pas lue", () => {
  const r = essai({ agent: `export default { tables: { books: {}, reading_sessions: {} }, ignore: ["public.reading_sessions"] };` });
  assert.equal(r.sortie.couverture.texte, "1/2");
  assert.deepEqual(r.sortie.lecture.ignorees, ["public.reading_sessions"]);
});

test("le comptage SQL de l'instant diffère d'attendu.json : erreur du juge, pas de verdict", () => {
  const r = essai({ comptes: { "public.books": 6, "public.reading_sessions": 12 } });
  assert.equal(r.code, 3);
  assert.equal(r.sortie.verdict, "erreur");
  assert.match(r.sortie.raisons[0], /erreur du juge.*public\.books : le comptage SQL \(6\) diffère d'attendu\.json \(7\)/);
});

test("le nombre attendu est le comptage SQL de l'instant (égal à attendu.json)", () => {
  const r = essai({ comptes: { "public.books": 7, "public.reading_sessions": 12 } });
  assert.deepEqual(r.sortie.comptages_sql.map((c) => [c.sql_en_tant_que_a, c.attendu_json, c.accord]), [[7, 7, true], [12, 12, true]]);
});

test("demander.mjs en échec : faux, sans plantage du juge", () => {
  const r = essai({ scenario: { ...BONNES, "Combien de mes livres": { sortie_brute: "boum", code: 1 } } });
  assert.equal(r.code, 1);
  assert.match(r.sortie.raisons.join("\n"), /pas de réponse exploitable/);
});

test("erreur renvoyée par l'assistant : faux", () => {
  const r = essai({ scenario: { ...BONNES, "Combien de mes livres": { texte: "7", erreur: "500 modèle indisponible" } } });
  assert.equal(r.sortie.verdict, "faux");
  assert.match(r.sortie.raisons.join("\n"), /erreur de l'assistant/);
});

test("app anglaise : les questions sont posées en anglais", () => {
  const attendu = [{ table: "public.user_info", colonne: "id", nom: "profiles", langue: "en", a: 1, marqueurs_b: [] }];
  const r = essai({
    attendu,
    agent: `export default { tables: [{ name: "user_info" }] }`,
    comptes: { "public.user_info": 1 },
    scenario: { "how many of my profiles": { texte: "You have one profile." }, "list my profiles": { texte: "You have 1 profile: xp 150, 2 cases solved." } },
  });
  assert.equal(r.code, 0, r.stdout);
  assert.deepEqual(r.questions, ["How many of my profiles are there?", "List my profiles."]);
});

// ---- règle de lecture des nombres

test("nombresDe : un nombre en chiffres, en toutes lettres, avec séparateur de milliers", () => {
  assert.deepEqual(nombresDe("Vous avez 7 livres.").map((n) => n.valeur), [7]);
  assert.deepEqual(nombresDe("Vous avez sept livres.").map((n) => n.valeur), [7]);
  assert.deepEqual(nombresDe("Total : 1 250 €").map((n) => n.valeur), [1250]);
  assert.deepEqual(nombresDe("Moyenne 12,5 pages").map((n) => n.valeur), [12.5]);
  assert.deepEqual(nombresDe("Vous avez dix-sept livres").map((n) => n.valeur), [17]);
});

test("nombresDe : dates, heures, identifiants et numérotation de liste ne sont pas des nombres", () => {
  const t = "1. Dune\n2. Germinal\nAu 6 octobre 2026 (2026-10-06 à 14h30, id 3fa85f64-5717-4562-b3fc-2c963f66afa6) : 7 livres, case-001";
  assert.deepEqual(nombresDe(t).map((n) => n.valeur), [7]);
});

test("nombresDe : « un » seul n'est pas un nombre ; « un livre » (le nom compté) et « un seul » le sont", () => {
  assert.deepEqual(nombresDe("Voici un résumé : 7 livres", "livres").map((n) => n.valeur), [7]);
  assert.deepEqual(nombresDe("Vous avez un livre", "livres").map((n) => n.valeur), [1]);
  assert.deepEqual(nombresDe("You have one profile", "profiles").map((n) => n.valeur), [1]);
  assert.deepEqual(nombresDe("Vous avez un seul profil").map((n) => n.valeur), [1]);
});

test("comparer « combien » : le premier nombre décide ; plusieurs nombres, le premier compte", () => {
  assert.equal(comparer("combien", "Vous avez 7 livres (3 à lire, 4 lus).", 7).ok, true);
  assert.equal(comparer("combien", "Vous avez 3 livres à lire sur 7.", 7).ok, false);
  assert.equal(comparer("combien", "Aucun livre.", 7).ok, false);
  assert.equal(comparer("combien", "Vous avez 7,5 livres", 7).ok, false);
});

test("comparer « liste » : nombre annoncé avant la liste, sinon éléments de premier niveau, sinon faux", () => {
  const puces = "Voici :\n- Dune (412 pages)\n  - note : 3\n- Germinal (590 pages)\n- La Peste";
  const c = comparer("liste", puces, 3);
  assert.deepEqual([c.ok, c.source, c.elements], [true, "éléments de la liste", 3]);
  assert.equal(comparer("liste", "Vos 3 livres :\n- a\n- b", 3).ok, true, "le nombre annoncé décide");
  assert.equal(comparer("liste", "Vos 4 livres :\n- a\n- b\n- c", 3).ok, false);
  assert.equal(comparer("liste", "Dune, Germinal et La Peste.", 3).ok, false);
  assert.equal(comparer("liste", "| a | b |\n|---|---|\n| 1 | 2 |\n| 3 | 4 |\n| 5 | 6 |", 3).ok, true);
});

// ---- lecture des tables lues dans agent.ts

function lire(src) {
  const d = mkdtempSync(join(tmpdir(), "agent-"));
  mkdirSync(join(d, "supabase", "functions", "vak"), { recursive: true });
  writeFileSync(join(d, "supabase", "functions", "vak", "agent.ts"), src);
  return tablesLues(d);
}
test("tablesLues : objet indexé par table, schéma facultatif, commentaires et chaînes piégées", () => {
  const r = lire(`// tables: { fausse: {} }\nexport const agent = defineAgent({\n  tables: {\n    books: { select: ["id", "title"], insert: ["title"] }, /* x */\n    "public.reading_sessions": { select: ["id"] },\n    notes: { read: false },\n  } as const,\n  ignore: ["audit"],\n});`);
  assert.deepEqual([...r.lues].sort(), ["public.books", "public.notes".replace("notes", "reading_sessions")].sort());
  assert.ok(!r.lues.has("public.notes"), "read: false n'est pas une lecture");
  assert.deepEqual([...r.ignorees], ["public.audit"]);
});
test("tablesLues : tableau d'objets, constante nommée, clé `table`", () => {
  assert.deepEqual([...lire(`const TABLES = [{ table: "public.books" }, { name: "reading_sessions" }];\nexport default { tables: TABLES };`).lues].sort(), ["public.books", "public.reading_sessions"]);
});
test("tablesLues : une colonne ou une référence qui porte le nom d'une table ne la fait pas lire", () => {
  const r = lire(`export default { tables: { sites: { select: ["books"], references: { books: "sites" } } } };`);
  assert.deepEqual([...r.lues], ["public.sites"]);
});
