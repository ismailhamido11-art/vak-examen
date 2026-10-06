#!/usr/bin/env bash
# Recopie l'examen dans un clone du dépôt public (https://github.com/ismailhamido11-art/vak-examen), aux mêmes chemins
# que dans le dépôt de vak, depuis l'état commité (HEAD), jamais depuis des fichiers en cours.
# Usage, depuis n'importe où : [GRAINES=1] bash vak-examen/publier.sh <clone du dépôt public>
# Recopié :
#  - vak-examen/, sans graines/ (publiées après les essais : GRAINES=1 les ajoute) ni REPRISE.md ;
#  - les scripts du lanceur des essais (repetition2/), sans ses résultats ni son journal ;
#  - RACINE.md, qui devient le README de la racine.
# - avec RESULTATS=1, les résultats des essais (voir plus bas), transcriptions masquées par masquer.mjs.
# Rien n'est commité ni poussé : le script montre l'état du clone public. Seuls les résultats sont mis dans l'index
# (git add -f) : sans cela, le .gitignore du lanceur (repetition2/.gitignore, « resultats/ ») les écarte du commit
# sans rien dire (publication du 06/10, 14:55, EXAMEN.md).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
DEST="${1:?usage : bash vak-examen/publier.sh <clone du dépôt public>}"
fail() { echo "✗ $*" >&2; exit 1; }
[ -d "$DEST/.git" ] || fail "$DEST n'est pas un dépôt git"
[ "$(cd "$DEST" && pwd)" != "$(pwd)" ] || fail "$DEST est le dépôt de vak lui-même"
# Ce qui est déjà publié ne s'efface pas par oubli d'une variable : sans elle, la copie l'enlèverait du clone public.
if [ "${RESULTATS:-0}" != 1 ] && [ -n "$(git -C "$DEST" ls-files repetition2/resultats | head -1)" ]; then
  fail "$DEST publie déjà des résultats : relancer avec RESULTATS=1 pour ne pas les effacer"
fi
if [ "${GRAINES:-0}" != 1 ] && [ -n "$(git -C "$DEST" ls-files vak-examen/graines | head -1)" ]; then
  fail "$DEST publie déjà les graines : relancer avec GRAINES=1 pour ne pas les effacer"
fi
LANCEUR=(.gitignore apps.tsv controle.mjs controler.sh horodater.mjs lancer.sh mesurer.mjs messages.sh preparer.sh
  transcription.mjs)
rm -rf "$DEST/vak-examen" "$DEST/repetition2"
git archive --format=tar HEAD -- vak-examen "${LANCEUR[@]/#/repetition2/}" | tar -x -C "$DEST"
[ "${GRAINES:-0}" = 1 ] || rm -rf "$DEST/vak-examen/graines"
# La note de reprise sert aux sessions de travail (elle nomme le dépôt privé) : elle n'est pas publiée.
rm -f "$DEST/vak-examen/REPRISE.md"
mv "$DEST/vak-examen/RACINE.md" "$DEST/README.md"
# RESULTATS=1 : les résultats commités des essais de l'examen (repetition2/resultats/<id>, coupures comprises), pour les
# ids de LISTE_ESSAIS (défaut : vak-examen/essais.tsv), sans essai.bundle : l'état commité d'un essai contient vak, il
# n'est publié que si l'examen est réussi (ETATS=1).
if [ "${RESULTATS:-0}" = 1 ]; then
  CHEMINS=()
  while read -r ID _; do
    [ -n "$ID" ] && [ "${ID:0:1}" != "#" ] || continue
    while read -r C; do [ -z "$C" ] || CHEMINS+=("$C"); done < <(git ls-tree -d --name-only HEAD repetition2/resultats/ |
      grep -E "^repetition2/resultats/${ID}(-(coupe|panne)-[a-z0-9-]+)?$" || true)
  done < "${LISTE_ESSAIS:-vak-examen/essais.tsv}"
  [ "${#CHEMINS[@]}" -eq 0 ] || git archive --format=tar HEAD -- "${CHEMINS[@]}" | tar -x -C "$DEST"
  [ "${ETATS:-0}" = 1 ] || find "$DEST/repetition2" -name essai.bundle -delete
  # Les noms et identifiants de modèle et les e-mails de tiers que la transcription du lanceur laisse passer, et ceux du
  # code d'un agent témoin (autres.diff) : masquer.mjs, sur chaque fichier des résultats, copie publiée seulement.
  mapfile -t A_MASQUER < <(find "$DEST/repetition2/resultats" -type f 2>/dev/null)
  [ "${#A_MASQUER[@]}" -eq 0 ] || node vak-examen/masquer.mjs "${A_MASQUER[@]}" | tail -1
  [ "${#CHEMINS[@]}" -eq 0 ] || git -C "$DEST" add -f -- "${CHEMINS[@]}"
  echo "résultats recopiés : ${#CHEMINS[@]} dossier(s)$([ "${ETATS:-0}" = 1 ] && echo ", états commités compris" || echo ", sans les états commités")"
fi
echo "recopié depuis $(git rev-parse --short HEAD) ($([ "${GRAINES:-0}" = 1 ] && echo "graines comprises" || echo "sans les graines"))"
git -C "$DEST" status --short | head -40
