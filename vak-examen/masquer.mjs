#!/usr/bin/env node
// Masque, dans les transcriptions publiées (transcription.jsonl.gz), ce que la transcription du lanceur
// (repetition2/transcription.mjs, figée) laisse passer : elle masque les identifiants de modèle (« claude-… »), pas les
// noms commerciaux, ni les adresses e-mail de tiers (un `git log` d'une app publique, par exemple). Seule la copie
// publiée est masquée, par publier.sh : les résultats commités ne changent pas, et aucun jugement n'en dépend.
// Usage : node vak-examen/masquer.mjs <transcription.jsonl.gz>…   Node 22, aucune dépendance.
import { readFileSync, writeFileSync } from "node:fs";
import { gunzipSync, gzipSync } from "node:zlib";

const MODELE_ID = /\bclaude-(?:opus|sonnet|haiku|fable)(?:-[0-9a-z]+)+\b/gi;
const MODELE_NOM = /\b(?:Claude\s+)?(?:Opus|Sonnet|Haiku|Fable)\s+[0-9]+(?:\.[0-9]+)?\b/g;
const FAMILLE = /\bClaude\s+[0-9]+(?:\.[0-9]+)?\s+family\b/g;
const EMAIL = /[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/g;
// Gardées : les adresses factices (.test, .invalid, example.*), celle des commits d'agent, et les faux positifs
// qui sont des noms de fichier (« …@AGENTS.md »).
const garder = (a) => /@anthropic\.com$|\.(?:test|invalid|example|md)$|@example\.(?:com|org|net)$/i.test(a);

let total = 0;
for (const f of process.argv.slice(2)) {
  const avant = gunzipSync(readFileSync(f)).toString("utf8");
  let n = 0;
  const apres = avant
    .replace(MODELE_ID, () => (n++, "«modèle»"))
    .replace(MODELE_NOM, () => (n++, "«modèle»"))
    .replace(FAMILLE, () => (n++, "«modèle»"))
    .replace(EMAIL, (a) => (garder(a) ? a : (n++, "«e-mail»")));
  // Chaque ligne qui était du JSON l'est encore.
  const lignes = (t) => t.split("\n").map((l) => { try { JSON.parse(l); return true; } catch { return false; } });
  const a = lignes(avant), b = lignes(apres);
  if (a.length !== b.length || a.some((ok, i) => ok && !b[i])) {
    console.error(`✗ ${f} : le masquage casserait le JSON, fichier laissé tel quel`);
    process.exitCode = 1;
    continue;
  }
  if (n) writeFileSync(f, gzipSync(apres));
  total += n;
  console.log(`${f} : ${n} masquage(s)`);
}
console.log(`masquages : ${total}`);
