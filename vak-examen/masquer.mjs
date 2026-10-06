#!/usr/bin/env node
// Masque, dans les résultats publiés, ce que la transcription du lanceur (repetition2/transcription.mjs, figée) laisse
// passer : elle masque les identifiants de modèle (« claude-… »), pas les noms commerciaux, ni les adresses e-mail de
// tiers (un `git log` d'une app publique, par exemple) ; et les autres fichiers (autres.diff : le code d'un agent du
// groupe témoin, qui écrit un identifiant de modèle en dur) ne sont pas masqués du tout. Seule la copie publiée est
// masquée, par publier.sh : les résultats commités ne changent pas, et aucun jugement n'en dépend.
// Usage : node vak-examen/masquer.mjs <fichier>…   (.gz : décompressé puis recompressé ; un fichier binaire est laissé)
// Node 22, aucune dépendance.
import { readFileSync, writeFileSync } from "node:fs";
import { gunzipSync, gzipSync } from "node:zlib";

const MODELE_ID = /claude-(?:opus|sonnet|haiku|fable)(?:-[0-9a-z]+)+(?![0-9a-z])/gi;
// Sans \b au début : dans le JSON d'une transcription, un nom de modèle juste après « \n » est collé au « n » de
// l'échappement. Toute casse.
const MODELE_NOM = /(?:Claude\s+)?(?:Opus|Sonnet|Haiku|Fable)\s+[0-9]+(?:\.[0-9]+)?(?!\w)/gi;
const FAMILLE = /Claude\s+[0-9]+(?:\.[0-9]+)?\s+family\b/gi;
const EMAIL = /[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/g;
// Gardées : les adresses factices (.test, .invalid, example.*), celle des commits d'agent, et les faux positifs
// qui sont des noms de fichier (« …@AGENTS.md »).
const garder = (a) => /@anthropic\.com$|\.(?:test|invalid|example|md)$|@example\.(?:com|org|net)$/i.test(a);

let total = 0;
for (const f of process.argv.slice(2)) {
  const gz = f.endsWith(".gz");
  const brut = readFileSync(f);
  if (!gz && brut.includes(0)) continue; // binaire
  const avant = (gz ? gunzipSync(brut) : brut).toString("utf8");
  let n = 0;
  const apres = avant
    .replace(MODELE_ID, () => (n++, "«modèle»"))
    .replace(MODELE_NOM, () => (n++, "«modèle»"))
    .replace(FAMILLE, () => (n++, "«modèle»"))
    .replace(EMAIL, (a) => (garder(a) ? a : (n++, "«e-mail»")));
  // Chaque ligne qui était du JSON l'est encore ; un fichier .json entier aussi.
  const lignes = (t) => t.split("\n").map((l) => { try { JSON.parse(l); return true; } catch { return false; } });
  const entier = (t) => { try { JSON.parse(t); return true; } catch { return false; } };
  const a = lignes(avant), b = lignes(apres);
  if (a.length !== b.length || a.some((ok, i) => ok && !b[i]) || (f.endsWith(".json") && entier(avant) && !entier(apres))) {
    console.error(`✗ ${f} : le masquage casserait le JSON, fichier laissé tel quel`);
    process.exitCode = 1;
    continue;
  }
  if (n) writeFileSync(f, gz ? gzipSync(apres) : apres);
  total += n;
  if (n) console.log(`${f} : ${n} masquage(s)`);
}
console.log(`masquages : ${total}`);
