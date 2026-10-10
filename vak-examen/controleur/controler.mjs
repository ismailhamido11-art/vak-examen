#!/usr/bin/env node
// Contrôleur de l'examen public de vak (règle : REGLE.md, points 1, 2, 3, 4, 6 et 7).
//   node controleur/controler.mjs <dossier d'un essai> <dossier de travail>
// Écrit <dossier de travail>/verdict.json ; dernière ligne : « verdict <id> : réussi | échec (…) | refus propre (…) ».
// Node 22, aucune dépendance npm. Aucune IA : des comparaisons et des comptes.
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { arbre, court, derniereLignes, git, gitShow, gitShowBuf, lireJson, sansCouleurs, sh, sha256, supprimer } from './lib/outils.mjs';
import { comparerDependances, legacyDansNpmrc } from './lib/deps.mjs';
import { compterAvertissements, comparerErreurs, extraireErreurs, extraireGenerique, resumeTests } from './lib/erreurs.mjs';
import {
  RE_NON_PRIS_EN_CHARGE, contournements, debutAgent, dernierTexteAgent, echecsDePreuve, legacyPoseParVak, lireJournal, premierVakOk,
} from './lib/journal.mjs';
import { lireIgnore, lireSchema, tablesAMoi } from './lib/schema.mjs';

const VERSION = '1.0.0';
const MIN = 60_000;
const DELAI_VERIF = Number(process.env.CONTROLEUR_DELAI_MIN || 20) * MIN;
const DELAI_INSTALL = Number(process.env.CONTROLEUR_INSTALL_MIN || 30) * MIN;
const DELAI_VAK = Number(process.env.CONTROLEUR_VAK_MIN || 25) * MIN;
const LIMITE_DUREE_MIN = 120;
const GARDER = process.env.CONTROLEUR_GARDER === '1';

// Pas de cache d'outil entre deux mesures (turbo, nx…), pas d'interaction, pas de télémétrie.
const ENV_MESURE = {
  CI: 'true', FORCE_COLOR: '0', NO_COLOR: '1',
  TURBO_FORCE: 'true', TURBO_TELEMETRY_DISABLED: '1', DO_NOT_TRACK: '1',
  NX_SKIP_NX_CACHE: 'true', NX_DAEMON: 'false', NX_NO_CLOUD: 'true',
  NEXT_TELEMETRY_DISABLED: '1', EXPO_NO_TELEMETRY: '1', ADBLOCK: '1', DISABLE_OPENCOLLECTIVE: '1',
  NODE_ENV: undefined, npm_config_audit: 'false', npm_config_fund: 'false', npm_config_update_notifier: 'false',
};

// ───────────────────────── sorties ─────────────────────────

const v = { controleur: { nom: 'controler.mjs', version: VERSION }, id: null, verdict: null, reussi: false, points: {}, raisons: [], notes: [] };
const echec = (point, code, resume, preuve = []) => v.raisons.push({ point, code, resume, preuve: preuve.map((p) => (typeof p === 'string' ? court(p, 400) : p)) });
const note = (t) => v.notes.push(t);
const log = (t) => process.stderr.write(`[contrôleur] ${t}\n`);

function terminer(travail) {
  const refus = v.points.p7?.refusPropre;
  if (refus) v.verdict = 'refus propre';
  else v.verdict = v.raisons.length === 0 ? 'réussi' : 'échec';
  v.reussi = v.verdict === 'réussi';
  v.fin = new Date().toISOString();
  fs.mkdirSync(travail, { recursive: true });
  fs.writeFileSync(path.join(travail, 'verdict.json'), `${JSON.stringify(v, null, 2)}\n`);
  let ligne;
  if (v.verdict === 'réussi') ligne = `verdict ${v.id} : réussi`;
  else if (v.verdict === 'refus propre') ligne = `verdict ${v.id} : refus propre (${v.points.p7.raison})`;
  else ligne = `verdict ${v.id} : échec (${v.raisons.map((r) => `point ${r.point} : ${r.resume}`).join(' ; ')})`;
  console.log(ligne);
  return v.verdict === 'réussi' ? 0 : 1;
}

// ───────────────────────── gestionnaire de paquets, installation ─────────────────────────

function gestionnaire(dossier) {
  const a = (f) => fs.existsSync(path.join(dossier, f));
  let pm = null;
  try { pm = lireJson(path.join(dossier, 'package.json')).packageManager?.split('@')[0] ?? null; } catch { /* pas de package.json */ }
  if (a('pnpm-lock.yaml')) return 'pnpm';
  if (a('yarn.lock')) return 'yarn';
  if (a('package-lock.json') || a('npm-shrinkwrap.json')) return 'npm';
  if (a('bun.lock') || a('bun.lockb')) return 'bun';
  return pm || (a('package.json') ? 'npm' : null);
}

function commandesInstall(pm, dossier, legacy) {
  const berry = pm === 'yarn' && (fs.existsSync(path.join(dossier, '.yarnrc.yml')) || /__metadata:/.test(safeRead(path.join(dossier, 'yarn.lock'))));
  const fl = legacy ? ' --legacy-peer-deps' : '';
  if (pm === 'npm') return { strict: `npm ci --no-audit --no-fund${fl}`, souple: `npm install --no-audit --no-fund${fl}` };
  if (pm === 'pnpm') return { strict: 'pnpm install --frozen-lockfile', souple: 'pnpm install --no-frozen-lockfile' };
  if (pm === 'yarn') return berry ? { strict: 'yarn install --immutable', souple: 'yarn install' } : { strict: 'yarn install --frozen-lockfile', souple: 'yarn install' };
  return null;
}
const safeRead = (f) => { try { return fs.readFileSync(f, 'utf8'); } catch { return ''; } };

async function installer(dossier, pm, logs, nom, legacy) {
  const cmds = commandesInstall(pm, dossier, false);
  if (!cmds) return { ok: false, raison: `gestionnaire de paquets non géré (${pm ?? 'aucun'})`, nonGere: true };
  const essai = async (cmd, suffixe) => sh(cmd, { cwd: dossier, env: ENV_MESURE, timeoutMs: DELAI_INSTALL, logFile: path.join(logs, `${nom}-install-${suffixe}.log`) });
  let r = await essai(cmds.strict, 'strict');
  const tentatives = [{ commande: cmds.strict, code: r.code, delai: r.timedOut }];
  let utilise = cmds.strict;
  // Un développeur qui bute sur ERESOLVE à cause de vak (exception du point 3) : seulement si vak l'a lui-même posé.
  if (r.code !== 0 && !r.timedOut && legacy && pm === 'npm' && /ERESOLVE/.test(r.out)) {
    const c2 = commandesInstall(pm, dossier, true);
    r = await essai(c2.strict, 'legacy');
    tentatives.push({ commande: c2.strict, code: r.code, delai: r.timedOut });
    utilise = c2.strict;
  }
  let souple = false;
  if (r.code !== 0 && !r.timedOut) {
    r = await essai(cmds.souple, 'souple');
    tentatives.push({ commande: cmds.souple, code: r.code, delai: r.timedOut });
    utilise = cmds.souple;
    souple = r.code === 0;
  }
  return { ok: r.code === 0, tentatives, commande: utilise, souple, fin: derniereLignes(r.out, 12), delai: r.timedOut };
}

// ───────────────────────── vérifications de l'app ─────────────────────────

const CANDIDATS = {
  typecheck: ['typecheck', 'type-check', 'check-types', 'types', 'tsc'],
  lint: ['lint'],
  test: ['test', 'test:ci', 'test:unit'],
  build: ['build', 'export', 'build:web', 'export:web'],
};

function detecterVerifs(dossier, pm) {
  const run = (s) => (pm === 'pnpm' ? `pnpm run ${s}` : pm === 'yarn' ? `yarn run ${s}` : `npm run ${s}`);
  let scripts = {};
  try { scripts = lireJson(path.join(dossier, 'package.json')).scripts ?? {}; } catch { /* aucun */ }
  const out = {};
  for (const [genre, noms] of Object.entries(CANDIDATS)) {
    const nom = noms.find((n) => typeof scripts[n] === 'string' && !/no test specified/.test(scripts[n]));
    if (nom && genre === 'test') {
      const sansSurveillance = testsSansSurveillance(dossier);
      if (sansSurveillance) { out[genre] = sansSurveillance; continue; }
    }
    if (nom) { out[genre] = { commande: run(nom), source: `script « ${nom} » : ${scripts[nom]}` }; continue; }
    if (genre === 'typecheck' && fs.existsSync(path.join(dossier, 'tsconfig.json')) && fs.existsSync(path.join(dossier, 'node_modules/.bin/tsc'))) {
      out[genre] = { commande: 'npx --no-install tsc --noEmit', source: 'tsconfig.json à la racine, sans script' };
    }
    if (genre === 'test') {
      for (const d of ['test', 'tests']) {
        const p = path.join(dossier, d);
        if (!fs.existsSync(p) || !fs.statSync(p).isDirectory()) continue;
        const js = fs.readdirSync(p).filter((f) => /\.(c|m)?js$/.test(f));
        if (js.length === 1) out[genre] = { commande: `node ${d}/${js[0]}`, source: `aucun script « test » ; un seul fichier dans ${d}/` };
      }
    }
  }
  return out;
}

// Un script « test » en mode surveillance (`jest --watchAll`) ne rend jamais la main : un développeur lance alors
// l'outil une fois. On exécute le corps de chaque script « test » (racine ou espaces de travail) sans l'option
// de surveillance, dans son dossier, avec les binaires locaux dans le PATH.
const RE_SURVEILLANCE = /(^|\s)--watch(All)?(?![\w-])(?!=false)/;
function testsSansSurveillance(dossier) {
  const fichiers = git(dossier, ['ls-files', '--', '*package.json']).split('\n').filter((f) => f && !/(^|\/)(node_modules|vendor|\.claude|\.agents)\//.test(f)).sort();
  const scripts = [];
  for (const f of fichiers) {
    let t;
    try { t = lireJson(path.join(dossier, f)).scripts?.test; } catch { continue; }
    if (typeof t === 'string' && !/no test specified/.test(t)) scripts.push({ dir: path.dirname(f), corps: t });
  }
  if (!scripts.some((x) => RE_SURVEILLANCE.test(x.corps))) return null;
  const morceaux = scripts.filter((x) => !/^(turbo|nx|lerna|pnpm -r|pnpm --recursive|yarn workspaces)\b/.test(x.corps)).map((x) => {
    const corps = x.corps.replace(RE_SURVEILLANCE, ' ').trim();
    return `echo "== ${x.dir} : ${corps.replace(/"/g, '')}"; (cd ${JSON.stringify(x.dir)} && PATH="$PWD/node_modules/.bin:$RACINE/node_modules/.bin:$PATH" ${corps}) || rc=1`;
  });
  return {
    commande: `RACINE="$PWD"; rc=0; ${morceaux.join('; ')}; exit $rc`,
    source: `script « test » en mode surveillance : exécuté une fois, sans --watch, dans ${scripts.filter((x) => !/^(turbo|nx|lerna)\b/.test(x.corps)).map((x) => x.dir).join(', ')}`,
  };
}

async function mesurerVerifs(dossier, verifs, logs, nom, envApp = {}) {
  const res = {};
  for (const [genre, def] of Object.entries(verifs)) {
    log(`${nom} : ${genre} (${def.commande})`);
    const r = await sh(def.commande, { cwd: dossier, env: { ...envApp, ...ENV_MESURE }, timeoutMs: DELAI_VERIF, logFile: path.join(logs, `${nom}-${genre}.log`) });
    let erreurs = extraireErreurs(r.out, dossier);
    let generique = false;
    if (erreurs.length === 0 && r.code !== 0 && !r.timedOut) { erreurs = extraireGenerique(r.out, dossier); generique = erreurs.length > 0; }
    res[genre] = {
      commande: def.commande, source: def.source, code: r.code, delai: r.timedOut, ms: r.ms, erreurs, generique,
      avertissements: genre === 'lint' ? compterAvertissements(r.out) : undefined,
      tests: genre === 'test' ? resumeTests(r.out) : undefined,
      fin: derniereLignes(r.out, 12),
    };
  }
  return res;
}

// Variables d'un fichier d'exemple (.env.example…) : ce que fait un développeur avant de compiler. Lues une fois, sur
// le commit de préparation, et passées aux deux mesures.
function envExemple(dossier) {
  for (const f of ['.env.local.example', '.env.example', '.env.sample', '.env.development', '.env.local.sample']) {
    const t = safeRead(path.join(dossier, f));
    if (!t) continue;
    const env = {};
    for (const l of t.split('\n')) {
      const m = /^\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*$/.exec(l);
      if (m && !l.trim().startsWith('#')) env[m[1]] = m[2].replace(/^(['"])(.*)\1$/, '$2');
    }
    return { fichier: f, env };
  }
  return { fichier: null, env: {} };
}

function cloner(app, rev, dossier) {
  supprimer(dossier);
  git(process.cwd(), ['clone', '-q', '--no-hardlinks', '--no-checkout', app, dossier]);
  git(dossier, ['checkout', '-q', '--detach', rev]);
}

// ───────────────────────── point 1 : vak a fini ─────────────────────────

function trouverCli(dossierApp, racine) {
  let d = dossierApp;
  for (;;) {
    const c = path.join(d, 'node_modules/@vak/agent/bin/vak.mjs');
    if (fs.existsSync(c)) return c;
    if (d === racine || path.dirname(d) === d) return null;
    d = path.dirname(d);
  }
}

const statutGit = (d) => new Set(git(d, ['status', '--porcelain', '-uno', '-z']).split('\0').filter(Boolean));

// Deux contrôleurs lancés en même temps ne doivent pas lancer vak ensemble : le ménage des bases de test, par
// différence avant/après, supprimerait les bases de l'autre. Un verrou (dossier créé de façon atomique) les sérialise.
async function avecVerrou(fn) {
  const verrou = path.join(os.tmpdir(), 'vak-controleur-vak.lock');
  const limite = Date.now() + 60 * MIN;
  for (;;) {
    try { fs.mkdirSync(verrou); break; } catch (e) {
      if (e.code !== 'EEXIST') throw e;
      try { if (Date.now() - fs.statSync(verrou).mtimeMs > 40 * MIN) fs.rmSync(verrou, { recursive: true }); } catch { /* repris par un autre */ }
      if (Date.now() > limite) throw new Error('verrou de vak jamais obtenu');
      await new Promise((r) => setTimeout(r, 2000));
    }
  }
  try { return await fn(); } finally { fs.rmSync(verrou, { recursive: true, force: true }); }
}

async function listerBases() {
  const r = await sh(`psql -h 127.0.0.1 -U root -d postgres -qAtc 'select datname from pg_database'`, { timeoutMs: 60_000 });
  return new Set(r.code === 0 ? r.out.split('\n').map((x) => x.trim()).filter(Boolean) : []);
}

async function lancerVak(clone, appDirs, logs) {
  const resultats = [];
  for (const rel of appDirs) {
    const dossierApp = path.join(clone, rel);
    const cli = trouverCli(dossierApp, clone);
    if (!cli) { resultats.push({ app: rel || '.', ok: false, raison: 'la CLI de vak n\'est pas installée (node_modules/@vak/agent/bin/vak.mjs introuvable)' }); continue; }
    const avant = statutGit(clone);
    const basesAvant = await listerBases();
    const cmd = `node ${JSON.stringify(path.relative(dossierApp, cli) || cli)}`;
    log(`vak : ${cmd} (dans ${rel || '.'})`);
    const r = await sh(cmd, { cwd: dossierApp, env: { ...ENV_MESURE, CI: undefined }, timeoutMs: DELAI_VAK, logFile: path.join(logs, `head-vak-${(rel || 'racine').replace(/\W+/g, '_')}.log`) });
    const apres = statutGit(clone);
    const modifies = [...apres].filter((x) => !avant.has(x)).map((x) => x.slice(3));
    const sortie = sansCouleurs(r.out);
    const derniere = /^vak : .*$/m.exec([...sortie.matchAll(/^vak : .*$/gm)].map((m) => m[0]).pop() ?? '');
    // Nettoyage : les bases créées par vak pendant cette exécution sur le PostgreSQL local de l'examen.
    const apresBases = await listerBases();
    for (const nomBase of apresBases) {
      if (!basesAvant.has(nomBase)) await sh(`psql -h 127.0.0.1 -U root -d postgres -qAtc 'DROP DATABASE IF EXISTS "${nomBase}" WITH (FORCE)'`, { timeoutMs: 60_000 });
    }
    resultats.push({
      app: rel || '.', cli: path.relative(clone, cli), code: r.code, delai: r.timedOut, ms: r.ms,
      derniereLigne: derniere ? derniere[0] : null, fin: derniereLignes(sortie, 25),
      controles: sortie.split('\n').filter((l) => /^(✓|✗|!) (VAK\d+|\S+ (éprouvé|fuite|rls|étroit|total faux|non prouvé))/.test(l)).map((l) => l.slice(0, 220)),
      fichiersReecrits: modifies,
    });
  }
  return resultats;
}

// ───────────────────────── programme ─────────────────────────

async function main() {
  const [, , essaiArg, travailArg] = process.argv;
  if (!essaiArg || !travailArg) {
    console.error('usage : node controleur/controler.mjs <dossier d\'un essai> <dossier de travail>');
    return 2;
  }
  const essai = path.resolve(essaiArg);
  const travail = path.resolve(travailArg);
  const logs = path.join(travail, 'journaux');
  fs.mkdirSync(logs, { recursive: true });
  const prep = lireJson(path.join(essai, 'preparation.json'));
  v.id = prep.id;
  v.entree = { essai, preparation: prep };
  const app = path.join(essai, 'app');
  const journal = lireJournal(path.join(essai, 'journal.jsonl'));
  v.journal = { entrees: journal.evts.length, illisibles: journal.illisibles };

  // ── historique : app d'origine → préparation → agent
  const rev = (r) => git(app, ['rev-parse', '--verify', '-q', `${r}^{commit}`], { tolerant: true })?.trim() || null;
  const tip = rev('refs/heads/essai') ?? rev('HEAD');
  const sPrep = rev(prep.prepare);
  const sOrig = rev(prep.commit);
  if (!tip || !sPrep || !sOrig) {
    echec('entrée', 'historique', 'historique de l\'essai incomplet', [`HEAD=${tip} prepare=${sPrep} commit=${sOrig}`]);
    return terminer(travail);
  }
  const ancetre = (a, b) => { try { git(app, ['merge-base', '--is-ancestor', a, b]); return true; } catch { return false; } };
  if (!ancetre(sPrep, tip) || !ancetre(sOrig, sPrep)) {
    echec('entrée', 'historique', 'l\'historique ne suit pas « app d\'origine → préparation → agent »', [`commit=${sOrig} prepare=${sPrep} HEAD=${tip}`]);
    return terminer(travail);
  }
  const arbPrep = arbre(app, sPrep);
  const arbTip = arbre(app, tip);
  const commitsAgent = git(app, ['rev-list', '--count', `${sPrep}..${tip}`]).trim();
  const sale = git(app, ['status', '--porcelain'], { tolerant: true })?.split('\n').filter(Boolean) ?? [];
  v.entree.tip = tip;
  v.entree.commitsAgent = Number(commitsAgent);
  const diffOrigPrep = git(app, ['diff', '--name-status', '--no-renames', sOrig, sPrep]).trim().split('\n').filter(Boolean);
  if (diffOrigPrep.some((l) => !/^A\s+.*vendor\/vak\/[^/]+\.tgz$/.test(l))) note(`le commit de préparation change autre chose que l'archive : ${diffOrigPrep.join(' | ')}`);
  if (sale.length) note(`${sale.length} fichier(s) non commités dans app/ (ignorés : seul le commité est jugé) : ${sale.slice(0, 6).join(' | ')}`);

  // ── point 7 : refus propre
  const dernier = dernierTexteAgent(journal);
  const rienEcrit = tip === sPrep && sale.length === 0;
  const dit = dernier && RE_NON_PRIS_EN_CHARGE.test(dernier.texte);
  v.points.p7 = { refusPropre: false };
  if (rienEcrit && dit) {
    const phrase = dernier.texte.split(/\n+/).find((l) => RE_NON_PRIS_EN_CHARGE.test(l)) ?? dernier.texte;
    v.points.p7 = { refusPropre: true, raison: `l'agent s'est arrêté sans rien écrire : « ${court(phrase, 160)} »`, preuve: [`journal ligne ${dernier.n} : ${court(phrase, 300)}`, `HEAD = commit de préparation ${sPrep.slice(0, 8)}, arbre propre`] };
    note('refus propre : compte comme un échec de l\'essai (règle, point 7), noté à part');
    return terminer(travail);
  }
  if (rienEcrit) {
    echec(1, 'rien-livre', 'l\'agent n\'a rien écrit et n\'a pas dit que l\'app n\'est pas prise en charge', [`HEAD = commit de préparation ${sPrep.slice(0, 8)}`]);
  }

  // ── point 3 : dépendances (git seul, pas d'installation)
  {
    const c = comparerDependances(app, sPrep, tip);
    const legacyNpmrc = legacyDansNpmrc(app, sPrep, tip);
    const legacyVak = legacyPoseParVak(journal);
    v.points.p3 = { ok: true, fichiers: c.fichiers, notes: c.notes, legacyPoseParVak: legacyVak };
    for (const n of c.notes) note(n);
    if (c.problemes.length) {
      v.points.p3.ok = false;
      const parType = new Map();
      for (const p of c.problemes) parType.set(p.type, (parType.get(p.type) ?? 0) + 1);
      const resume = [...parType].map(([t, n]) => `${n} ${t}`).join(', ');
      echec(3, 'dependances', `une dépendance existante a bougé (${resume})`, c.problemes.slice(0, 12).map((p) => p.detail).concat(c.problemes.length > 12 ? [`… et ${c.problemes.length - 12} autre(s) (voir points.p3.problemes)`] : []));
      v.points.p3.problemes = c.problemes;
    }
    if (legacyNpmrc.length && legacyVak.length === 0) {
      v.points.p3.ok = false;
      echec(3, 'legacy-peer-deps', '--legacy-peer-deps posé dans .npmrc, sans que le journal montre vak le poser', legacyNpmrc.map((f) => `${f} contient legacy-peer-deps=true`));
    } else if (legacyNpmrc.length) note(`legacy-peer-deps dans ${legacyNpmrc.join(', ')} : permis, vak l'a posé (journal ligne ${legacyVak[0].ligne} : ${legacyVak[0].texte})`);
  }

  // ── point 4 : contournements
  {
    const p4 = { ok: true, controles: [] };
    v.points.p4 = p4;
    const ajoute = (code, resume, p) => { p4.ok = false; echec(4, code, resume, p); };
    // archive du kit intacte
    const archive = [...arbTip.keys()].find((p) => /(^|\/)vendor\/vak\/[^/]+\.tgz$/.test(p));
    if (archive) {
      const sha = sha256(gitShowBuf(app, tip, archive));
      p4.controles.push(`archive ${archive} sha256 ${sha === prep.archive.sha256 ? '= préparation' : '≠ préparation'}`);
      if (sha !== prep.archive.sha256) ajoute('archive', 'l\'archive du kit commitée n\'est plus celle de la préparation', [`${archive} : ${sha} au lieu de ${prep.archive.sha256}`]);
    }
    // migrations de l'app : empreintes comparées
    const migrationsPrep = new Map();
    for (const [p, e] of arbPrep) if (/(^|\/)migrations\/[^/]+\.sql$/.test(p) && !/_vak_/.test(p)) migrationsPrep.set(p, e.sha);
    const changees = [];
    for (const [p, sha] of migrationsPrep) {
      const e = arbTip.get(p);
      if (!e) changees.push({ p, quoi: 'supprimée' });
      else if (e.sha !== sha) changees.push({ p, quoi: 'modifiée' });
    }
    p4.controles.push(`${migrationsPrep.size} migration(s) de l'app comparées par empreinte : ${changees.length} changée(s)`);
    if (changees.length) {
      ajoute('migration', `${changees.length} migration(s) de l'app modifiée(s)`, changees.slice(0, 5).flatMap((c) => [`${c.p} ${c.quoi}`, ...(c.quoi === 'modifiée' ? git(app, ['diff', '--no-color', '-U1', sPrep, tip, '--', c.p]).split('\n').filter((l) => /^[+-][^+-]/.test(l)).slice(0, 6) : [])]));
    }
    // migrations ajoutées hors vak : rôle, extension, table
    for (const [p] of arbTip) {
      if (!/(^|\/)migrations\/[^/]+\.sql$/.test(p) || /_vak_/.test(p) || arbPrep.has(p)) continue;
      const t = gitShow(app, tip, p) || '';
      const m = /\bcreate\s+(?:or\s+replace\s+)?(?:role|user)\s+\S+|\bcreate\s+extension\b[^;\n]*|\bcreate\s+(?:unlogged\s+)?table\b[^;\n(]*/i.exec(t);
      if (m) ajoute('sql-a-la-main', `migration ajoutée à la main : ${p}`, [`${p} : ${court(m[0], 120)}`]);
      else note(`migration ajoutée par l'agent hors vak : ${p}`);
    }
    // liens symboliques
    const liens = [...arbTip].filter(([p, e]) => e.mode === '120000' && (!arbPrep.has(p) || arbPrep.get(p).sha !== e.sha)).map(([p]) => p);
    p4.controles.push(`${liens.length} lien(s) symbolique(s) nouveau(x) dans le commit`);
    if (liens.length) ajoute('lien-symbolique', `lien symbolique commité : ${liens.slice(0, 3).join(', ')}`, liens.slice(0, 5).map((p) => `${p} → ${court(gitShow(app, tip, p) ?? '?', 120)}`));
    // fichiers gérés par vak : empreintes du verrou
    const verrous = [...arbTip.keys()].filter((p) => /(^|\/)supabase\/functions\/vak\/vak\.lock\.json$/.test(p));
    const dossiersApp = [];
    const dossiersMesure = new Set();
    for (const lockPath of verrous) {
      const racineApp = lockPath.replace(/supabase\/functions\/vak\/vak\.lock\.json$/, '');
      dossiersApp.push(racineApp.replace(/\/$/, ''));
      let verrou;
      try { verrou = JSON.parse(gitShow(app, tip, lockPath)); } catch { ajoute('fichier-gere', 'vak.lock.json illisible', [lockPath]); continue; }
      // `vak init --app <dossier>` : l'app est dans un sous-dossier de la racine de vak, inscrit dans `apps` du verrou
      for (const a of Array.isArray(verrou.apps) ? verrou.apps : []) {
        const rel = path.posix.normalize(String(a)).replace(/\/$/, '');
        if (rel !== '.' && !rel.startsWith('..')) dossiersMesure.add(path.posix.join(racineApp, rel));
      }
      const alterés = [];
      const absents = [];
      let n = 0;
      for (const [cle, attendu] of Object.entries(verrou.managed ?? {})) {
        if (cle.includes('#')) continue; // blocs dans un fichier de l'app : contrôlés par `vak doctor` (VAK003)
        n++;
        const buf = gitShowBuf(app, tip, racineApp + cle);
        if (!buf) { absents.push(`${racineApp}${cle}`); continue; } // copies .claude/ ignorées par git : permis, vak doctor tranche
        const reel = `sha256:${sha256(buf)}`;
        if (reel !== attendu) alterés.push(`${racineApp}${cle} : ${reel} au lieu de ${attendu}`);
      }
      if (absents.length) note(`${absents.length} fichier(s) géré(s) par vak absent(s) du commit (ignorés par git ?) : ${absents.slice(0, 3).join(', ')}${absents.length > 3 ? '…' : ''} ; « vak doctor » (VAK001, VAK003) en juge au point 1`);
      p4.controles.push(`${n} fichier(s) géré(s) par vak vérifiés par empreinte (${lockPath}) : ${alterés.length} altéré(s)`);
      if (alterés.length) ajoute('fichier-gere', `${alterés.length} fichier(s) géré(s) par vak retouché(s)`, alterés.slice(0, 8));
    }
    v.entree.appsVak = dossiersApp;
    v.entree.dossiersMesure = dossiersMesure.size ? [...dossiersMesure].sort() : ['.'];
    // table « à moi » mise dans ignore après une sortie de vak qui la juge `non prouvé`, `total faux` ou `étroit`.
    // Après `fuite`, l'écarter avec sa raison écrite dans ignore est permis : noté, pas un échec.
    const echecs = echecsDePreuve(journal);
    p4.echecsDePreuve = echecs.map((e) => `${e.table} ${e.verdict} (journal ligne ${e.ligne})`);
    p4.fuitesEcartees = [];
    for (const racineApp of dossiersApp) {
      const dir = `${racineApp ? `${racineApp}/` : ''}supabase/functions/vak/`;
      const agent = gitShow(app, tip, `${dir}agent.ts`);
      const schema = lireSchema(gitShow(app, tip, `${dir}schema.gen.ts`));
      const ignore = lireIgnore(agent);
      const aMoi = tablesAMoi(schema);
      if (!schema) note(`schema.gen.ts illisible dans ${dir} : « table à moi » jugée sur la seule sortie de vak`);
      const fautifs = [];
      const fuites = new Map();
      for (const e of echecs) {
        if (!ignore?.has(e.table)) continue;
        if (schema && !aMoi.has(e.table)) { note(`table ${e.table} : échec de preuve puis ignore, mais pas une table « à moi » (${schema.tables[e.table] ? 'aucune colonne ne désigne l\'utilisateur' : 'absente du schéma'}) : non retenu`); continue; }
        if (e.verdict === 'fuite') { if (!fuites.has(e.table)) fuites.set(e.table, e); continue; }
        fautifs.push(e);
      }
      for (const [table, e] of fuites) {
        if (fautifs.some((f) => f.table === table)) continue; // jugée aussi non prouvé, total faux ou étroit : échec ci-dessous
        const { ligne, raison } = ignore.get(table);
        const ecartee = { table, app: racineApp || '.', journalLigne: e.ligne, journalHeure: e.heure, agentTsLigne: ligne, raison };
        p4.fuitesEcartees.push(ecartee);
        note(`table « à moi » ${table} écartée dans ignore après « fuite » (journal ligne ${e.ligne}, ${e.heure}) : permis ; ${dir}agent.ts ligne ${ligne}, ${raison ? `raison écrite : « ${court(raison, 200)} »` : 'AUCUNE raison écrite dans ignore'}`);
      }
      if (fautifs.length) {
        const uniq = [...new Map(fautifs.map((f) => [f.table, f])).values()];
        ajoute('ignore-apres-echec', `table(s) « à moi » mise(s) dans ignore après une sortie de vak qui la juge en échec : ${uniq.map((f) => `${f.table} (${f.verdict})`).join(', ')}`,
          uniq.flatMap((f) => [`journal ligne ${f.ligne} (${f.heure}) : ${f.texte}`, `${dir}agent.ts ligne ${ignore.get(f.table).ligne} : ${f.table} est dans ignore${aMoi.has(f.table) ? ` (« à moi » : ${aMoi.get(f.table)})` : ''}`]));
      }
      if (schema) {
        let recu = null;
        try { recu = JSON.parse(gitShow(app, tip, `${dir}vak-proof.json`)); } catch { /* absent */ }
        const lues = recu ? Object.keys(recu.tables ?? {}).filter((t) => aMoi.has(t)) : [];
        v.couverture = v.couverture ?? [];
        v.couverture.push({ app: racineApp || '.', tablesDeLApp: Object.keys(schema.tables).length, tablesAMoi: aMoi.size, aMoiEprouvees: lues.length, ignorees: ignore?.size ?? 0, verdictDuRecu: recu?.verdict ?? null });
        if (aMoi.size > 0 && lues.length === 0) note(`aucune table « à moi » éprouvée dans ${dir} (${aMoi.size} dans le schéma) : le point 5 échouera, vérifié à part`);
      }
    }
    // ce que l'agent a tapé
    const racineApp = /L['’]app est dans (\/\S+?)[\s ,;:.]/.exec(journal.evts.find((e) => e.genre === 'demande')?.texte ?? '')?.[1] ?? null;
    const trouves = contournements(journal, { racineApp, migrationsPrep: new Set([...migrationsPrep.keys()].map((p) => p.replace(/^.*\//, ''))) });
    p4.journal = trouves;
    const parCode = new Map();
    for (const t of trouves) { if (!parCode.has(t.code)) parCode.set(t.code, []); parCode.get(t.code).push(t); }
    const libelles = {
      force: '--force tapé par l\'agent', 'legacy-peer-deps': '--legacy-peer-deps tapé par l\'agent', 'lien-symbolique': 'lien symbolique créé à la main',
      'sql-a-la-main': 'rôle, extension ou table créé à la main', 'fichier-gere': 'fichier géré par vak retouché à la main', migration: 'migration de l\'app modifiée à la main',
    };
    for (const t of parCode.get('lien-hors-depot') ?? []) note(`lien symbolique tapé hors du dépôt de l'app (une mesure, pas un échec) : journal ligne ${t.ligne} (${t.heure}) : ${t.detail} — commande : ${court(t.commande, 200)}`);
    parCode.delete('lien-hors-depot');
    for (const [code, l] of parCode) {
      ajoute(`journal-${code}`, `${libelles[code] ?? code} (${l.length} fois)`, l.slice(0, 4).map((t) => `journal ligne ${t.ligne} (${t.heure}) : ${t.detail} — commande : ${court(t.commande, 200)}`));
    }
  }

  // ── point 6 : durée (journal)
  {
    const { agent, demande } = debutAgent(journal);
    const fini = premierVakOk(journal);
    const p6 = { ok: false, limiteMinutes: LIMITE_DUREE_MIN };
    v.points.p6 = p6;
    if (!fini) {
      echec(6, 'jamais-fini', 'aucun « vak » ne rend 0 dans le journal', ['aucune sortie « vak : fini (…) [code 0] » d\'une commande vak sans sous-commande']);
    } else if (!agent?.ts || !fini.ts) {
      echec(6, 'horodatage', 'journal sans horodatage exploitable', []);
    } else {
      const minutes = (fini.ts - agent.ts) / MIN;
      Object.assign(p6, { debut: new Date(agent.ts).toISOString(), demande: demande?.ts ? new Date(demande.ts).toISOString() : null, premierVakQuiRendZero: new Date(fini.ts).toISOString(), preuve: `${fini.source} : ${court(fini.texte, 120)}`, minutes: Math.round(minutes * 100) / 100, ligne: fini.ligne });
      p6.ok = minutes <= LIMITE_DUREE_MIN;
      if (!p6.ok) echec(6, 'duree', `${minutes.toFixed(1)} minutes (limite ${LIMITE_DUREE_MIN})`, [`début ${p6.debut} (journal ligne ${agent.n}) → vak à 0 ${p6.premierVakQuiRendZero} (journal ligne ${fini.ligne})`]);
    }
  }

  // ── points 2 et 1 : mesures sur clones propres
  // Le point 2 se mesure dans le dossier de l'app : la racine, ou le sous-dossier de `vak init --app <dossier>`.
  const dirs = v.entree.dossiersMesure ?? ['.'];
  const unSeul = dirs.length === 1;
  const lieu = (dir) => (dir === '.' ? '' : ` dans ${dir}`);
  const cleDe = (genre, dir) => (unSeul ? genre : `${genre}@${dir}`);
  const pmDe = (dir) => { // détecté sur le commit de préparation
    const pre = dir === '.' ? '' : `${dir}/`;
    if (arbPrep.has(`${pre}pnpm-lock.yaml`)) return 'pnpm';
    if (arbPrep.has(`${pre}yarn.lock`)) return 'yarn';
    if (arbPrep.has(`${pre}package-lock.json`) || arbPrep.has(`${pre}npm-shrinkwrap.json`)) return 'npm';
    return null;
  };
  const legacyVakLignes = legacyPoseParVak(journal);
  const mesures = {};
  const exemples = {};

  async function cote(nom, revision) {
    const dossier = path.join(travail, 'clones', nom);
    log(`${nom} : clone propre de ${revision.slice(0, 8)}`);
    cloner(app, revision, dossier);
    const m = { revision, dossiers: {} };
    mesures[nom] = m;
    for (const dir of dirs) {
      const cible = dir === '.' ? dossier : path.join(dossier, dir);
      const nomLog = dir === '.' ? nom : `${nom}-${dir.replace(/\W+/g, '_')}`;
      const d = { dir, pm: null };
      m.dossiers[dir] = d;
      if (!fs.existsSync(cible)) { d.installation = { ok: false, raison: `le dossier ${dir} n'existe pas dans ${nom}` }; continue; }
      d.pm = pmDe(dir) ?? gestionnaire(cible);
      if (!d.pm) { d.installation = { ok: false, raison: 'aucun verrou ni package.json' }; continue; }
      log(`${nom} : installation (${d.pm})${lieu(dir)}`);
      d.installation = await installer(cible, d.pm, logs, nomLog, nom === 'head' && legacyVakLignes.length > 0);
      if (d.installation.ok) {
        // chaque côté détecte ses propres vérifications : une vérification qui existait avant et plus après est « disparue »
        d.detectees = detecterVerifs(cible, d.pm);
        if (nom === 'prep') { exemples[dir] = envExemple(cible); d.envExemple = exemples[dir].fichier; }
        d.verifs = await mesurerVerifs(cible, d.detectees, logs, nomLog, exemples[dir]?.env ?? {});
      }
    }
    // vak se lance depuis la racine de son verrou : ses dépendances s'y installent, même si l'app est dans un sous-dossier
    m.racine = m.dossiers['.']?.installation;
    if (!m.racine) {
      const pm = gestionnaire(dossier);
      m.racine = pm ? await installer(dossier, pm, logs, `${nom}-racine`, nom === 'head' && legacyVakLignes.length > 0) : { ok: false, raison: 'aucun verrou ni package.json' };
    }
    return { dossier, m };
  }

  const prepCote = await cote('prep', sPrep);
  if (!GARDER) supprimer(prepCote.dossier);
  const headCote = await cote('head', tip);

  // point 1
  {
    const p1 = { ok: false };
    v.points.p1 = p1;
    const dossiersApp = v.entree.appsVak ?? [];
    if (dossiersApp.length === 0) {
      echec(1, 'pas-integre', 'vak n\'est pas intégré : aucun supabase/functions/vak/vak.lock.json dans le HEAD', []);
    } else if (!headCote.m.racine?.ok) {
      p1.raison = 'installation impossible';
      echec(1, 'installation', 'les dépendances du HEAD ne s\'installent pas : vak ne peut pas être lancé', headCote.m.racine?.fin ?? [headCote.m.racine?.raison]);
    } else {
      const res = await avecVerrou(() => lancerVak(headCote.dossier, dossiersApp, logs));
      p1.apps = res;
      p1.ok = res.every((r) => r.code === 0);
      for (const r of res) {
        const recu = r.fichiersReecrits?.some((f) => /vak-proof\.json$/.test(f));
        const reecrits = r.fichiersReecrits?.length ? ` ; en le lançant, vak a réécrit ${r.fichiersReecrits.slice(0, 4).join(', ')}${recu ? ' : le reçu de preuve commité n\'est pas à jour' : ' : l\'état commité n\'est pas à jour'}` : '';
        if (r.code !== 0) {
          echec(1, recu ? 'recu-perime' : 'vak-non-nul', `« vak » rend ${r.delai ? 'un dépassement de délai' : r.code} dans ${r.app}${r.derniereLigne ? ` : ${court(r.derniereLigne, 200)}` : ''}${r.raison ? ` : ${r.raison}` : ''}${reecrits}`,
            [...(r.controles ?? []).filter((l) => !l.startsWith('✓')), ...(r.fin ?? []).slice(-6), ...(r.fichiersReecrits?.length ? [`fichiers modifiés par « vak » dans un clone propre : ${r.fichiersReecrits.join(', ')}`] : [])]);
        } else if (r.fichiersReecrits?.length) {
          p1.ok = false;
          echec(1, recu ? 'recu-perime' : 'etat-perime', `${recu ? 'le reçu de preuve commité n\'est pas à jour' : 'vak a réécrit des fichiers suivis : l\'état commité n\'est pas à jour'} (${r.fichiersReecrits.slice(0, 4).join(', ')})`, [`fichiers modifiés par « vak » dans un clone propre : ${r.fichiersReecrits.join(', ')}`]);
        } else if (r.controles && !r.controles.some((l) => /^[✓!] VAK015/.test(l))) {
          note(`${r.app} : VAK015 absent de la sortie de vak (reçu non confirmé par la sortie)`);
        }
      }
    }
  }
  if (!GARDER) supprimer(headCote.dossier);

  // point 2 : comparaison avant / après, dans chaque dossier d'app
  {
    const p2 = { ok: true, dossiers: dirs, installation: {}, verifs: {} };
    v.points.p2 = p2;
    v.mesures = { prep: strip(mesures.prep), head: strip(mesures.head) };
    for (const dir of dirs) {
      const ap = mesures.prep.dossiers[dir];
      const ah = mesures.head.dossiers[dir];
      const ip = ap?.installation;
      const ih = ah?.installation;
      const ou = lieu(dir);
      const inst = { avant: ip && { ok: ip.ok, commande: ip.commande, souple: ip.souple }, apres: ih && { ok: ih.ok, commande: ih.commande, souple: ih.souple } };
      if (unSeul) p2.installation = inst; else p2.installation[dir] = inst;
      if (ip && !ip.ok && ih && !ih.ok) note(`installation impossible avant et après${ou} : vérifications non comparables`);
      else if (ip && !ip.ok) note(`installation impossible au commit de préparation${ou} (${ip.raison ?? 'échec'}) : vérifications non comparables`);
      else if (ih && !ih.ok) {
        p2.ok = false;
        echec(2, 'installation', `les dépendances s'installaient avant (verrou commité) et ne s'installent plus${ou}`, ih.fin ?? []);
      } else if (ip?.ok && ih?.ok) {
        if (ih.souple && !ip.souple) note(`installation stricte impossible au HEAD${ou} (verrou en désaccord avec package.json), réussie en mode souple : ${ih.tentatives?.map((t) => `${t.commande} → ${t.code}`).join(' ; ')}`);
        if (ih.souple && !ip.souple) { p2.ok = false; echec(2, 'verrou', `le verrou commité ne suffit plus à installer l'app${ou} (installation stricte refusée au HEAD, acceptée avant)`, ih.tentatives.map((t) => `${t.commande} → code ${t.code}`)); }
        for (const genre of Object.keys(CANDIDATS)) {
          const a = ap.verifs?.[genre];
          const b = ah.verifs?.[genre];
          const e = { avant: a && resumeV(a), apres: b && resumeV(b) };
          const cle = cleDe(genre, dir);
          const nom = `${genre}${ou}`;
          p2.verifs[cle] = e;
          if (!a && !b) { e.etat = 'absente'; continue; }
          if (a && !b) {
            e.etat = 'disparue';
            p2.ok = false;
            echec(2, `${genre}-disparue`, `${nom} : la vérification existait avant (${a.commande}) et n'existe plus`, [`avant : ${a.source}`]);
            continue;
          }
          if (!a && b) { e.etat = 'ajoutée'; note(`${nom} : absente avant, présente après (${b.commande}) : rien à comparer`); continue; }
          if (a.delai && b.delai) { e.etat = 'non comparable (délai dépassé avant et après)'; note(`${nom} : délai dépassé avant et après : non comparable`); continue; }
          if (b.delai) { e.etat = 'échec'; p2.ok = false; echec(2, `${genre}-delai`, `${nom} : délai dépassé après (${Math.round(b.ms / MIN)} min), pas avant`, b.fin); continue; }
          if (a.delai) { e.etat = 'meilleure (le délai était dépassé avant)'; continue; }
          const cmp = comparerErreurs(a.erreurs, b.erreurs);
          e.erreurs = { avant: cmp.avant, apres: cmp.apres, nouvelles: cmp.nouvelles.map((x) => `${x.fichier}:${x.ligne} ${x.brut}`) };
          if (a.generique || b.generique) e.erreurs.generique = true;
          if (a.code === 0 && b.code !== 0) {
            e.etat = 'échec';
            p2.ok = false;
            echec(2, `${genre}-code`, `${nom} : le code de sortie passe de 0 à ${b.code}`, [`${b.commande}`, ...(cmp.nouvelles.length ? cmp.nouvelles.slice(0, 6).map((x) => `${x.fichier}:${x.ligne} ${x.brut}`) : b.fin.slice(-6))]);
          } else if (cmp.allonge) {
            e.etat = 'échec';
            p2.ok = false;
            echec(2, `${genre}-erreurs`, `${nom} : ${cmp.nouvelles.length} erreur(s) nouvelle(s) (${cmp.avant} → ${cmp.apres} erreurs distinctes)`, cmp.nouvelles.slice(0, 8).map((x) => `${x.fichier}:${x.ligne} ${x.brut}`));
          } else {
            e.etat = a.code === b.code ? `identique (code ${b.code})` : `code ${a.code} → ${b.code}, sans nouvelle erreur`;
            if (a.code !== 0 && cmp.avant === 0 && cmp.apres === 0) note(`${nom} : échoue avant (code ${a.code}) et après (code ${b.code}) sans erreur reconnue : comparé par le seul code de sortie`);
          }
          if (genre === 'lint' && a.avertissements && b.avertissements && b.avertissements.avertissements > a.avertissements.avertissements) note(`${nom} : avertissements ${a.avertissements.avertissements} → ${b.avertissements.avertissements} (non bloquant : seuls les erreurs comptent)`);
        }
      }
    }
  }

  if (!GARDER) supprimer(path.join(travail, 'clones'));
  return terminer(travail);
}

const strip = (m) => m && {
  revision: m.revision,
  dossiers: Object.fromEntries(Object.entries(m.dossiers).map(([dir, d]) => [dir, {
    gestionnaire: d.pm, installation: d.installation,
    verifs: Object.fromEntries(Object.entries(d.verifs ?? {}).map(([k, x]) => [k, resumeV(x, true)])),
  }])),
  installationRacine: m.racine,
};
function resumeV(x, avecErreurs = false) {
  return {
    commande: x.commande, source: x.source, code: x.code, delai: x.delai, secondes: Math.round(x.ms / 1000), erreurs: x.erreurs.length,
    avertissements: x.avertissements, tests: x.tests, ...(avecErreurs ? { liste: x.erreurs.slice(0, 200).map((e) => `${e.fichier}:${e.ligne} ${e.brut}`), fin: x.fin } : {}),
  };
}

main().then((c) => process.exit(c), (e) => {
  console.error(e.stack || e);
  v.raisons.push({ point: 'contrôleur', code: 'plantage', resume: `le contrôleur a planté : ${e.message}`, preuve: [] });
  try { terminer(path.resolve(process.argv[3] || '.')); } catch { /* rien */ }
  process.exit(3);
});

