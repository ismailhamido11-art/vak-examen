#!/usr/bin/env bash
# Répétition 2, message 1 (hors chrono) : prépare l'environnement d'un essai. Idempotent.
# Usage, depuis la racine du dépôt : bash repetition2/preparer.sh <id> [--neuf]   (id : apps.tsv)
#  1. PostgreSQL 16 : installé par apt-get si psql manque (avec pgvector si le paquet existe), puis démarré.
#  2. Super-utilisateur local au nom de l'utilisateur du système, mot de passe aléatoire dans ~/.pgpass (jamais
#     affiché) ; l'URL d'administration par défaut de vak (postgresql://127.0.0.1:5432/postgres) répond sans invite.
#  3. Identité git, si elle manque (synthétique : essai@example.invalid).
#  4. Clone neuf de l'app à son commit dans /work/<id>/app, branche « essai », sans remote ; l'archive du kit
#     (vertical-agent-kit/releases/vak-agent-<version>.tgz) copiée dans vendor/vak et commitée (« vak : archive du
#     kit », geste du propriétaire pour un agent de code en ligne). Commit reproductible : auteur et date fixes, donc
#     même empreinte d'une machine à l'autre (le bundle de l'essai s'applique dessus).
#     La même archive est copiée au chemin fixe /work/vak-agent.tgz, celui que donne la demande : la règle de
#     permission du dépôt (.claude/settings.json, posée sur l'accord du propriétaire) nomme ce chemin exact, qui ne
#     change pas d'une version à l'autre (le mode auto de Claude Code ignore les règles larges, à joker).
#  5. Mesure « avant », indépendante : autre clone neuf du commit (/work/<id>/avant), mesurer.mjs → /work/<id>/avant.json
#     (journaux dans /work/<id>/avant-journaux), puis node_modules et .next retirés.
# Avant tout : l'environnement d'examen n'a aucun accès réel. Une variable de Supabase (jeton, clé, mot de passe), une
# clé de modèle (…_API_KEY) ou une variable VAK_ donne un code 1, qui la nomme (jamais sa valeur) : l'agent ne travaille
# que sur la base locale, et un essai ne doit jamais toucher un vrai projet.
# Un essai commencé (app modifiée depuis la préparation) n'est jamais touché ; --neuf efface /work/<id> et refait tout.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/.." && pwd)"
TRAVAIL="${TRAVAIL:-/work}"
fail() { echo "✗ $*" >&2; exit 1; }
etape() { echo "→ $*"; }
maintenant() { date -u +%Y-%m-%dT%H:%M:%SZ; }
lire() { node -p "JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8'))$2" "$1"; }

ID="${1:-}"
NEUF="${2:-}"
[ -n "$ID" ] || fail "usage : bash repetition2/preparer.sh <id> [--neuf] (id : première colonne de apps.tsv)"
[ -z "$NEUF" ] || [ "$NEUF" = "--neuf" ] || fail "option inconnue : $NEUF (seule --neuf existe)"
# APPS=<liste> : une autre liste que apps.tsv, de même forme (les essais de l'examen).
LISTE="${APPS:-$HERE/apps.tsv}"
LIGNE="$(awk -F'\t' -v id="$ID" '$1 == id' "$LISTE")"
[ -n "$LIGNE" ] || fail "id inconnu : $ID ($LISTE : $(awk -F'\t' '!/^#/ {printf "%s ", $1}' "$LISTE"))"
IFS=$'\t' read -r _ DEPOT COMMIT _ _ <<<"$LIGNE"
shopt -s nullglob
ARCHIVES=("$REPO"/vertical-agent-kit/releases/vak-agent-*.tgz)
shopt -u nullglob
[ "${#ARCHIVES[@]}" -eq 1 ] || fail "il faut exactement une archive vak-agent-<version>.tgz dans $REPO/vertical-agent-kit/releases (trouvées : ${#ARCHIVES[@]})"
ARCHIVE="${ARCHIVES[0]}"
NOM="$(basename "$ARCHIVE")"
EMPREINTE="$(sha256sum "$ARCHIVE" | cut -d' ' -f1)"
W="$TRAVAIL/$ID"
APP="$W/app"
DEBUT="$(maintenant)"
echo "préparation de l'essai $ID ($DEPOT @ ${COMMIT:0:7}, $NOM sha256 ${EMPREINTE:0:12}) : $DEBUT"

etape "environnement d'examen sans accès réel"
# Noms (jamais les valeurs) des variables de ce shell ET de ses ancêtres : un `unset` ou un `env -u` posé juste avant ne
# cache pas une clé que la session porte (répétition 4 : mission-control avait retiré les clés de chaque commande).
noms_env() {
  env | cut -d= -f1
  local pid="$PPID"
  while [ -n "$pid" ] && [ "$pid" -gt 1 ] 2>/dev/null; do
    { tr '\0' '\n' <"/proc/$pid/environ"; } 2>/dev/null | cut -d= -f1
    pid="$(awk '/^PPid:/ { print $2 }' "/proc/$pid/status" 2>/dev/null || true)"
  done
  { tr '\0' '\n' </proc/1/environ; } 2>/dev/null | cut -d= -f1
  true
}
ACCES="$(noms_env | grep -E '^(SUPABASE_[A-Z0-9_]*(TOKEN|KEY|PASSWORD)|[A-Z0-9_]*_API_KEY|VAK_[A-Z0-9_]+)$' | sort -u | tr '\n' ' ' || true)"
# Décision du propriétaire (03/10/2026) : la clé DeepSeek et le jeton du compte Supabase d'essai séparé (registre, 29/09 :
# jamais son app, jamais la production) restent dans l'environnement cloud des essais. Ces deux noms sont admis, notés
# dans preparation.json puis au rapport ; toute autre variable d'accès réel arrête encore l'essai.
ADMIS_POSSIBLES=" DEEPSEEK_API_KEY SUPABASE_ACCESS_TOKEN "
ADMIS=""
REFUSES=""
for NOM_ACCES in $ACCES; do
  case "$ADMIS_POSSIBLES" in *" $NOM_ACCES "*) ADMIS="$ADMIS $NOM_ACCES" ;; *) REFUSES="$REFUSES $NOM_ACCES" ;; esac
done
ADMIS="${ADMIS# }"
[ -z "$REFUSES" ] || fail "environnement d'examen avec un accès réel : ${REFUSES# }. L'essai s'arrête ici : ne retire pas ces variables toi-même (unset, env -u), l'humain relance l'essai dans un environnement cloud sans elles (l'agent ne travaille que sur la base locale)."
if [ -n "$ADMIS" ]; then
  echo "  accès du compte d'essai admis par le propriétaire (03/10), jamais utilisés par l'essai : $ADMIS"
else
  echo "  aucune variable de Supabase, de clé de modèle ni de vak"
fi

SUDO=()
[ "$(id -u)" -eq 0 ] || SUDO=(sudo)
en_postgres() { if [ "$(id -u)" -eq 0 ]; then (cd / && runuser -u postgres -- "$@"); else (cd / && sudo -u postgres "$@"); fi; }

etape "PostgreSQL 16"
if ! command -v psql >/dev/null || ! command -v pg_lsclusters >/dev/null || [ -z "$(pg_lsclusters -h 2>/dev/null | awk '$1 == 16')" ]; then
  "${SUDO[@]}" apt-get update -q
  PAQUETS=(postgresql-16)
  apt-cache show postgresql-16-pgvector >/dev/null 2>&1 && PAQUETS+=(postgresql-16-pgvector)
  "${SUDO[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -y -q "${PAQUETS[@]}" >/dev/null || fail "installation impossible : apt-get install ${PAQUETS[*]}"
  echo "  installé : ${PAQUETS[*]}"
fi
if ! pg_isready -q -h 127.0.0.1 -p 5432; then
  "${SUDO[@]}" pg_ctlcluster 16 main start 2>/dev/null || "${SUDO[@]}" service postgresql start >/dev/null 2>&1 || true
  for _ in $(seq 30); do pg_isready -q -h 127.0.0.1 -p 5432 && break; sleep 1; done
fi
pg_isready -q -h 127.0.0.1 -p 5432 || fail "PostgreSQL ne répond pas sur 127.0.0.1:5432 (pg_lsclusters ; service postgresql start)"
echo "  serveur $(en_postgres psql -X -A -t -d postgres -c 'show server_version' 2>/dev/null) sur 127.0.0.1:5432$(en_postgres psql -X -A -t -d postgres -c "select ', pgvector disponible' from pg_available_extensions where name = 'vector'" 2>/dev/null)"
for v in PGUSER PGHOST PGPORT PGDATABASE PGPASSWORD PGSERVICE SUPABASE_DB_URL; do
  [ -z "${!v:-}" ] || echo "  ! $v est posée dans l'environnement : vak et psql la suivent (attendu : aucune)"
done

MOI="$(id -un)"
etape "super-utilisateur local « $MOI » et ~/.pgpass"
URL_ADMIN="postgresql://127.0.0.1:5432/postgres"
superu() { psql -X -w -A -t -d "$URL_ADMIN" -c "select current_setting('is_superuser')" 2>/dev/null || true; }
if [ "$(superu)" = "on" ]; then
  echo "  déjà prêt : $URL_ADMIN répond sans invite (rien changé)"
else
  MDP="$(openssl rand -hex 16 2>/dev/null || od -An -N16 -tx1 /dev/urandom | tr -d ' \n')"
  # mot de passe par l'entrée standard de psql (jamais sur une ligne de commande, jamais affiché)
  en_postgres psql -X -q -v ON_ERROR_STOP=1 -d postgres >/dev/null <<SQL
\set moi '$MOI'
\set mdp '$MDP'
select format('create role %I', :'moi') where not exists (select 1 from pg_roles where rolname = :'moi') \gexec
select format('alter role %I with login superuser password %L', :'moi', :'mdp') \gexec
SQL
  PGPASS="$HOME/.pgpass"
  (
    umask 077
    { [ -f "$PGPASS" ] && grep -v -F "127.0.0.1:5432:*:$MOI:" "$PGPASS" || true; printf '127.0.0.1:5432:*:%s:%s\n' "$MOI" "$MDP"; } >"$PGPASS.tmp"
  )
  mv "$PGPASS.tmp" "$PGPASS"
  chmod 600 "$PGPASS"
  unset MDP
  echo "  rôle $MOI : super-utilisateur, mot de passe aléatoire dans ~/.pgpass (non affiché)"
fi
[ "$(superu)" = "on" ] || fail "$URL_ADMIN : connexion sans invite ou super-utilisateur impossible (rôle $MOI, ~/.pgpass)"
psql -X -w -h 127.0.0.1 postgres -c 'select 1' >/dev/null || fail "psql -h 127.0.0.1 postgres -c 'select 1' demande un mot de passe ou échoue"
echo "  ok : psql -h 127.0.0.1 postgres -c 'select 1' sans invite ; $URL_ADMIN en super-utilisateur"

etape "identité git"
git config --global user.name >/dev/null || git config --global user.name "Essai vak"
git config --global user.email >/dev/null || git config --global user.email "essai@example.invalid"
echo "  $(git config --global user.name) <$(git config --global user.email)>"

# clone neuf du dépôt à son commit (une seule révision), sous-modules compris, sans remote (aucun push possible)
cloner() {
  local d="$1" n
  rm -rf "$d"
  git init -q -b essai "$d"
  git -C "$d" remote add origin "$DEPOT"
  for n in 1 2 3; do
    git -C "$d" fetch -q --depth 1 origin "$COMMIT" && break
    [ "$n" -lt 3 ] || fail "git fetch $DEPOT $COMMIT impossible"
    sleep 5
  done
  git -C "$d" checkout -q -B essai FETCH_HEAD
  [ "$(git -C "$d" rev-parse HEAD)" = "$COMMIT" ] || fail "$d : HEAD n'est pas $COMMIT"
  if [ -f "$d/.gitmodules" ]; then git -C "$d" submodule update -q --init --recursive --depth 1 || fail "$d : sous-modules impossibles"; fi
  git -C "$d" remote remove origin
}
ecrire_preparation() { # [fin]
  node -e '
const [fichier, id, depot, commit, prepare, nom, sha256, debut, admis, fin] = process.argv.slice(1);
const dir = require("path").dirname(fichier);
const acces = admis ? { acces_admis: admis.split(" ") } : {};
const p = { id, depot, commit, prepare, archive: { nom, sha256 }, app: `${dir}/app`, avant: `${dir}/avant.json`, debut, ...acces, ...(fin ? { fin } : {}) };
require("fs").writeFileSync(fichier, `${JSON.stringify(p, null, 2)}\n`);
' "$W/preparation.json" "$ID" "$DEPOT" "$COMMIT" "$PREPARE" "$NOM" "$EMPREINTE" "$DEBUT" "$ADMIS" "${1:-}"
}

FIXE="$TRAVAIL/vak-agent.tgz"
etape "archive au chemin fixe de la demande : $FIXE"
mkdir -p "$TRAVAIL"
if [ -f "$FIXE" ] && [ "$(sha256sum "$FIXE" | cut -d' ' -f1)" = "$EMPREINTE" ]; then
  echo "  déjà en place ($NOM)"
else
  cp "$ARCHIVE" "$FIXE.tmp" && mv -f "$FIXE.tmp" "$FIXE"
  echo "  copiée ($NOM, sha256 ${EMPREINTE:0:12})"
fi

[ "$NEUF" != "--neuf" ] || { etape "--neuf : $W effacé"; rm -rf "$W"; }
mkdir -p "$W"
etape "app : $APP (branche essai, archive commitée dans vendor/vak)"
if [ -f "$W/preparation.json" ] && [ -d "$APP/.git" ]; then
  PREPARE="$(lire "$W/preparation.json" .prepare)"
  ANCIENNE="$(lire "$W/preparation.json" .archive.sha256)"
  [ "$ANCIENNE" = "$EMPREINTE" ] || fail "$APP préparée avec une autre archive (sha256 ${ANCIENNE:0:12}) : --neuf pour tout refaire"
  if [ "$(git -C "$APP" rev-parse HEAD)" = "$PREPARE" ] && [ -z "$(git -C "$APP" status --porcelain)" ]; then
    echo "  déjà préparée (HEAD ${PREPARE:0:7}, arbre propre) : rien changé"
  else
    fail "$APP a changé depuis la préparation (essai commencé ?) : rien n'est touché ; --neuf efface $W et refait tout"
  fi
else
  [ ! -e "$APP" ] || echo "  préparation précédente incomplète : app reclonée"
  cloner "$APP"
  mkdir -p "$APP/vendor/vak"
  cp "$ARCHIVE" "$APP/vendor/vak/$NOM"
  if git -C "$APP" check-ignore -q "vendor/vak/$NOM"; then echo "  ! vendor/vak/$NOM est ignorée par le .gitignore de l'app : commitée quand même (git add -f)"; fi
  git -C "$APP" add -f "vendor/vak/$NOM"
  DATE="$(git -C "$APP" log -1 --format=%cI HEAD)"
  GIT_AUTHOR_NAME="Préparation vak" GIT_AUTHOR_EMAIL="essai@example.invalid" GIT_AUTHOR_DATE="$DATE" \
    GIT_COMMITTER_NAME="Préparation vak" GIT_COMMITTER_EMAIL="essai@example.invalid" GIT_COMMITTER_DATE="$DATE" \
    git -C "$APP" -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -q --no-verify -m "vak : archive du kit"
  PREPARE="$(git -C "$APP" rev-parse HEAD)"
  ecrire_preparation
  echo "  commit de préparation ${PREPARE:0:7} sur ${COMMIT:0:7}"
fi

etape "mesure avant (clone neuf séparé) : $W/avant.json"
if [ -f "$W/avant.json" ] && [ "$(lire "$W/avant.json" .commit)" = "$COMMIT" ]; then
  echo "  déjà mesurée (rien changé)"
else
  cloner "$W/avant"
  node "$HERE/mesurer.mjs" "$W/avant" "$W/avant.json"
fi
find "$W/avant" -name node_modules -type d -prune -exec rm -rf {} + 2>/dev/null || true
find "$W/avant" -name .next -type d -prune -exec rm -rf {} + 2>/dev/null || true

ecrire_preparation "$(maintenant)"
LIBRE="$(df -Pk "$TRAVAIL" | awk 'NR == 2 {print int($4 / 1048576)}')"
[ "$LIBRE" -ge 3 ] || echo "  ! disque : ${LIBRE} Go libres sous $TRAVAIL (au moins 3 Go conseillés)"
echo "prêt : $APP ($(maintenant))"
