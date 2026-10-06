#!/usr/bin/env bash
# Les lecteurs des étiquettes (REGLE.md, « Comment on compte les seuils » ; etiquettes/README.md) : une session Claude
# Code scellée neuve par étiquette (scelle/lancer.sh, mode ETIQUETTE=, consigne scelle/ETIQUETTE.md), toutes en même
# temps, chacune dans son dossier /srv/lecteur-<id>. Les dossiers sont tous créés avant le premier lancement : une
# session cache les dossiers de /srv qui existent à son lancement. À lancer seulement après la publication des vérités.
# Sortie, pour chaque essai : repetition2/resultats/<id>/reponses-lecteur.json et etiquette-lue.txt (les lignes que le
# lecteur a reçues) ; journal de la session dans /srv/journaux/lecteur-<id>.jsonl.
# Usage, en root, depuis n'importe où : bash vak-examen/lecteurs.sh [<id>…]
#   (défaut : les essais d'essais.tsv, hors témoins, dont l'étiquette a été lue sur la pile)
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
IDS=("$@")
[ "${#IDS[@]}" -gt 0 ] || mapfile -t IDS < <(grep -v '^#' vak-examen/essais.tsv | cut -f1 | grep -v -E '^temoin[-_]')
mkdir -p /srv/journaux
A_LANCER=()
for id in "${IDS[@]}"; do
  [ -n "$id" ] || continue
  if [ ! -f "repetition2/resultats/$id/etiquette.json" ]; then echo "$id : pas d'étiquette lue (la pile n'a pas servi l'assistant)"; continue; fi
  rm -rf "/srv/lecteur-$id" && mkdir -p "/srv/lecteur-$id"
  A_LANCER+=("$id")
done
for id in "${A_LANCER[@]}"; do
  ETIQUETTE="repetition2/resultats/$id/etiquette.json" CONSIGNE=vak-examen/scelle/ETIQUETTE.md SCELLE="/srv/lecteur-$id" LIMITE=10 \
    bash vak-examen/scelle/lancer.sh > "/srv/journaux/lecteur-$id.log" 2>&1 &
done
wait
for id in "${A_LANCER[@]}"; do
  S="/srv/lecteur-$id"
  cp "$S/session.jsonl" "/srv/journaux/lecteur-$id.jsonl" 2>/dev/null
  if [ -f "$S/travail/reponses.json" ] && node -e 'JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))' "$S/travail/reponses.json" 2>/dev/null; then
    cp "$S/travail/reponses.json" "repetition2/resultats/$id/reponses-lecteur.json"
    cp "$S/travail/ETIQUETTE.txt" "repetition2/resultats/$id/etiquette-lue.txt"
    echo "$id : réponses écrites"
  else
    echo "✗ $id : pas de reponses.json lisible (voir /srv/journaux/lecteur-$id.log) : relancer ce lecteur seul"
  fi
done
