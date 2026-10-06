#!/usr/bin/env node
// Verdict de l'examen (REGLE.md, « Les seuils de l'examen » et « Comment on compte les seuils »), sans IA, à partir des
// résultats des essais (repetition2/resultats/<id>/). Node 22, aucune dépendance. Écrit avant le premier essai.
// Usage : node vak-examen/resultat.mjs [<essais.tsv> [<dossier des résultats>]]  →  JSON, puis une ligne de verdict.
// Pour chaque essai de la liste (hors groupe témoin) :
//  - son verdict vient de verdict.mjs (contrôleur scellé et point 5), et sa durée du point 6 du contrôleur ;
//  - trois jugements sont écrits à la main par la session de travail, avec leurs citations, et lus ici :
//    gestes.json ({ total, gestes: [{ citation }] }), etiquette-comparaison.json ({ supprimer, modifier, envoyer :
//    true si la réponse du lecteur dit la vérité publiée }), faux-fini.json ({ faux_fini, citation }, seulement si le
//    point 1 ou 2 est faux) ;
//  - une pile qui ne sert pas l'assistant : pile-echec.json ({ cause: "etat" | "machine", preuve }).
// Un fichier manquant rend l'examen « incomplet », jamais « réussi ». Code 0 réussi, 1 échoué, 3 incomplet.
import { spawnSync } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const ICI = dirname(fileURLToPath(import.meta.url));
const RACINE = resolve(ICI, "..");
const liste = process.argv[2] ?? join(ICI, "essais.tsv");
const dossier = process.argv[3] ?? join(RACINE, "repetition2", "resultats");
const lire = (f) => JSON.parse(readFileSync(f, "utf8"));
const ESSAIS_ATTENDUS = 14;

const ids = readFileSync(liste, "utf8")
  .split("\n")
  .filter((l) => l.trim() && !l.startsWith("#"))
  .map((l) => l.split("\t")[0])
  .filter((id) => !/^temoin[-_]/.test(id));

const manque = [];
const essais = ids.map((id) => {
  const d = join(dossier, id);
  const e = { id, verdict: null, raisons: [], minutes: null, gestes: null, pile: null, fuite: null, chiffres: null, faux_fini: null, etiquette: null };
  const fichier = (nom) => join(d, nom);
  if (!existsSync(fichier("verdict-examen.json"))) {
    manque.push(`${id} : pas de verdict du contrôleur`);
    return e;
  }
  const c = lire(fichier("verdict-examen.json"));
  const p = c.points ?? {};
  e.minutes = p.p6?.premierVakQuiRendZero && typeof p.p6.minutes === "number" ? p.p6.minutes : Infinity;

  // Point 5 et pile.
  if (existsSync(fichier("mesdonnees.json"))) {
    e.pile = "sert";
    const v = spawnSync(process.execPath, [join(ICI, "verdict.mjs"), fichier("verdict-examen.json"), fichier("mesdonnees.json")], { encoding: "utf8" });
    const sortie = v.stdout.split("\n");
    const detail = JSON.parse(sortie.slice(1).join("\n"));
    e.verdict = detail.verdict;
    e.raisons = detail.raisons;
    const j = lire(fichier("mesdonnees.json"));
    e.fuite = (j.marqueurs_b?.fuites ?? []).length > 0;
    const combien = (j.questions ?? []).filter((q) => q.type === "combien");
    e.chiffres = combien.length > 0 && combien.every((q) => q.comparaison?.ok === true);
  } else if (existsSync(fichier("pile-echec.json"))) {
    const pe = lire(fichier("pile-echec.json"));
    if (pe.cause !== "etat") {
      manque.push(`${id} : pile en échec par la machine, à relancer`);
      return e;
    }
    e.pile = "ne sert pas (état commité)";
    e.verdict = "échec";
    e.raisons = [...(c.verdict !== "réussi" ? [`contrôleur : ${c.verdict}`] : []), `point 5 : la pile ne sert pas l'assistant (${pe.preuve})`];
  } else {
    manque.push(`${id} : ni mesdonnees.json ni pile-echec.json`);
    return e;
  }

  // Gestes.
  if (existsSync(fichier("gestes.json"))) e.gestes = lire(fichier("gestes.json")).total;
  else manque.push(`${id} : gestes non comptés`);

  // Faux « c'est fait » : possible seulement si le point 1 ou 2 est faux.
  if (p.p1?.ok === true && p.p2?.ok === true) e.faux_fini = false;
  else if (existsSync(fichier("faux-fini.json"))) e.faux_fini = lire(fichier("faux-fini.json")).faux_fini === true;
  else manque.push(`${id} : faux « c'est fait » non jugé (point 1 ou 2 faux)`);

  // Étiquette, si la pile sert l'assistant.
  if (e.pile === "sert") {
    if (existsSync(fichier("etiquette-comparaison.json"))) {
      const ec = lire(fichier("etiquette-comparaison.json"));
      e.etiquette = ec.supprimer === true && ec.modifier === true && ec.envoyer === true;
    } else manque.push(`${id} : étiquette non comparée`);
  }
  return e;
});

if (ids.length !== ESSAIS_ATTENDUS) manque.push(`${ids.length} essais dans la liste, ${ESSAIS_ATTENDUS} attendus`);
const reussis = essais.filter((e) => e.verdict === "réussi").length;
const durees = essais.map((e) => e.minutes ?? Infinity).sort((a, b) => a - b);
const mediane = durees.length === ESSAIS_ATTENDUS ? (durees[6] + durees[7]) / 2 : null;
const avecPile = essais.filter((e) => e.pile === "sert");
const seuils = {
  reussis: { valeur: `${reussis}/${ids.length}`, vrai: reussis >= 12 },
  mediane_minutes: { valeur: mediane, vrai: mediane !== null && mediane <= 45 },
  gestes_au_plus_3: { valeur: essais.map((e) => `${e.id}:${e.gestes ?? "?"}`).join(" "), vrai: essais.every((e) => e.gestes !== null && e.gestes <= 3) },
  aucune_fuite: { valeur: avecPile.filter((e) => e.fuite).map((e) => e.id), vrai: avecPile.every((e) => e.fuite === false) },
  chiffres_exacts: { valeur: avecPile.filter((e) => !e.chiffres).map((e) => e.id), vrai: avecPile.every((e) => e.chiffres === true) },
  jamais_faux_fini: { valeur: essais.filter((e) => e.faux_fini).map((e) => e.id), vrai: essais.every((e) => e.faux_fini === false) },
  etiquettes: { valeur: avecPile.filter((e) => e.etiquette !== true).map((e) => e.id), vrai: avecPile.every((e) => e.etiquette === true) },
};
const tousVrais = Object.values(seuils).every((s) => s.vrai);
// Échoué dès qu'un seuil ne peut plus être tenu ; sinon incomplet tant qu'il manque un jugement.
const perdu = ids.length - essais.filter((e) => e.verdict === "échec").length < 12 || essais.some((e) => e.fuite === true) ||
  avecPile.some((e) => e.chiffres === false) || essais.some((e) => e.gestes !== null && e.gestes > 3) ||
  essais.some((e) => e.faux_fini === true) || avecPile.some((e) => e.etiquette === false);
const verdict = perdu ? "échoué" : manque.length ? "incomplet" : tousVrais ? "réussi" : "échoué";
console.log(JSON.stringify({ verdict, manque, seuils, essais }, (k, v) => (v === Infinity ? "infini" : v), 2));
console.log(`examen : ${verdict}${manque.length && verdict === "incomplet" ? ` (${manque.length} élément(s) manquant(s))` : ""}`);
process.exit(verdict === "réussi" ? 0 : verdict === "échoué" ? 1 : 3);
