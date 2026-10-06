#!/usr/bin/env node
// Après le tirage : écrit vak-examen/TIRAGE.md et vak-examen/graines-tirees.tsv à partir de la sortie de tirage.mjs.
// Usage : node vak-examen/tirage-publier.mjs <sortie de tirage.mjs (JSON)> <tour enregistré (JSON du relais drand)>
// graines-tirees.tsv (nom, dépôt, commit) sert à la session scellée des graines (TIREES= de scelle/lancer.sh). Le nom
// d'une app est celui de son dépôt, en minuscules ; ses essais seront <nom>-1 et <nom>-2.
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const ICI = dirname(fileURLToPath(import.meta.url));
const [fichierTirage, fichierTour] = process.argv.slice(2);
if (!fichierTirage || !fichierTour) {
  console.error("usage : node vak-examen/tirage-publier.mjs <sortie de tirage.mjs> <tour.json>");
  process.exit(2);
}
const t = JSON.parse(readFileSync(fichierTirage, "utf8"));
const tour = JSON.parse(readFileSync(fichierTour, "utf8"));
if (tour.round !== t.tour || tour.randomness !== t.aleas) throw new Error("le tour enregistré n'est pas celui du tirage");

const lignes = readFileSync(join(ICI, "candidats", "candidats.tsv"), "utf8").trim().split("\n").map((l) => l.split("\t"));
const commitDe = (url) => {
  const l = lignes.find((c) => c[0] === url);
  if (!l) throw new Error(`${url} absent de candidats.tsv`);
  return l[1];
};
const nomDe = (url) => url.replace(/^https:\/\/github\.com\/[^/]+\//, "").toLowerCase();
const tirees = t.tirees.map((a) => ({ ...a, nom: nomDe(a.url), commit: commitDe(a.url) }));
if (new Set(tirees.map((a) => a.nom)).size !== tirees.length) throw new Error("deux apps tirées ont le même nom");

const GENESE = 1692803367;
const d = new Date((GENESE + (t.tour - 1) * 3) * 1000);
const deux = (n) => String(n).padStart(2, "0");
const quand = `${deux(d.getUTCDate())}/${deux(d.getUTCMonth() + 1)}/${d.getUTCFullYear()} à ${deux(d.getUTCHours())}:${deux(d.getUTCMinutes())}:${deux(d.getUTCSeconds())} UTC`;
const md = [
  "# Le tirage",
  "",
  `Tour **${t.tour}** de la chaîne drand « quicknet », produit le ${quand}. Il a été annoncé avant d'exister :`,
  "`PUBLICATION.md` (commit `698f07b`, poussé le 06/10/2026 à 09:54:30 UTC) et le ticket #1 du dépôt.",
  "",
  `- Chaîne : \`${t.chaine}\`.`,
  `- Aléa : \`${t.aleas}\`.`,
  `- Signature (vérifiée : son SHA-256 est l'aléa) :`,
  `  \`${t.signature}\`.`,
  `- Liste : \`${t.liste.fichier}\` (SHA-256 \`${t.liste.sha256}\`), ${t.liste.eligibles} apps éligibles.`,
  "",
  "## Les 4 apps tirées",
  "",
  "| plateforme | app | commit | rang (SHA-256 du texte « aléa, saut de ligne, url ») | essais |",
  "|---|---|---|---|---|",
  ...tirees.map((a) => `| ${a.plateforme} | ${a.url} | \`${a.commit.slice(0, 12)}\` | \`${a.rang.slice(0, 16)}…\` | \`${a.nom}-1\`, \`${a.nom}-2\` |`),
  "",
  "## La réserve, dans l'ordre",
  "",
  "Une app tirée n'est remplacée que si son commit ne peut plus être cloné, et rien n'est remplacé après le premier",
  "essai (REGLE.md, « Tirage »).",
  "",
  ...Object.entries(t.reserve).map(([p, apps]) => `- ${p} : ${apps.map((a) => a.url.replace("https://github.com/", "")).join(", ") || "aucune"}.`),
  "",
  "## Refaire le tirage",
  "",
  `- Sur un relais public de drand : \`node vak-examen/tirage.mjs ${t.tour}\`.`,
  `- Avec le tour enregistré ici : \`node vak-examen/tirage.mjs ${t.tour} vak-examen/tirage-tour.json\`.`,
  "",
].join("\n");
writeFileSync(join(ICI, "TIRAGE.md"), md);
writeFileSync(join(ICI, "graines-tirees.tsv"), tirees.map((a) => `${a.nom}\t${a.url}\t${a.commit}`).join("\n") + "\n");
console.log(tirees.map((a) => `${a.plateforme} ${a.nom} (${a.url} @ ${a.commit.slice(0, 7)})`).join("\n"));
