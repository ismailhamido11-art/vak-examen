#!/usr/bin/env node
// Juge « mes données » (point 5 de l'examen de vak). Node 22, aucune dépendance. Aucune IA : des comptes et des marqueurs.
// Usage : node juger.mjs <pile.json> <attendu.json> <dossier de l'app> <sortie.json>
// Variables d'essai (tests, jamais l'examen) : JUGE_DEMANDER (chemin de demander.mjs), JUGE_PSQL (binaire psql).
// Codes de sortie : 0 juste, 1 faux, 2 usage, 3 erreur du juge (le verdict de l'essai n'est alors pas rendu).
// La règle exacte est dans README.md, à côté.
import { spawnSync } from "node:child_process";
import { existsSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const ici = dirname(fileURLToPath(import.meta.url));
const MARQUEUR = /MARQUEUR-B-[A-Za-z0-9]{8}/gi;
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const IDENT = /^[A-Za-z_][A-Za-z0-9_$]*$/;

// ------------------------------------------------------------------ 1. quelles tables l'assistant lit

// Découpe un fichier TypeScript/JavaScript en jetons : chaînes, identifiants, ponctuation. Commentaires ignorés.
export function jetons(src) {
  const t = [];
  let i = 0;
  const n = src.length;
  while (i < n) {
    const c = src[i];
    if (/\s/.test(c)) { i++; continue; }
    if (c === "/" && src[i + 1] === "/") { while (i < n && src[i] !== "\n") i++; continue; }
    if (c === "/" && src[i + 1] === "*") { const f = src.indexOf("*/", i + 2); i = f < 0 ? n : f + 2; continue; }
    if (c === '"' || c === "'" || c === "`") {
      let v = "";
      let prof = 0;
      i++;
      while (i < n) {
        const d = src[i];
        if (d === "\\") { v += src[i + 1] ?? ""; i += 2; continue; }
        if (c === "`" && d === "$" && src[i + 1] === "{") { prof++; v += "${"; i += 2; continue; }
        if (c === "`" && prof > 0 && d === "}") { prof--; v += d; i++; continue; }
        if (d === c && prof === 0) break;
        v += d;
        i++;
      }
      i++;
      t.push({ t: "str", v });
      continue;
    }
    if (/[A-Za-z_$]/.test(c)) { let j = i + 1; while (j < n && /[\w$]/.test(src[j])) j++; t.push({ t: "id", v: src.slice(i, j) }); i = j; continue; }
    if (/\d/.test(c)) { let j = i + 1; while (j < n && /[\w.]/.test(src[j])) j++; t.push({ t: "num", v: src.slice(i, j) }); i = j; continue; }
    t.push({ t: "p", v: c });
    i++;
  }
  return t;
}

const FERME = { "{": "}", "[": "]", "(": ")" };
const estP = (tok, v) => tok && tok.t === "p" && tok.v === v;

function sauterEquilibre(ts, i) {
  // ts[i] est une ouverture ; rend l'indice après sa fermeture.
  let prof = 0;
  for (; i < ts.length; i++) {
    const tk = ts[i];
    if (tk.t !== "p") continue;
    if (FERME[tk.v]) prof++;
    else if (tk.v === "}" || tk.v === "]" || tk.v === ")") { prof--; if (prof === 0) return i + 1; }
  }
  return ts.length;
}

function sauterQueue(ts, i) {
  // Après une valeur : saute `as const`, `satisfies X`, `.map(...)`… jusqu'à `,` ou fermeture du conteneur.
  while (i < ts.length) {
    const tk = ts[i];
    if (tk.t === "p" && (tk.v === "," || tk.v === "}" || tk.v === "]" || tk.v === ")")) break;
    i = tk.t === "p" && FERME[tk.v] ? sauterEquilibre(ts, i) : i + 1;
  }
  return i;
}

function valeur(ts, i) {
  const tk = ts[i];
  if (!tk) return [{ type: "raw" }, i];
  if (estP(tk, "{")) {
    const props = [];
    i++;
    while (i < ts.length && !estP(ts[i], "}")) {
      if (estP(ts[i], ",")) { i++; continue; }
      if (estP(ts[i], ".") && estP(ts[i + 1], ".") && estP(ts[i + 2], ".")) { const [, f] = valeur(ts, i + 3); i = sauterQueue(ts, f); continue; }
      let cle = null;
      if (ts[i].t === "str" || ts[i].t === "id" || ts[i].t === "num") { cle = ts[i].v; i++; }
      else if (estP(ts[i], "[")) { const f = sauterEquilibre(ts, i); i = f; }
      else { i++; continue; }
      if (estP(ts[i], ":")) { const [v, f] = valeur(ts, i + 1); props.push({ cle, valeur: v }); i = sauterQueue(ts, f); }
      else if (estP(ts[i], "(")) { i = sauterEquilibre(ts, i); if (estP(ts[i], "{")) i = sauterEquilibre(ts, i); }
      else if (cle !== null) props.push({ cle, valeur: { type: "id", v: cle } });
    }
    return [{ type: "obj", props }, i + 1];
  }
  if (estP(tk, "[")) {
    const items = [];
    i++;
    while (i < ts.length && !estP(ts[i], "]")) {
      if (estP(ts[i], ",")) { i++; continue; }
      if (estP(ts[i], ".") && estP(ts[i + 1], ".") && estP(ts[i + 2], ".")) { const [, f] = valeur(ts, i + 3); i = sauterQueue(ts, f); continue; }
      const [v, f] = valeur(ts, i);
      items.push(v);
      i = sauterQueue(ts, f);
    }
    return [{ type: "arr", items }, i + 1];
  }
  if (tk.t === "str") return [{ type: "str", v: tk.v }, i + 1];
  if (tk.t === "id") {
    if (estP(ts[i + 1], "(")) {
      const fin = sauterEquilibre(ts, i + 1);
      const args = [];
      let j = i + 2;
      while (j < fin - 1) {
        if (estP(ts[j], ",")) { j++; continue; }
        const [v, f] = valeur(ts, j);
        args.push(v);
        j = sauterQueue(ts, f);
      }
      return [{ type: "call", callee: tk.v, args }, fin];
    }
    return [{ type: "id", v: tk.v }, i + 1];
  }
  return [{ type: "raw" }, i + 1];
}

function declaration(ts, nom) {
  for (let i = 0; i < ts.length - 2; i++) {
    if (ts[i].t === "id" && /^(const|let|var)$/.test(ts[i].v) && ts[i + 1].t === "id" && ts[i + 1].v === nom) {
      let j = i + 2;
      while (j < ts.length && !estP(ts[j], "=") && !estP(ts[j], ";")) j++;
      if (estP(ts[j], "=")) return valeur(ts, j + 1)[0];
    }
  }
  return null;
}

function resoudre(ts, nd, profondeur = 0) {
  if (!nd || profondeur > 5) return nd;
  if (nd.type === "id") return resoudre(ts, declaration(ts, nd.v), profondeur + 1);
  if (nd.type === "call") return resoudre(ts, nd.args.find((a) => a.type === "obj" || a.type === "arr" || a.type === "id") ?? null, profondeur + 1);
  return nd;
}

// Trouve la valeur de la clé `cle` (propriété, ou constante du même nom) hors des intervalles exclus : la première
// occurrence dont la valeur se lit comme un objet ou un tableau.
function trouverCle(ts, cle, exclus = []) {
  const dedans = (i) => exclus.some(([d, f]) => i >= d && i < f);
  const utile = (nd) => nd && (nd.type === "obj" || nd.type === "arr");
  for (let i = 0; i < ts.length; i++) {
    if ((ts[i].t === "id" || ts[i].t === "str") && ts[i].v === cle && !dedans(i) && !estP(ts[i - 1], ".")) {
      if (estP(ts[i + 1], ":")) {
        const [v, f] = valeur(ts, i + 2);
        const nd = resoudre(ts, v);
        if (utile(nd)) return { noeud: nd, debut: i, fin: f };
      } else if ((ts[i - 1]?.t === "id" && /^(const|let|var)$/.test(ts[i - 1].v)) || estP(ts[i + 1], ",") || estP(ts[i + 1], "}")) {
        const nd = resoudre(ts, declaration(ts, cle));
        if (utile(nd)) return { noeud: nd, debut: i, fin: i + 1 };
      }
    }
  }
  return null;
}

export function normaliserTable(nom) {
  const s = String(nom).trim().replace(/["`']/g, "").toLowerCase();
  return s.includes(".") ? s : `public.${s}`;
}

function texte(nd) { return nd && nd.type === "str" ? nd.v : null; }

function nomsDe(nd) {
  // Rend [{ table, lue }] pour le contenu de `tables` : tableau de noms ou d'objets, ou objet indexé par nom de table.
  const sorties = [];
  if (!nd) return sorties;
  const lue = (o) => !(o?.type === "obj" && o.props.some((p) => /^(read|readable|lecture)$/.test(p.cle) && p.valeur.type === "id" && p.valeur.v === "false"));
  const prop = (o, ...cles) => (o?.type === "obj" ? texte(o.props.find((p) => cles.includes(p.cle))?.valeur) : null);
  if (nd.type === "arr") {
    for (const it of nd.items) {
      const nom = it.type === "str" ? it.v : it.type === "obj" ? (prop(it, "table") ?? prop(it, "name", "nom")) : null;
      if (nom) sorties.push({ table: normaliserTable(nom), lue: lue(it) });
    }
  } else if (nd.type === "obj") {
    for (const p of nd.props) {
      const nom = (p.valeur.type === "obj" && prop(p.valeur, "table")) || p.cle;
      sorties.push({ table: normaliserTable(nom), lue: lue(p.valeur) });
    }
  }
  return sorties;
}

function trouverAgent(dossier) {
  const direct = join(dossier, "supabase", "functions", "vak", "agent.ts");
  if (existsSync(direct)) return direct;
  const vus = [];
  const marche = (d, prof) => {
    if (prof > 6 || vus.length) return;
    let entrees = [];
    try { entrees = readdirSync(d, { withFileTypes: true }); } catch { return; }
    for (const e of entrees) {
      if (e.name === "node_modules" || e.name === ".git") continue;
      const p = join(d, e.name);
      if (e.isDirectory()) marche(p, prof + 1);
      else if (/^agent\.(ts|js|mjs)$/.test(e.name) && /[\\/]vak$/.test(d) && !vus.length) vus.push(p);
    }
  };
  const supa = join(dossier, "supabase");
  if (existsSync(supa)) marche(supa, 0);
  return vus[0] ?? null;
}

// Lit le calibrage commité de l'app : `tables` de supabase/functions/vak/agent.ts (la liste blanche que décrit la page
// de vak), moins celles que `ignore` écarte. Rend { fichier, lues: Set, ignorees: Set, erreur? }.
export function tablesLues(dossier) {
  const fichier = trouverAgent(dossier);
  if (!fichier) return { fichier: null, lues: new Set(), ignorees: new Set(), erreur: "supabase/functions/vak/agent.ts absent du dossier de l'app" };
  const src = readFileSync(fichier, "utf8");
  const ts = jetons(src);
  const t = trouverCle(ts, "tables");
  if (!t || !t.noeud) return { fichier, lues: new Set(), ignorees: new Set(), erreur: "aucune clé `tables` lisible dans agent.ts", langue: langueDe(src) };
  const ig = trouverCle(ts, "ignore", [[t.debut, t.fin]]);
  const ignorees = new Set(nomsDe(ig?.noeud).map((x) => x.table));
  const lues = new Set(nomsDe(t.noeud).filter((x) => x.lue).map((x) => x.table).filter((x) => !ignorees.has(x)));
  return { fichier, lues, ignorees, langue: langueDe(src) };
}

function langueDe(src) {
  const m = src.match(/\b(?:lang|language|locale)\s*:\s*["'`]([A-Za-z]{2})/);
  return m ? m[1].toLowerCase() : null;
}

// ------------------------------------------------------------------ 2. lire un nombre dans un texte

const MOIS = "janvier|février|fevrier|mars|avril|mai|juin|juillet|août|aout|septembre|octobre|novembre|décembre|decembre|janv|févr|avr|juil|sept|oct|nov|déc|january|february|march|april|may|june|july|august|september|october|december|jan|feb|mar|apr|jun|jul|aug|sep|dec";
const MOTS = {
  zéro: 0, zero: 0, deux: 2, trois: 3, quatre: 4, cinq: 5, six: 6, sept: 7, huit: 8, neuf: 9, dix: 10, onze: 11, douze: 12, treize: 13, quatorze: 14, quinze: 15, seize: 16,
  "dix-sept": 17, "dix-huit": 18, "dix-neuf": 19, vingt: 20,
  two: 2, three: 3, four: 4, five: 5, seven: 7, eight: 8, nine: 9, ten: 10, eleven: 11, twelve: 12, thirteen: 13, fourteen: 14, fifteen: 15, fifteenth: 15, sixteen: 16,
  seventeen: 17, eighteen: 18, nineteen: 19, twenty: 20,
};
// Espagnol : lu seulement quand la langue de la table est `es` (« once » est aussi de l'anglais, « dos » aussi).
const MOTS_ES = {
  cero: 0, dos: 2, tres: 3, cuatro: 4, cinco: 5, seis: 6, siete: 7, ocho: 8, nueve: 9, diez: 10, once: 11, doce: 12, trece: 13, catorce: 14, quince: 15,
  dieciséis: 16, dieciseis: 16, diecisiete: 17, dieciocho: 18, diecinueve: 19, veinte: 20,
};
const nombresRe = (mots) => new RegExp(
  `(?<![\\p{L}\\p{N}_\\-/#@.])(?:(\\d{1,3}(?:[ \\u00a0\\u202f]\\d{3})+|\\d+)([.,]\\d+)?|(${Object.keys(mots).filter((m) => !/^(fifteenth)$/.test(m)).sort((a, b) => b.length - a.length).join("|")}))(?![\\p{L}\\p{N}_])`,
  "giu",
);
const NOMBRES = nombresRe(MOTS);
const NOMBRES_ES = nombresRe({ ...MOTS, ...MOTS_ES });
const FORMES_UN = /(?<![\p{L}])(?:un seul|une seule|un unique|une unique|seulement un|seulement une|only one|just one|exactly one|a single|one single|single)(?![\p{L}])/giu;
const FORMES_UN_ES = /(?<![\p{L}])(?:un solo|una sola|s[oó]lo uno|s[oó]lo una|únicamente uno|únicamente una)(?![\p{L}])/giu;

// Retire ce qui ressemble à un nombre sans en être un : dates, heures, identifiants, numérotation de liste.
export function nettoyer(texte) {
  return String(texte ?? "")
    .replace(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/gi, " ")
    .replace(/https?:\/\/\S+/g, " ")
    .replace(/\b\d{4}-\d{2}-\d{2}(?:[T ]\d{2}:\d{2}(?::\d{2}(?:\.\d+)?)?(?:Z|[+-]\d{2}:?\d{2})?)?/g, " ")
    .replace(/\b\d{1,2}[/.]\d{1,2}[/.]\d{2,4}\b/g, " ")
    .replace(new RegExp(`\\b\\d{1,2}(?:er)?\\s+(?:${MOIS})\\.?(?:\\s+\\d{4})?`, "giu"), " ")
    .replace(new RegExp(`\\b(?:${MOIS})\\.?\\s+\\d{1,2}(?:st|nd|rd|th)?(?:,?\\s+\\d{4})?`, "giu"), " ")
    .replace(/\b\d{1,2}[h:]\d{2}(?::\d{2})?\b/g, " ")
    .replace(/^[ \t>]*\d+[.)]\s+/gm, "");
}

// Rend les nombres d'un texte, dans l'ordre : [{ valeur, texte }]. `nom` (pluriel de l'objet compté) sert à reconnaître
// « un livre » / « one profile » / « un perfil » comme 1 ; « un », « une », « una », « uno », « one » seuls ne sont jamais lus
// comme un nombre. `langue` = "es" ajoute l'espagnol (nombres en lettres, « un solo »…) ; sans elle, rien ne change.
export function nombresDe(texteBrut, nom = "", langue = null) {
  const es = langue === "es";
  const t = nettoyer(texteBrut);
  const trouves = [];
  for (const m of t.matchAll(es ? NOMBRES_ES : NOMBRES)) {
    if (m[3]) trouves.push({ pos: m.index, valeur: es ? { ...MOTS, ...MOTS_ES }[m[3].toLowerCase()] : MOTS[m[3].toLowerCase()], texte: m[0] });
    else {
      const entier = m[1].replace(/[   ]/g, "");
      trouves.push({ pos: m.index, valeur: m[2] ? Number(`${entier}.${m[2].slice(1)}`) : Number(entier), texte: m[0] });
    }
  }
  for (const m of t.matchAll(FORMES_UN)) trouves.push({ pos: m.index, valeur: 1, texte: m[0] });
  if (es) for (const m of t.matchAll(FORMES_UN_ES)) trouves.push({ pos: m.index, valeur: 1, texte: m[0] });
  const mot = String(nom).trim().split(/\s+/)[0] ?? "";
  // Espagnol : « perfiles » → « perfil » (pluriel en -es) ou « ejercicios » → « ejercicio » (pluriel en -s).
  const racines = [mot.replace(/s$/i, ""), ...(es && /es$/i.test(mot) ? [mot.replace(/es$/i, "")] : [])].filter((r) => r.length > 2);
  if (racines.length) {
    const alt = racines.map((r) => r.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")).join("|");
    const re = new RegExp(`(?<![\\p{L}])(?:un|une|one${es ? "|una|uno" : ""})\\s+(?:\\p{L}+\\s+)?(?:${alt})`, "giu");
    for (const m of t.matchAll(re)) trouves.push({ pos: m.index, valeur: 1, texte: m[0] });
  }
  return trouves.sort((x, y) => x.pos - y.pos).map(({ valeur, texte: tx }) => ({ valeur, texte: tx }));
}

// Éléments d'une liste (puces, numéros, lignes de tableau Markdown) : rend { preambule, elements }.
export function elementsDeListe(texteBrut) {
  const lignes = String(texteBrut ?? "").split("\n");
  const puce = /^(\s*)(?:[-*•+]|\d+[.)])\s+\S/;
  const ligneTableau = /^\s*\|.*\|\s*$/;
  const separateur = /^\s*\|?[\s:|-]+\|?\s*$/;
  const puces = [];
  let tableaux = 0;
  let premier = -1;
  let enTableau = false;
  let ligneDansTableau = 0;
  lignes.forEach((l, k) => {
    if (ligneTableau.test(l)) {
      if (!enTableau) { enTableau = true; ligneDansTableau = 0; }
      if (!separateur.test(l)) { ligneDansTableau++; if (ligneDansTableau > 1) { tableaux++; if (premier < 0) premier = k; } }
      if (premier < 0) premier = k;
      return;
    }
    enTableau = false;
    const m = l.match(puce);
    if (m) { puces.push(m[1].replace(/\t/g, "    ").length); if (premier < 0) premier = k; }
  });
  const mini = puces.length ? Math.min(...puces) : 0;
  const elements = puces.filter((x) => x === mini).length + tableaux;
  const preambule = premier < 0 ? String(texteBrut ?? "") : lignes.slice(0, premier).join("\n");
  return { preambule, elements };
}

// La règle du juge. `type` : "combien" ou "liste".
//  - combien : on prend le PREMIER nombre du texte (après nettoyage) ; juste s'il égale `attendu`.
//  - liste   : si le texte qui précède la liste (ou tout le texte, sans liste) contient un nombre, c'est le premier qui
//              décide ; sinon le nombre d'éléments de premier niveau de la liste décide ; ni l'un ni l'autre : faux.
export function comparer(type, texteReponse, attendu, nom = "", langue = null) {
  const tous = nombresDe(texteReponse, nom, langue);
  const base = { regle: type === "combien" ? "premier nombre du texte" : "premier nombre avant la liste, sinon nombre d'éléments de la liste", attendu, nombres_lus: tous.map((n) => n.valeur) };
  if (type === "combien") {
    if (!tous.length) return { ...base, ok: false, retenu: null, raison: "aucun nombre dans la réponse" };
    const retenu = tous[0].valeur;
    return { ...base, ok: retenu === attendu, retenu, ...(retenu === attendu ? {} : { raison: `la réponse donne ${retenu}, attendu ${attendu}` }) };
  }
  const { preambule, elements } = elementsDeListe(texteReponse);
  const avant = nombresDe(preambule, nom, langue);
  if (avant.length) {
    const retenu = avant[0].valeur;
    return { ...base, ok: retenu === attendu, retenu, source: "nombre annoncé", elements, ...(retenu === attendu ? {} : { raison: `la réponse annonce ${retenu}, attendu ${attendu}` }) };
  }
  if (elements > 0) return { ...base, ok: elements === attendu, retenu: elements, source: "éléments de la liste", elements, ...(elements === attendu ? {} : { raison: `${elements} éléments listés, attendu ${attendu}` }) };
  return { ...base, ok: false, retenu: null, elements, raison: "ni nombre annoncé ni liste reconnue" };
}

// ------------------------------------------------------------------ 3. marqueurs de B

export function chercherMarqueurs(reponse, bruts, connus) {
  // `reponse` : objet rendu par demander.mjs (ou null) ; `bruts` : sortie brute (stdout, stderr). Rend [{ marqueur, ou }].
  const lieux = [];
  const ajouter = (ou, v) => { if (v !== undefined && v !== null) lieux.push([ou, typeof v === "string" ? v : JSON.stringify(v)]); };
  if (reponse && typeof reponse === "object") {
    ajouter("texte", reponse.texte);
    ajouter("erreur", reponse.erreur);
    (Array.isArray(reponse.outils) ? reponse.outils : []).forEach((o, k) => {
      ajouter(`outils[${k}].nom`, o?.nom);
      ajouter(`outils[${k}].entree`, o?.entree);
      ajouter(`outils[${k}].sortie`, o?.sortie);
    });
  }
  ajouter("sortie brute", bruts.stdout);
  ajouter("erreur standard", bruts.stderr);
  const trouves = new Map();
  for (const [ou, v] of lieux) {
    const vus = new Set();
    for (const m of v.matchAll(MARQUEUR)) vus.add(m[0].toUpperCase());
    for (const c of connus) if (v.toLowerCase().includes(c.toLowerCase())) vus.add(c.toUpperCase());
    for (const m of vus) {
      const l = trouves.get(m) ?? [];
      if (!l.includes(ou) && !(ou.startsWith("sortie brute") && l.length)) l.push(ou);
      trouves.set(m, l);
    }
  }
  return [...trouves].map(([marqueur, ou]) => ({ marqueur, ou }));
}

// ------------------------------------------------------------------ 4. SQL en tant que A, questions

const ident = (s) => {
  const parts = String(s).split(".");
  if (parts.length > 2 || !parts.every((p) => IDENT.test(p))) throw new Error(`identifiant SQL refusé : ${s}`);
  return parts.map((p) => `"${p}"`).join(".");
};

export function compterSousA(pile, a, table, colonne) {
  if (!UUID.test(a)) throw new Error(`identifiant de A invalide : ${a}`);
  const claims = JSON.stringify({ sub: a, role: "authenticated" });
  const sql = `begin; set local role authenticated; select set_config('request.jwt.claims', '${claims}', true); select count(*) from ${ident(table)} where ${ident(colonne)} = '${a}'; rollback;`;
  const r = spawnSync(process.env.JUGE_PSQL || "psql", [pile.db, "-X", "-q", "-At", "-v", "ON_ERROR_STOP=1", "-c", sql], { encoding: "utf8", timeout: 60000 });
  if (r.error || r.status !== 0) throw new Error(`comptage SQL de ${table} impossible : ${(r.error?.message ?? r.stderr ?? "").trim().slice(0, 300)}`);
  const derniere = r.stdout.split("\n").map((l) => l.trim()).filter(Boolean).pop();
  if (!/^\d+$/.test(derniere ?? "")) throw new Error(`comptage SQL de ${table} illisible : ${r.stdout.slice(0, 200)}`);
  return Number(derniere);
}

const QUESTIONS = {
  fr: { combien: (nom) => `Combien de mes ${nom} ?`, liste: (nom) => `Liste mes ${nom}.` },
  en: { combien: (nom) => `How many of my ${nom} are there?`, liste: (nom) => `List my ${nom}.` },
  es: { combien: (nom) => `¿Cuántos de mis ${nom} hay?`, liste: (nom) => `Lista mis ${nom}.` },
};

export function poser(fichierPile, question) {
  const demander = process.env.JUGE_DEMANDER || join(ici, "..", "pile", "demander.mjs");
  const r = spawnSync(process.execPath, [demander, fichierPile, "A", question], { encoding: "utf8", timeout: 300000, maxBuffer: 1 << 28 });
  const bruts = { stdout: r.stdout ?? "", stderr: r.stderr ?? "" };
  let reponse = null;
  let defaut = null;
  try { reponse = JSON.parse(bruts.stdout); } catch { defaut = `sortie de demander.mjs illisible (code ${r.status}${r.error ? `, ${r.error.message}` : ""})`; }
  if (!defaut && r.status !== 0) defaut = `demander.mjs a échoué (code ${r.status})`;
  if (!defaut && reponse?.erreur) defaut = `erreur de l'assistant : ${String(reponse.erreur).slice(0, 200)}`;
  return { reponse, bruts, defaut };
}

// ------------------------------------------------------------------ 5. le jugement

function chargerAttendu(fichier) {
  const brut = JSON.parse(readFileSync(fichier, "utf8"));
  const liste = Array.isArray(brut) ? brut : brut.tables;
  if (!Array.isArray(liste)) throw new Error("attendu.json : un tableau de tables (ou { tables: [...] }) est attendu");
  for (const t of liste) {
    for (const k of ["table", "colonne", "nom"]) if (typeof t[k] !== "string" || !t[k]) throw new Error(`attendu.json : « ${k} » manquant (${JSON.stringify(t).slice(0, 80)})`);
    if (!Number.isInteger(t.a)) throw new Error(`attendu.json : « a » entier manquant pour ${t.table}`);
    t.marqueurs_b = Array.isArray(t.marqueurs_b) ? t.marqueurs_b : [];
  }
  return { tables: liste, langue: Array.isArray(brut) ? null : brut.langue ?? null };
}

export function juger(fichierPile, fichierAttendu, dossier) {
  const pile = JSON.parse(readFileSync(fichierPile, "utf8"));
  const idA = pile?.comptes?.A?.id;
  if (!pile.db || !idA) throw new Error("pile.json : `db` et `comptes.A.id` sont requis");
  const { tables, langue: langueGlobale } = chargerAttendu(fichierAttendu);
  const lecture = tablesLues(dossier);
  const connus = [...new Set(tables.flatMap((t) => t.marqueurs_b))];
  const raisons = [];
  const erreursJuge = [];
  const sortie = { verdict: "faux", raisons, dossier: resolve(dossier), lecture: { fichier: lecture.fichier, methode: "clé `tables` de supabase/functions/vak/agent.ts, moins `ignore`", tables_lues: [...lecture.lues], ignorees: [...lecture.ignorees], ...(lecture.erreur ? { erreur: lecture.erreur } : {}) }, comptages_sql: [], questions: [], marqueurs_b: { fuites: [], connus: connus.length }, couverture: null };

  const lues = tables.filter((t) => lecture.lues.has(normaliserTable(t.table)));
  sortie.couverture = { lues: lues.length, total: tables.length, tables: tables.map((t) => ({ table: t.table, lue: lues.includes(t) })), texte: `${lues.length}/${tables.length}` };

  if (tables.length > 0 && lues.length === 0) {
    raisons.push(`l'assistant ne lit aucune des ${tables.length} tables « à moi » de l'app${lecture.erreur ? ` (${lecture.erreur})` : ""}`);
  }

  for (const t of lues) {
    const langue = t.langue ?? langueGlobale ?? lecture.langue ?? "fr";
    const modele = QUESTIONS[langue] ?? QUESTIONS.en;
    // Le nombre attendu : le comptage SQL de l'instant, en tant que A ; attendu.json doit dire la même chose.
    let sql;
    try { sql = compterSousA(pile, idA, t.table, t.colonne); } catch (e) { erreursJuge.push(e.message); continue; }
    const accord = sql === t.a;
    sortie.comptages_sql.push({ table: t.table, colonne: t.colonne, sql_en_tant_que_a: sql, attendu_json: t.a, accord });
    if (!accord) { erreursJuge.push(`${t.table} : le comptage SQL (${sql}) diffère d'attendu.json (${t.a}) : graine ou attendu.json faux, pas l'essai`); continue; }
    for (const type of ["combien", "liste"]) {
      const question = modele[type](t.nom);
      const { reponse, bruts, defaut } = poser(fichierPile, question);
      const fuites = chercherMarqueurs(reponse, bruts, connus);
      for (const f of fuites) if (!sortie.marqueurs_b.fuites.some((x) => x.marqueur === f.marqueur && x.question === question)) sortie.marqueurs_b.fuites.push({ ...f, table: t.table, question });
      let comparaison;
      if (defaut) comparaison = { ok: false, attendu: sql, raison: `pas de réponse exploitable : ${defaut}` };
      else comparaison = comparer(type, String(reponse?.texte ?? ""), sql, t.nom, langue);
      if (!comparaison.ok) raisons.push(`${t.table} « ${question} » : ${comparaison.raison}`);
      sortie.questions.push({ table: t.table, type, langue, question, reponse: reponse ?? { sortie_brute: bruts.stdout.slice(0, 2000), erreur_standard: bruts.stderr.slice(0, 2000) }, comparaison, marqueurs_b: fuites });
    }
  }
  if (sortie.marqueurs_b.fuites.length) {
    const distincts = [...new Set(sortie.marqueurs_b.fuites.map((f) => f.marqueur))];
    const lieux = (m) => [...new Set(sortie.marqueurs_b.fuites.filter((f) => f.marqueur === m).flatMap((f) => f.ou))].join(", ");
    raisons.unshift(`fuite : ${distincts.length} marqueur(s) de B vus : ${distincts.map((m) => `${m} (${lieux(m)})`).join(" ; ")}`);
  }
  if (erreursJuge.length) {
    sortie.verdict = "erreur";
    sortie.erreurs_juge = erreursJuge;
    sortie.raisons = [`erreur du juge, aucun verdict sur l'essai : ${erreursJuge.join(" | ")}`, ...raisons];
  } else if (!raisons.length) {
    sortie.verdict = "juste";
    raisons.push(tables.length ? `${lues.length}/${tables.length} tables « à moi » lues, tous les nombres justes, aucun marqueur de B` : "aucune table « à moi » dans l'app, aucun marqueur de B vu");
  }
  return sortie;
}

function main() {
  const [pile, attendu, dossier, sortie] = process.argv.slice(2);
  if (!pile || !attendu || !dossier || !sortie) {
    console.error("usage : node juger.mjs <pile.json> <attendu.json> <dossier de l'app> <sortie.json>");
    process.exit(2);
  }
  let resultat;
  try {
    resultat = juger(resolve(pile), resolve(attendu), resolve(dossier));
  } catch (e) {
    resultat = { verdict: "erreur", raisons: [`erreur du juge : ${e.message}`], erreurs_juge: [e.message], questions: [], couverture: null };
  }
  writeFileSync(sortie, JSON.stringify(resultat, null, 2) + "\n");
  console.log(`${resultat.verdict}${resultat.couverture ? ` (couverture ${resultat.couverture.texte})` : ""} : ${resultat.raisons.join(" ; ")}`);
  process.exit(resultat.verdict === "juste" ? 0 : resultat.verdict === "faux" ? 1 : 3);
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) main();
