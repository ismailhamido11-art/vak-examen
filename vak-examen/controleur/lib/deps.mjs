// Point 3 : les dépendances de l'app ne bougent pas. Compare, entre le commit de préparation et le HEAD, les verrous
// (npm, pnpm, yarn 1 et berry) et les package.json (+ catalogues pnpm). Seuls des ajouts sont permis.
import path from 'node:path';
import { arbre, gitShow } from './outils.mjs';

const VERROUS = new Set(['package-lock.json', 'npm-shrinkwrap.json', 'pnpm-lock.yaml', 'yarn.lock', 'bun.lock', 'bun.lockb']);
const base = (p) => p.replace(/^.*\//, '');

// ── YAML minimal : suffit pour pnpm-lock.yaml et pnpm-workspace.yaml (cartes imbriquées par indentation) ──
export function yamlLite(texte) {
  const racine = {};
  const pile = [{ indent: -1, obj: racine }];
  for (const brut of texte.split('\n')) {
    if (!brut.trim() || /^\s*#/.test(brut)) continue;
    const indent = brut.length - brut.trimStart().length;
    const ligne = brut.trim();
    if (ligne.startsWith('- ') || ligne === '-') continue;
    let cle;
    let reste;
    const q = /^(['"])((?:\\.|(?!\1).)*)\1\s*:(?:\s+(.*))?$/.exec(ligne);
    if (q) { cle = q[2].replace(/''/g, "'"); reste = q[3] ?? ''; }
    else {
      const m = /^(.*?):(?:\s+(.*)|$)/.exec(ligne);
      if (!m) continue;
      cle = m[1]; reste = m[2] ?? '';
    }
    while (pile.length > 1 && pile[pile.length - 1].indent >= indent) pile.pop();
    const parent = pile[pile.length - 1].obj;
    const v = reste.trim().replace(/^(['"])(.*)\1$/, '$2');
    if (v === '') {
      const enfant = {};
      parent[cle] = enfant;
      pile.push({ indent, obj: enfant });
    } else parent[cle] = v;
  }
  return racine;
}

const aplatirCartes = (obj, prefixe = '', out = new Map()) => {
  for (const [k, v] of Object.entries(obj || {})) {
    if (v && typeof v === 'object') aplatirCartes(v, `${prefixe}${k} › `, out);
    else out.set(`${prefixe}${k}`, String(v));
  }
  return out;
};

// ── verrous → Map id → "version [empreinte]" ──
function lireVerrou(nom, texte) {
  const m = new Map();
  if (nom === 'package-lock.json' || nom === 'npm-shrinkwrap.json') {
    const j = JSON.parse(texte);
    if (j.packages) {
      for (const [p, e] of Object.entries(j.packages)) {
        if (p === '') continue;
        m.set(p, `${e.version ?? e.resolved ?? '?'}${e.integrity ? ` ${e.integrity}` : ''}`);
      }
    } else {
      const parcourir = (deps, pre) => {
        for (const [n, e] of Object.entries(deps || {})) {
          m.set(`${pre}${n}`, `${e.version}${e.integrity ? ` ${e.integrity}` : ''}`);
          parcourir(e.dependencies, `${pre}${n} › `);
        }
      };
      parcourir(j.dependencies, '');
    }
  } else if (nom === 'pnpm-lock.yaml') {
    const y = yamlLite(texte);
    for (const [k, e] of Object.entries(y.packages || {})) m.set(`paquet ${k}`, typeof e === 'object' ? String(e.resolution ?? '') : String(e));
    const importeurs = y.importers || { '.': { dependencies: y.dependencies, devDependencies: y.devDependencies, optionalDependencies: y.optionalDependencies } };
    for (const [imp, sections] of Object.entries(importeurs)) {
      for (const [sec, deps] of Object.entries(sections || {})) {
        if (!deps || typeof deps !== 'object') continue;
        for (const [n, e] of Object.entries(deps)) {
          m.set(`${imp} › ${sec} › ${n}`, typeof e === 'object' ? `${e.specifier ?? ''} → ${e.version ?? ''}` : String(e));
        }
      }
    }
    for (const section of ['catalogs', 'overrides']) {
      for (const [k, v] of aplatirCartes(y[section])) m.set(`${section} › ${k}`, v);
    }
  } else if (nom === 'yarn.lock') {
    let entetes = [];
    for (const l of texte.split('\n')) {
      if (/^\S.*:\s*$/.test(l) && !l.startsWith('#')) {
        entetes = l.replace(/:\s*$/, '').split(/,\s*/).map((s) => s.trim().replace(/^"|"$/g, ''));
      } else if (entetes.length) {
        const v = /^\s+version:?\s+"?([^"\s]+)"?/.exec(l);
        if (v) for (const h of entetes) m.set(h, v[1]);
        const i = /^\s+(?:integrity|checksum):?\s+"?([^"\s]+)"?/.exec(l);
        if (i) for (const h of entetes) m.set(h, `${m.get(h) ?? ''} ${i[1]}`);
      }
    }
  }
  return m;
}

const SECTIONS_DEPS = ['dependencies', 'devDependencies', 'peerDependencies', 'optionalDependencies', 'overrides', 'resolutions'];

function lirePackageJson(texte) {
  const j = JSON.parse(texte);
  const m = new Map();
  for (const s of SECTIONS_DEPS) for (const [k, v] of aplatirCartes(j[s])) m.set(`${s} › ${k}`, v);
  for (const [k, v] of aplatirCartes(j.pnpm?.overrides)) m.set(`pnpm.overrides › ${k}`, v);
  for (const [k, v] of aplatirCartes(j.pnpm?.patchedDependencies)) m.set(`pnpm.patchedDependencies › ${k}`, v);
  for (const [k, v] of aplatirCartes(j.workspaces && !Array.isArray(j.workspaces) ? j.workspaces.catalog : undefined)) m.set(`workspaces.catalog › ${k}`, v);
  return m;
}

function lireWorkspace(texte) {
  const y = yamlLite(texte);
  const m = new Map();
  for (const s of ['catalog', 'catalogs', 'overrides']) for (const [k, v] of aplatirCartes(y[s])) m.set(`${s} › ${k}`, v);
  return m;
}

// avant ⊆ après : une entrée existante garde sa valeur ; seuls des ajouts sont permis.
function comparer(avant, apres) {
  const modifies = [];
  const retires = [];
  let ajouts = 0;
  for (const [k, v] of avant) {
    if (!apres.has(k)) retires.push({ id: k, avant: v });
    else if (apres.get(k) !== v) modifies.push({ id: k, avant: v, apres: apres.get(k) });
  }
  for (const k of apres.keys()) if (!avant.has(k)) ajouts++;
  return { modifies, retires, ajouts };
}

export function comparerDependances(depot, revAvant, revApres) {
  const A = arbre(depot, revAvant);
  const B = arbre(depot, revApres);
  const problemes = [];
  const notes = [];
  const fichiers = [];
  const concerne = (p) => !/(^|\/)(node_modules|vendor)\//.test(p);
  for (const p of A.keys()) {
    if (!concerne(p)) continue;
    const n = base(p);
    let genre;
    if (VERROUS.has(n)) genre = 'verrou';
    else if (n === 'package.json') genre = 'package.json';
    else if (n === 'pnpm-workspace.yaml') genre = 'workspace';
    else continue;
    if (!B.has(p)) { problemes.push({ fichier: p, type: 'supprimé', detail: `${p} existait au commit de préparation et n'est plus dans le HEAD` }); continue; }
    if (A.get(p).sha === B.get(p).sha) { fichiers.push({ fichier: p, genre, identique: true }); continue; }
    if (n === 'bun.lockb') { notes.push(`${p} (binaire) changé : non comparé`); continue; }
    let avant;
    let apres;
    try {
      const ta = gitShow(depot, revAvant, p);
      const tb = gitShow(depot, revApres, p);
      const lire = genre === 'verrou' ? (t) => lireVerrou(n, t) : genre === 'package.json' ? lirePackageJson : lireWorkspace;
      avant = lire(ta);
      apres = lire(tb);
    } catch (e) {
      notes.push(`${p} : illisible (${e.message}), non comparé`);
      continue;
    }
    const c = comparer(avant, apres);
    fichiers.push({ fichier: p, genre, ajouts: c.ajouts, modifies: c.modifies.length, retires: c.retires.length, entrees: avant.size });
    for (const x of c.modifies) problemes.push({ fichier: p, type: 'version changée', detail: `${p} : ${x.id} : ${x.avant} → ${x.apres}` });
    for (const x of c.retires) problemes.push({ fichier: p, type: 'retiré', detail: `${p} : ${x.id} (${x.avant}) n'est plus là` });
  }
  // verrou d'un autre gestionnaire ajouté
  for (const p of B.keys()) if (concerne(p) && VERROUS.has(base(p)) && !A.has(p)) notes.push(`verrou ajouté : ${p}`);
  return { problemes, notes, fichiers };
}

// Les « .npmrc » : legacy-peer-deps ajouté ?
export function legacyDansNpmrc(depot, revAvant, revApres) {
  const A = arbre(depot, revAvant);
  const B = arbre(depot, revApres);
  const out = [];
  for (const p of B.keys()) {
    if (base(p) !== '.npmrc') continue;
    const t = gitShow(depot, revApres, p) || '';
    const avant = A.has(p) ? gitShow(depot, revAvant, p) || '' : '';
    const re = /legacy[-_]peer[-_]deps\s*=\s*true/i;
    if (re.test(t) && !re.test(avant)) out.push(p);
  }
  return out;
}

export { path };
