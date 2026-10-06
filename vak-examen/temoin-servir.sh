#!/usr/bin/env bash
# « Mes données » du groupe témoin (REGLE.md, « Le groupe témoin ») : sert l'interface que l'agent a construite, sur
# la pile témoin déjà levée (temoin-pile.sh), avec le même modèle que les essais de vak (DeepSeek).
#   bash vak-examen/temoin-servir.sh deno <id> <dossier de la fonction> [VAR=valeur…]
#     Une Edge Function (Deno) : copiée dans /work/<id>/pile/fonction, servie par Deno sur le port de pile.json
#     (`fonction`), derrière le relais (/functions/v1/<nom>). Elle reçoit SUPABASE_URL, SUPABASE_ANON_KEY et
#     SUPABASE_JWT_SECRET de la pile.
#   bash vak-examen/temoin-servir.sh next <id> <état commité> <port> [VAR=valeur…]
#     Une app Next.js (route d'API) : copiée dans /work/<id>/pile/app, installée (npm ci), construite et servie par
#     `next start` sur <port>. Elle reçoit NEXT_PUBLIC_SUPABASE_URL et NEXT_PUBLIC_SUPABASE_ANON_KEY de la pile.
#   bash vak-examen/temoin-servir.sh stop <id>
# Seules adaptations du code de l'agent, dans la copie servie seulement : l'URL du fournisseur de modèle écrite en dur
# devient celle de DeepSeek (api.anthropic.com → api.deepseek.com/anthropic, api.openai.com/v1 → api.deepseek.com/v1),
# et un identifiant de modèle Claude écrit en dur devient deepseek-flash, le modèle de la pile des essais de vak.
# Le modèle et la clé passent par les variables que le code lit (VAR=valeur) ; « @DEEPSEEK_API_KEY@ » y est remplacé
# par la clé de l'environnement, jamais écrite sur le disque, et « @SERVICE_ROLE_KEY@ » par une clé service_role de la
# pile (locale). Chaque substitution faite est affichée.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
TRAVAIL="${TRAVAIL:-/work}"
DENO_VERSION="${DENO_VERSION:-2.9.6}"
fail() { echo "✗ $*" >&2; exit 1; }
MODE="${1:-}"; ID="${2:-}"
[ -n "$MODE" ] && [ -n "$ID" ] || fail "usage : bash vak-examen/temoin-servir.sh deno|next|stop <id> …"
P="$TRAVAIL/$ID/pile"
arreter() {
  [ -f "$P/pids-interface" ] || return 0
  while read -r pid; do kill -- "-$pid" 2>/dev/null || kill "$pid" 2>/dev/null || true; done < "$P/pids-interface"
  rm -f "$P/pids-interface"
}
if [ "$MODE" = stop ]; then arreter; echo "interface de $ID arrêtée"; exit 0; fi
[ -f "$P/pile.json" ] || fail "$P/pile.json absent : lance d'abord temoin-pile.sh up $ID <état>"
[ -n "${DEEPSEEK_API_KEY:-}" ] || fail "DEEPSEEK_API_KEY absent"
lire() { node -e 'const p = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8")); process.stdout.write(String(p[process.argv[2]]))' "$P/pile.json" "$1"; }
RELAIS="$(lire relais)"; ANON="$(lire anon)"; SECRET="$(lire secret)"
CA=/etc/ssl/certs/ca-certificates.crt
# Clé « service_role » de la pile (jeton HS256 signé avec son secret, local) : pour une interface qui l'exige.
SERVICE="$(node -e '
const { createHmac } = require("crypto");
const b = (x) => Buffer.from(JSON.stringify(x)).toString("base64url");
const t = `${b({ alg: "HS256", typ: "JWT" })}.${b({ role: "service_role", iss: "supabase", iat: Math.floor(Date.now() / 1000), exp: Math.floor(Date.now() / 1000) + 86400 })}`;
process.stdout.write(`${t}.${createHmac("sha256", process.argv[1]).update(t).digest("base64url")}`);' "$SECRET")"
# Variables de l'interface : « @DEEPSEEK_API_KEY@ » et « @SERVICE_ROLE_KEY@ » remplacés au lancement.
variables() { for v in "$@"; do v="${v//@DEEPSEEK_API_KEY@/$DEEPSEEK_API_KEY}"; printf '%s\n' "${v//@SERVICE_ROLE_KEY@/$SERVICE}"; done; }
# L'URL du fournisseur, dans la copie servie : chaque fichier touché est affiché.
rediriger() {
  local d="$1" f
  while IFS= read -r f; do
    sed -i -e 's#https://api\.anthropic\.com#https://api.deepseek.com/anthropic#g' -e 's#https://api\.openai\.com/v1#https://api.deepseek.com/v1#g' "$f"
    echo "  fournisseur redirigé vers DeepSeek : ${f#"$d"/}"
  done < <(grep -rlE --exclude-dir=node_modules --exclude-dir=.next 'https://api\.(anthropic\.com|openai\.com/v1)' "$d" || true)
  # Un identifiant de modèle Claude écrit en dur : le même modèle que les essais de vak (DeepSeek) le remplace.
  while IFS= read -r f; do
    sed -i -E 's#claude-(opus|sonnet|haiku|fable)(-[0-9a-z]+)+#deepseek-flash#g' "$f"
    echo "  modèle écrit en dur remplacé par deepseek-flash : ${f#"$d"/}"
  done < <(grep -rlE --exclude-dir=node_modules --exclude-dir=.next 'claude-(opus|sonnet|haiku|fable)(-[0-9a-z]+)+' "$d" || true)
}
arreter

case "$MODE" in
  deno)
    SOURCE="${3:?dossier de la fonction}"; shift 3
    F="$P/fonction"
    rm -rf "$F" && cp -r "$SOURCE" "$F"
    rediriger "$F"
    PORT="$(lire fonction_port)"
    mapfile -t VARS < <(variables "$@")
    ENTREE="index.ts"; [ -f "$F/$ENTREE" ] || fail "$F/index.ts absent"
    (cd "$F" && exec setsid env -i PATH="$PATH" HOME="$P" DENO_DIR="$P/deno" npm_config_cache="$P/npm" \
      NODE_EXTRA_CA_CERTS="$CA" DENO_CERT="$CA" HTTPS_PROXY="${HTTPS_PROXY:-}" NO_PROXY=localhost,127.0.0.1 \
      SUPABASE_URL="$RELAIS" SUPABASE_ANON_KEY="$ANON" SUPABASE_JWT_SECRET="$SECRET" "${VARS[@]}" \
      npx -y "deno@$DENO_VERSION" run --allow-env --allow-read=. --allow-net="0.0.0.0:$PORT,127.0.0.1,localhost,api.deepseek.com" \
        "$ENTREE" > "$P/interface.log" 2>&1) &
    echo $! >> "$P/pids-interface"
    URL="http://127.0.0.1:$PORT"
    ;;
  next)
    ETAT="${3:?état commité}"; PORT="${4:?port}"; shift 4
    A="$P/app"
    rm -rf "$A" && git clone -q "$ETAT" "$A"
    rediriger "$A"
    mapfile -t VARS < <(variables "$@")
    # npm ci et next build dans l'environnement de la pile seulement ; la clé n'est donnée qu'au serveur.
    (cd "$A" && env -i PATH="$PATH" HOME="$P" npm_config_cache="$P/npm" NODE_EXTRA_CA_CERTS="$CA" HTTPS_PROXY="${HTTPS_PROXY:-}" \
      NEXT_TELEMETRY_DISABLED=1 NEXT_PUBLIC_SUPABASE_URL="$RELAIS" NEXT_PUBLIC_SUPABASE_ANON_KEY="$ANON" \
      bash -c 'npm ci --no-audit --no-fund >/dev/null 2>&1 && npx next build' > "$P/interface-build.log" 2>&1) ||
      { tail -20 "$P/interface-build.log" >&2; fail "next build a échoué (voir $P/interface-build.log)"; }
    (cd "$A" && exec setsid env -i PATH="$PATH" HOME="$P" NODE_EXTRA_CA_CERTS="$CA" HTTPS_PROXY="${HTTPS_PROXY:-}" \
      NO_PROXY=localhost,127.0.0.1 NEXT_TELEMETRY_DISABLED=1 NEXT_PUBLIC_SUPABASE_URL="$RELAIS" \
      NEXT_PUBLIC_SUPABASE_ANON_KEY="$ANON" "${VARS[@]}" npx next start -p "$PORT" -H 127.0.0.1 > "$P/interface.log" 2>&1) &
    echo $! >> "$P/pids-interface"
    URL="http://127.0.0.1:$PORT"
    ;;
  *) fail "mode inconnu : $MODE (deno, next ou stop)" ;;
esac
for _ in $(seq 120); do
  [ "$(curl -s -o /dev/null -w '%{http_code}' "$URL/" || true)" != "000" ] && { echo "interface de $ID servie : $URL"; exit 0; }
  sleep 1
done
tail -20 "$P/interface.log" >&2
fail "l'interface ne répond pas (voir $P/interface.log)"
