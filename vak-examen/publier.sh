#!/usr/bin/env bash
# Recopie l'examen dans un clone du dépôt public (https://github.com/ismailhamido11-art/vak-examen), aux mêmes chemins
# que dans le dépôt de vak, depuis l'état commité (HEAD), jamais depuis des fichiers en cours.
# Usage, depuis n'importe où : [GRAINES=1] bash vak-examen/publier.sh <clone du dépôt public>
# Recopié :
#  - vak-examen/, sans graines/ (publiées après les essais : GRAINES=1 les ajoute) ;
#  - les scripts du lanceur des essais (repetition2/), sans ses résultats ni son journal ;
#  - RACINE.md, qui devient le README de la racine.
# Rien n'est commité ni poussé : le script montre l'état du clone public.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
DEST="${1:?usage : bash vak-examen/publier.sh <clone du dépôt public>}"
fail() { echo "✗ $*" >&2; exit 1; }
[ -d "$DEST/.git" ] || fail "$DEST n'est pas un dépôt git"
[ "$(cd "$DEST" && pwd)" != "$(pwd)" ] || fail "$DEST est le dépôt de vak lui-même"
LANCEUR=(.gitignore apps.tsv controle.mjs controler.sh horodater.mjs lancer.sh mesurer.mjs messages.sh preparer.sh
  transcription.mjs)
rm -rf "$DEST/vak-examen" "$DEST/repetition2"
git archive --format=tar HEAD -- vak-examen "${LANCEUR[@]/#/repetition2/}" | tar -x -C "$DEST"
[ "${GRAINES:-0}" = 1 ] || rm -rf "$DEST/vak-examen/graines"
mv "$DEST/vak-examen/RACINE.md" "$DEST/README.md"
echo "recopié depuis $(git rev-parse --short HEAD) ($([ "${GRAINES:-0}" = 1 ] && echo "graines comprises" || echo "sans les graines"))"
git -C "$DEST" status --short | head -40
