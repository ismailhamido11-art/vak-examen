#!/usr/bin/env node
// Remplace pile/demander.mjs dans les tests : mêmes arguments, même forme de sortie, réponses tirées d'un scénario.
// FAUX_SCENARIO : fichier JSON { "<expression régulière sur la question>": { texte, outils?, erreur? } | { sortie_brute, code } }
// FAUX_JOURNAL (facultatif) : fichier où chaque question posée est ajoutée, une par ligne.
import { appendFileSync, readFileSync } from "node:fs";
const [fichier, qui, question] = process.argv.slice(2);
if (qui !== "A") { console.error("le juge ne pose ses questions qu'en tant que A"); process.exit(2); }
if (!fichier) process.exit(2);
if (process.env.FAUX_JOURNAL) appendFileSync(process.env.FAUX_JOURNAL, question + "\n");
const scenario = JSON.parse(readFileSync(process.env.FAUX_SCENARIO, "utf8"));
const cle = Object.keys(scenario).find((k) => new RegExp(k, "i").test(question));
if (!cle) { console.error(`aucune réponse prévue pour : ${question}`); process.exit(3); }
const r = scenario[cle];
if (r.sortie_brute !== undefined) { process.stdout.write(r.sortie_brute); process.exit(r.code ?? 0); }
console.log(JSON.stringify({ compte: "A", conversation: "faux", question, texte: r.texte ?? "", outils: r.outils ?? [], ...(r.erreur ? { erreur: r.erreur } : {}) }, null, 2));
