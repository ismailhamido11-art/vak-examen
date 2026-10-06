#!/usr/bin/env bash
# Un essai de l'examen, de bout en bout (REGLE.md), l'un après l'autre :
#  1. l'essai : repetition/jouer.sh (le lanceur figé ; rejoué à neuf s'il est coupé par la limite d'usage) ;
#  2. le contrôleur scellé : controleur/juger.sh ;
#  3. la pile et le juge « mes données » : pile/pile.sh avec la graine de l'app, puis mesdonnees/juger.mjs ;
#  4. l'étiquette, lue sur la pile : etiquettes/lire.mjs ;
#  5. le verdict : verdict.mjs.
# Les résultats vont dans repetition2/resultats/<id>/ (transcription masquée, rapport du lanceur, verdict-examen.json,
# mesdonnees.json, etiquette.json, verdict.txt). Puis le dossier de travail est vidé : le disque ne tient pas 14
# essais. Une pile qui ne démarre pas arrête l'essai ici, avec son journal : la règle dit quoi en faire (point 5).
# Usage, en root, depuis n'importe où : bash vak-examen/essai.sh <id>…   (ids <app>_<n> de vak-examen/essais.tsv)
# Après un redémarrage de la machine, la même commande reprend là où elle en était (voir plus bas).
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
export APPS="${APPS:-vak-examen/essais.tsv}"
TRAVAIL="${TRAVAIL:-/work}"
for id in "$@"; do
  app="${id%_[0-9]*}"
  G="vak-examen/graines/$app"
  R="repetition2/resultats/$id"
  if [ ! -f "$G/graine.sql" ] || [ ! -f "$G/attendu.json" ]; then echo "=== $id : graines de $app absentes"; continue; fi
  # Reprise après un redémarrage de la machine, par la même commande : un essai jugé n'est pas rejoué ; un essai fini
  # (lanceur.json, la dernière écriture du lanceur) reprend au contrôleur ; un essai commencé puis coupé par la machine
  # garde ses journaux dans <id>-coupe-machine-<n>, puis il est rejoué à neuf (REGLE.md, « Les essais »).
  if [ -f "$R/verdict.txt" ]; then echo "=== $id : déjà jugé ($(head -1 "$R/verdict.txt"))"; continue; fi
  if [ -f "$R/lanceur.json" ] && [ -d "$TRAVAIL/$id" ]; then
    echo "=== $id : essai fini, le jugement reprend $(date -u +%H:%M:%SZ)"
  else
    if [ -d "$TRAVAIL/$id" ]; then
      n=1
      while [ -e "$R-coupe-machine-$n" ]; do n=$((n + 1)); done
      C="$R-coupe-machine-$n"
      mkdir -p "$C"
      cp -a "$TRAVAIL/$id/agent.jsonl" "$TRAVAIL/$id/agent.err" "/work/repetition5-$id.log" "$C/" 2>/dev/null
      [ ! -d "$R" ] || mv "$R" "$C/resultats"
      echo "=== $id : coupé par la machine, journaux gardés dans $C ; rejoué à neuf"
    fi
    echo "=== $id : essai, début $(date -u +%H:%M:%SZ)"
    LIMITE=120 bash vak-examen/repetition/jouer.sh "$id"
  fi
  if [ ! -f "$R/rapport.json" ]; then echo "=== $id : pas de résultats de l'essai ($R)"; continue; fi
  echo "=== $id : contrôleur scellé"
  bash vak-examen/controleur/juger.sh "$id"
  cp "/srv/verdicts/$id/verdict.json" "$R/verdict-examen.json" || { echo "=== $id : verdict du contrôleur absent"; continue; }
  echo "=== $id : pile et juge « mes données »"
  if ! GRAINE="$G/graine.sql" bash vak-examen/pile/pile.sh up "$id" > "$R/pile.txt" 2>&1; then
    tail -5 "$R/pile.txt"
    bash vak-examen/pile/pile.sh down "$id" > /dev/null 2>&1
    echo "=== $id : la pile ne sert pas l'assistant (voir $R/pile.txt) ; dossier de travail gardé"
    continue
  fi
  node vak-examen/mesdonnees/juger.mjs "$TRAVAIL/$id/pile/pile.json" "$G/attendu.json" "$TRAVAIL/$id/apres" "$R/mesdonnees.json" | tail -1
  node vak-examen/etiquettes/lire.mjs "$TRAVAIL/$id/pile/pile.json" > "$R/etiquette.json" || echo "=== $id : étiquette illisible"
  bash vak-examen/pile/pile.sh down "$id" > /dev/null 2>&1
  node vak-examen/verdict.mjs "$R/verdict-examen.json" "$R/mesdonnees.json" > "$R/verdict.txt"
  head -1 "$R/verdict.txt"
  rm -rf "${TRAVAIL:?}/$id" "/srv/essais/$id"
  echo "=== $id : fin $(date -u +%H:%M:%SZ)"
done
