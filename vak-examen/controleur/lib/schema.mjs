// Lecture de la photographie du schéma (schema.gen.ts) et du calibrage (agent.ts) : quelles tables sont « à moi »,
// lesquelles sont dans `ignore`. Sert au point 4 (« une table à moi mise dans ignore pour faire passer la preuve »).

export function lireSchema(texte) {
  if (!texte) return null;
  try {
    const corps = texte
      .replace(/^\s*import[^\n]*\n/gm, '')
      .replace(/export\s+const\s+schema\s*=\s*/, 'return ')
      .replace(/\}\s*as const[^;\n]*;?\s*$/, '}');
    // eslint-disable-next-line no-new-func
    const s = new Function(corps)();
    return s?.tables ? s : null;
  } catch {
    return null;
  }
}

// Clés de premier niveau de `ignore: { … }` dans agent.ts, avec leur ligne.
export function cleIgnore(texte) {
  if (!texte) return null;
  const debut = /^\s*ignore\s*:\s*\{/m.exec(texte);
  if (!debut) return new Map();
  let i = debut.index + debut[0].length;
  let profondeur = 1;
  let q = null;
  let ligne = texte.slice(0, i).split('\n').length;
  let debutCle = true;
  const cles = new Map();
  while (i < texte.length && profondeur > 0) {
    const ch = texte[i];
    if (ch === '\n') { ligne++; debutCle = profondeur === 1; i++; continue; }
    if (q) {
      if (ch === '\\') i++;
      else if (ch === q) q = null;
      i++; continue;
    }
    if (ch === '/' && texte[i + 1] === '/') { while (i < texte.length && texte[i] !== '\n') i++; continue; }
    if (ch === '/' && texte[i + 1] === '*') { const f = texte.indexOf('*/', i + 2); i = f < 0 ? texte.length : f + 2; continue; }
    if (profondeur === 1 && debutCle) {
      const m = /^\s*(?:"([^"]+)"|'([^']+)'|([A-Za-z_$][\w$]*))\s*:/.exec(texte.slice(i, i + 200));
      if (m) { cles.set(m[1] ?? m[2] ?? m[3], ligne); debutCle = false; }
      else if (!/\s/.test(ch)) debutCle = false;
    }
    if (ch === '"' || ch === "'" || ch === '`') q = ch;
    else if (ch === '{' || ch === '[' || ch === '(') profondeur++;
    else if (ch === '}' || ch === ']' || ch === ')') profondeur--;
    else if (ch === ',' && profondeur === 1) debutCle = true;
    i++;
  }
  return cles;
}

// Définition de la règle (point 5) : une colonne désigne l'utilisateur : clé vers auth.users ou vers la table du
// compte, défaut auth.uid(), ou colonne comparée à auth.uid() par une politique.
export function tablesAMoi(schema) {
  const res = new Map(); // table -> raison
  if (!schema) return res;
  const T = schema.tables;
  const directes = new Map();
  for (const [nom, t] of Object.entries(T)) {
    if (t.kind && t.kind !== 'table') continue;
    const cols = Object.keys(t.columns ?? {});
    for (const [c, d] of Object.entries(t.columns ?? {})) {
      if (/^auth\.users\b/.test(d.references ?? '')) { directes.set(nom, `${c} → auth.users`); break; }
      if (/auth\.uid\(\)/.test(d.default ?? '')) { directes.set(nom, `${c} par défaut auth.uid()`); break; }
    }
    if (directes.has(nom)) continue;
    for (const p of t.policies ?? []) {
      for (const expr of [p.using, p.check]) {
        if (!expr) continue;
        const motifs = [
          /auth\.uid\(\)(?:\s+AS\s+\w+)?\)?\s*=\s*\(?\s*(?:\w+\.)?"?(\w+)"?/gi,
          /(?:\w+\.)?"?(\w+)"?\)?\s*=\s*\(?\s*(?:\(?\s*SELECT\s+)?auth\.uid\(\)/gi,
        ];
        for (const re of motifs) for (const m of expr.matchAll(re)) if (cols.includes(m[1])) { directes.set(nom, `${m[1]} comparée à auth.uid() (politique « ${p.name} »)`); }
      }
      if (directes.has(nom)) break;
    }
  }
  for (const [n, r] of directes) res.set(n, r);
  for (const [nom, t] of Object.entries(T)) {
    if (res.has(nom) || (t.kind && t.kind !== 'table')) continue;
    for (const [c, d] of Object.entries(t.columns ?? {})) {
      const cible = /^(?:public\.)?(\w+)\./.exec(d.references ?? '');
      if (cible && directes.has(cible[1])) { res.set(nom, `${c} → ${cible[1]} (table du compte)`); break; }
    }
  }
  return res;
}
