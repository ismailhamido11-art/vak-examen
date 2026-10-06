#!/usr/bin/env node
// Tirage des 4 apps publiques de l'examen (REGLE.md, « Tirage »). Node 22, aucune dépendance npm.
// Usage : node tirage.mjs <tour drand> [<tour.json>]
// La graine est l'aléa d'un tour drand « quicknet » : une valeur publique toutes les 3 s, signée par le réseau League
// of Entropy, que personne ne connaît d'avance. Le tour est fixé et publié avant d'exister.
// Les apps éligibles sont les lignes de candidats/historique.tsv dont la colonne `eligible` vaut `oui`. Chaque app
// reçoit le rang SHA-256(aléa + "\n" + url), en hexadécimal. On trie par rang, puis on prend, dans cet ordre, les 2
// premières apps Expo et les 2 premières apps Next. Les suivantes, dans le même ordre, forment la réserve de leur
// plateforme : une app sautée avant tout essai (REGLE.md) est remplacée par la première de sa réserve, et consignée.
// Sans <tour.json>, le tour est lu sur le relais public de drand ; avec, le fichier tient lieu de relais (même forme :
// { round, randomness, signature }). Dans les deux cas, l'aléa est contrôlé : SHA-256(signature) = randomness.
import { createHash } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const ICI = dirname(fileURLToPath(import.meta.url));
const CHAINE = '52db9ba70e0cc0f6eaf7803dd07447a1f5477735fd3f661792ba94600c84e971'; // quicknet
const RELAIS = ['https://api.drand.sh', 'https://api2.drand.sh', 'https://api3.drand.sh', 'https://drand.cloudflare.com'];
const PAR_PLATEFORME = { expo: 2, next: 2 };

const [tourArg, fichier] = process.argv.slice(2);
const tour = Number(tourArg);
if (!Number.isSafeInteger(tour) || tour < 1) {
  console.error('usage : node tirage.mjs <tour drand> [<tour.json>]');
  process.exit(2);
}
const sha256 = (x) => createHash('sha256').update(x).digest('hex');

async function lireTour() {
  if (fichier) return JSON.parse(readFileSync(fichier, 'utf8'));
  for (const r of RELAIS) {
    const rep = await fetch(`${r}/${CHAINE}/public/${tour}`).catch(() => null);
    if (rep?.ok) return rep.json();
    if (rep && rep.status >= 400 && rep.status < 500) throw new Error(`tour ${tour} pas encore publié (${r} : HTTP ${rep.status})`);
  }
  throw new Error('aucun relais drand ne répond');
}

process.on('uncaughtException', (e) => {
  console.error(`✗ ${e.message}`);
  process.exit(1);
});
const t = await lireTour();
if (t.round !== tour) throw new Error(`le relais rend le tour ${t.round}, pas ${tour}`);
if (sha256(Buffer.from(t.signature, 'hex')) !== t.randomness) throw new Error('aléa incohérent : SHA-256(signature) ≠ randomness');

const liste = readFileSync(join(ICI, 'candidats', 'historique.tsv'), 'utf8');
const [entete, ...lignes] = liste.trim().split('\n').map((l) => l.split('\t'));
const col = (nom) => entete.indexOf(nom);
const eligibles = lignes
  .filter((c) => c[col('eligible')] === 'oui')
  .map((c) => ({ url: c[col('url')], plateforme: c[col('plateforme')], rang: sha256(`${t.randomness}\n${c[col('url')]}`) }))
  .sort((a, b) => (a.rang < b.rang ? -1 : 1));

const tirees = [];
const reserve = { expo: [], next: [] };
for (const app of eligibles) {
  const deja = tirees.filter((x) => x.plateforme === app.plateforme).length;
  if (deja < (PAR_PLATEFORME[app.plateforme] ?? 0)) tirees.push(app);
  else reserve[app.plateforme]?.push(app);
}
for (const [p, n] of Object.entries(PAR_PLATEFORME)) {
  if (tirees.filter((x) => x.plateforme === p).length < n) throw new Error(`moins de ${n} apps ${p} éligibles`);
}

console.log(
  JSON.stringify(
    { chaine: CHAINE, tour, aleas: t.randomness, signature: t.signature, liste: { fichier: 'candidats/historique.tsv', sha256: sha256(liste), eligibles: eligibles.length }, tirees, reserve },
    null,
    2,
  ),
);
console.error(`tour ${tour} : ${tirees.map((x) => `${x.plateforme} ${x.url}`).join(' ; ')}`);
