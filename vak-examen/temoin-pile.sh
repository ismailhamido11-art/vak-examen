#!/usr/bin/env bash
# La pile « mes données » du groupe témoin (REGLE.md, « Le groupe témoin ») : les mêmes pièces que pile/pile.sh, sans
# la fonction de vak, que le témoin n'a pas. L'interface que l'agent a construite se sert ensuite à la main, sur le
# port réservé ici (`fonction` de pile.json, derrière le relais en /functions/v1/…), ou à côté (serveur de l'app).
#   [FONCTION_PORT=<port>] bash vak-examen/temoin-pile.sh up <id> <état commité (etiquettes/etat.sh)>   # écrit /work/<id>/pile/pile.json
#   bash vak-examen/temoin-pile.sh down <id> <état commité>                     # arrête tout et supprime la base
# Pièces, toutes locales, comme la pile des essais de vak :
#  - la base : `vak localdb --db-name examen_<id>` (archive gelée du dépôt, vertical-agent-kit/releases/) dans l'état
#    commité : les migrations de l'app, celles de l'agent comprises ; puis les comptes A et B, et la graine de l'app ;
#  - PostgREST, par un rôle de connexion à lui (examen_pile), membre de anon et authenticated ;
#  - relais.mjs : /rest/v1, connexion par mot de passe (jetons HS256 signés en local), /auth/v1/user, /functions/v1.
# pile.json : { relais, anon, secret, fonction, fonction_port, db, comptes: { A: { email, password, id }, B: { … } } }.
# `secret` signe les jetons (aléatoire, local) : une fonction de l'agent qui vérifie elle-même les jetons le reçoit.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
REPO="$(pwd)"
TRAVAIL="${TRAVAIL:-/work}"
fail() { echo "✗ $*" >&2; exit 1; }
ACTION="${1:-}"
ID="${2:-}"
APP="${3:-}"
[ -n "$ACTION" ] && [ -n "$ID" ] && [ -n "$APP" ] || fail "usage : bash vak-examen/temoin-pile.sh up|down <id> <état commité>"
case "$ID" in temoin_*) ;; *) fail "$ID : pas un essai du groupe témoin" ;; esac
APP="$(cd "$APP" && pwd)"
P="$TRAVAIL/$ID/pile"
APPNOM="${ID#temoin_}"
G="vak-examen/graines/$APPNOM"
TGZ="$(ls "$REPO"/vertical-agent-kit/releases/vak-agent-*.tgz | head -1)"
VAK=(npx -y --package="$TGZ" vak)
# PostgREST et port libre : comme pile/pile.sh.
POSTGREST_VERSION="${POSTGREST_VERSION:-v12.2.12}"
postgrest_bin() {
  local bin="${POSTGREST_BIN:-$(command -v postgrest || true)}"
  if [ -n "$bin" ]; then echo "$bin"; return; fi
  bin="${XDG_CACHE_HOME:-$HOME/.cache}/vak/postgrest-$POSTGREST_VERSION"
  [ -x "$bin" ] || fail "PostgREST absent : $bin (pile/pile.sh le télécharge au premier essai)"
  echo "$bin"
}
port_libre() { node -e 'const s=require("node:net").createServer();s.listen(0,"127.0.0.1",()=>{console.log(s.address().port);s.close()})'; }
arreter() {
  [ -f "$P/pids" ] || return 0
  while read -r pid; do kill -- "-$pid" 2>/dev/null || kill "$pid" 2>/dev/null || true; done < "$P/pids"
  rm -f "$P/pids"
}

if [ "$ACTION" = "down" ]; then
  arreter
  (cd "$APP" && "${VAK[@]}" localdb --drop --db-name "examen_$ID" >/dev/null 2>&1 || true)
  echo "pile témoin $ID arrêtée"
  exit 0
fi
[ "$ACTION" = "up" ] || fail "action inconnue : $ACTION (up ou down)"
pg_isready -q -h 127.0.0.1 -p 5432 || pg_ctlcluster 16 main start 2>/dev/null || true
for _ in $(seq 30); do pg_isready -q -h 127.0.0.1 -p 5432 && break; sleep 1; done
pg_isready -q -h 127.0.0.1 -p 5432 || fail "PostgreSQL ne répond pas sur 127.0.0.1:5432"
[ -f "$G/graine.sql" ] || fail "graine absente : $G/graine.sql"
mkdir -p "$P"
arreter

# 1. La base neuve, les comptes A et B, la graine. vak localdb demande supabase/config.toml : sans lui, le minimum que
#    vak init écrirait (comme graines-pile.sh), hors de l'état commité, effacé ensuite.
CONFIG_AJOUTEE=""
if [ ! -f "$APP/supabase/config.toml" ]; then mkdir -p "$APP/supabase"; printf 'project_id = "app"\n' > "$APP/supabase/config.toml"; CONFIG_AJOUTEE=1; fi
SORTIE="$(cd "$APP" && "${VAK[@]}" localdb --db-name "examen_$ID" 2>&1)" || { echo "$SORTIE" >&2; fail "vak localdb a échoué (migrations de l'état commité)"; }
[ -z "$CONFIG_AJOUTEE" ] || rm -f "$APP/supabase/config.toml"
DB="$(sed -n 's/^.*URL : //p' <<<"$SORTIE" | head -1)"
[ -n "$DB" ] || fail "URL de la base introuvable dans la sortie de vak localdb"
node -e '
const c = require("crypto");
const compte = (n) => ({ email: `${n.toLowerCase()}-${c.randomBytes(3).toString("hex")}@examen-vak.test`, password: c.randomBytes(18).toString("base64url"), id: c.randomUUID() });
require("fs").writeFileSync(process.argv[1], JSON.stringify({ A: compte("A"), B: compte("B") }, null, 2), { mode: 0o600 });
' "$P/comptes.json"
read -r A_ID B_ID A_MEL B_MEL < <(node -e 'const c = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8")); console.log(c.A.id, c.B.id, c.A.email, c.B.email)' "$P/comptes.json")
psql -X -q -v ON_ERROR_STOP=1 "$DB" -c "insert into auth.users (id, email) values ('$A_ID', '$A_MEL'), ('$B_ID', '$B_MEL')" >/dev/null ||
  fail "comptes A et B refusés par la base (déclencheur de l'app ?)"
psql -X -q -v ON_ERROR_STOP=1 -v a="$A_ID" -v b="$B_ID" -f "$G/graine.sql" "$DB" >/dev/null || fail "graine refusée par la base : $G/graine.sql"

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
-- Une interface qui écrit avec la clé service_role (comme sur Supabase) : le rôle, s'il existe dans la base.
do \$\$ begin
  if exists (select 1 from pg_roles where rolname = 'service_role') then grant service_role to examen_pile; end if;
end \$\$;
SQL
PG_PORT="$(port_libre)"
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
setsid "$(postgrest_bin)" "$P/postgrest.conf" > "$P/postgrest.log" 2>&1 &
echo $! >> "$P/pids"

# 3. Le relais ; /functions/v1/… va au port réservé à l'interface de l'agent.
# FONCTION_PORT : le port qu'impose l'interface (Deno.serve sans option écoute sur 8000), sinon un port libre.
F_PORT="${FONCTION_PORT:-$(port_libre)}"
R_PORT="$(port_libre)"
node -e '
const [p, port, postgrest, fonction, secret] = process.argv.slice(1);
const fs = require("fs");
const comptes = JSON.parse(fs.readFileSync(`${p}/comptes.json`, "utf8"));
const parAdresse = Object.fromEntries(Object.values(comptes).map((c) => [c.email, { id: c.id, password: c.password }]));
fs.writeFileSync(`${p}/relais.json`, JSON.stringify({ port: Number(port), postgrest, fonction, secret, comptes: parAdresse }), { mode: 0o600 });
' "$P" "$R_PORT" "http://127.0.0.1:$PG_PORT" "http://127.0.0.1:$F_PORT" "$SECRET"
setsid node vak-examen/pile/relais.mjs "$P/relais.json" > "$P/relais.log" 2>&1 &
echo $! >> "$P/pids"
for _ in $(seq 50); do grep -q '"relais"' "$P/relais.log" 2>/dev/null && break; sleep 0.2; done
ANON="$(node -e 'process.stdout.write(JSON.parse(require("fs").readFileSync(process.argv[1], "utf8").split("\n")[0]).anon)' "$P/relais.log")" ||
  fail "le relais n'a pas démarré (voir $P/relais.log)"
for _ in $(seq 50); do [ "$(curl -s -o /dev/null -w '%{http_code}' -H "apikey: $ANON" "http://127.0.0.1:$R_PORT/rest/v1/" || true)" = "200" ] && break; sleep 0.2; done
node -e '
const [p, relais, anon, secret, fport, db] = process.argv.slice(1);
const fs = require("fs");
const comptes = JSON.parse(fs.readFileSync(`${p}/comptes.json`, "utf8"));
fs.writeFileSync(`${p}/pile.json`, JSON.stringify({ relais, anon, secret, fonction: `http://127.0.0.1:${fport}`, fonction_port: Number(fport), db, comptes }, null, 2) + "\n", { mode: 0o600 });
' "$P" "http://127.0.0.1:$R_PORT" "$ANON" "$SECRET" "$F_PORT" "$DB"
echo "pile témoin $ID prête : $P/pile.json (relais http://127.0.0.1:$R_PORT ; port réservé à l'interface : $F_PORT)"
