#!/usr/bin/env bash
# L'état commité d'un essai, reconstruit sans /work (effacé après le jugement) : l'app clonée à son commit, le commit
# de préparation refait à l'identique (repetition2/preparer.sh : même arbre, même auteur, même date, donc même
# empreinte), puis les commits de l'essai pris dans essai.bundle. Sert à établir la vérité de l'étiquette
# (etiquettes/README.md) et à publier l'état commité.
# Usage, depuis n'importe où : bash vak-examen/etiquettes/etat.sh <id> <dossier neuf>
#   → <dossier> à l'état commité de l'essai (branche essai), puis la liste des fichiers du calibrage et des migrations.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.."
REPO="$(pwd)"
ID="${1:?usage : bash vak-examen/etiquettes/etat.sh <id> <dossier neuf>}"
D="${2:?usage : bash vak-examen/etiquettes/etat.sh <id> <dossier neuf>}"
R="repetition2/resultats/$ID"
fail() { echo "✗ $*" >&2; exit 1; }
[ -f "$R/preparation.json" ] && [ -f "$R/essai.bundle" ] || fail "$R : preparation.json ou essai.bundle absent"
[ ! -e "$D" ] || fail "$D existe déjà"
lire() { node -e 'const p = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8")); process.stdout.write(String(eval("p" + process.argv[2]) ?? ""))' "$R/preparation.json" "$1"; }
DEPOT="$(lire .depot)"
COMMIT="$(lire .commit)"
PREPARE="$(lire .prepare)"
NOM="$(lire '.archive?.nom')"
case "$DEPOT" in http://* | https://* | git@* | /*) ;; *) DEPOT="$REPO/$DEPOT" ;; esac
git clone -q "$DEPOT" "$D"
git -C "$D" checkout -q -b essai "$COMMIT"
if [ -n "$NOM" ]; then
  [ -f "vertical-agent-kit/releases/$NOM" ] || fail "archive vertical-agent-kit/releases/$NOM absente"
  mkdir -p "$D/vendor/vak" && cp "vertical-agent-kit/releases/$NOM" "$D/vendor/vak/$NOM"
  git -C "$D" add -f "vendor/vak/$NOM"
  DATE="$(git -C "$D" log -1 --format=%cI HEAD)"
  GIT_AUTHOR_NAME="Préparation vak" GIT_AUTHOR_EMAIL="essai@example.invalid" GIT_AUTHOR_DATE="$DATE" \
    GIT_COMMITTER_NAME="Préparation vak" GIT_COMMITTER_EMAIL="essai@example.invalid" GIT_COMMITTER_DATE="$DATE" \
    git -C "$D" -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -q --no-verify -m "vak : archive du kit"
fi
[ "$(git -C "$D" rev-parse HEAD)" = "$PREPARE" ] || fail "commit de préparation refait $(git -C "$D" rev-parse --short HEAD), attendu ${PREPARE:0:7}"
git -C "$D" fetch -q "$REPO/$R/essai.bundle" HEAD
git -C "$D" reset -q --hard FETCH_HEAD
echo "état commité de $ID : $(git -C "$D" log --oneline -1) ($(git -C "$D" rev-list --count "$PREPARE..HEAD") commit(s) de l'essai)"
echo "calibrage : $(git -C "$D" ls-files | grep -E '(^|/)supabase/functions/vak/agent\.ts$' | tr '\n' ' ')"
echo "migrations : $(git -C "$D" ls-files | grep -cE '(^|/)supabase/migrations/[^/]+\.sql$') fichier(s)"
