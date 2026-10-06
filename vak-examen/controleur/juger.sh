#!/usr/bin/env bash
# Juge des essais avec le contrôleur scellé (vak-examen/controleur, écrit le 04/10 par une session scellée :
# vak-examen/scelle/). Pour chaque id : dossier d'essai /srv/essais/<id> (clone de /work/<id>/app, preparation.json
# réduit, journal = transcription masquée), puis le contrôleur, dans la bulle des essais (environnement vide : les
# scripts de l'app qu'il installe et construit ne voient aucune clé de la session). Verdict dans /srv/verdicts/<id>/.
# Usage, en root, depuis la racine du dépôt : bash vak-examen/controleur/juger.sh <id>[=<transcription.jsonl.gz>]…
# (transcription par défaut : repetition2/resultats/<id>/transcription.jsonl.gz ; JOURNAL_EN_PLUS=<fichier> ajoute des
# lignes au journal, pour un sabotage).
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.."
REPO="$(pwd)"
CTRL=/srv/controleur-juge
rm -rf "$CTRL" && cp -r vak-examen/controleur "$CTRL"
CA=/etc/ssl/certs/ca-certificates.crt
CACHER="$HOME:$(dirname "$REPO"):/work"
for d in /tmp/claude-*; do [ -d "$d" ] && CACHER="$CACHER:$d"; done
mkdir -p /srv/juge-home && [ ! -f "$HOME/.pgpass" ] || install -m 600 "$HOME/.pgpass" /srv/juge-home/.pgpass
# PostgreSQL démarré ici, hors de la bulle : la machine peut redémarrer (le disque reste, les processus non), et un
# PostgreSQL lancé dans une bulle meurt avec elle (06/10).
pg_isready -q -h 127.0.0.1 -p 5432 || pg_ctlcluster 16 main start 2>/dev/null || service postgresql start >/dev/null 2>&1 || true
for _ in $(seq 30); do pg_isready -q -h 127.0.0.1 -p 5432 && break; sleep 1; done
pg_isready -q -h 127.0.0.1 -p 5432 || { echo "✗ PostgreSQL ne répond pas sur 127.0.0.1:5432 : rien n'est jugé" >&2; exit 1; }

for arg in "$@"; do
  id="${arg%%=*}"; tr="${arg#*=}"; [ "$tr" != "$arg" ] || tr="repetition2/resultats/$id/transcription.jsonl.gz"
  E="/srv/essais/$id"; V="/srv/verdicts/$id"
  rm -rf "$E" "$V"; mkdir -p "$E" "$V"
  git clone -q --no-local --branch essai "/work/$id/app" "$E/app" && git -C "$E/app" remote remove origin
  node -e '
const p = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
const { id, depot, commit, prepare, archive, debut } = p;
process.stdout.write(JSON.stringify({ id, depot, commit, prepare, archive, debut }, null, 2) + "\n");' "/work/$id/preparation.json" > "$E/preparation.json"
  gzip -dc "$tr" > "$E/journal.jsonl"
  [ -z "${JOURNAL_EN_PLUS:-}" ] || cat "$JOURNAL_EN_PLUS" >> "$E/journal.jsonl"
  # Dossier courant visible dans la bulle (le dépôt y est caché : sinon, ENOENT à chaque commande lancée).
  (cd /srv && env -i PATH="$PATH" LANG=C.UTF-8 TERM=dumb HOME=/srv/juge-home \
    HTTPS_PROXY="$HTTPS_PROXY" https_proxy="$HTTPS_PROXY" NO_PROXY=localhost,127.0.0.1 no_proxy=localhost,127.0.0.1 \
    NODE_EXTRA_CA_CERTS="$CA" SSL_CERT_FILE="$CA" GIT_SSL_CAINFO="$CA" BULLE_CACHER="$CACHER" \
    unshare --pid --fork --mount-proc --mount bash -c '
      IFS=: read -ra CACHER <<<"$BULLE_CACHER"; unset BULLE_CACHER
      for d in "${CACHER[@]}"; do [ ! -d "$d" ] || mount -t tmpfs -o mode=0700 none "$d" || exit 97; done
      exec "$@"' bulle node "$CTRL/controler.mjs" "$E" "$V") > "$V/sortie.txt" 2>&1
  echo "$(tail -1 "$V/sortie.txt")"
done
