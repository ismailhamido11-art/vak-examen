#!/usr/bin/env node
// « Mes données » d'un essai du groupe témoin (REGLE.md, « Le groupe témoin ») : trois questions « combien de mes … ? »
// posées en tant que A à l'interface que l'agent a construite, sur la pile témoin (temoin-pile.sh), avec les mêmes
// graines. Les nombres doivent être exacts, et aucun marqueur de B ne doit apparaître. Les règles de lecture sont celles
// du juge des essais de vak (mesdonnees/juger.mjs : comparer, chercherMarqueurs, compterSousA), et ses questions aussi.
// Les questions portent sur les trois premières tables d'attendu.json, dans son ordre (toutes s'il en a moins).
// Usage : node vak-examen/temoin-mesdonnees.mjs <pile.json> <id> <demander.mjs> [<sortie.json>]
//   <demander.mjs> : propre à l'interface de l'essai, écrit à la main d'après le code de l'agent et publié avec ses
//   résultats. Il exporte `description` (ce qui est servi, et comment) et une fonction par défaut
//   async (pile, compte, question) → { texte, brut } : la réponse lisible, et la réponse HTTP brute (pour les marqueurs).
// Sortie (défaut repetition2/resultats/<id>/mesdonnees-temoin.json) : { mesure: "mesuré", chiffres_exacts, aucune_fuite,
// questions, marqueurs_b, … }. Une interface qu'on ne peut ni servir ni interroger s'écrit à la main :
// { mesure: "non mesuré", raison }.
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { chercherMarqueurs, comparer, compterSousA } from "./mesdonnees/juger.mjs";

const [fichierPile, id, fichierDemander, sortieArg] = process.argv.slice(2);
if (!fichierPile || !id || !fichierDemander) {
  console.error("usage : node vak-examen/temoin-mesdonnees.mjs <pile.json> <id> <demander.mjs> [<sortie.json>]");
  process.exit(2);
}
const ICI = dirname(fileURLToPath(import.meta.url));
const RACINE = resolve(ICI, "..");
const app = id.replace(/^temoin_/, "");
const pile = JSON.parse(readFileSync(fichierPile, "utf8"));
const brut = JSON.parse(readFileSync(join(ICI, "graines", app, "attendu.json"), "utf8"));
const tables = Array.isArray(brut) ? brut : brut.tables;
const connus = tables.flatMap((t) => t.marqueurs_b ?? []);
const module = await import(pathToFileURL(resolve(fichierDemander)).href);
const demander = module.default;
const QUESTIONS = { fr: (nom) => `Combien de mes ${nom} ?`, en: (nom) => `How many of my ${nom} are there?` };

const sortie = {
  id,
  regle: "REGLE.md, « Le groupe témoin » : trois questions « combien de mes … ? » en tant que A, nombres exacts, aucun marqueur de B",
  methode: "questions et lecture des nombres du juge des essais de vak (mesdonnees/juger.mjs) ; trois premières tables d'attendu.json",
  interface: module.description ?? null,
  demander: fichierDemander.replace(`${RACINE}/`, ""),
  mesure: "mesuré",
  questions: [],
  marqueurs_b: { fuites: [], connus: connus.length },
};
for (const t of tables.slice(0, 3)) {
  const question = (QUESTIONS[t.langue] ?? QUESTIONS.en)(t.nom);
  const attendu = compterSousA(pile, pile.comptes.A.id, t.table, t.colonne);
  const q = { table: t.table, question, attendu, attendu_graine: t.a };
  try {
    const { texte, brut: reponseBrute } = await demander(pile, pile.comptes.A, question);
    q.reponse = texte;
    q.comparaison = comparer("combien", texte ?? "", attendu, t.nom);
    q.marqueurs_b = chercherMarqueurs({ texte }, { stdout: String(reponseBrute ?? ""), stderr: "" }, connus);
  } catch (e) {
    q.reponse = null;
    q.erreur = e instanceof Error ? e.message : String(e);
    q.comparaison = { ok: false, raison: `pas de réponse exploitable : ${q.erreur.slice(0, 200)}` };
    q.marqueurs_b = [];
  }
  for (const f of q.marqueurs_b) sortie.marqueurs_b.fuites.push({ ...f, table: t.table, question });
  sortie.questions.push(q);
  console.log(`${q.comparaison.ok ? "juste" : "faux "} ${question} → ${q.comparaison.retenu ?? "?"} (attendu ${attendu})${q.marqueurs_b.length ? ` ; MARQUEURS DE B : ${q.marqueurs_b.map((m) => m.marqueur).join(", ")}` : ""}`);
}
sortie.chiffres_exacts = sortie.questions.length > 0 && sortie.questions.every((q) => q.comparaison.ok === true);
sortie.aucune_fuite = sortie.marqueurs_b.fuites.length === 0;
const fichierSortie = sortieArg ?? join(RACINE, "repetition2", "resultats", id, "mesdonnees-temoin.json");
writeFileSync(fichierSortie, JSON.stringify(sortie, null, 2) + "\n");
console.log(`${id} : chiffres exacts ${sortie.chiffres_exacts ? "oui" : "non"}, aucune fuite ${sortie.aucune_fuite ? "oui" : "non"} → ${fichierSortie.replace(`${RACINE}/`, "")}`);
