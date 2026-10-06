#!/usr/bin/env node
// Critère « pas une copie », tranché à la reprise du 06/10. L'API GitHub étant fermée à cette machine pour les dépôts
// tiers, deux signes se vérifient mécaniquement :
// - historique commun : les deux dépôts partagent au moins un commit ;
// - contenu copié : plus de la moitié des fichiers du candidat (à son commit du 04/10, fichier vide exclu) ont le même
//   contenu, octet pour octet, qu'un fichier de l'autre dépôt (à sa tête). Ce signe voit une copie sans historique.
// Un candidat qui porte l'un des deux signes face à une app des répétitions, ou face à un autre candidat, est écarté ;
// entre deux candidats, les deux le sont (sans l'API, rien ne dit lequel est l'original).
// Node 22, aucune dépendance npm.
// Une app des répétitions elle-même, ou un dépôt de l'un de leurs propriétaires, est écarté aussi (ajouté le 06/10 : la
// liste remise à la session scellée oubliait les apps de la répétition 1, et l'une d'elles était candidate).
// Usage : node candidats/historique.mjs <dossier de travail> > candidats/historique.tsv
// Lit candidats.tsv (les éligibles) et exclusions.txt (les apps des répétitions, toutes). Chaque dépôt est cloné sans
// le contenu des fichiers (--filter=blob:none : commits et arborescences, empreintes comprises) ; un candidat est jugé
// sur les ancêtres de son commit du 04/10, une app des répétitions sur toutes ses branches (historique) et sur sa tête
// (contenu). Les clones sont supprimés à la fin (GARDER=1 les garde).
import { spawnSync } from 'node:child_process';
import { mkdirSync, readFileSync, rmSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const ICI = dirname(fileURLToPath(import.meta.url));
const SEUIL_CONTENU = 0.5;
const FICHIER_VIDE = 'e69de29bb2d1d6434b8b29ae775ad8c2e48c5391';
const travail = process.argv[2];
if (!travail) {
  console.error('usage : node candidats/historique.mjs <dossier de travail>');
  process.exit(2);
}

const git = (args, cwd) => spawnSync('git', args, { cwd, encoding: 'utf8', maxBuffer: 1 << 28 });
const nom = (url) => url.replace(/^https?:\/\/github\.com\//i, '').replace(/(\.git)?\/?$/, '');
const pourcent = (x) => `${Math.round(x * 100)} %`;

const lignes = readFileSync(join(ICI, 'candidats.tsv'), 'utf8').trim().split('\n').slice(1).map((l) => l.split('\t'));
const candidats = lignes.filter((c) => c[4] === 'oui').map(([url, commit, , plateforme]) => ({ url, commit, plateforme, sorte: 'candidat' }));
const repetitions = readFileSync(join(ICI, 'exclusions.txt'), 'utf8')
  .split('\n')
  .map((l) => l.trim())
  .filter((l) => /^https?:\/\/github\.com\/[^/\s]+\/[^/\s]+/i.test(l))
  .map((url) => ({ url, commit: null, plateforme: '', sorte: 'répétition' }));
const depots = [...candidats, ...repetitions];

const racine = resolve(travail, `historique-${process.pid}`);
mkdirSync(racine, { recursive: true });
const parCommit = new Map(); // commit → indices des dépôts qui le contiennent

depots.forEach((d, i) => {
  const dir = join(racine, String(i));
  const clone = git(['clone', '--quiet', '--bare', '--filter=blob:none', `${d.url.replace(/\/$/, '')}.git`, dir]);
  if (clone.status !== 0) {
    d.erreur = `clone impossible : ${(clone.stderr || '').trim().split('\n').pop()}`;
    d.fichiers = new Set();
    return;
  }
  let depuis = ['--all'];
  let tete = 'HEAD';
  if (d.commit) {
    if (git(['cat-file', '-e', `${d.commit}^{commit}`], dir).status === 0) {
      depuis = [d.commit];
      tete = d.commit;
    } else d.note = 'commit du 04/10 introuvable : toutes les branches et la tête comparées';
  }
  const commits = git(['rev-list', ...depuis], dir).stdout.split('\n').filter(Boolean);
  d.commits = commits.length;
  d.racines = git(['rev-list', '--max-parents=0', ...depuis], dir).stdout.split('\n').filter(Boolean).length;
  for (const c of commits) {
    const deja = parCommit.get(c);
    if (deja) deja.add(i);
    else parCommit.set(c, new Set([i]));
  }
  // Empreintes des fichiers (objets « blob ») à la tête jugée ; les sous-modules (« commit ») ne comptent pas.
  d.fichiers = new Set(
    git(['ls-tree', '-r', tete], dir)
      .stdout.split('\n')
      .map((l) => /^\d+ blob ([0-9a-f]{40})\t/.exec(l)?.[1])
      .filter((h) => h && h !== FICHIER_VIDE),
  );
  console.error(`${i + 1}/${depots.length} ${nom(d.url)} : ${d.commits} commits, ${d.fichiers.size} fichiers`);
});

// Nombre de commits partagés, par paire de dépôts.
const partages = depots.map(() => new Map());
for (const indices of parCommit.values()) {
  if (indices.size < 2) continue;
  for (const a of indices) for (const b of indices) if (a !== b) partages[a].set(b, (partages[a].get(b) ?? 0) + 1);
}

// Part des fichiers du candidat i dont le contenu se retrouve dans le dépôt j.
const contenuCommun = (i, j) => {
  const a = depots[i].fichiers;
  if (a.size === 0) return 0;
  let n = 0;
  for (const h of a) if (depots[j].fichiers.has(h)) n++;
  return n / a.size;
};

console.log(['url', 'plateforme', 'commits', 'racines', 'fichiers', 'historique_commun', 'contenu_commun_max', 'eligible', 'raison'].join('\t'));
candidats.forEach((d, i) => {
  const raisons = [];
  if (d.erreur) raisons.push(d.erreur);
  const cle = (url) => nom(url).toLowerCase();
  const proprio = (url) => cle(url).split('/')[0];
  const meme = repetitions.find((r) => cle(r.url) === cle(d.url));
  const parent = repetitions.find((r) => proprio(r.url) === proprio(d.url));
  if (meme) raisons.push("app des répétitions");
  else if (parent) raisons.push(`même propriétaire qu'une app des répétitions : ${nom(parent.url)}`);
  const historique = [...partages[i]].filter(([j]) => depots[j] !== meme).map(([j, n]) => ({ autre: depots[j], n }));
  const contenu = depots
    .map((autre, j) => ({ autre, part: j === i || autre === meme ? 0 : contenuCommun(i, j) }))
    .sort((x, y) => y.part - x.part);
  const copies = (sorte) => [
    ...historique.filter((p) => p.autre.sorte === sorte).map((p) => `${nom(p.autre.url)} (${p.n} commits communs)`),
    ...contenu.filter((p) => p.autre.sorte === sorte && p.part > SEUIL_CONTENU).map((p) => `${nom(p.autre.url)} (${pourcent(p.part)} des fichiers identiques)`),
  ];
  const rep = copies('répétition');
  const cand = copies('candidat');
  if (rep.length) raisons.push(`copie d'une app des répétitions : ${rep.join(', ')}`);
  if (cand.length) raisons.push(`copie partagée avec un autre candidat : ${cand.join(', ')}`);
  const eligible = raisons.length === 0;
  if (d.note) raisons.push(`note : ${d.note}`);
  const commun = historique.map((p) => `${nom(p.autre.url)}:${p.n}`).join(', ') || '—';
  const max = contenu[0] && contenu[0].part > 0 ? `${pourcent(contenu[0].part)} (${nom(contenu[0].autre.url)})` : '0 %';
  console.log([d.url, d.plateforme, d.commits ?? '', d.racines ?? '', d.fichiers.size, commun, max, eligible ? 'oui' : 'non', raisons.join(' ; ') || 'ni historique commun ni contenu copié'].join('\t'));
});
for (const d of repetitions.filter((r) => r.erreur)) console.error(`répétition ${nom(d.url)} : ${d.erreur}`);

if (process.env.GARDER !== '1') rmSync(racine, { recursive: true, force: true });
