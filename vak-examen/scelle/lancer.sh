#!/usr/bin/env bash
# Session scellée qui écrit le contrôleur de l'examen (REGLE.md, « Le contrôleur » ; 03/10 : Claude Code, Codex
# abandonné). Elle n'a ni le dépôt de vak, ni le contrôleur de la répétition, ni ses verdicts : seulement la règle, la
# page publique de vak (README du kit), CAHIER.md et trois essais de la répétition (dépôt de l'app, préparation,
# transcription masquée de l'agent).
# Usage, en root, depuis la racine du dépôt : bash vak-examen/scelle/lancer.sh [<id>…]   (défaut : wacrm maybewe makerkit)
# Dossier : /srv/scelle (travail/, home/, session.jsonl). Le contrôleur écrit est dans /srv/scelle/travail/controleur.
# Reprise : CONSIGNE=vak-examen/scelle/MISE-A-JOUR-<n>.md SCELLE=/srv/scelle-<n> : la consigne remplace CAHIER.md comme
# demande (CAHIER.md reste fourni), et le contrôleur de vak-examen/controleur est copié dans travail/controleur.
# Construction d'une app de l'examen (06/10) : FICHE=vak-examen/fiches/<forme>.md CONSIGNE=vak-examen/scelle/CONSTRUIRE.md
# SCELLE=/srv/construire-<forme> : la session ne reçoit que la consigne et la fiche (FICHE.md) ; l'app est dans
# travail/app.
# Graines et juge « mes données » (06/10) : GRAINES=1 CONSIGNE=vak-examen/scelle/GRAINES.md SCELLE=/srv/graines : la
# règle, la page de vak, la consigne, l'outil de questions de la pile, les 3 apps construites et sqlnoir (répétition).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.."
REPO="$(pwd)"
S="${SCELLE:-/srv/scelle}"
LIMITE="${LIMITE:-240}"
CONSIGNE="${CONSIGNE:-}"
IDS=("$@")
[ "${#IDS[@]}" -gt 0 ] || [ "${SANS_ESSAIS:-}" = 1 ] || IDS=(wacrm maybewe makerkit)
fail() { echo "✗ $*" >&2; exit 1; }
[ "$(id -u)" -eq 0 ] || fail "à lancer en root : la bulle (unshare) en a besoin"
[ -n "${HTTPS_PROXY:-}" ] || fail "HTTPS_PROXY absent : pas de registre npm dans la bulle"
[ ! -e "$S/session.jsonl" ] || fail "$S/session.jsonl existe : une session scellée a déjà tourné (efface $S pour recommencer)"

rm -rf "$S/travail" "$S/home"
mkdir -p "$S/travail/essais" "$S/home"
if [ -n "${FICHE:-}" ]; then
  # Construction d'une app : la consigne et la fiche seulement. Ni la règle, ni la page de vak, ni les exclusions : la
  # session qui construit ne sait rien du kit testé.
  [ -n "$CONSIGNE" ] || fail "FICHE demande une CONSIGNE"
  rmdir "$S/travail/essais"
  cp "$CONSIGNE" "$S/travail/" && cp "$FICHE" "$S/travail/FICHE.md"
  DEMANDE="$(basename "$CONSIGNE")"
  IDS=()
  CONSIGNE=""
elif [ "${GRAINES:-}" = 1 ]; then
  [ -n "$CONSIGNE" ] || fail "GRAINES=1 demande une CONSIGNE"
  rmdir "$S/travail/essais"
  cp vak-examen/REGLE.md "$CONSIGNE" "$S/travail/" && cp vertical-agent-kit/README.md "$S/travail/PAGE-VAK.md"
  mkdir -p "$S/travail/pile" "$S/travail/apps" && cp vak-examen/pile/demander.mjs vak-examen/pile/PILE.md "$S/travail/pile/"
  for f in demarre equipe fonctions; do
    git clone -q "vak-examen/apps/$f.bundle" "$S/travail/apps/$f" && git -C "$S/travail/apps/$f" remote remove origin
  done
  read -r _ SQ_DEPOT SQ_COMMIT _ < <(awk -F'\t' '$1 == "sqlnoir"' repetition2/apps.tsv)
  git clone -q "$SQ_DEPOT" "$S/travail/apps/sqlnoir" && git -C "$S/travail/apps/sqlnoir" checkout -q "$SQ_COMMIT" &&
    git -C "$S/travail/apps/sqlnoir" remote remove origin
  DEMANDE="$(basename "$CONSIGNE")"
  IDS=()
  CONSIGNE=""
elif [ "${SANS_ESSAIS:-}" = 1 ]; then
  # Tâche sans rapport avec vak (liste des apps éligibles) : la règle, la consigne et les exclusions seulement.
  [ -n "$CONSIGNE" ] || fail "SANS_ESSAIS=1 demande une CONSIGNE"
  cp vak-examen/REGLE.md "$CONSIGNE" vak-examen/scelle/exclusions.txt "$S/travail/"
  DEMANDE="$(basename "$CONSIGNE")"
  IDS=()
  CONSIGNE=""
else
cp vak-examen/REGLE.md vak-examen/scelle/CAHIER.md "$S/travail/"
DEMANDE="CAHIER.md"
if [ -n "$CONSIGNE" ]; then
  cp "$CONSIGNE" "$S/travail/" && DEMANDE="$(basename "$CONSIGNE")"
  cp -r vak-examen/controleur "$S/travail/controleur" && rm -f "$S/travail/controleur/juger.sh"
fi
cp vertical-agent-kit/README.md "$S/travail/PAGE-VAK.md"
fi
for id in "${IDS[@]+"${IDS[@]}"}"; do
  [ -d "/work/$id/app/.git" ] || fail "/work/$id/app absent : essai $id introuvable"
  [ -f "repetition2/resultats/$id/transcription.jsonl.gz" ] || fail "transcription de l'essai $id absente"
  E="$S/travail/essais/$id"
  git clone -q --no-local --branch essai "/work/$id/app" "$E/app"
  git -C "$E/app" remote remove origin
  node -e '
const p = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
const { id, depot, commit, prepare, archive, debut } = p;
process.stdout.write(JSON.stringify({ id, depot, commit, prepare, archive, debut }, null, 2) + "\n");' "/work/$id/preparation.json" > "$E/preparation.json"
  gzip -dc "repetition2/resultats/$id/transcription.jsonl.gz" > "$E/journal.jsonl"
done
[ ! -f "$HOME/.pgpass" ] || install -m 600 "$HOME/.pgpass" "$S/home/.pgpass"
if [ -n "${FICHE:-}" ]; then
  git config --file "$S/home/.gitconfig" user.name "Développeur de l'app"
  git config --file "$S/home/.gitconfig" user.email "dev@example.invalid"
else
  git config --file "$S/home/.gitconfig" user.name "Contrôleur scellé"
  git config --file "$S/home/.gitconfig" user.email "controleur@example.invalid"
fi

# Bulle de lancer.sh : processus à elle, environnement vide sauf proxy et certificats ; cachés : la session de travail,
# le dépôt de vak et /work (essais complets, mesures et verdicts du contrôleur de la répétition).
CA=/etc/ssl/certs/ca-certificates.crt
CACHER="$HOME:$(dirname "$REPO"):/work"
for d in /tmp/claude-*; do [ -d "$d" ] && CACHER="$CACHER:$d"; done
echo "session scellée : lancée à $(date -u +%H:%M:%SZ) (limite $LIMITE min), essais : ${IDS[*]:-aucun}"
set +e
(cd "$S/travail" && env -i PATH="$PATH" LANG=C.UTF-8 TERM=dumb HOME="$S/home" IS_SANDBOX=1 \
  HTTPS_PROXY="$HTTPS_PROXY" https_proxy="$HTTPS_PROXY" NO_PROXY=localhost,127.0.0.1 no_proxy=localhost,127.0.0.1 \
  NODE_EXTRA_CA_CERTS="$CA" SSL_CERT_FILE="$CA" GIT_SSL_CAINFO="$CA" BULLE_CACHER="$CACHER" \
  unshare --pid --fork --mount-proc --mount bash -c '
    IFS=: read -ra CACHER <<<"$BULLE_CACHER"; unset BULLE_CACHER
    for d in "${CACHER[@]}"; do [ ! -d "$d" ] || mount -t tmpfs -o mode=0700 none "$d" || exit 97; done
    exec "$@"' bulle timeout -k 60 "${LIMITE}m" \
  claude -p "Lis $DEMANDE, dans ce dossier, et fais ce qu'il demande." --permission-mode bypassPermissions \
    --output-format stream-json --verbose) < /dev/null > "$S/session.jsonl" 2> "$S/session.err"
CODE=$?
set -e
[ "$CODE" -ne 97 ] || fail "bulle impossible à monter : session annulée"
echo "session scellée : terminée à $(date -u +%H:%M:%SZ) (code $CODE)"
node -e '
let fin = "";
for (const l of require("fs").readFileSync(process.argv[1], "utf8").split("\n")) {
  try { const e = JSON.parse(l); if (e.type === "result") fin = `${e.result ?? ""}\n(${e.num_turns} tours, ${e.total_cost_usd} $)`; } catch {}
}
console.log(fin || "aucun résultat dans le flux");' "$S/session.jsonl"
if [ -n "${FICHE:-}" ]; then
  git -C "$S/travail/app" log --oneline -5 2>/dev/null || echo "✗ aucun dépôt app/"
elif [ "${GRAINES:-}" = 1 ]; then
  ls "$S/travail/graines" "$S/travail/mesdonnees" 2>/dev/null || echo "✗ ni graines/ ni mesdonnees/"
else
  ls "$S/travail/controleur" 2>/dev/null || echo "✗ aucun dossier controleur/"
fi
