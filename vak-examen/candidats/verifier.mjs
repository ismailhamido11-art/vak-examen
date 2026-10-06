#!/usr/bin/env node
// Juge mécaniquement l'éligibilité d'un dépôt. Node 22, aucune dépendance npm.
// Usage : node candidats/verifier.mjs <url du dépôt> <dossier de travail>
// Rend une ligne JSON sur stdout. Le clone et la base sont supprimés à la fin
// (GARDER=1 garde le clone, pour le débogage).
import { spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, readdirSync, readFileSync, rmSync, statSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { randomBytes } from 'node:crypto';

const ICI = dirname(fileURLToPath(import.meta.url));
const DATE_MIN = '2025-03-30';
const NODE_ENV = [22, 22, 0]; // la machine des essais : 22.22
const PG = ['-h', '127.0.0.1', '-U', 'root', '-X', '-q', '-v', 'VERBOSITY=terse'];
const EXT_ABSENTES = ['vector', 'http', 'pg_net', 'pg_cron', 'pgjwt', 'pgsodium', 'supabase_vault', 'pg_graphql', 'wrappers'];
const ORGS_FOURNISSEUR = ['supabase', 'supabase-community'];

const [url, travail] = process.argv.slice(2);
if (!url || !travail) {
  console.error('usage : node candidats/verifier.mjs <url du dépôt> <dossier de travail>');
  process.exit(2);
}

// 06/10 : SOURCE=<dépôt git local> juge une app construite pour l'examen, pas encore publiée. L'URL n'est alors qu'un
// nom simple (construite-<forme>), et les critères propres à GitHub (public, fork) sont hors sujet.
const SOURCE = process.env.SOURCE;
const res = { url, commit: null, date: null, plateforme: null, tables_a_moi: [], eligible: false, raisons: [] };
const echecs = []; // raisons d'inéligibilité
const notes = []; // remarques qui n'empêchent rien

function sortie() {
  res.raisons = [...echecs, ...notes.map((n) => 'note : ' + n)];
  res.eligible = echecs.length === 0;
  if (res.eligible && res.raisons.length === 0) res.raisons = ['tous les critères sont remplis'];
  console.log(JSON.stringify(res));
}

// ---------- critère 1 et 8 : dépôt, exclusions ----------
const m = SOURCE ? [url, 'local', url.replace(/[^\w.-]/g, '_')] : /^https?:\/\/github\.com\/([^/\s]+)\/([^/\s#?]+?)(?:\.git)?\/?$/i.exec(url.trim());
if (!m) {
  echecs.push('URL : pas un dépôt github.com/<propriétaire>/<nom>');
  sortie();
  process.exit(0);
}
const [, proprio, nom] = m;
const cle = (s) => s.toLowerCase();

const exclus = lireExclusions();
const proprioExclus = new Set(exclus.map((u) => cle(u.proprio)));
if (exclus.some((u) => cle(u.proprio) === cle(proprio) && cle(u.nom) === cle(nom))) echecs.push('exclusion : dépôt de exclusions.txt');
else if (proprioExclus.has(cle(proprio))) echecs.push(`exclusion : propriétaire ${proprio} présent dans exclusions.txt`);
if (['chatbot-ui', 'expo-ai'].includes(cle(nom))) echecs.push(`exclusion : dépôt nommé ${nom}`);
if (ORGS_FOURNISSEUR.includes(cle(proprio))) echecs.push(`exclusion : kit du fournisseur de la base (${proprio})`);

function lireExclusions() {
  const chemins = [process.env.EXCLUSIONS, join(ICI, '..', 'exclusions.txt'), join(ICI, 'exclusions.txt')].filter(Boolean);
  for (const c of chemins) {
    if (!existsSync(c)) continue;
    return readFileSync(c, 'utf8')
      .split('\n')
      .map((l) => /github\.com\/([^/\s]+)\/([^/\s]+?)(?:\.git)?\/?\s*$/i.exec(l.trim()))
      .filter(Boolean)
      .map((x) => ({ proprio: x[1], nom: x[2] }));
  }
  return [];
}

if (echecs.length) {
  sortie();
  process.exit(0);
}

// public et pas un fork : l'API GitHub si elle répond, sinon le clone anonyme prouve « public »
const api = SOURCE ? null : await fetch(`https://api.github.com/repos/${proprio}/${nom}`, { headers: { 'user-agent': 'verifier-candidats' } }).catch(() => null);
let apiJson = null;
if (api && api.ok) apiJson = await api.json().catch(() => null);
if (api && api.status === 404) echecs.push('critère 1 : dépôt introuvable ou privé');
else if (apiJson) {
  if (apiJson.fork) echecs.push('critère 1 : le dépôt est un fork');
  if (apiJson.private) echecs.push('critère 1 : le dépôt est privé');
  if (apiJson.archived) notes.push('dépôt archivé');
} else {
  notes.push(SOURCE ? 'app construite, jugée depuis un dépôt local : public et fork hors sujet' : 'fork non vérifiable (API GitHub injoignable ou refusée) : à contrôler à part');
}
if (echecs.length) {
  sortie();
  process.exit(0);
}

// ---------- clone ----------
mkdirSync(travail, { recursive: true });
const dossier = resolve(travail, `${proprio}__${nom}`);
rmSync(dossier, { recursive: true, force: true });
const env = { ...process.env, GIT_TERMINAL_PROMPT: '0', GIT_ASKPASS: 'true' };
const cl = spawnSync('git', ['clone', '-q', '--depth', '1', '--no-tags', SOURCE ? `file://${resolve(SOURCE)}` : `https://github.com/${proprio}/${nom}.git`, dossier], { env, encoding: 'utf8', timeout: 300000 });
if (cl.status !== 0) {
  echecs.push('critère 1 : clone impossible (privé, supprimé ou réseau) : ' + (cl.stderr || '').trim().split('\n').pop());
  sortie();
  process.exit(0);
}
const git = (...a) => spawnSync('git', ['-C', dossier, ...a], { encoding: 'utf8' }).stdout.trim();
res.commit = git('rev-parse', 'HEAD');
res.date = git('log', '-1', '--format=%cI');

let nomBase = null;
let rolesAvant = null; // les rôles sont globaux au serveur : ceux que créent les migrations sont supprimés ensuite

// ---------- jugement ----------
function jugerDepot() {
  // critère 6
  if (res.date.slice(0, 10) < DATE_MIN) echecs.push(`critère 6 : dernier commit du ${res.date.slice(0, 10)}, avant le ${DATE_MIN}`);

  // critères 2 et 5
  const paquets = trouver(dossier, (rel, nomF) => nomF === 'package.json', 6).map((f) => {
    try {
      return { f, json: JSON.parse(readFileSync(f, 'utf8')) };
    } catch {
      return { f, json: null };
    }
  });
  const dep = (j, n) => j && ['dependencies', 'devDependencies', 'peerDependencies', 'optionalDependencies'].some((k) => j[k] && n in j[k]);
  const aExpo = paquets.some((p) => dep(p.json, 'expo'));
  const aNext = paquets.some((p) => dep(p.json, 'next'));
  if (aExpo) res.plateforme = 'expo';
  else if (aNext) res.plateforme = 'next';
  else echecs.push('critère 2 : aucun package.json ne dépend de next ou de expo');
  if (aExpo && aNext) notes.push('dépend à la fois de expo et de next (plateforme : expo)');

  const pertinents = paquets.filter((p) => dep(p.json, 'expo') || dep(p.json, 'next') || p.f === join(dossier, 'package.json'));
  for (const p of pertinents) {
    const eng = p.json?.engines?.node;
    if (typeof eng !== 'string') continue;
    const r = admet(eng, NODE_ENV);
    const rel = p.f.slice(dossier.length + 1);
    if (r === false) echecs.push(`critère 5 : ${rel} engines.node "${eng}" n'admet pas Node 22`);
    else if (r === null) notes.push(`${rel} engines.node "${eng}" non interprété, supposé compatible`);
  }

  // critère 3
  const dossiersMig = trouver(dossier, (rel, nomF, estDossier) => estDossier && nomF === 'migrations' && /(^|\/)supabase\/migrations$/.test(rel) && rel.split('/').length <= 4, 4, true)
    .map((d) => ({ d, sql: readdirSync(d).filter((x) => x.endsWith('.sql')) }))
    .filter((x) => x.sql.length)
    .sort((a, b) => a.d.length - b.d.length);
  if (!dossiersMig.length) {
    echecs.push('critère 3 : aucun supabase/migrations/*.sql (racine ou trois niveaux au plus)');
    return;
  }

  // critères 4 et 7 : chaque dossier de migrations dans sa propre base ; le premier qui s'applique sert
  let meilleur = null;
  for (const dm of dossiersMig) {
    const r = appliquer(dm);
    if (!meilleur || (r.echecs.length < meilleur.echecs.length) || (r.echecs.length === meilleur.echecs.length && r.tables.length > meilleur.tables.length)) meilleur = r;
    if (!r.echecs.length && r.tables.length) break;
  }
  if (dossiersMig.length > 1) notes.push(`${dossiersMig.length} dossiers de migrations ; retenu : ${meilleur.rel}`);
  res.tables_a_moi = meilleur.tables;
  for (const e of meilleur.echecs) echecs.push('critère 7 : ' + e);
  for (const n of meilleur.notes) notes.push(n);
  if (!meilleur.tables.length && !meilleur.echecs.length) echecs.push('critère 4 : les migrations ne créent aucune table « à moi »');
  else if (!meilleur.tables.length) echecs.push('critère 4 : aucune table « à moi » trouvée dans la base obtenue');
}

function appliquer({ d, sql }) {
  const rel = d.slice(dossier.length + 1);
  const out = { rel, echecs: [], notes: [], tables: [] };
  if (nomBase) psql('postgres', `drop database if exists ${nomBase} with (force)`);
  nomBase = 'cand_' + randomBytes(5).toString('hex');
  rolesAvant ??= psql('postgres', 'select rolname from pg_roles', ['-At']).stdout.split('\n').filter(Boolean);
  const c = psql('postgres', `create database ${nomBase}`);
  if (c.status !== 0) {
    out.echecs.push('impossible de créer la base : ' + c.stderr.trim());
    return out;
  }
  const b = spawnSync('psql', [...PG, '-d', nomBase, '-v', 'ON_ERROR_STOP=1', '-c', BOOTSTRAP.replace('__DB__', nomBase)], { encoding: 'utf8' });
  if (b.status !== 0) {
    out.echecs.push('amorçage Supabase impossible : ' + b.stderr.trim());
    return out;
  }
  const fichiers = sql.filter((x) => /^\d+_.*\.sql$/.test(x)).sort((a, b) => cmpVersion(a, b));
  const ignores = sql.filter((x) => !/^\d+_.*\.sql$/.test(x));
  if (ignores.length) out.notes.push(`${ignores.length} fichier(s) .sql au nom hors format <version>_<nom>.sql ignoré(s) comme le fait la CLI Supabase`);
  let extManque = null;
  const consequences = [];
  for (const f of fichiers) {
    const p = spawnSync('psql', [...PG, '-d', nomBase, '-c', 'set session authorization postgres', '-f', join(d, f)], { encoding: 'utf8', timeout: 180000, maxBuffer: 1 << 26 });
    if (p.error) {
      out.echecs.push(`${f} : ${p.error.code === 'ETIMEDOUT' ? 'délai de 180 s dépassé' : p.error.message}`);
      continue;
    }
    const erreurs = (p.stderr || '').split('\n').filter((l) => /\bERROR:/.test(l)).map((l) => l.replace(/^.*?ERROR:\s*/, '').trim());
    for (const e of erreurs) {
      const ext = extensionAbsente(e);
      if (ext) {
        extManque ??= ext;
        out.notes.push(`${f} : échoue faute de ${ext} (${e.slice(0, 120)}) ; l'app reste éligible`);
      } else if (extManque && /does not exist|n'existe pas|already exists|cannot be implemented/i.test(e)) {
        consequences.push(`${f} : ${e.slice(0, 120)}`);
      } else {
        out.echecs.push(`${f} : ${e.slice(0, 200)}`);
      }
    }
  }
  if (consequences.length) out.notes.push(`${consequences.length} erreur(s) probablement consécutives à l'extension absente, tolérées (première : ${consequences[0]})`);
  out.tables = tablesAMoi();
  return out;
}

function extensionAbsente(e) {
  const noms = EXT_ABSENTES.join('|');
  let r;
  if ((r = new RegExp(`extension "(${noms})" is not available`).exec(e))) return r[1];
  if ((r = new RegExp(`extension "(${noms})"`).exec(e))) return r[1];
  if ((r = new RegExp(`could not open extension control file.*?/(${noms})\\.control`).exec(e))) return r[1];
  if (/type "(extensions\.|public\.)?(vector|halfvec|sparsevec)"/.test(e) || /operator class "vector_/.test(e) || /access method "(hnsw|ivfflat)"/.test(e)) return 'vector';
  if (/schema "net"|function net\.|"net"\./.test(e)) return 'pg_net';
  if (/schema "cron"|function cron\./.test(e)) return 'pg_cron';
  if (/schema "vault"|function vault\./.test(e)) return 'supabase_vault';
  if (/schema "(pgsodium|graphql|graphql_public)"|function pgsodium\./.test(e)) return 'pgsodium/pg_graphql';
  if (/function (extensions\.)?(http|http_get|http_post|http_header|urlencode)\(/.test(e)) return 'http';
  if (/function (extensions\.)?(sign|verify|algorithm_sign)\(/.test(e)) return 'pgjwt';
  if (/schema "(wrappers|supabase_wrappers)"|foreign data wrapper "(\w+_wrapper)"/.test(e)) return 'wrappers';
  return null;
}

function cmpVersion(a, b) {
  const va = BigInt(/^\d+/.exec(a)[0]);
  const vb = BigInt(/^\d+/.exec(b)[0]);
  return va < vb ? -1 : va > vb ? 1 : a < b ? -1 : a > b ? 1 : 0;
}

// ---------- critère 4 : tables « à moi » (REGLE.md, point 5) ----------
function tablesAMoi() {
  const q = (s) => {
    const p = psql(nomBase, s, ['-At', '-F', '\t']);
    return p.status === 0 ? p.stdout.split('\n').filter(Boolean).map((l) => l.split('\t')) : [];
  };
  const HORS = `n.nspname not in ('auth','storage','extensions','information_schema','pg_catalog','pg_toast','graphql','graphql_public','realtime','vault','net','cron','pgsodium','supabase_functions') and n.nspname not like 'pg\\_%'`;
  const tables = q(`select c.oid::text, n.nspname||'.'||c.relname from pg_class c join pg_namespace n on n.oid=c.relnamespace where c.relkind in ('r','p') and not c.relispartition and ${HORS}`);
  const nomDe = new Map(tables.map(([o, n]) => [o, n]));
  const mine = new Set();

  // clé étrangère vers auth.users ; la table dont la clé primaire est une telle clé est « la table du compte »
  const fk = q(`select c.conrelid::text, c.confrelid::text, (c.confrelid = 'auth.users'::regclass)::text,
      (c.conkey = (select array_agg(a.attnum order by a.attnum) from pg_index i, unnest(i.indkey) a(attnum) where i.indrelid = c.conrelid and i.indisprimary))::text
    from pg_constraint c where c.contype='f'`);
  const comptes = new Set();
  for (const [de, vers, versUsers, surPk] of fk) {
    if (versUsers === 'true' && nomDe.has(de)) {
      mine.add(de);
      if (surPk === 'true') comptes.add(de);
    }
  }
  for (const [de, vers] of fk) if (comptes.has(vers) && nomDe.has(de)) mine.add(de);

  // défaut auth.uid()
  for (const [o] of q(`select distinct d.adrelid::text from pg_attrdef d where pg_get_expr(d.adbin, d.adrelid) ~* '(^|[^a-z_])(auth\\.)?uid\\(\\)'`)) if (nomDe.has(o)) mine.add(o);

  // colonne comparée à auth.uid() par une politique
  const pol = q(`select c.oid::text, coalesce(pg_get_expr(p.polqual,p.polrelid),'')||' '||coalesce(pg_get_expr(p.polwithcheck,p.polrelid),'')
    from pg_policy p join pg_class c on c.oid=p.polrelid`);
  for (const [o, expr] of pol) {
    if (!nomDe.has(o) || mine.has(o)) continue;
    const e = expr.replace(/::[a-z_ ]+(\[\])?/gi, '').replace(/\s+/g, ' ');
    const uid = String.raw`\(*\s*(?:select\s+)?(?:auth\.)?uid\(\)(?:\s+as\s+\w+)?\s*\)*`;
    const col = String.raw`\(*\s*"?([a-z_][a-z0-9_]*)"?\s*\)*`;
    const re1 = new RegExp(`${col}\\s*=\\s*${uid}`, 'gi');
    const re2 = new RegExp(`${uid}\\s*=\\s*${col}`, 'gi');
    const cols = new Set();
    for (const re of [re1, re2]) for (const x of e.matchAll(re)) cols.add(x[1].toLowerCase());
    if (!cols.size) continue;
    const reelles = new Set(q(`select attname from pg_attribute where attrelid = ${o} and attnum > 0 and not attisdropped`).map((r) => r[0].toLowerCase()));
    if ([...cols].some((cn) => reelles.has(cn))) mine.add(o);
  }
  return [...mine].map((o) => nomDe.get(o)).sort();
}

// ---------- Supabase minimal ----------
function psql(base, sqlTexte, extra = []) {
  return spawnSync('psql', [...PG, '-d', base, ...extra, '-c', sqlTexte], { encoding: 'utf8', timeout: 60000 });
}

const BOOTSTRAP = String.raw`
do $$ begin
  if not exists (select from pg_roles where rolname='anon') then create role anon nologin noinherit; end if;
  if not exists (select from pg_roles where rolname='authenticated') then create role authenticated nologin noinherit; end if;
  if not exists (select from pg_roles where rolname='service_role') then create role service_role nologin noinherit bypassrls; end if;
  if not exists (select from pg_roles where rolname='postgres') then create role postgres nologin superuser; end if;
  if not exists (select from pg_roles where rolname='supabase_admin') then create role supabase_admin nologin; end if;
end $$;
create schema if not exists extensions;
create extension if not exists "uuid-ossp" schema extensions;
create extension if not exists pgcrypto schema extensions;
alter database __DB__ set search_path to "$user", public, extensions;
set search_path to "$user", public, extensions;

create schema auth;
create table auth.users (
  instance_id uuid, id uuid primary key default gen_random_uuid(), aud varchar(255), role varchar(255),
  email varchar(255), encrypted_password varchar(255), email_confirmed_at timestamptz, invited_at timestamptz,
  confirmation_token varchar(255), confirmation_sent_at timestamptz, recovery_token varchar(255), recovery_sent_at timestamptz,
  email_change varchar(255), email_change_sent_at timestamptz, last_sign_in_at timestamptz,
  raw_app_meta_data jsonb, raw_user_meta_data jsonb, is_super_admin boolean,
  created_at timestamptz default now(), updated_at timestamptz default now(),
  phone text unique, phone_confirmed_at timestamptz, confirmed_at timestamptz generated always as (least(email_confirmed_at, phone_confirmed_at)) stored,
  banned_until timestamptz, deleted_at timestamptz, is_anonymous boolean not null default false
);
create unique index users_email_key on auth.users (lower(email));
create function auth.uid() returns uuid language sql stable as $f$
  select coalesce(nullif(current_setting('request.jwt.claim.sub', true), ''), (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub'))::uuid $f$;
create function auth.role() returns text language sql stable as $f$
  select coalesce(nullif(current_setting('request.jwt.claim.role', true), ''), (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role'))::text $f$;
create function auth.email() returns text language sql stable as $f$
  select coalesce(nullif(current_setting('request.jwt.claim.email', true), ''), (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email'))::text $f$;
create function auth.jwt() returns jsonb language sql stable as $f$
  select coalesce(nullif(current_setting('request.jwt.claim', true), ''), nullif(current_setting('request.jwt.claims', true), ''))::jsonb $f$;

create schema storage;
create table storage.buckets (
  id text primary key, name text not null, owner uuid, created_at timestamptz default now(), updated_at timestamptz default now(),
  public boolean default false, avif_autodetection boolean default false, file_size_limit bigint, allowed_mime_types text[], owner_id text
);
create unique index bname on storage.buckets (name);
create table storage.objects (
  id uuid primary key default gen_random_uuid(), bucket_id text references storage.buckets(id), name text, owner uuid,
  created_at timestamptz default now(), updated_at timestamptz default now(), last_accessed_at timestamptz default now(),
  metadata jsonb, path_tokens text[] generated always as (string_to_array(name, '/')) stored, version text, owner_id text, user_metadata jsonb
);
create unique index bucketid_objname on storage.objects (bucket_id, name);
alter table storage.objects enable row level security;
alter table storage.buckets enable row level security;
create function storage.foldername(name text) returns text[] language plpgsql as $f$
declare _parts text[]; begin select string_to_array(name, '/') into _parts; return _parts[1:array_length(_parts, 1) - 1]; end $f$;
create function storage.filename(name text) returns text language plpgsql as $f$
declare _parts text[]; begin select string_to_array(name, '/') into _parts; return _parts[array_length(_parts, 1)]; end $f$;
create function storage.extension(name text) returns text language plpgsql as $f$
declare _parts text[]; _filename text; begin
  select string_to_array(name, '/') into _parts; select _parts[array_length(_parts, 1)] into _filename;
  return reverse(split_part(reverse(_filename), '.', 1)); end $f$;

create schema realtime;
create table realtime.messages (
  id bigint generated by default as identity, topic text not null, extension text not null, payload jsonb, event text,
  private boolean default false, updated_at timestamp not null default now(), inserted_at timestamp not null default now()
);
alter table realtime.messages enable row level security;
create function realtime.topic() returns text language sql stable as $f$ select nullif(current_setting('realtime.topic', true), '')::text $f$;

grant usage on schema public, extensions, auth, storage, realtime to anon, authenticated, service_role;
grant all on all tables in schema auth, storage, realtime to service_role;
grant select, insert, update, delete on all tables in schema storage to anon, authenticated;
grant execute on all functions in schema auth, storage, realtime to anon, authenticated, service_role;
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;
create publication supabase_realtime;
`;

// ---------- utilitaires ----------
function trouver(racine, pred, profondeur, dossiers = false) {
  const out = [];
  (function aller(d, niv) {
    let ents;
    try {
      ents = readdirSync(d, { withFileTypes: true });
    } catch {
      return;
    }
    for (const e of ents) {
      if (e.name === 'node_modules' || e.name === '.git' || e.isSymbolicLink()) continue;
      const p = join(d, e.name);
      const rel = p.slice(racine.length + 1);
      if (e.isDirectory()) {
        if (dossiers && pred(rel, e.name, true)) out.push(p);
        if (niv < profondeur) aller(p, niv + 1);
      } else if (!dossiers && pred(rel, e.name, false)) out.push(p);
    }
  })(racine, 0);
  return out;
}

// Une plage semver admet-elle la version v ? true / false, ou null si non interprétée.
function admet(plage, v) {
  try {
    const ors = plage.split('||').map((s) => s.trim());
    let inconnu = false;
    for (const o of ors) {
      const r = ensemble(o, v);
      if (r === null) inconnu = true;
      else if (r) return true;
    }
    return inconnu ? null : false;
  } catch {
    return null;
  }
}
function ensemble(o, v) {
  if (o === '' || o === '*' || o === 'x' || o === 'latest') return true;
  const h = /^(\S+)\s+-\s+(\S+)$/.exec(o);
  const toks = h ? [`>=${h[1]}`, `<=${h[2]}`] : o.replace(/(>=|<=|>|<|=|\^|~)\s+/g, '$1').split(/\s+/);
  for (const t of toks) {
    const r = comparateur(t, v);
    if (r === null) return null;
    if (!r) return false;
  }
  return true;
}
function parse(s) {
  const x = /^v?(\d+|[xX*])(?:\.(\d+|[xX*]))?(?:\.(\d+|[xX*]))?(?:-.*)?$/.exec(s);
  if (!x) return null;
  return [x[1], x[2], x[3]].map((p) => (p === undefined || /[xX*]/.test(p) ? null : Number(p)));
}
const cmp = (a, b) => { for (let i = 0; i < 3; i++) if (a[i] !== b[i]) return a[i] < b[i] ? -1 : 1; return 0; };
function comparateur(t, v) {
  const x = /^(>=|<=|>|<|=|\^|~)?(.*)$/.exec(t);
  const op = x[1] || '=';
  const p = parse(x[2]);
  if (!p) return null;
  const bas = p.map((n) => n ?? 0);
  const nul = p.filter((n) => n === null).length;
  if (op === '=') {
    for (let i = 0; i < 3; i++) if (p[i] !== null && p[i] !== v[i]) return false;
    return true;
  }
  if (op === '>=') return cmp(v, bas) >= 0;
  if (op === '>') {
    if (!nul) return cmp(v, bas) > 0;
    return cmp(v, p[1] === null ? [bas[0] + 1, 0, 0] : [bas[0], bas[1] + 1, 0]) >= 0;
  }
  if (op === '<') return cmp(v, bas) < 0;
  if (op === '<=') {
    if (!nul) return cmp(v, bas) <= 0;
    for (let i = 0; i < 3; i++) { if (p[i] === null) return true; if (v[i] !== p[i]) return v[i] < p[i]; }
    return true;
  }
  let haut;
  if (op === '~') haut = p[1] === null ? [bas[0] + 1, 0, 0] : [bas[0], bas[1] + 1, 0];
  else if (bas[0] > 0 || p[1] === null) haut = [bas[0] + 1, 0, 0];
  else if (bas[1] > 0 || p[2] === null) haut = [0, bas[1] + 1, 0];
  else haut = [0, 0, bas[2] + 1];
  return cmp(v, bas) >= 0 && cmp(v, haut) < 0;
}

// ---------- exécution (en dernier : les constantes ci-dessus doivent exister) ----------
try {
  jugerDepot();
} finally {
  if (nomBase) psql('postgres', `drop database if exists ${nomBase} with (force)`);
  if (rolesAvant) {
    const apres = psql('postgres', 'select rolname from pg_roles', ['-At']).stdout.split('\n').filter(Boolean);
    for (const r of apres) if (!rolesAvant.includes(r)) psql('postgres', `drop role if exists "${r}"`);
  }
  if (!process.env.GARDER) rmSync(dossier, { recursive: true, force: true });
}
sortie();
