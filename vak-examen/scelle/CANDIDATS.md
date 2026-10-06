# Consigne : la liste des apps éligibles à l'examen

Tu constitues, en tiers, la liste des apps publiques parmi lesquelles quatre seront tirées au sort pour un examen. Lis
d'abord `REGLE.md` : seule la partie « Les apps : 7, jamais vues » te concerne, et la définition d'une table « à moi »
(point 5). Tu n'as pas à connaître le kit testé, ni à t'en servir.

## Ce que tu livres, dans `candidats/`

- `verifier.mjs` : Node 22, sans dépendance npm. `node candidats/verifier.mjs <url du dépôt> <dossier de travail>`
  clone le dépôt et juge les critères ci-dessous ; il rend une ligne JSON avec `url`, `commit` (SHA complet du HEAD),
  `date` (du dernier commit), `plateforme` (`expo` ou `next`), `tables_a_moi`, `eligible` et `raisons`. Tout ce qu'il
  juge est mécanique, sans IA.
- `candidats.tsv` : une ligne par dépôt examiné, avec les colonnes url, commit, date, plateforme, eligible et raison.
- `README.md` : comment tu as trouvé les dépôts (requêtes, sources, date), les critères tels que `verifier.mjs` les
  applique, et ses limites.

## Les critères d'éligibilité

1. Le dépôt est public sur GitHub, et ce n'est pas un fork.
2. C'est une app Next.js ou Expo : un `package.json` (racine ou paquet d'un monorepo) dépend de `next` ou de `expo`.
3. Le dépôt contient `supabase/migrations/*.sql` (à la racine ou à trois niveaux au plus).
4. Les migrations créent au moins une table « à moi » (définition de la règle, point 5).
5. `engines.node`, s'il existe, admet Node 22.
6. Le dernier commit date du 30/03/2025 ou après.
7. Les migrations s'appliquent dans l'ordre sur un PostgreSQL 16 neuf. Tu écris le minimum de Supabase qu'elles
   attendent, dans `verifier.mjs` :
   - les rôles `anon`, `authenticated` et `service_role` ;
   - le schéma `auth`, avec `users`, `uid()`, `role()` et `jwt()` ;
   - le schéma `storage`, avec `buckets` et `objects` ;
   - le schéma `extensions`, et les extensions standard de PostgreSQL.

   Une migration qui échoue seulement faute de `vector`, `http`, `pg_net`, `pg_cron`, `pgjwt`, `pgsodium`,
   `supabase_vault`, `pg_graphql` ou `wrappers` laisse l'app éligible : note-le. Pas de Docker : le serveur local est
   sur 127.0.0.1:5432, avec le super-utilisateur `root` et le mot de passe dans `~/.pgpass`. Une base par dépôt, que tu
   supprimes ensuite.
8. Exclusions :
   - les dépôts de `exclusions.txt` et tous les dépôts de leurs propriétaires ;
   - tout dépôt nommé `chatbot-ui` ou `expo-ai` ;
   - les kits du fournisseur de la base (organisation `supabase`, `supabase-community`).

## La recherche

- Cherche sur le web des dépôts GitHub d'apps Next.js ou Expo adossées à Supabase, en variant les domaines (santé,
  sport, finance, éducation, jeux, outils d'équipe…).
- Examine au moins 60 dépôts. Il faut au moins 12 apps éligibles, dont au moins 4 Expo et 4 Next ; si tu n'y
  arrives pas, dis-le.
- Clone en profondeur 1 et supprime les clones au fur et à mesure : le disque est limité.

Termine par un compte rendu court : le nombre de dépôts examinés et d'apps éligibles par plateforme, et les limites.
