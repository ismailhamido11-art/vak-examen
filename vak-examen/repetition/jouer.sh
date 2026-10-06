#!/usr/bin/env bash
# Répétition 5 : joue des essais sans fenêtre l'un après l'autre (repetition2/lancer.sh), puis donne le verdict de
# chacun. Usage, en root, depuis la racine du dépôt : [AGENT=codex] bash vak-examen/repetition/jouer.sh <id>… (apps de
# repetition2/apps.tsv). Journal de chaque essai : /work/repetition5-<id>.log ; résultats : repetition2/resultats/<id>/.
# Un essai coupé par la limite d'usage du compte de l'agent n'a pas eu lieu (REGLE.md, « Les essais ») : ses résultats
# vont dans resultats/<id>-coupe-<n>/, puis il est rejoué à neuf (preparer.sh --neuf) après la remise à zéro de la
# limite, 3 fois au plus.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.."
RES=repetition2/resultats

# Heure de reprise (secondes depuis 1970) si le flux de l'agent montre la limite d'usage atteinte, sinon rien.
coupe() {
  node -e '
const fs = require("fs");
let texte = "";
try { texte = fs.readFileSync(process.argv[1], "utf8"); } catch { process.exit(0); }
let limite = false, reprise = 0;
for (const l of texte.split("\n")) {
  let e;
  try { e = JSON.parse(l); } catch { continue; }
  const info = e.type === "rate_limit_event" ? e.rate_limit_info : undefined;
  if (info?.status === "rejected") { limite = true; reprise = Math.max(reprise, Number(info.resetsAt) || 0); }
  if (e.type === "result" && e.is_error && /limit/i.test(String(e.result ?? ""))) limite = true;
  if ((e.type === "turn.failed" || e.type === "error") && /usage limit|rate limit|limit reached/i.test(JSON.stringify(e))) limite = true; // Codex
}
if (limite) process.stdout.write(String(reprise || Math.floor(Date.now() / 1000) + 3600));' "$1"
}

for id in "$@"; do
  for tentative in 1 2 3 4; do
    # Essai déjà commencé (coupé, ou machine redémarrée en route) : tout est refait à neuf, bases d'essai locales
    # comprises (vak_local_* : même chemin d'app, donc même nom de base qu'avant).
    if [ "$tentative" -gt 1 ] || [ -e "/work/$id" ]; then
      bash repetition2/preparer.sh "$id" --neuf > "/work/repetition5-$id-preparation.log" 2>&1 ||
        { echo "=== $id : préparation à neuf impossible (voir /work/repetition5-$id-preparation.log)"; continue 2; }
      for base in $(psql -h 127.0.0.1 -d postgres -Atc "select datname from pg_database where datname like 'vak\_local\_%'"); do
        dropdb -h 127.0.0.1 --if-exists "$base"
      done
    fi
    echo "=== $id : début $(date -u +%H:%M:%SZ)"
    LIMITE="${LIMITE:-120}" bash repetition2/lancer.sh "$id" 5 > "/work/repetition5-$id.log" 2>&1
    reprise="$(coupe "/work/$id/agent.jsonl")"
    if [ -z "$reprise" ]; then
      verdict="$(grep '^verdict' "/work/repetition5-$id.log" | tail -1)"
      echo "=== $id : ${verdict:-verdict absent (voir /work/repetition5-$id.log)} ; fin $(date -u +%H:%M:%SZ)"
      continue 2
    fi
    [ ! -d "$RES/$id" ] || { rm -rf "$RES/$id-coupe-$tentative"; mv "$RES/$id" "$RES/$id-coupe-$tentative"; }
    cp "/work/repetition5-$id.log" "/work/repetition5-$id-coupe-$tentative.log"
    [ "$tentative" -lt 4 ] || { echo "=== $id : coupé par la limite d'usage 4 fois : abandonné"; continue 2; }
    attente=$(( reprise - $(date +%s) + 120 ))
    [ "$attente" -gt 0 ] || attente=120
    echo "=== $id : coupé par la limite d'usage du compte (essai non joué) ; reprise à $(date -u -d "@$(( $(date +%s) + attente ))" +%H:%M:%SZ)"
    sleep "$attente"
  done
done
echo "=== FIN"
