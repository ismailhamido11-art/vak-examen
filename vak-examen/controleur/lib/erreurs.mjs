// Point 2 : extraction des erreurs (fichier:ligne) de la sortie de typecheck, lint, tests, build, et comparaison.
import { sansCouleurs } from './outils.mjs';

// Retire le dossier du clone des chemins, pour que les deux mesures (deux clones) parlent des mêmes fichiers.
const relatif = (f, racine) => {
  let r = f.trim().replace(/\\/g, '/');
  if (racine) {
    const rr = racine.replace(/\\/g, '/').replace(/\/$/, '');
    if (r.startsWith(`${rr}/`)) r = r.slice(rr.length + 1);
  }
  return r.replace(/^\.\//, '');
};
const nettoyerMessage = (m) => m.replace(/\s+/g, ' ').replace(/\b\d+(?::\d+)?\b/g, '#').trim().slice(0, 160);

// turbo préfixe chaque ligne par « paquet:tâche: » (« app:typecheck: », « @kit/ui:lint: »).
const sansPrefixeTurbo = (l) => l.replace(/^(?:@[\w-]+\/)?[\w-]+:[a-z][\w-]*:\s?/, '');

const EXT = String.raw`(?:[cm]?[jt]sx?|vue|svelte|astro|json|css|scss)`;
const horsOutils = (f) => !/(^|\/)node_modules\//.test(f) && !/^node:/.test(f);

// Renvoie [{ fichier, ligne, sig, brut, genre }]
export function extraireErreurs(sortie, racine) {
  const lignes = sansCouleurs(sortie).split('\n').map(sansPrefixeTurbo);
  const out = [];
  const ajouter = (genre, fichier, ligne, msg, brut) => {
    const f = relatif(fichier, racine);
    if (!horsOutils(f)) return;
    out.push({ genre, fichier: f, ligne: ligne ? Number(ligne) : 0, sig: `${f}|${nettoyerMessage(msg)}`, brut: brut.trim().slice(0, 260) });
  };
  let fichierLint = null;
  let fichierTest = null;
  for (let i = 0; i < lignes.length; i++) {
    const l = lignes[i];
    let m;
    // tsc : « src/a.ts(12,5): error TS2322: … » ou « src/a.ts:12:5 - error TS2322: … »
    if ((m = /^([^\s"'<>|]+?)\((\d+),\d+\):\s+error\s+(TS\d+):\s+(.*)$/.exec(l)) || (m = /^([^\s"'<>|]+?):(\d+):\d+\s+-\s+error\s+(TS\d+):\s+(.*)$/.exec(l))) {
      ajouter('tsc', m[1], m[2], `${m[3]} ${m[4]}`, l);
      continue;
    }
    // eslint (stylish) : ligne de fichier, puis « 12:5  error  message  règle »
    if (/^\S.*\.\w+$/.test(l) && new RegExp(`\\.${EXT}$`).test(l) && !/^\s*(FAIL|PASS|at)\b/.test(l) && !/\s{2,}/.test(l)) { fichierLint = l; continue; }
    if (fichierLint && (m = /^\s+(\d+):(\d+)\s+error\s+(.*?)(?:\s{2,}(\S+))?\s*$/.exec(l))) {
      ajouter('eslint', fichierLint, m[1], `${m[4] ?? ''} ${m[3]}`, `${fichierLint} ${l.trim()}`);
      continue;
    }
    if (/^\s*$/.test(l)) { /* fin de bloc eslint */ }
    // eslint (unix / compact) : « /chemin/a.js:12:5: message [Error/règle] »
    if ((m = new RegExp(`^(.+?\\.${EXT}):(\\d+):\\d+:\\s+(.*)\\[Error\\b.*$`).exec(l))) { ajouter('eslint', m[1], m[2], m[3], l); continue; }
    // jest : « FAIL chemin » puis « ● suite › test »
    if ((m = /^\s*FAIL\s+(\S+)(?:\s+>\s+(.*))?$/.exec(l))) {
      fichierTest = m[1];
      if (m[2]) ajouter('test', fichierTest, 0, m[2], l);
      continue;
    }
    if (fichierTest && (m = /^\s*●\s+(.*?)\s*$/.exec(l)) && !/Console|Test suite failed to run/.test(m[1])) { ajouter('test', fichierTest, 0, m[1], l); continue; }
    if (fichierTest && /Test suite failed to run/.test(l)) { ajouter('test', fichierTest, 0, 'suite non exécutée', l); continue; }
    // vitest : « × nom » / « ✗ nom » sous un fichier
    if (fichierTest && (m = /^\s*[×✗✘]\s+(.*?)(?:\s+\d+ms)?\s*$/.exec(l))) { ajouter('test', fichierTest, 0, m[1], l); continue; }
    // node:assert : « AssertionError [ERR_ASSERTION]: message » puis la première pile hors node:internal
    if ((m = /^\s*(?:Assertion)?Error(?: \[[A-Z_]+\])?:\s*(.*)$/.exec(l)) && /Assertion/.test(l)) {
      let ref = null;
      for (let j = Math.max(0, i - 8); j < Math.min(lignes.length, i + 12); j++) {
        const f = new RegExp(`\\(?((?:/|\\.{1,2}/)[^\\s():]+\\.${EXT}):(\\d+):\\d+\\)?`).exec(lignes[j]);
        if (f && horsOutils(f[1])) { ref = f; break; }
      }
      ajouter('assert', ref ? ref[1] : '(inconnu)', ref ? ref[2] : 0, m[1], l);
      continue;
    }
  }
  return out;
}

// Quand rien de structuré n'est reconnu et que la commande a échoué : lignes « … erreur … fichier:ligne ».
export function extraireGenerique(sortie, racine) {
  const out = [];
  const lignes = sansCouleurs(sortie).split('\n').map(sansPrefixeTurbo);
  const re = new RegExp(`((?:\\.{0,2}/|[A-Za-z]:[\\\\/])?[\\w@./\\\\\\[\\]()+-]*?\\.${EXT})(?::|\\s*\\()(\\d+)(?:[:,]\\d+)?\\)?`);
  for (let i = 0; i < lignes.length; i++) {
    const l = lignes[i];
    const m = re.exec(l);
    if (!m || !horsOutils(m[1])) continue;
    const contexte = `${l} ${lignes[i + 1] ?? ''}`;
    if (!/error|erreur|failed|unable to resolve|cannot find|not found|unexpected/i.test(contexte)) continue;
    const f = relatif(m[1], racine);
    out.push({ genre: 'generique', fichier: f, ligne: Number(m[2]), sig: `${f}|${nettoyerMessage(contexte.replace(m[0], ''))}`, brut: l.trim().slice(0, 260) });
  }
  return out;
}

export function compterAvertissements(sortie) {
  const m = /✖\s+(\d+)\s+problems?\s+\((\d+)\s+errors?,\s+(\d+)\s+warnings?\)/.exec(sansCouleurs(sortie));
  return m ? { problemes: Number(m[1]), erreurs: Number(m[2]), avertissements: Number(m[3]) } : null;
}

export function resumeTests(sortie) {
  const t = sansCouleurs(sortie);
  const v = /Tests\s+(?:(\d+)\s+failed\s*\|\s*)?(\d+)\s+passed/.exec(t);
  if (v) return { echecs: Number(v[1] ?? 0), reussis: Number(v[2]) };
  const j = /Tests:\s+(?:(\d+)\s+failed,\s*)?(?:\d+\s+skipped,\s*)?(?:(\d+)\s+passed,\s*)?(\d+)\s+total/.exec(t);
  if (j) return { echecs: Number(j[1] ?? 0), reussis: Number(j[2] ?? 0) };
  return null;
}

// avant, après : listes d'erreurs. Une erreur est « nouvelle » si sa signature (fichier + message, sans numéros)
// est plus fréquente après qu'avant : les lignes qui bougent parce qu'on a inséré du code ne comptent pas.
export function comparerErreurs(avant, apres) {
  const compte = (l) => { const m = new Map(); for (const e of l) m.set(e.sig, (m.get(e.sig) ?? 0) + 1); return m; };
  const ca = compte(avant);
  const cb = compte(apres);
  const nouvelles = [];
  const vues = new Map();
  for (const e of apres) {
    const dejaVu = vues.get(e.sig) ?? 0;
    vues.set(e.sig, dejaVu + 1);
    if (dejaVu >= (ca.get(e.sig) ?? 0)) nouvelles.push(e);
  }
  return { avant: avant.length, apres: apres.length, nouvelles, allonge: apres.length > avant.length || nouvelles.length > 0 };
}
