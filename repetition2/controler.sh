#!/usr/bin/env bash
# Répétition 2, message 3 (après la réponse finale de l'agent) : contrôleur indépendant d'un essai.
# Usage, depuis la racine du dépôt : bash repetition2/controler.sh <id>
# Juge le seul état commité de /work/<id>/app (clone propre de HEAD dans /work/<id>/apres) avec controle.mjs, puis
# écrit repetition2/resultats/<id>/ (rapport.md, rapport.json, essai.bundle, autres.diff, journaux/).
# Ne corrige rien, ne pousse rien. Puis transcription.mjs y copie la transcription de la session (valeurs secrètes
# masquées) et en tire chrono.json. Dernière ligne : « verdict <id> : réussi » ou « verdict <id> : échec (raisons) ».
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRAVAIL="${TRAVAIL:-/work}"
fail() { echo "✗ $*" >&2; exit 1; }
ID="${1:-}"
[ -n "$ID" ] || fail "usage : bash repetition2/controler.sh <id>"
[ -f "$TRAVAIL/$ID/preparation.json" ] || fail "$TRAVAIL/$ID/preparation.json absent : lance d'abord preparer.sh $ID"
# La machine de l'essai a pu redémarrer entre deux messages (le disque reste, les processus non) : PostgreSQL est
# redémarré ici, comme dans preparer.sh.
if ! pg_isready -q -h 127.0.0.1 -p 5432; then
  SUDO=(); [ "$(id -u)" -eq 0 ] || SUDO=(sudo)
  "${SUDO[@]}" pg_ctlcluster 16 main start 2>/dev/null || "${SUDO[@]}" service postgresql start >/dev/null 2>&1 || true
  for _ in $(seq 30); do pg_isready -q -h 127.0.0.1 -p 5432 && break; sleep 1; done
fi
pg_isready -q -h 127.0.0.1 -p 5432 || fail "PostgreSQL ne répond pas sur 127.0.0.1:5432 : relance preparer.sh $ID (il le démarre)"
echo "contrôle de l'essai $ID : $(date -u +%Y-%m-%dT%H:%M:%SZ)"
SORTIE="$(mktemp)"
set +e
TRAVAIL="$TRAVAIL" node "$HERE/controle.mjs" "$ID" | tee "$SORTIE"
CODE=${PIPESTATUS[0]}
node "$HERE/transcription.mjs" "$ID"
set -e
VERDICT="$(tail -n 1 "$SORTIE")"
rm -f "$SORTIE"
echo "$VERDICT"
exit "$CODE"
