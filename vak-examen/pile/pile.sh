#!/usr/bin/env bash
# Pile « mes données » de l'examen (REGLE.md) pour un essai fini : l'assistant de l'app tel qu'il a été commité, servi
# en local avec le vrai modèle, sur une base neuve où vivent deux comptes d'essai, A et B.
#   bash vak-examen/pile/pile.sh up <id>     # écrit /work/<id>/pile/pile.json
#   bash vak-examen/pile/pile.sh down <id>   # arrête tout et supprime la base
# Pièces, toutes locales :
#  - la base : `vak localdb --db-name examen_<id>` dans le clone propre /work/<id>/apres (état commité, fait par le
#    contrôleur), donc les migrations de l'app et de vak ; puis les comptes A et B dans auth.users ;
#  - PostgREST, connecté par un rôle de connexion à lui (examen_pile), membre de anon et authenticated ;
#  - relais.mjs : /rest/v1, connexion par mot de passe (jetons HS256 signés en local), /auth/v1/user, /functions/v1 ;
#  - la fonction vak de l'app, servie par `deno serve`, avec DeepSeek (DEEPSEEK_API_KEY) : Deno ne lit que le dossier
#    de la fonction, n'a que les variables qu'on lui donne (env -i), et ne joint que la machine locale et l'API du modèle.
# pile.json : { relais, anon, fonction, db, comptes: { A: { email, password, id }, B: { … } } }.
# Les graines (données de A et de B) sont écrites par l'auteur du contrôleur, pour chaque app ; la pile ne les invente pas.
# GRAINE=<graine.sql> l'applique après la création des comptes, avec leurs identifiants (psql -v a=<A> -v b=<B>).
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRAVAIL="${TRAVAIL:-/work}"
DENO_VERSION="${DENO_VERSION:-2.9.6}"
fail() { echo "✗ $*" >&2; exit 1; }
ACTION="${1:-}"
ID="${2:-}"
[ -n "$ACTION" ] && [ -n "$ID" ] || fail "usage : bash vak-examen/pile/pile.sh up|down <id>"
APP="$TRAVAIL/$ID/apres"
P="$TRAVAIL/$ID/pile"
# La CLI de vak depuis l'archive que l'app embarque (vendor/vak) : le clone propre n'a pas ses dépendances installées.
TGZ="$(ls "$APP"/vendor/vak/vak-agent-*.tgz 2>/dev/null | head -1 || true)"
VAK=(npx -y --package="$TGZ" vak)
# Deux fonctions recopiées du harnais de test du kit (test/harness/lib.sh, 06/10) : la pile ne lit aucun fichier du
# dépôt de vak, seulement l'archive que l'app embarque.
# PostgREST : POSTGREST_BIN, sinon `postgrest` du PATH, sinon le binaire en cache, sinon téléchargé (Linux x64).
POSTGREST_VERSION="${POSTGREST_VERSION:-v12.2.12}"
vak_postgrest_bin() {
  local bin="${POSTGREST_BIN:-$(command -v postgrest || true)}"
  if [ -n "$bin" ]; then echo "$bin"; return; fi
  bin="${XDG_CACHE_HOME:-$HOME/.cache}/vak/postgrest-$POSTGREST_VERSION"
  if [ ! -x "$bin" ]; then
    echo "→ téléchargement de PostgREST $POSTGREST_VERSION (Linux x64)" >&2
    mkdir -p "$(dirname "$bin")"
    local tmp; tmp="$(mktemp -d)"
    curl -fsSL "https://github.com/PostgREST/postgrest/releases/download/$POSTGREST_VERSION/postgrest-$POSTGREST_VERSION-linux-static-x86-64.tar.xz" \
      | tar -xJ -C "$tmp" || { rm -rf "$tmp"; return 1; }
    mv "$tmp/postgrest" "$bin"
    rm -rf "$tmp"
  fi
  echo "$bin"
}
# Port TCP libre sur 127.0.0.1 (choisi par le système).
vak_free_port() {
  node -e 'const s=require("node:net").createServer();s.listen(0,"127.0.0.1",()=>{console.log(s.address().port);s.close()})'
}

arreter() {
  [ -f "$P/pids" ] || return 0
  while read -r pid; do kill -- "-$pid" 2>/dev/null || kill "$pid" 2>/dev/null || true; done < "$P/pids"
  rm -f "$P/pids"
}

if [ "$ACTION" = "down" ]; then
  arreter
  [ ! -d "$APP" ] || (cd "$APP" && "${VAK[@]}" localdb --drop --db-name "examen_$ID" >/dev/null 2>&1 || true)
  echo "pile $ID arrêtée"
  exit 0
fi
[ "$ACTION" = "up" ] || fail "action inconnue : $ACTION (up ou down)"
# La machine peut redémarrer (le disque reste, les processus non) : PostgreSQL est démarré s'il le faut (06/10).
pg_isready -q -h 127.0.0.1 -p 5432 || pg_ctlcluster 16 main start 2>/dev/null || service postgresql start >/dev/null 2>&1 || true
for _ in $(seq 30); do pg_isready -q -h 127.0.0.1 -p 5432 && break; sleep 1; done
pg_isready -q -h 127.0.0.1 -p 5432 || fail "PostgreSQL ne répond pas sur 127.0.0.1:5432 (pg_lsclusters ; service postgresql start)"
[ -d "$APP/supabase/functions/vak" ] || fail "$APP/supabase/functions/vak absent : lance d'abord le contrôleur (clone propre de l'état commité)"
[ -n "${DEEPSEEK_API_KEY:-}" ] || fail "DEEPSEEK_API_KEY absent : la pile sert l'assistant avec le vrai modèle"
[ -n "$TGZ" ] || fail "$APP/vendor/vak/vak-agent-*.tgz absent : archive de vak de l'app introuvable"
mkdir -p "$P"
arreter

# 1. La base neuve, et les comptes A et B (identifiants et mots de passe tirés au hasard, jamais affichés).
SORTIE="$(cd "$APP" && "${VAK[@]}" localdb --db-name "examen_$ID" 2>&1)" || { echo "$SORTIE" >&2; fail "vak localdb a échoué"; }
DB="$(sed -n 's/^.*URL : //p' <<<"$SORTIE" | head -1)"
[ -n "$DB" ] || fail "URL de la base introuvable dans la sortie de vak localdb"
node -e '
const c = require("crypto");
const compte = (n) => ({ email: `${n.toLowerCase()}-${c.randomBytes(3).toString("hex")}@examen-vak.test`, password: c.randomBytes(18).toString("base64url"), id: c.randomUUID() });
require("fs").writeFileSync(process.argv[1], JSON.stringify({ A: compte("A"), B: compte("B") }, null, 2), { mode: 0o600 });
' "$P/comptes.json"
SQL="$(node -e '
const { A, B } = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
const q = (s) => `'"'"'${s.replace(/'"'"'/g, "'"'"''"'"'")}'"'"'`;
process.stdout.write(`insert into auth.users (id, email) values (${q(A.id)}, ${q(A.email)}), (${q(B.id)}, ${q(B.email)});`);
' "$P/comptes.json")"
psql -X -q -v ON_ERROR_STOP=1 "$DB" -c "$SQL" >/dev/null || fail "comptes A et B refusés par la base (déclencheur de l'app ?)"
if [ -n "${GRAINE:-}" ]; then
  [ -f "$GRAINE" ] || fail "graine introuvable : $GRAINE"
  read -r A_ID B_ID < <(node -e 'const c = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8")); console.log(c.A.id, c.B.id)' "$P/comptes.json")
  psql -X -q -v ON_ERROR_STOP=1 -v a="$A_ID" -v b="$B_ID" -f "$GRAINE" "$DB" >/dev/null || fail "graine refusée par la base : $GRAINE"
fi

# 2. PostgREST, par un rôle de connexion à lui.
SECRET="$(node -e 'process.stdout.write(require("crypto").randomBytes(32).toString("base64url"))')"
MDP="$(node -e 'process.stdout.write(require("crypto").randomBytes(18).toString("hex"))')"
psql -X -q -v ON_ERROR_STOP=1 "$DB" >/dev/null <<SQL
do \$\$ begin
  if not exists (select 1 from pg_roles where rolname = 'examen_pile') then
    create role examen_pile login noinherit;
  end if;
end \$\$;
alter role examen_pile with login password '$MDP';
grant anon, authenticated to examen_pile;
SQL
BIN="$(vak_postgrest_bin)" || fail "PostgREST introuvable"
PG_PORT="$(vak_free_port)"
NOM_BASE="${DB##*/}"; NOM_BASE="${NOM_BASE%%\?*}"
cat > "$P/postgrest.conf" <<CONF
db-uri = "postgres://examen_pile:$MDP@127.0.0.1:${PGPORT:-5432}/$NOM_BASE"
db-schemas = "public"
db-anon-role = "anon"
jwt-secret = "$SECRET"
server-host = "127.0.0.1"
server-port = $PG_PORT
CONF
chmod 600 "$P/postgrest.conf"
setsid "$BIN" "$P/postgrest.conf" > "$P/postgrest.log" 2>&1 &
echo $! >> "$P/pids"

# 3. La fonction vak de l'app, servie par Deno avec le vrai modèle.
F_PORT="$(vak_free_port)"
R_PORT="$(vak_free_port)"
APPROBATION="$(node -e 'process.stdout.write(require("crypto").randomBytes(32).toString("base64url"))')"
CA=/etc/ssl/certs/ca-certificates.crt
# Le relais d'abord (il signe la clé publique), puis Deno, qui la reçoit.
node -e '
const [p, port, postgrest, fonction, secret] = process.argv.slice(1);
const fs = require("fs");
const comptes = JSON.parse(fs.readFileSync(`${p}/comptes.json`, "utf8"));
const parAdresse = Object.fromEntries(Object.values(comptes).map((c) => [c.email, { id: c.id, password: c.password }]));
fs.writeFileSync(`${p}/relais.json`, JSON.stringify({ port: Number(port), postgrest, fonction, secret, comptes: parAdresse }), { mode: 0o600 });
' "$P" "$R_PORT" "http://127.0.0.1:$PG_PORT" "http://127.0.0.1:$F_PORT" "$SECRET"
setsid node "$HERE/relais.mjs" "$P/relais.json" > "$P/relais.log" 2>&1 &
echo $! >> "$P/pids"
for _ in $(seq 50); do grep -q '"relais"' "$P/relais.log" 2>/dev/null && break; sleep 0.2; done
ANON="$(node -e 'process.stdout.write(JSON.parse(require("fs").readFileSync(process.argv[1], "utf8").split("\n")[0]).anon)' "$P/relais.log")" \
  || fail "le relais n'a pas démarré (voir $P/relais.log)"
(cd "$APP/supabase/functions/vak" && exec setsid env -i PATH="$PATH" HOME="$P" DENO_DIR="$P/deno" npm_config_cache="$P/npm" \
  NODE_EXTRA_CA_CERTS="$CA" DENO_CERT="$CA" HTTPS_PROXY="${HTTPS_PROXY:-}" NO_PROXY=localhost,127.0.0.1 \
  SUPABASE_URL="http://127.0.0.1:$R_PORT" SUPABASE_ANON_KEY="$ANON" \
  VAK_OPENAI_COMPAT_BASE_URL=https://api.deepseek.com/v1 VAK_OPENAI_COMPAT_API_KEY="$DEEPSEEK_API_KEY" VAK_OPENAI_COMPAT_NAME=DeepSeek \
  VAK_MODEL_CHAT=deepseek-flash VAK_MODEL_CHEAP=deepseek-flash VAK_TOOL_APPROVAL_SECRET="$APPROBATION" VAK_ALLOWED_ORIGINS=http://localhost \
  npx -y "deno@$DENO_VERSION" serve --port "$F_PORT" --allow-env --allow-read=. \
    --allow-net="127.0.0.1,localhost,api.deepseek.com" index.ts > "$P/deno.log" 2>&1) &
echo $! >> "$P/pids"
PRET=""
for _ in $(seq 120); do
  if [ "$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$R_PORT/functions/v1/vak/config" || true)" = "200" ]; then PRET=1; break; fi
  sleep 1
done
[ -n "$PRET" ] || { tail -20 "$P/deno.log" >&2; fail "la fonction vak ne répond pas (voir $P/deno.log)"; }

node -e '
const [p, relais, anon, db] = process.argv.slice(1);
const fs = require("fs");
const comptes = JSON.parse(fs.readFileSync(`${p}/comptes.json`, "utf8"));
fs.writeFileSync(`${p}/pile.json`, JSON.stringify({ relais, anon, fonction: `${relais}/functions/v1/vak`, db, comptes }, null, 2) + "\n", { mode: 0o600 });
' "$P" "http://127.0.0.1:$R_PORT" "$ANON" "$DB"
echo "pile $ID prête : $P/pile.json (fonction http://127.0.0.1:$R_PORT/functions/v1/vak)"
