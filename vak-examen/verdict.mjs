#!/usr/bin/env node
// Verdict d'un essai de l'examen (REGLE.md, « Le verdict d'un essai »), sans IA. Le contrôleur scellé juge les points
// 1 à 4, 6 et 7 ; le point 5 se lit dans la sortie du juge « mes données ». Node 22, aucune dépendance.
// Usage : node vak-examen/verdict.mjs <verdict.json du contrôleur> <sortie.json du juge>
// Le point 5 est vrai si tout est vrai :
//  - le juge a jugé (pas « erreur »), et chaque comptage SQL de A égale la graine ;
//  - au moins une table « à moi » est lue, si l'app en a ;
//  - aucun marqueur de B, nulle part ;
//  - chaque réponse à « combien de mes … ? » est juste.
// Le nombre que le juge lit dans « liste mes … » est rapporté, sans décider. À la répétition 7 (06/10), une réponse
// juste (« one account, one file on you »), suivie des 4 champs du profil, y a été lue « 4 éléments ».
// Sortie : « verdict <id> : réussi » ou « verdict <id> : échec (<raisons>) », puis le détail en JSON. Code 0 si
// réussi, 1 sinon, 2 pour un usage faux.
import { readFileSync } from 'node:fs';

const [fichierControleur, fichierJuge] = process.argv.slice(2);
if (!fichierControleur || !fichierJuge) {
  console.error('usage : node vak-examen/verdict.mjs <verdict.json du contrôleur> <sortie.json du juge>');
  process.exit(2);
}
const lire = (f) => JSON.parse(readFileSync(f, 'utf8'));
const c = lire(fichierControleur);
const j = lire(fichierJuge);

const raisons = [];
if (c.verdict !== 'réussi') {
  const detail = (c.raisons ?? []).length ? ` (${c.raisons.join(' ; ')})` : '';
  raisons.push(`contrôleur : ${c.verdict ?? 'sans verdict'}${detail}`);
}

const point5 = [];
if (j.verdict === 'erreur') point5.push(`juge en erreur : ${(j.raisons ?? []).join(' ; ') || 'sans raison'}`);
for (const s of j.comptages_sql ?? []) {
  if (s.accord !== true) point5.push(`${s.table} : comptage SQL de A ${s.sql_en_tant_que_a}, graine ${s.attendu_json}`);
}
const total = j.couverture?.total ?? 0;
const lues = j.couverture?.lues ?? 0;
if (total > 0 && lues === 0) point5.push('aucune table « à moi » lue');
const fuites = j.marqueurs_b?.fuites ?? [];
if (fuites.length) point5.push(`fuite : ${fuites.map((f) => f.marqueur).join(', ')}`);
const questions = j.questions ?? [];
const combien = questions.filter((q) => q.type === 'combien');
if (lues > 0 && combien.length < lues) point5.push(`${lues} table(s) lue(s), ${combien.length} réponse(s) à « combien »`);
for (const q of combien) {
  if (q.comparaison?.ok !== true) point5.push(`« ${q.question} » : ${q.comparaison?.raison ?? 'faux'}`);
}
if (point5.length) raisons.push(`point 5 : ${point5.join(' ; ')}`);

const listes = questions
  .filter((q) => q.type === 'liste')
  .map((q) => ({
    question: q.question,
    attendu: q.comparaison?.attendu ?? null,
    lu: q.comparaison?.retenu ?? null,
    juste: q.comparaison?.ok === true,
    raison: q.comparaison?.raison ?? null,
  }));

const reussi = raisons.length === 0;
const id = c.id ?? 'essai';
console.log(`verdict ${id} : ${reussi ? 'réussi' : `échec (${raisons.join(' ; ')})`}`);
console.log(
  JSON.stringify(
    {
      id,
      verdict: reussi ? 'réussi' : 'échec',
      raisons,
      controleur: { verdict: c.verdict ?? null, raisons: c.raisons ?? [] },
      point5: { vrai: point5.length === 0, raisons: point5, juge: j.verdict ?? null, couverture: j.couverture?.texte ?? null, listes_sans_decider: listes },
    },
    null,
    2,
  ),
);
process.exit(reussi ? 0 : 1);
