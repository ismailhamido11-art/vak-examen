#!/usr/bin/env node
// Après le tirage et les graines des apps tirées : la liste des 14 essais (REGLE.md, « Le verdict d'un essai » : elle
// est publiée avant le premier essai). Node 22, aucune dépendance.
// Usage : node vak-examen/liste-essais.mjs
//  - ajoute à essais.tsv les 8 essais des 4 apps tirées (graines-tirees.tsv, écrit par tirage-publier.mjs) : <nom>_1 et
//    <nom>_2, avec le dépôt, le commit, le métier et l'emplacement recopiés tels quels de champs-candidats.tsv (fixés
//    avant le tirage) ;
//  - remplit AVANT-ESSAIS.md : les apps tirées, les empreintes des graines (graines/<nom>/), la liste des essais ;
//  - écrit l'ordre des essais : le premier de chaque app, puis le second, dans le même ordre.
import { createHash } from "node:crypto";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const ICI = dirname(fileURLToPath(import.meta.url));
const lignes = (f) => readFileSync(join(ICI, f), "utf8").split("\n").filter((l) => l.trim() && !l.startsWith("#"));
const sha256 = (f) => createHash("sha256").update(readFileSync(join(ICI, f))).digest("hex");

const tirees = lignes("graines-tirees.tsv").map((l) => {
  const [nom, url, commit] = l.split("\t");
  return { nom, url, commit };
});
if (tirees.length !== 4) throw new Error(`${tirees.length} apps dans graines-tirees.tsv, 4 attendues`);
const [entete, ...champs] = lignes("champs-candidats.tsv").map((l) => l.split("\t"));
const col = Object.fromEntries(entete.map((n, i) => [n, i]));
for (const a of tirees) {
  const c = champs.find((r) => r[col.url] === a.url);
  if (!c) throw new Error(`${a.url} absente de champs-candidats.tsv`);
  // champs-candidats.tsv garde le nom du dépôt en minuscules ; l'id d'un essai n'a que [a-z0-9_] (essais.tsv).
  if (c[col.nom].replace(/[^a-z0-9]+/g, "_") !== a.nom || c[col.commit] !== a.commit) throw new Error(`${a.nom} : nom ou commit différent de champs-candidats.tsv`);
  Object.assign(a, { plateforme: c[col.plateforme], metier: c[col.metier], emplacement: c[col.emplacement], onglets: c[col.onglets] });
  for (const f of ["graine.sql", "attendu.json"]) {
    if (!existsSync(join(ICI, "graines", a.nom, f))) throw new Error(`graines/${a.nom}/${f} absent : graines-tirees.sh d'abord`);
  }
}

// essais.tsv : les 6 essais des apps construites y sont déjà ; on ajoute ceux des apps tirées, une seule fois.
const texte = readFileSync(join(ICI, "essais.tsv"), "utf8");
const deja = texte.split("\n").filter((l) => l.trim() && !l.startsWith("#")).map((l) => l.split("\t")[0]);
const nouveaux = tirees.flatMap((a) => [1, 2].map((n) => [`${a.nom}_${n}`, a.url, a.commit, a.metier, a.emplacement].join("\t")));
if (nouveaux.some((l) => deja.includes(l.split("\t")[0]))) throw new Error("des essais des apps tirées sont déjà dans essais.tsv");
writeFileSync(join(ICI, "essais.tsv"), texte.replace(/\n*$/, "\n") + nouveaux.join("\n") + "\n");
const tous = [...deja, ...nouveaux.map((l) => l.split("\t")[0])];
if (tous.length !== 14) throw new Error(`${tous.length} essais dans essais.tsv, 14 attendus`);
if (tous.some((id) => !/^[a-z0-9_]+_[0-9]+$/.test(id) || `examen_${id}`.length > 63)) throw new Error("un id d'essai n'est pas un nom de base valide (examen_<id>)");
const apps = [...new Set(tous.map((id) => id.replace(/_[0-9]+$/, "")))];
const ordre = [1, 2].flatMap((n) => apps.map((a) => `${a}_${n}`));
if (ordre.some((id) => !tous.includes(id))) throw new Error("l'ordre cite un essai absent d'essais.tsv");

// AVANT-ESSAIS.md
const court = (c) => c.slice(0, 7);
const blocTirees = tirees
  .map((a) => `- **${a.nom}** (${a.plateforme === "expo" ? "Expo" : "Next.js"}) : ${a.url}, commit \`${court(a.commit)}\`. Métier : « ${a.metier} » Emplacement : ${a.emplacement}${a.onglets !== "—" ? ` (onglets : \`${a.onglets}\`)` : ""}.`)
  .join("\n");
const blocGraines = tirees.flatMap((a) => ["graine.sql", "attendu.json"].map((f) => `${sha256(join("graines", a.nom, f))}  vak-examen/graines/${a.nom}/${f}`)).join("\n");
const blocEssais = [
  "Dans l'ordre où ils sont joués :",
  "",
  "```sh",
  `bash vak-examen/essai.sh ${ordre.join(" ")}`,
  "```",
].join("\n");
let avant = readFileSync(join(ICI, "AVANT-ESSAIS.md"), "utf8");
for (const [marque, bloc] of [["@TIREES@", blocTirees], ["@GRAINES@", blocGraines], ["@ESSAIS@", blocEssais]]) {
  if (avant.split(marque).length !== 2) throw new Error(`AVANT-ESSAIS.md : ${marque} absent ou en double`);
  avant = avant.replace(marque, () => bloc);
}
writeFileSync(join(ICI, "AVANT-ESSAIS.md"), avant);
console.log(ordre.join(" "));
