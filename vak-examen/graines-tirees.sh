#!/usr/bin/env bash
# Graines des apps tirées (REGLE.md, « Comment on vérifie « mes données » ») : une session scellée par app, en même
# temps (scelle/lancer.sh, TIREES=, consigne scelle/GRAINES-TIREES.md), chacune dans son dossier /srv/graines-<nom>,
# sans voir les autres. Puis les graines sont recopiées dans vak-examen/graines/<nom>/ et éprouvées sur des bases
# neuves (graines/eprouver.mjs), dans un dossier de travail qui a la disposition des sessions scellées.
# Usage, en root, depuis n'importe où : bash vak-examen/graines-tirees.sh [vak-examen/graines-tirees.tsv]
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
LISTE="${1:-vak-examen/graines-tirees.tsv}"
[ -f "$LISTE" ] || { echo "✗ $LISTE absent : lance d'abord tirage-publier.mjs" >&2; exit 1; }
NOMS=()
while IFS=$'\t' read -r NOM DEPOT COMMIT; do
  [ -n "$NOM" ] && [ "${NOM:0:1}" != "#" ] || continue
  NOMS+=("$NOM")
  S="/srv/graines-$NOM"
  rm -rf "$S" && mkdir -p "$S"
  printf '%s\t%s\t%s\n' "$NOM" "$DEPOT" "$COMMIT" > "$S.tsv"
  TIREES="$S.tsv" CONSIGNE=vak-examen/scelle/GRAINES-TIREES.md SCELLE="$S" LIMITE="${LIMITE:-60}" \
    bash vak-examen/scelle/lancer.sh > "$S.log" 2>&1 &
  echo "session scellée des graines de $NOM : lancée ($S.log)"
done < "$LISTE"
wait
for NOM in "${NOMS[@]}"; do
  S="/srv/graines-$NOM"
  echo "=== $NOM : $(grep -E 'Graines des apps tirées livrées|tours' "$S.log" | tr '\n' ' ')"
  if [ -f "$S/travail/graines/$NOM/graine.sql" ] && [ -f "$S/travail/graines/$NOM/attendu.json" ]; then
    mkdir -p "vak-examen/graines/$NOM"
    cp "$S/travail/graines/$NOM/graine.sql" "$S/travail/graines/$NOM/attendu.json" "vak-examen/graines/$NOM/"
    [ ! -f "$S/travail/graines/RAPPORT-TIREES.md" ] || cp "$S/travail/graines/RAPPORT-TIREES.md" "vak-examen/graines/RAPPORT-$NOM.md"
    cp "$S/session.jsonl" "/srv/journaux/graines-$NOM.jsonl" 2>/dev/null
  else
    echo "✗ $NOM : graine.sql ou attendu.json absent"
  fi
done

# Épreuve, hors de la bulle, dans la disposition des sessions : apps/<nom> à son commit, graines/, mesdonnees/.
E="$(mktemp -d)"
cp -r vak-examen/graines vak-examen/mesdonnees "$E/"
mkdir -p "$E/apps"
while IFS=$'\t' read -r NOM DEPOT COMMIT; do
  [ -n "$NOM" ] && [ "${NOM:0:1}" != "#" ] || continue
  git clone -q "$DEPOT" "$E/apps/$NOM" && git -C "$E/apps/$NOM" checkout -q "$COMMIT"
  # Une session a pu adapter sa copie d'eprouver.mjs (migrations rangées ailleurs) : c'est elle qui éprouve son app.
  OUTIL="/srv/graines-$NOM/travail/graines/eprouver.mjs"
  [ -f "$OUTIL" ] && cp "$OUTIL" "$E/graines/eprouver-$NOM.mjs" || cp "$E/graines/eprouver.mjs" "$E/graines/eprouver-$NOM.mjs"
  echo "=== épreuve de $NOM"
  (cd "$E" && node "graines/eprouver-$NOM.mjs" "$NOM" 2>&1 | tail -4)
done < "$LISTE"
rm -rf "$E"
