#!/usr/bin/env bash
# Rejoue le contrôleur sur des essais sabotés (créés par planter.mjs) et résume les raisons trouvées.
#   controleur/sabotages/rejouer.sh <dossier des sabotages> <dossier de travail> [nom …]
set -u
here="$(cd "$(dirname "$0")/.." && pwd)"
sab="$(cd "$1" && pwd)"; travail="$2"; shift 2
noms=("$@"); [ ${#noms[@]} -eq 0 ] && noms=($(ls "$sab"))
mkdir -p "$travail"
for n in "${noms[@]}"; do
  node "$here/controler.mjs" "$sab/$n" "$travail/$n" > "$travail/$n.log" 2>&1
  echo "== $n : $(tail -1 "$travail/$n.log")"
  jq -r '.raisons[] | "   point \(.point) [\(.code)] \(.resume)"' "$travail/$n/verdict.json" 2>/dev/null
done
