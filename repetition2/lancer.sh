#!/usr/bin/env bash
# Lanceur sans fenêtre (D9, 03/10 : agents en mode non interactif ; règle R1) : un essai de vak par Claude Code, sans
# classifieur ni humain, dans une bulle isolée, puis le contrôleur, isolé lui aussi. Aucun accès réel n'entre dans une
# bulle.
# Usage, depuis la racine du dépôt, en root : [AGENT=codex] bash repetition2/lancer.sh <id> [<numéro de la répétition, 5 par défaut>]
#  1. preparer.sh <id>, hors chrono, par la session de travail.
#  2. L'agent, dans /work/<id>/app, limité à LIMITE minutes (120 par défaut, règle de l'examen). La demande
#     (messages.sh --sans-fenetre) est celle du README du kit, mot pour mot, avec les règles de l'essai.
#     - AGENT=claude (défaut) : `claude -p` en mode bypassPermissions (ni classifieur ni question).
#     - AGENT=codex : `codex exec` (version CODEX_VERSION) sans approbation ni bac à sable propre, la bulle en tenant
#       lieu. Sa connexion (~/.codex/auth.json de la session, faite par `codex login --device-auth`) est copiée dans
#       le HOME de l'essai, puis retirée après le contrôle ; ses jetons renouvelés reviennent à la session. Son flux
#       JSON est horodaté à la réception (horodater.mjs).
#  3. controler.sh <id> : il installe, construit et teste l'app, puis lit la transcription de l'agent dans son HOME.
# La bulle (agent et contrôleur) :
#  - un espace de processus à elle : rien de la session de travail n'y est visible, ni son environnement ;
#  - /root et les brouillons de la session (/tmp/claude-*) sont cachés ; pour l'agent, aussi le dossier de ce dépôt,
#    /srv, un /tmp vide à lui, et, sous $TRAVAIL, tout sauf son essai et l'archive (06/10) ;
#  - avant l'essai, toutes les bases locales sont supprimées, sauf postgres (06/10) ;
#  - un environnement vide, sauf le proxy réseau, les certificats du système et IS_SANDBOX (mode sans permission en
#    root) ;
#  - un HOME neuf (/work/<id>/home), avec une identité git d'essai et le ~/.pgpass de la base locale.
# Limite connue : le proxy réseau de la session reste joignable (npm en a besoin) ; une commande de l'agent qui ajoute
# un dépôt distant ou pousse est marquée « à relire » par transcription.mjs.
# Sortie : repetition2/resultats/<id>/ (rapport du contrôleur, transcription masquée, chrono.json, lanceur.json) et
# /work/<id>/agent.jsonl (flux brut de l'agent). Dernière ligne : celle du contrôleur.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/.." && pwd)"
TRAVAIL="${TRAVAIL:-/work}"
LIMITE="${LIMITE:-120}"
fail() { echo "✗ $*" >&2; exit 1; }
# Disque : un essai coupé par un disque plein (06/10, ENOSPC) ne dit rien de vak. 3 Go libres au moins avant de lancer.
LIBRE_KO="$(df --output=avail -k "$TRAVAIL" 2>/dev/null | tail -1 || df --output=avail -k / | tail -1)"
[ "${LIBRE_KO:-0}" -ge 3145728 ] || fail "moins de 3 Go libres sur le disque ($((${LIBRE_KO:-0} / 1024)) Mo) : libère de la place avant de lancer un essai"
ID="${1:-}"
N="${2:-5}"
[ -n "$ID" ] || fail "usage : bash repetition2/lancer.sh <id> [<numéro de la répétition>]"
[ "$(id -u)" -eq 0 ] || fail "à lancer en root : la bulle (unshare) en a besoin"
AGENT="${AGENT:-claude}"
CODEX_VERSION="${CODEX_VERSION:-0.160.0}"
case "$AGENT" in
  claude) command -v claude >/dev/null || fail "claude (Claude Code) absent" ;;
  codex)
    CODEX_AUTH="${CODEX_HOME:-$HOME/.codex}/auth.json"
    [ -s "$CODEX_AUTH" ] || fail "Codex non connecté ($CODEX_AUTH absent) : codex login --device-auth, code saisi par le propriétaire"
    [ "$(codex --version 2>/dev/null | awk '{print $NF}')" = "$CODEX_VERSION" ] ||
      npm install -g --no-fund --no-audit "@openai/codex@$CODEX_VERSION" >/dev/null 2>&1 ||
      fail "Codex $CODEX_VERSION impossible à installer"
    ;;
  *) fail "AGENT=$AGENT : claude ou codex" ;;
esac
command -v unshare >/dev/null || fail "unshare (util-linux) absent"
[ -n "${HTTPS_PROXY:-}" ] || fail "HTTPS_PROXY absent : l'agent n'aurait pas le réseau npm"

APP="$TRAVAIL/$ID/app"
TH="$TRAVAIL/$ID/home"
FLUX="$TRAVAIL/$ID/agent.jsonl"
[ ! -e "$FLUX" ] || fail "$FLUX existe : l'essai $ID a déjà tourné (preparer.sh $ID --neuf pour recommencer)"

bash "$HERE/preparer.sh" "$ID"
bash "$HERE/messages.sh" "$ID" "$N" --sans-fenetre > "$TRAVAIL/$ID/demande.txt"

# Bases locales remises à neuf (06/10) : l'agent ne voit aucune base d'un essai ou d'une pile précédents. Seules
# restent postgres et les modèles.
for BASE in $(psql -X -w -h 127.0.0.1 -d postgres -Atc "select datname from pg_database where not datistemplate and datname <> 'postgres'"); do
  dropdb -w -h 127.0.0.1 --if-exists --force "$BASE" || fail "base $BASE impossible à supprimer avant l'essai"
done

mkdir -p "$TH"
[ ! -f "$HOME/.pgpass" ] || install -m 600 "$HOME/.pgpass" "$TH/.pgpass"
# Identité git d'essai seule : le ~/.gitconfig de la session n'entre pas (il peut porter des réglages d'accès).
git config --file "$TH/.gitconfig" user.name "Essai vak"
git config --file "$TH/.gitconfig" user.email "essai@example.invalid"
CA=/etc/ssl/certs/ca-certificates.crt
SESSION="$HOME"
for d in /tmp/claude-*; do [ -d "$d" ] && SESSION="$SESSION:$d"; done

# bulle <chemins à cacher, séparés par « : »> <commande…> : lance la commande dans la bulle, depuis le dossier courant.
# Un dossier caché devient vide (tmpfs ; /tmp reste ouvert à tous, comme d'habitude), un fichier caché devient vide.
bulle() {
  local cacher="$1"; shift
  env -i PATH="$PATH" LANG=C.UTF-8 TERM=dumb HOME="$TH" IS_SANDBOX=1 TRAVAIL="$TRAVAIL" \
    HTTPS_PROXY="$HTTPS_PROXY" https_proxy="$HTTPS_PROXY" NO_PROXY=localhost,127.0.0.1 no_proxy=localhost,127.0.0.1 \
    NODE_EXTRA_CA_CERTS="$CA" SSL_CERT_FILE="$CA" GIT_SSL_CAINFO="$CA" DENO_CERT="$CA" BULLE_CACHER="$cacher" \
    unshare --pid --fork --mount-proc --mount bash -c '
      IFS=: read -ra CACHER <<<"$BULLE_CACHER"; unset BULLE_CACHER
      for d in "${CACHER[@]}"; do
        if [ "$d" = /tmp ]; then mount -t tmpfs -o mode=1777 none /tmp || exit 97
        elif [ -d "$d" ]; then mount -t tmpfs -o mode=0700 none "$d" || exit 97
        elif [ -e "$d" ]; then mount --bind /dev/null "$d" || exit 97
        fi
      done
      exec "$@"' bulle "$@"
}

# Ce que l'agent ne voit pas (06/10) : la session et le dépôt, /srv (contrôleur, verdicts, graines), un /tmp vide à
# lui, et, sous $TRAVAIL, tout sauf son essai et l'archive (ni les essais précédents, ni leurs journaux).
CACHER_AGENT="$SESSION:$(dirname "$REPO"):/srv:/tmp"
# Groupe témoin (TEMOIN=1, REGLE.md) : l'archive de vak est cachée aussi.
[ "${TEMOIN:-0}" != 1 ] || CACHER_AGENT="$CACHER_AGENT:$TRAVAIL/vak-agent.tgz"
for E in "$TRAVAIL"/* "$TRAVAIL"/.[!.]*; do
  [ -e "$E" ] || continue
  case "$E" in "$TRAVAIL/$ID" | "$TRAVAIL/vak-agent.tgz") ;; *) CACHER_AGENT="$CACHER_AGENT:$E" ;; esac
done
# SONDE_BULLE=1 : montre ce que l'agent verrait, sans le lancer (pour éprouver la bulle), puis s'arrête.
if [ "${SONDE_BULLE:-0}" = 1 ]; then
  (cd "$APP" && bulle "$CACHER_AGENT" bash -c '
    echo "travail : $(ls -A "$TRAVAIL" | tr "\n" " ")"
    echo "archive dans la bulle : $(wc -c < "$TRAVAIL/vak-agent.tgz" 2>/dev/null || echo absente) octets"
    echo "srv : $(ls -A /srv | tr "\n" " ")"
    echo "tmp : $(ls -A /tmp | tr "\n" " ")"
    echo "racine du compte : $(ls -A /root | tr "\n" " ")"
    echo "dépôt : $(ls -A /home/user 2>&1 | tr "\n" " ")"
    echo "bases : $(psql -X -w -h 127.0.0.1 -d postgres -Atc "select string_agg(datname, chr(32) order by datname) from pg_database where not datistemplate")"
    echo "app : $(git -C . log --oneline -1)"')
  exit 0
fi

DEBUT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "essai sans fenêtre $ID : agent $AGENT lancé à $DEBUT (limite $LIMITE min)"
set +e
if [ "$AGENT" = codex ]; then
  install -d -m 700 "$TH/.codex" && install -m 600 "$CODEX_AUTH" "$TH/.codex/auth.json"
  (cd "$APP" && bulle "$CACHER_AGENT" timeout -k 60 "${LIMITE}m" \
    codex exec --dangerously-bypass-approvals-and-sandbox --json -o "$TRAVAIL/$ID/reponse-finale.txt" \
    "$(cat "$TRAVAIL/$ID/demande.txt")") < /dev/null 2> "$TRAVAIL/$ID/agent.err" | node "$HERE/horodater.mjs" > "$FLUX"
  CODE=${PIPESTATUS[0]}
  # Jetons renouvelés pendant l'essai : la copie de l'essai, si elle est valide, redevient celle de la session.
  if ! cmp -s "$TH/.codex/auth.json" "$CODEX_AUTH" &&
    node -e 'process.exit(JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))?.tokens?.refresh_token ? 0 : 1)' "$TH/.codex/auth.json" 2>/dev/null; then
    install -m 600 "$TH/.codex/auth.json" "$CODEX_AUTH"
  fi
else
  (cd "$APP" && bulle "$CACHER_AGENT" timeout -k 60 "${LIMITE}m" \
    claude -p "$(cat "$TRAVAIL/$ID/demande.txt")" --permission-mode bypassPermissions --output-format stream-json --verbose) \
    < /dev/null > "$FLUX" 2> "$TRAVAIL/$ID/agent.err"
  CODE=$?
fi
set -e
FIN="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
[ "$CODE" -ne 97 ] || fail "bulle impossible à monter (dossiers de la session non cachés) : essai annulé"
[ "$CODE" -ne 124 ] || echo "essai sans fenêtre $ID : limite de $LIMITE min atteinte, agent arrêté"
echo "essai sans fenêtre $ID : agent terminé à $FIN (code $CODE)"

# Transcription : celle de la session Claude Code (son identifiant, dans le flux), ou le flux horodaté de Codex.
SID=""
if [ "$AGENT" = claude ]; then
  SID="$(node -e '
for (const l of require("fs").readFileSync(process.argv[1], "utf8").split("\n")) {
  try { const e = JSON.parse(l); if (e.session_id) { process.stdout.write(e.session_id); break; } } catch {}
}' "$FLUX" 2>/dev/null || true)"
  [ -n "$SID" ] || echo "essai sans fenêtre $ID : identifiant de session introuvable dans $FLUX (transcription non copiée)"
fi

set +e
(cd "$REPO" && bulle "$SESSION" env CLAUDE_CODE_SESSION_ID="$SID" ESSAI_AGENT="$AGENT" bash "$HERE/controler.sh" "$ID") | tee "$TRAVAIL/$ID/controle.txt"
CONTROLE=${PIPESTATUS[0]}
set -e
RES="$HERE/resultats/$ID"
if [ -d "$RES" ]; then
  node -e '
const [flux, sortie, debut, fin, code, limite, agent, version, sessions] = process.argv.slice(1);
const fs = require("fs"), path = require("path");
const evenements = [];
for (const l of fs.readFileSync(flux, "utf8").split("\n")) {
  try { evenements.push(JSON.parse(l)); } catch {}
}
const commun = {
  protocole: "sans fenêtre (D9)",
  agent,
  bulle: "processus et dossiers de la session cachés, environnement vide sauf proxy et certificats",
};
const chrono = { debut, fin, code_agent: Number(code), limite_min: Number(limite), limite_atteinte: Number(code) === 124 };
let fiche;
if (agent === "codex") {
  // Modèle : dans les fichiers de session de Codex (HOME de l essai), à défaut inconnu.
  let modele = null;
  const fichiers = (d) => (fs.existsSync(d) ? fs.readdirSync(d, { withFileTypes: true }).flatMap((x) => (x.isDirectory() ? fichiers(path.join(d, x.name)) : [path.join(d, x.name)])) : []);
  for (const f of fichiers(sessions).filter((f) => f.endsWith(".jsonl"))) {
    for (const l of fs.readFileSync(f, "utf8").split("\n")) {
      try { const m = JSON.parse(l)?.payload?.model; if (typeof m === "string") { modele = m; break; } } catch {}
    }
    if (modele) break;
  }
  const jetons = {};
  for (const e of evenements.filter((e) => e.type === "turn.completed")) for (const [k, v] of Object.entries(e.usage ?? {})) jetons[k] = (jetons[k] ?? 0) + Number(v || 0);
  fiche = {
    ...commun,
    permission: "dangerously-bypass-approvals-and-sandbox",
    modele,
    version_codex: version,
    ...chrono,
    tours: evenements.filter((e) => e.type === "turn.completed").length,
    jetons,
    cout_usd: null,
    tours_en_echec: evenements.filter((e) => e.type === "turn.failed").length,
  };
} else {
  const init = evenements.find((e) => e.type === "system" && e.subtype === "init") ?? {};
  const resultat = evenements.filter((e) => e.type === "result").at(-1) ?? {};
  fiche = {
    ...commun,
    permission: "bypassPermissions",
    modele: init.model ? "«modèle»" : null, // identifiant hors des fichiers commités (06/10)
    version_claude_code: init.claude_code_version ?? null,
    ...chrono,
    tours: resultat.num_turns ?? null,
    cout_usd: resultat.total_cost_usd ?? null,
    refus_de_permission: (resultat.permission_denials ?? []).length,
  };
}
fs.writeFileSync(sortie, JSON.stringify(fiche, null, 2) + "\n");
' "$FLUX" "$RES/lanceur.json" "$DEBUT" "$FIN" "$CODE" "$LIMITE" "$AGENT" "$CODEX_VERSION" "$TH/.codex/sessions" || echo "essai sans fenêtre $ID : lanceur.json non écrit"
fi
# La connexion Codex ne reste pas dans le HOME de l'essai (visible des essais suivants).
[ "$AGENT" != codex ] || rm -f "$TH/.codex/auth.json"
tail -n 1 "$TRAVAIL/$ID/controle.txt"
exit "$CONTROLE"
