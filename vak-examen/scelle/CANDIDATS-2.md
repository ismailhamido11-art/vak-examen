# Consigne : compléter la liste des apps éligibles à l'examen (22/10)

Tu complètes, en tiers, la liste des apps publiques parmi lesquelles quatre seront tirées au sort pour un examen. La
liste a été faite le 04/10 par une autre session, puis réduite à chaque examen : les apps tirées sont exclues de
l'examen suivant. Il ne reste qu'une app Next.js éligible ; la règle en demande au moins deux au tirage, et un tirage
n'a de sens que parmi assez d'apps.

Lis d'abord `REGLE.md` : seule la partie « Les apps : 7, jamais vues » te concerne, et la définition d'une table « à
moi » (point 5). Puis lis `candidats/README.md` : comment la liste a été faite, et les critères tels que
`candidats/verifier.mjs` les applique. Tu n'as pas à connaître le kit testé, ni à le chercher, ni à t'en servir.

## Ce que tu as, dans `candidats/`

- `verifier.mjs` : l'outil qui juge un dépôt (`node candidats/verifier.mjs <url du dépôt> <dossier de travail>`, une
  ligne JSON en sortie). **Ne le modifie pas** : la liste entière doit être jugée par le même outil. S'il se trompe sur
  un dépôt, ne le corrige pas : note le dépôt et la raison dans le compte rendu.
- `candidats.tsv` : les 80 dépôts déjà examinés, éligibles ou non.
- `exclusions.txt` : les apps exclues, avec leurs propriétaires (l'outil les lit lui-même).
- `README.md` : la méthode du 04/10.

## Ce que tu fais

1. Cherche sur le web des dépôts GitHub d'apps **Next.js** ou **Expo** adossées à Supabase, avec un dossier
   `supabase/migrations`. Varie les domaines (santé, sport, finance, éducation, jeux, outils d'équipe, réservation,
   associations, voyages, cuisine, apprentissage…) et les formulations. **Cherche d'abord des apps Next.js** : ce sont
   elles qui manquent.
2. Écarte d'emblée, sans les compter :
   - les dépôts déjà dans `candidats.tsv` (même URL, à la casse près) ;
   - les dépôts de `exclusions.txt` et tous ceux de leurs propriétaires ;
   - tout dépôt nommé `chatbot-ui` ou `expo-ai`, et les organisations `supabase` et `supabase-community`.
3. Juge chaque dépôt nouveau avec `verifier.mjs`, un à la fois (il crée une base PostgreSQL et des rôles, puis les
   supprime ; deux en même temps se gêneraient). Ajoute sa ligne à la fin de `candidats.tsv`, au même format que les
   autres (url, commit, date, plateforme, eligible, raison ; la raison est la liste `raisons` jointe par « ; »).
4. Examine au moins 40 dépôts nouveaux. Il faut **au moins 6 nouvelles apps éligibles, dont au moins 4 Next.js et 2
   Expo**. Si tu n'y arrives pas en 120 minutes, arrête-toi et dis-le.
5. Ajoute à `candidats/README.md` une section « Ajouts du 22/10/2026 » : les requêtes et les sources, la date, le
   nombre de dépôts examinés et d'apps éligibles par plateforme, et les limites (ce que tu n'as pas pu vérifier).
   Ne change rien d'autre dans le README.

## Les règles

- Pas de Docker. Le serveur PostgreSQL local est sur 127.0.0.1:5432, avec le super-utilisateur `root` et le mot de
  passe dans `~/.pgpass`. Ne touche à aucune base que tu n'as pas créée.
- Clone en profondeur 1 et supprime les clones au fur et à mesure : le disque est limité (garde moins de 2 Go).
- Ne lis pas le code des apps au-delà de ce qu'il faut pour savoir si c'est une app Next.js ou Expo adossée à
  Supabase : l'outil juge le reste.
- Ne publie rien, n'ouvre aucun ticket, ne pousse rien.

Termine par un compte rendu court : le nombre de dépôts nouveaux examinés, les apps éligibles nouvelles par
plateforme (avec leur URL), les dépôts où l'outil t'a paru se tromper, et les limites.
