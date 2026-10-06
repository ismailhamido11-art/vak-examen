// Essai synthétique minuscule (aucune dépendance) : exerce le point 2 dans les cas que les essais de répétition ne
// déclenchent pas : liste d'erreurs qui s'allonge, code 0 → autre chose, délai dépassé après seulement, avant et après,
// vérification disparue, vérification ajoutée.   node --test controleur/tests/synthetique.test.mjs
import assert from 'node:assert/strict';
import { execFileSync, spawnSync } from 'node:child_process';
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

const ici = path.dirname(fileURLToPath(import.meta.url));
const controleur = path.join(ici, '..', 'controler.mjs');

function essai(prepScripts, agentScripts, fichiersAgent = {}) {
  const racine = fs.mkdtempSync(path.join(ici, '.tmp-essai-'));
  const app = path.join(racine, 'app');
  fs.mkdirSync(app);
  const g = (...a) => execFileSync('git', ['-c', 'user.name=t', '-c', 'user.email=t@t', ...a], { cwd: app, stdio: 'pipe' }).toString().trim();
  const ecrire = (f, t) => { fs.mkdirSync(path.dirname(path.join(app, f)), { recursive: true }); fs.writeFileSync(path.join(app, f), t); };
  g('init', '-q', '-b', 'essai');
  const pj = (scripts) => JSON.stringify({ name: 'synthetique', version: '1.0.0', scripts }, null, 2);
  ecrire('package.json', pj(prepScripts.scripts));
  ecrire('package-lock.json', JSON.stringify({ name: 'synthetique', version: '1.0.0', lockfileVersion: 3, requires: true, packages: { '': { name: 'synthetique', version: '1.0.0' } } }));
  for (const [f, t] of Object.entries(prepScripts.fichiers ?? {})) ecrire(f, t);
  g('add', '-A'); g('commit', '-q', '-m', 'app d\'origine');
  const commit = g('rev-parse', 'HEAD');
  const octets = Buffer.from('archive du kit');
  ecrire('vendor/vak/vak-agent-0.0.0.tgz', octets);
  g('add', '-A'); g('commit', '-q', '-m', 'vak : archive du kit');
  const prepare = g('rev-parse', 'HEAD');
  ecrire('package.json', pj(agentScripts));
  for (const [f, t] of Object.entries(fichiersAgent)) ecrire(f, t);
  g('add', '-A'); g('commit', '-q', '-m', 'agent');
  fs.writeFileSync(path.join(racine, 'preparation.json'), JSON.stringify({ id: 'synth', depot: 'x', commit, prepare, archive: { nom: 'vak-agent-0.0.0.tgz', sha256: crypto.createHash('sha256').update(octets).digest('hex') }, debut: '2026-01-01T00:00:00Z' }));
  const ligne = (o) => JSON.stringify(o);
  fs.writeFileSync(path.join(racine, 'journal.jsonl'), `${[
    ligne({ type: 'queue-operation', operation: 'enqueue', timestamp: '2026-01-01T00:00:00.000Z', content: 'Intègre vak.' }),
    ligne({ type: 'assistant', timestamp: '2026-01-01T00:00:01.000Z', message: { role: 'assistant', content: [{ type: 'text', text: 'Je commence.' }] } }),
  ].join('\n')}\n`);
  return racine;
}

function controler(racine, env = {}) {
  const travail = path.join(racine, 'travail');
  const r = spawnSync('node', [controleur, racine, travail], { env: { ...process.env, CONTROLEUR_DELAI_MIN: '0.1', ...env }, encoding: 'utf8', timeout: 300_000 });
  const verdict = JSON.parse(fs.readFileSync(path.join(travail, 'verdict.json'), 'utf8'));
  return { sortie: r.stdout, verdict };
}
const codes = (v) => v.raisons.filter((r) => r.point === 2).map((r) => r.code).sort();

const TSC2 = "console.log(\"src/a.ts(1,1): error TS2322: Type 'string' is not assignable to type 'number'.\\nsrc/b.ts(2,2): error TS2304: Cannot find name 'x'.\"); process.exit(2)";
const TSC1 = "console.log(\"src/a.ts(9,1): error TS2322: Type 'string' is not assignable to type 'number'.\"); process.exit(2)";

test('point 2 : erreurs qui s\'allongent, code 0 → 1, délai après seulement, délai avant et après', () => {
  const racine = essai(
    { scripts: { typecheck: `node -e '${TSC1}'`, lint: 'node -e "process.exit(0)"', test: 'node -e "setTimeout(()=>{},60000)"', build: 'node -e "process.exit(0)"' } },
    { typecheck: `node -e '${TSC2}'`, lint: 'node -e "console.log(\'/x/src/c.ts\\n  3:1  error  oups  no-undef\'); process.exit(1)"', test: 'node -e "setTimeout(()=>{},60000)"', build: 'node -e "setTimeout(()=>{},60000)"' },
  );
  try {
    const { sortie, verdict } = controler(racine);
    assert.match(sortie, /verdict synth : échec \(/);
    assert.deepEqual(codes(verdict), ['build-delai', 'lint-code', 'typecheck-erreurs']);
    assert.equal(verdict.points.p2.verifs.test.etat, 'non comparable (délai dépassé avant et après)');
    const tc = verdict.raisons.find((r) => r.code === 'typecheck-erreurs');
    assert.match(tc.preuve.join('\n'), /src\/b\.ts:2/); // l'erreur nouvelle est citée, fichier:ligne
    assert.ok(!tc.preuve.join('\n').includes('src/a.ts'), 'l\'erreur ancienne, qui a seulement changé de ligne, n\'est pas nouvelle');
    assert.match(verdict.raisons.find((r) => r.code === 'lint-code').preuve.join('\n'), /src\/c\.ts:3/);
  } finally { fs.rmSync(racine, { recursive: true, force: true }); }
});

test('point 2 : vérification disparue ; vérification ajoutée ; liste inchangée', () => {
  const racine = essai(
    { scripts: { typecheck: `node -e '${TSC1}'`, lint: 'node -e "process.exit(0)"' } },
    { typecheck: `node -e '${TSC1}'`, build: 'node -e "process.exit(0)"' },
  );
  try {
    const { verdict } = controler(racine);
    assert.deepEqual(codes(verdict), ['lint-disparue']);
    assert.equal(verdict.points.p2.verifs.typecheck.etat, 'identique (code 2)');
    assert.equal(verdict.points.p2.verifs.build.etat, 'ajoutée');
    assert.equal(verdict.points.p2.verifs.test.etat, 'absente');
  } finally { fs.rmSync(racine, { recursive: true, force: true }); }
});

test('point 4 : migration de l\'app modifiée', () => {
  const racine = essai(
    { scripts: {}, fichiers: { 'supabase/migrations/001_a.sql': 'create table t(id int);\n' } },
    {},
    { 'supabase/migrations/001_a.sql': 'create table t(id bigint);\n' },
  );
  try {
    const { verdict } = controler(racine);
    assert.ok(verdict.raisons.some((r) => r.point === 4 && r.code === 'migration'));
    assert.match(verdict.raisons.find((r) => r.code === 'migration').preuve.join('\n'), /001_a\.sql/);
  } finally { fs.rmSync(racine, { recursive: true, force: true }); }
});
