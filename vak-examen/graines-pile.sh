#!/usr/bin/env bash
# Éprouve les graines dans les conditions de la pile (pile/pile.sh, étape 1), avant le premier essai : l'app clonée à son
# commit, sa base créée par `vak localdb` de l'archive gelée (migrations de l'app sur le minimum de Supabase du kit),
# les comptes A et B insérés comme la pile (id, email), la graine appliquée avec psql -v a -v b. Puis, pour chaque
# table d'attendu.json, le compte de A sous la RLS de l'app (rôle authenticated, request.jwt.claims : la méthode du
# juge) et les lignes marquées de B que A voit. graines/eprouver.mjs éprouve sur le minimum des graines ; ici, c'est la
# base que la pile servira. Aucun outil figé n'est touché.
# Usage, en root, depuis n'importe où : bash vak-examen/graines-pile.sh [<app>…]   (défaut : les apps d'essais.tsv)
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
REPO="$(pwd)"
TGZ="$(ls "$REPO"/vertical-agent-kit/releases/vak-agent-*.tgz | head -1)"
LISTE="${APPS:-vak-examen/essais.tsv}"
APPS_DEMANDEES=("$@")
if [ "${#APPS_DEMANDEES[@]}" -eq 0 ]; then
  mapfile -t APPS_DEMANDEES < <(grep -v '^#' "$LISTE" | cut -f1 | grep -v '^temoin' | sed -E 's/_[0-9]+$//' | awk '!vu[$0]++')
fi
echecs=0
for APP in "${APPS_DEMANDEES[@]}"; do
  G="vak-examen/graines/$APP"
  read -r _ DEPOT COMMIT _ < <(awk -F'\t' -v a="$APP" '!/^#/ && $1 ~ ("^" a "_[0-9]+$") { print; exit }' "$LISTE")
  [ -n "${DEPOT:-}" ] || { echo "✗ $APP absente de $LISTE"; echecs=$((echecs + 1)); continue; }
  case "$DEPOT" in http://* | https://* | git@* | /*) ;; *) DEPOT="$REPO/$DEPOT" ;; esac
  D="$(mktemp -d)"
  NOM_BASE="graine_pile_$APP"
  echo "=== $APP (${COMMIT:0:7}, base $NOM_BASE)"
  git clone -q "$DEPOT" "$D/app" && git -C "$D/app" checkout -q "$COMMIT" || { echo "✗ clone"; echecs=$((echecs + 1)); continue; }
  # vak localdb demande supabase/config.toml : sans lui, vak init écrit ce minimum pendant l'essai (src/cli/init.ts).
  [ -f "$D/app/supabase/config.toml" ] || printf 'project_id = "app"\n' > "$D/app/supabase/config.toml"
  SORTIE="$(cd "$D/app" && npx -y --package="$TGZ" vak localdb --db-name "$NOM_BASE" 2>&1)"
  DB="$(sed -n 's/^.*URL : //p' <<<"$SORTIE" | head -1)"
  if [ -z "$DB" ]; then echo "✗ vak localdb : $(tail -3 <<<"$SORTIE")"; echecs=$((echecs + 1)); rm -rf "$D"; continue; fi
  A="$(node -e 'console.log(require("crypto").randomUUID())')"
  B="$(node -e 'console.log(require("crypto").randomUUID())')"
  ok=1
  psql -X -q -v ON_ERROR_STOP=1 "$DB" -c "insert into auth.users (id, email) values ('$A', 'a-${A:0:6}@examen-vak.test'), ('$B', 'b-${B:0:6}@examen-vak.test')" >/dev/null ||
    { echo "✗ comptes A et B refusés"; ok=0; }
  if [ "$ok" = 1 ]; then
    if psql -X -q -v ON_ERROR_STOP=1 -v a="$A" -v b="$B" -f "$G/graine.sql" "$DB" > "$D/graine.log" 2>&1; then
      echo "graine appliquée"
    else
      echo "✗ graine refusée : $(grep -m3 -E 'ERROR|ERREUR' "$D/graine.log")"; ok=0
    fi
  fi
  if [ "$ok" = 1 ]; then
    node -e '
const { spawnSync } = require("child_process");
const [db, a, attendu] = process.argv.slice(1);
const ident = (t) => t.split(".").map((p) => `"${p}"`).join(".");
const sousA = (sql) => {
  const claims = JSON.stringify({ sub: a, role: "authenticated" });
  const r = spawnSync("psql", [db, "-X", "-q", "-At", "-v", "ON_ERROR_STOP=1", "-c", `begin; set local role authenticated; select set_config(${"\x27"}request.jwt.claims${"\x27"}, ${"\x27"}${claims}${"\x27"}, true); ${sql}; rollback;`], { encoding: "utf8" });
  if (r.status !== 0) return `erreur : ${r.stderr.trim().slice(0, 160)}`;
  return Number(r.stdout.split("\n").filter(Boolean).pop());
};
let echecs = 0;
for (const t of JSON.parse(require("fs").readFileSync(attendu, "utf8"))) {
  const n = sousA(`select count(*) from ${ident(t.table)} where ${ident(t.colonne)} = ${"\x27"}${a}${"\x27"}`);
  const fuites = sousA(`select count(*) from ${ident(t.table)} x where x::text ilike ${"\x27"}%MARQUEUR-B-%${"\x27"}`);
  const bon = n === t.a && fuites === 0;
  if (!bon) echecs++;
  console.log(`${bon ? "ok  " : "ÉCHEC"} ${t.table} : A en voit ${n} sous ${t.colonne} (attendu ${t.a}), lignes marquées de B visibles : ${fuites}`);
}
process.exit(echecs ? 1 : 0);
' "$DB" "$A" "$G/attendu.json" || ok=0
  fi
  (cd "$D/app" && npx -y --package="$TGZ" vak localdb --drop --db-name "$NOM_BASE" >/dev/null 2>&1)
  rm -rf "$D"
  [ "$ok" = 1 ] && echo "$APP : conforme dans les conditions de la pile" || { echo "✗ $APP : non conforme"; echecs=$((echecs + 1)); }
done
echo
[ "$echecs" = 0 ] && echo "toutes les graines sont conformes dans les conditions de la pile" || echo "$echecs app(s) non conforme(s)"
exit $((echecs > 0))
