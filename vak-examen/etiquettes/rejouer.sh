#!/usr/bin/env bash
# Rejeu sans IA de la preuve sur l'état commité d'essais (etat.sh), avec le kit de ce dépôt : agent.ts et la CLI
# chargent le même code (packages/agent, construit par pnpm build:agent), lié en node_modules/@vak/agent de l'état.
# Ni dépendance de l'app, ni réseau hors le clone des apps tirées, ni IA. Une base jetable par essai (vak prove).
# La référence est le reçu que l'essai a commité : « reçu inchangé » = mêmes verdicts, empreintes et étiquette ; sinon
# <dossier>/<id>.recu.diff dit ce qui change. Écrit le 13/10 : la commande des rejeux de la 0.26.1 et de la 0.27.0
# n'avait pas été consignée.
# Usage, depuis n'importe où : bash vak-examen/etiquettes/rejouer.sh <dossier de travail> <id>…
#   SYNC=1 : vak localdb, vak sync puis vak localdb --drop avant prove (photographie refaite par le kit rejoué : à
#   mettre dès qu'une version change la photographie, sinon prove dit « base différente de la photographie »).
# Rend 1 si un essai n'a pas pu être rejoué ou si un reçu diffère, 0 sinon.
# Après une série : psql -h 127.0.0.1 -d postgres -c "alter role authenticator login noinherit password 'vak-local-only'"
# (REPRENDRE.md, « Le rôle authenticator après des essais »).
set -uo pipefail
W="${1:?usage : bash vak-examen/etiquettes/rejouer.sh <dossier de travail> <id>…}"
W="$(mkdir -p "$W" && cd "$W" && pwd)" || exit 2
shift
cd "$(dirname "${BASH_SOURCE[0]}")/../.."
REPO="$(pwd)"
KIT="$REPO/vertical-agent-kit/packages/agent"
[ "$#" -gt 0 ] || { echo "✗ aucun id" >&2; exit 2; }
[ -f "$KIT/dist/edge/vak-server.mjs" ] || { echo "✗ kit non construit : pnpm build:agent dans vertical-agent-kit/" >&2; exit 2; }
case "$W/" in "$REPO"/*) echo "✗ dossier de travail dans le dépôt : $W" >&2; exit 2 ;; esac
VAK=(node "$KIT/bin/vak.mjs")
STATUT=0
for ID in "$@"; do
  [[ "$ID" =~ ^[a-z0-9_]+$ ]] && [ -f "repetition2/resultats/$ID/preparation.json" ] || { echo "$ID : id inconnu"; STATUT=1; continue; }
  D="$W/$ID"
  rm -rf "$D"
  if ! bash vak-examen/etiquettes/etat.sh "$ID" "$D" > "$W/$ID.etat.txt" 2>&1; then
    echo "$ID : état impossible ($(tail -1 "$W/$ID.etat.txt"))"; STATUT=1; continue
  fi
  A="$(git -C "$D" ls-files | grep -E '(^|/)supabase/functions/vak/agent\.ts$' | head -1)"
  [ -n "$A" ] || { echo "$ID : aucun agent.ts"; STATUT=1; continue; }
  APP="$D/${A%supabase/functions/vak/agent.ts}"
  mkdir -p "$APP/node_modules/@vak" && ln -sfn "$KIT" "$APP/node_modules/@vak/agent"
  (
    cd "$APP" || exit 9
    if [ "${SYNC:-}" = 1 ]; then
      { "${VAK[@]}" localdb && "${VAK[@]}" sync; } > "$W/$ID.sync.txt" 2>&1
      S=$?
      "${VAK[@]}" localdb --drop >> "$W/$ID.sync.txt" 2>&1
      [ "$S" -eq 0 ] || exit 8
    fi
    "${VAK[@]}" prove > "$W/$ID.prove.txt" 2>&1
  )
  CODE=$?
  git -C "$APP" diff -- supabase/functions/vak/vak-proof.json supabase/functions/vak/schema.gen.ts > "$W/$ID.recu.diff"
  RESUME="$(grep -E '^preuve à deux comptes' "$W/$ID.prove.txt" 2>/dev/null | tail -1 | sed -E 's/ ; base laissée intacte.*//')"
  [ -n "$RESUME" ] && [ "$CODE" -le 1 ] || STATUT=1
  [ -s "$W/$ID.recu.diff" ] && STATUT=1
  echo "$ID : code $CODE ; ${RESUME:-preuve non lancée ($W/$ID.prove.txt)}"
done
exit "$STATUT"
