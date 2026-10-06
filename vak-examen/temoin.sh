#!/usr/bin/env bash
# Le groupe témoin « sans vak » (REGLE.md, « Le groupe témoin ») : un essai par app, l'un après l'autre. Il ne décide
# pas de l'examen. Pour chaque id temoin_<app> d'essais.tsv :
#  1. l'essai : TEMOIN=1 repetition/jouer.sh (le lanceur figé ; l'app part sans l'archive de vak, la consigne fixée par
#     la règle remplace la demande, la bulle cache aussi l'archive ; 120 minutes ; rejoué à neuf s'il est coupé par la
#     limite d'usage) ;
#  2. le point 2, « l'app compile comme avant » : le contrôleur scellé (controleur/juger.sh), le même que pour les
#     essais de vak. Ses autres points ne s'appliquent pas au témoin ;
#  3. le dossier de travail est vidé (le disque ne tient pas 7 essais). L'état commité reste dans essai.bundle :
#     « mes données » (servir l'interface construite par l'agent avec la graine de l'app, puis poser en tant que A les
#     trois questions « combien de mes … ? ») se mesure ensuite, à la main si besoin, depuis cet état
#     (etiquettes/etat.sh), et s'écrit dans mesdonnees-temoin.json.
# Usage, en root, depuis n'importe où : bash vak-examen/temoin.sh [temoin_<app>…]   (défaut : tous ceux d'essais.tsv)
# Relancé après un redémarrage de la machine, il saute un essai jugé, reprend au contrôleur un essai fini, et garde les
# journaux d'un essai coupé avant de le rejouer à neuf (comme essai.sh).
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
export APPS="${APPS:-vak-examen/essais.tsv}"
TRAVAIL="${TRAVAIL:-/work}"
IDS=("$@")
[ "${#IDS[@]}" -gt 0 ] || mapfile -t IDS < <(grep -v '^#' "$APPS" | cut -f1 | grep -E '^temoin_')
for id in "${IDS[@]}"; do
  case "$id" in temoin_*) ;; *) echo "=== $id : pas un essai du groupe témoin (temoin_<app>)"; continue ;; esac
  R="repetition2/resultats/$id"
  if [ -f "$R/verdict-examen.json" ] && [ ! -d "$TRAVAIL/$id" ]; then echo "=== $id : déjà jugé"; continue; fi
  if [ -f "$R/lanceur.json" ] && [ -d "$TRAVAIL/$id" ]; then
    echo "=== $id : essai fini, le contrôleur reprend $(date -u +%H:%M:%SZ)"
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
    echo "=== $id : essai témoin, début $(date -u +%H:%M:%SZ)"
    TEMOIN=1 LIMITE=120 bash vak-examen/repetition/jouer.sh "$id"
  fi
  if [ ! -f "$R/rapport.json" ]; then echo "=== $id : pas de résultats de l'essai ($R) ; dossier de travail gardé"; continue; fi
  echo "=== $id : contrôleur scellé (point 2)"
  bash vak-examen/controleur/juger.sh "$id"
  if ! cp "/srv/verdicts/$id/verdict.json" "$R/verdict-examen.json"; then
    echo "=== $id : verdict du contrôleur absent ; dossier de travail gardé"
    continue
  fi
  node -e '
const v = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
const p2 = v.points?.p2 ?? {};
console.log(`point 2 (l app compile comme avant) : ${p2.ok === true ? "vrai" : p2.ok === false ? "faux" : "non mesuré"}`);' "$R/verdict-examen.json" | sed "s/l app/l'app/"
  [ -f "$R/essai.bundle" ] || echo "=== $id : ! pas d'essai.bundle (aucun commit de l'agent ?) : « mes données » partira de l'app à son commit"
  rm -rf "${TRAVAIL:?}/$id" "/srv/essais/$id"
  # Les caches du HOME du contrôleur (npm, pnpm) ne servent qu'à la vitesse : le disque ne les tient pas 7 fois.
  rm -rf /srv/juge-home/.npm/_cacache /srv/juge-home/.npm/_npx /srv/juge-home/.local/share/pnpm
  echo "=== $id : fin $(date -u +%H:%M:%SZ)"
done
echo "=== FIN"
