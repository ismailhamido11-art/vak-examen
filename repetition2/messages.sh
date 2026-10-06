#!/usr/bin/env bash
# Répétitions 2 et 3 : affiche la demande unique d'un essai, à donner telle quelle à la création de la session neuve (par
# la session de travail). Une seule demande : préparation, demande, règles et contrôle (voir README, « Protocole »).
# Usage, depuis la racine du dépôt : bash repetition2/messages.sh <id> [<numéro de la répétition, 3 par défaut>]
# La demande est celle du README livré du kit (« La demande en une ligne »), mot pour mot. Ses trois champs sont remplis
# par apps.tsv (métier, emplacement) et par le chemin fixe de l'archive, $TRAVAIL/vak-agent.tgz (preparer.sh l'y copie ;
# la même est commitée dans l'app) ; un autre champ fait échouer le script, qui ne devine jamais.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/.." && pwd)"
TRAVAIL="${TRAVAIL:-/work}"
fail() { echo "✗ $*" >&2; exit 1; }
ID="${1:-}"
N="${2:-3}"
# --sans-fenetre : la demande seule, pour lancer.sh (D9) ; la préparation et le contrôle sont faits par le lanceur.
FORME="${3:-}"
[ -n "$ID" ] || fail "usage : bash repetition2/messages.sh <id> [<numéro de la répétition>] [--sans-fenetre]"
[ -z "$FORME" ] || [ "$FORME" = "--sans-fenetre" ] || fail "forme inconnue : $FORME (attendu : --sans-fenetre)"
# APPS=<liste> : une autre liste que apps.tsv, de même forme (les essais de l'examen).
LISTE="${APPS:-$HERE/apps.tsv}"
LIGNE="$(awk -F'\t' -v id="$ID" '$1 == id' "$LISTE")"
[ -n "$LIGNE" ] || fail "id inconnu : $ID"
IFS=$'\t' read -r _ _ _ METIER EMPLACEMENT <<<"$LIGNE"
shopt -s nullglob
ARCHIVES=("$REPO"/vertical-agent-kit/releases/vak-agent-*.tgz)
[ "${#ARCHIVES[@]}" -eq 1 ] || fail "il faut exactement une archive dans vertical-agent-kit/releases (trouvées : ${#ARCHIVES[@]})"
NOM="$(basename "${ARCHIVES[0]}")"
APP="$TRAVAIL/$ID/app"
DEMANDE="$(node -e '
const [readme, metier, emplacement, chemin] = process.argv.slice(1);
const lignes = require("fs").readFileSync(readme, "utf8").split("\n");
const i = lignes.findIndex((l) => l.includes("**La demande en une ligne**"));
if (i < 0) throw new Error(`${readme} : « La demande en une ligne » introuvable`);
const bloc = [];
for (const l of lignes.slice(i + 1)) {
  if (/^\s*>/.test(l)) bloc.push(l.replace(/^\s*> ?/, ""));
  else if (bloc.length) break;
}
let demande = bloc.join(" ").replace(/\s+/g, " ").trim();
const champ = (motif, valeur) => {
  const trouves = [...demande.matchAll(/\*<((?:[^*]|\*(?!\s|$))+?)>\*/g)].filter((m) => motif.test(m[1]));
  if (trouves.length !== 1) throw new Error(`champ ${motif} : ${trouves.length} trouvé(s) dans la demande du README`);
  demande = demande.replace(trouves[0][0], valeur);
};
champ(/métier/, metier.replace(/\.$/, ""));
champ(/onglet|bouton|emplacement/i, emplacement);
champ(/chemin|\.tgz/, chemin);
const reste = demande.match(/\*<[^>]*>\*/);
if (reste) throw new Error(`champ non rempli dans la demande du README : ${reste[0]}`);
process.stdout.write(demande);
' "$REPO/vertical-agent-kit/README.md" "$METIER" "$EMPLACEMENT" "$TRAVAIL/vak-agent.tgz")" || fail "demande du README illisible (voir ci-dessus)"
if [ "$FORME" = "--sans-fenetre" ]; then
  cat <<EOF
Essai sans fenêtre de vak (essai $ID). Personne ne répondra pendant l'essai : ne pose aucune question et n'attends personne.

L'app est dans $APP (dépôt git, branche essai) : travaille là. $DEMANDE

Règles de l'essai. Il n'y a aucun accès réel (compte Supabase, jeton, clé de modèle, déploiement) : « fini » s'arrête à la base locale, PostgreSQL 16 sur 127.0.0.1:5432, où ton utilisateur est super-utilisateur sans invite. Personne ne lancera de commande pour toi : là où la demande dit de t'arrêter pour un accès ou une clé, note la commande exacte pour ton compte rendu et continue avec ce qui reste possible. Lance toi-même toute commande locale sans secret. Ne contourne jamais un refus : note-le et continue.

À la fin, une seule fois, écris ton compte rendu : ce qui est fait, les questions que tu aurais posées, chaque commande que tu as dû contourner ou qui t'a été refusée.
EOF
  exit 0
fi
cat <<EOF
Essai automatique de vak (répétition $N, app $ID). Personne ne répondra pendant l'essai : ne pose aucune question et n'attends personne.

1. Préparation, hors chrono. Depuis la racine du dépôt ($REPO), lance \`bash repetition2/preparer.sh $ID\` et attends, dans ce même tour, sa dernière ligne « prêt : $APP (heure UTC) ». Elle peut prendre plus de 10 minutes : si la commande passe en tâche de fond, relis sa sortie jusqu'à cette ligne, sans terminer ton tour. Ne regarde pas l'app avant cette ligne : le chrono part à cette ligne.

2. La demande, celle que reçoit tout agent de code (celle du README du kit, mot pour mot) :

L'app est dans $APP (dépôt git, branche essai) : travaille là. $DEMANDE

Règles de l'essai. N'utilise aucun accès réel (compte Supabase, jeton, clé de modèle, déploiement), même si l'environnement en contient : « fini » s'arrête à la base locale. Personne ne lancera de commande pour toi : là où la demande dit de t'arrêter pour un accès ou une clé, note la commande exacte pour ton compte rendu et passe à l'étape 3. Lance toi-même toute commande locale sans secret ; si PostgreSQL ne répond plus (la machine a pu redémarrer), relance \`bash repetition2/preparer.sh $ID\` depuis la racine du dépôt (il ne touche pas à l'app). Ne contourne jamais un refus des permissions de la session : note-le et continue avec ce qui reste possible. Si la préparation s'arrête sur « environnement d'examen avec un accès réel », l'essai s'arrête : ne retire jamais ces variables toi-même, écris ton compte rendu et passe à l'étape 3. Ne termine jamais ton tour pour attendre une commande en tâche de fond : attends-la dans le même tour.

3. À la fin, une seule fois. Écris ton compte rendu : ce qui est fait, les questions que tu aurais posées, chaque commande que tu as dû contourner ou qui t'a été refusée. Puis, sans plus rien corriger, lance depuis la racine du dépôt \`bash repetition2/controler.sh $ID\`, puis \`git add -f repetition2/resultats/$ID\`, \`git commit -m "répétition $N : résultats $ID"\` et pousse ta branche. Termine par la dernière ligne du contrôleur.
EOF
