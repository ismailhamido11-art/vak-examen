// Tests des briques du contrôleur : node --test controleur/tests/
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';
import { comparerDependances } from '../lib/deps.mjs';
import { comparerErreurs, extraireErreurs } from '../lib/erreurs.mjs';
import { contournements, echecsDePreuve, premierVakOk } from '../lib/journal.mjs';
import { cleIgnore, lireSchema, tablesAMoi } from '../lib/schema.mjs';

const ici = path.dirname(fileURLToPath(import.meta.url));

// ── journal : contournements ──
const journalDe = (...cmds) => ({ evts: cmds.map((c, i) => ({ n: i + 1, ts: 0, genre: 'outil', id: `t${i}`, nom: 'Bash', entree: { command: c } })), outils: new Map() });
const codes = (cmd, opts) => contournements(journalDe(cmd), opts).map((x) => x.code);

test('journal : --force et --legacy-peer-deps', () => {
  assert.deepEqual(codes('cd app && npm install --force'), ['force']);
  assert.deepEqual(codes('npx -y --package=/x.tgz vak init --force'), ['force']);
  assert.deepEqual(codes('bash -lc "npm i --force"'), ['force']);
  assert.deepEqual(codes('npm ci --legacy-peer-deps 2>&1 | tail'), ['legacy-peer-deps']);
  assert.deepEqual(codes('npm_config_legacy_peer_deps=true npm i'), ['legacy-peer-deps']);
  assert.deepEqual(codes('echo "legacy-peer-deps=true" >> .npmrc'), ['legacy-peer-deps']);
  // lectures et outils sans rapport : pas de faux positif
  assert.deepEqual(codes('grep -rn -- "--force" docs; cat FAQ.md | grep legacy-peer-deps'), []);
  assert.deepEqual(codes('git worktree remove --force /tmp/base'), []);
  assert.deepEqual(codes('rm -rf node_modules && npm ci'), []);
});

test('journal : lien symbolique, SQL à la main, fichiers gérés', () => {
  assert.deepEqual(codes('ln -s /a /b'), ['lien-symbolique']);
  assert.deepEqual(codes('ln -sf /a /b'), ['lien-symbolique']);
  assert.deepEqual(codes('ln /a /b'), []);
  // hors du dépôt de l'app (dossier jetable) : noté, pas un échec ; dans le dépôt ou dans le doute : échec
  const app = { racineApp: '/work/x/app' };
  assert.deepEqual(codes('ln -s $PWD/node_modules /tmp/base/node_modules', app), ['lien-hors-depot']);
  assert.deepEqual(codes('cd /work/x/app && ln -s /a ./vak.tgz', app), ['lien-symbolique']);
  assert.deepEqual(codes('ln -s /a vak.tgz', app), ['lien-symbolique']);
  assert.deepEqual(codes('ln -s /a /work/x/app/sub/l', app), ['lien-symbolique']);
  assert.deepEqual(codes('ln -s /a /work/x/app-autre/l', app), ['lien-hors-depot']);
  assert.deepEqual(codes('cd /tmp/base && ln -s /a l', app), ['lien-hors-depot']);
  assert.deepEqual(codes('cd /tmp/base && cd /work/x/app && ln -s /a l', app), ['lien-symbolique']);
  assert.deepEqual(codes('ln -s /a /tmp/l'), ['lien-symbolique']);
  assert.deepEqual(codes('python3 -c "import os; os.symlink(\'/a\', \'/b\')"'), ['lien-symbolique']);
  assert.deepEqual(codes('psql -c "CREATE ROLE authenticated"'), ['sql-a-la-main']);
  assert.deepEqual(codes('psql -d x -c "create extension if not exists vector"'), ['sql-a-la-main']);
  assert.deepEqual(codes('psql -d x <<SQL\nCREATE TABLE t(id int);\nSQL'), ['sql-a-la-main']);
  assert.deepEqual(codes('grep -n "CREATE TABLE" supabase/migrations/*.sql'), []);
  assert.deepEqual(codes("sed -i 's/a/b/' supabase/functions/vak/vak-server.mjs"), ['fichier-gere']);
  assert.deepEqual(codes("cat > .claude/skills/vak/SKILL.md <<'E'\nx\nE"), ['fichier-gere']);
  assert.deepEqual(codes("python3 - <<'E'\nopen('supabase/functions/vak/index.ts','w').write('x')\nE"), ['fichier-gere']);
  assert.deepEqual(codes("python3 - <<'E'\np='supabase/functions/vak/agent.ts'\nopen(p,'w').write('x')\nE"), []); // agent.ts est à l'agent
  assert.deepEqual(codes('cat supabase/functions/vak/vak-server.mjs | head'), []);
  assert.deepEqual(codes("sed -i 's/a/b/' supabase/migrations/001_a.sql", { migrationsPrep: new Set(['001_a.sql']) }), ['migration']);
  assert.deepEqual(codes("sed -i 's/a/b/' supabase/migrations/20260101_vak_0001_core.sql"), ['fichier-gere']);
});

test('journal : échecs de preuve et premier vak à 0', () => {
  const j = {
    evts: [
      { n: 1, ts: 1000, genre: 'outil', id: 'a', nom: 'Bash', entree: { command: 'node node_modules/@vak/agent/bin/vak.mjs 2>&1 | tail -5' } },
      { n: 2, ts: 2000, genre: 'resultat', id: 'a', texte: '✗ tags étroit\n    - ligne de C…\nvak : à corriger [code 1]' },
      { n: 3, ts: 3000, genre: 'outil', id: 'b', nom: 'Bash', entree: { command: 'node node_modules/@vak/agent/bin/vak.mjs doctor' } },
      { n: 4, ts: 4000, genre: 'resultat', id: 'b', texte: 'vak : fini (sync, doctor) [code 0]' },
      { n: 5, ts: 5000, genre: 'outil', id: 'c', nom: 'Bash', entree: { command: 'node node_modules/@vak/agent/bin/vak.mjs --migrations x' } },
      { n: 6, ts: 6000, genre: 'resultat', id: 'c', texte: 'vak : fini (sync, doctor, test, prove) [code 0]' },
    ],
  };
  j.outils = new Map(j.evts.filter((e) => e.genre === 'outil').map((e) => [e.id, e]));
  assert.deepEqual(echecsDePreuve(j).map((e) => [e.table, e.verdict]), [['tags', 'étroit']]);
  assert.equal(premierVakOk(j).ligne, 6); // « doctor » seul n'est pas « vak »
});

// ── erreurs ──
test('erreurs : tsc, eslint, jest, préfixes turbo', () => {
  const sortie = [
    "app:typecheck: lib/a.ts(3,7): error TS2322: Type 'string' is not assignable to type 'number'.",
    '@kit/ui:lint: /clone/packages/ui/a.tsx',
    "@kit/ui:lint:   12:5  error  'x' is defined but never used  @typescript-eslint/no-unused-vars",
    '@kit/ui:lint:   13:5  warning  bof  rule',
    ' FAIL  src/a.test.ts > suite > fait x',
    "src/b.ts:9:3 - error TS1005: ';' expected.",
  ].join('\n');
  const e = extraireErreurs(sortie, '/clone');
  assert.deepEqual(e.map((x) => `${x.fichier}:${x.ligne}`), ['lib/a.ts:3', 'packages/ui/a.tsx:12', 'src/a.test.ts:0', 'src/b.ts:9']);
});

test('erreurs : une ligne qui bouge n\'est pas une erreur nouvelle ; une erreur de plus, si', () => {
  const a = extraireErreurs("a.ts(3,1): error TS2322: Type 'x' is not assignable.", '');
  const decale = extraireErreurs("a.ts(8,1): error TS2322: Type 'x' is not assignable.", '');
  assert.equal(comparerErreurs(a, decale).allonge, false);
  const plus = extraireErreurs("a.ts(8,1): error TS2322: Type 'x' is not assignable.\nb.ts(1,1): error TS2304: Cannot find name 'y'.", '');
  const c = comparerErreurs(a, plus);
  assert.equal(c.allonge, true);
  assert.equal(c.nouvelles.length, 1);
});

// ── dépendances : dépôts git jetables ──
function depot(avant, apres) {
  const d = fs.mkdtempSync(path.join(ici, '.tmp-'));
  const g = (...a) => execFileSync('git', ['-c', 'user.name=t', '-c', 'user.email=t@t', ...a], { cwd: d, stdio: 'pipe' }).toString();
  g('init', '-q', '-b', 'essai');
  const ecrire = (fichiers) => { for (const [f, t] of Object.entries(fichiers)) { fs.mkdirSync(path.dirname(path.join(d, f)), { recursive: true }); fs.writeFileSync(path.join(d, f), t); } };
  ecrire(avant); g('add', '-A'); g('commit', '-q', '-m', 'a'); const a = g('rev-parse', 'HEAD').trim();
  ecrire({ ...apres, '.rien': String(Math.random()) }); g('add', '-A'); g('commit', '-q', '-m', 'b'); const b = g('rev-parse', 'HEAD').trim();
  return { d, a, b };
}
const verdictDeps = (avant, apres) => {
  const { d, a, b } = depot(avant, apres);
  try { return comparerDependances(d, a, b).problemes; } finally { fs.rmSync(d, { recursive: true, force: true }); }
};

test('dépendances : npm', () => {
  const lock = (v, extra = {}) => JSON.stringify({ lockfileVersion: 3, packages: { '': {}, 'node_modules/a': { version: v, integrity: 'sha512-A' }, ...extra } });
  assert.equal(verdictDeps({ 'package-lock.json': lock('1.0.0') }, { 'package-lock.json': lock('1.0.0', { 'node_modules/b': { version: '2.0.0' } }) }).length, 0); // ajout permis
  assert.equal(verdictDeps({ 'package-lock.json': lock('1.0.0') }, { 'package-lock.json': lock('1.1.0') }).length, 1); // version changée
  assert.equal(verdictDeps({ 'package-lock.json': lock('1.0.0') }, { 'package-lock.json': JSON.stringify({ lockfileVersion: 3, packages: { '': {} } }) }).length, 1); // retrait
  const pj = (deps) => JSON.stringify({ name: 'x', dependencies: deps });
  assert.equal(verdictDeps({ 'package.json': pj({ a: '^1.0.0' }) }, { 'package.json': pj({ a: '^1.0.0', b: '^2.0.0' }) }).length, 0);
  assert.equal(verdictDeps({ 'package.json': pj({ a: '^1.0.0' }) }, { 'package.json': pj({ a: '^2.0.0' }) }).length, 1);
});

test('dépendances : pnpm (verrou, catalogue)', () => {
  const lock = (v, extra = '') => `lockfileVersion: '9.0'\n\nimporters:\n\n  .:\n    dependencies:\n      a:\n        specifier: ^1.0.0\n        version: ${v}\n\npackages:\n\n  a@${v}:\n    resolution: {integrity: sha512-A}\n${extra}\nsnapshots:\n\n  a@${v}: {}\n`;
  assert.equal(verdictDeps({ 'pnpm-lock.yaml': lock('1.0.0') }, { 'pnpm-lock.yaml': lock('1.0.0', "  '@vak/agent@file:vendor/vak/x.tgz':\n    resolution: {integrity: sha512-B}\n") }).length, 0);
  assert.ok(verdictDeps({ 'pnpm-lock.yaml': lock('1.0.0') }, { 'pnpm-lock.yaml': lock('1.1.0') }).length >= 1);
  const ws = (v) => `packages:\n  - apps/*\ncatalog:\n  react: ${v}\n`;
  assert.equal(verdictDeps({ 'pnpm-workspace.yaml': ws('19.0.0') }, { 'pnpm-workspace.yaml': ws('19.1.0') }).length, 1);
});

test('dépendances : yarn 1 et berry', () => {
  const y1 = (v) => `# yarn lockfile v1\n\n\n"a@^1.0.0", a@^1.0.1:\n  version "${v}"\n  resolved "https://x/a-${v}.tgz#abc"\n  integrity sha512-A\n`;
  assert.equal(verdictDeps({ 'yarn.lock': y1('1.0.1') }, { 'yarn.lock': `${y1('1.0.1')}\nb@^2.0.0:\n  version "2.0.0"\n` }).length, 0);
  assert.ok(verdictDeps({ 'yarn.lock': y1('1.0.1') }, { 'yarn.lock': y1('1.0.2') }).length >= 1);
  const yb = (v) => `__metadata:\n  version: 8\n\n"a@npm:^1.0.0":\n  version: ${v}\n  resolution: "a@npm:${v}"\n  checksum: abc\n  languageName: node\n`;
  assert.ok(verdictDeps({ 'yarn.lock': yb('1.0.1') }, { 'yarn.lock': yb('1.0.2') }).length >= 1);
  assert.equal(verdictDeps({ 'yarn.lock': yb('1.0.1') }, { 'yarn.lock': yb('1.0.1') }).length, 0);
});

// ── schéma et calibrage ──
test('schéma : tables « à moi » ; ignore', () => {
  const schema = lireSchema(`import type { HostSnapshot } from "@vak/agent";
export const schema = { version: 1, tables: {
  notes: { kind: "table", columns: { id: { type: "uuid" }, owner: { type: "uuid", references: "auth.users.id" } }, policies: [] },
  lignes: { kind: "table", columns: { id: { type: "uuid" }, note_id: { type: "uuid", references: "public.notes.id" } }, policies: [] },
  amis: { kind: "table", columns: { a: { type: "uuid" } }, policies: [{ name: "p", cmd: "select", using: "(auth.uid() = a)" }] },
  catalogue: { kind: "table", columns: { id: { type: "uuid" }, nom: { type: "text" } }, policies: [{ name: "p", cmd: "select", using: "true" }] },
} } as const satisfies HostSnapshot;`);
  assert.deepEqual([...tablesAMoi(schema).keys()].sort(), ['amis', 'lignes', 'notes']);
  const ig = cleIgnore('export default defineAgent({\n  tables: { a: { x: 1 } },\n  ignore: {\n    notes: "a, b: c",\n    "lignes": "x", // ignore: { faux: 1 }\n    fn: "y",\n  },\n  plugins: [],\n});');
  assert.deepEqual([...ig.keys()], ['notes', 'lignes', 'fn']);
});
