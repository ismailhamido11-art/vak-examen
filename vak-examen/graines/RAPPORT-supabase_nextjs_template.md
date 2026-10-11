# Rapport : graines des apps tirées

## Livré

`apps/TIREES.tsv` ne contient qu'une app : `supabase_nextjs_template` (Razikus, commit d519bf18…).

| app | table « à moi » | colonne | nom | compte de A | marqueurs de B |
|---|---|---|---|---|---|
| supabase_nextjs_template | public.todo_list | owner | tasks (langue `en`) | 6 | 8 |

Fichiers livrés :
- `graines/supabase_nextjs_template/graine.sql`, `graines/supabase_nextjs_template/attendu.json` ;
- `graines/eprouver-tirees.mjs` : copie adaptée d'`eprouver.mjs` (le défaut est l'app tirée ; applique les compléments ; la variable `AAL` ajoute `aal` aux claims) ;
- `graines/supabase-complements-tirees.sql` : `auth.mfa_factors` et un schéma `storage` réduit.

Empreintes SHA-256 :
```
f3c404811a30df0e7fd804a5328b7a0dc756d1a075865bcbfb814367ab282686  supabase_nextjs_template/attendu.json
3ca0c84e5ee9cb20ca2489953c9b08a8a269b1f3739c7072637be83d50692671  supabase_nextjs_template/graine.sql
8a41c679ed8df33b14b849290771613c973adca889c740348b48b7969980ebb9  eprouver-tirees.mjs
eeed31a04ab9c7bbf089f38a77531e6d3115d9d710ab5abfd25f9d42bef5c477  supabase-complements-tirees.sql
```

## ⚠ Point à traiter avant l'examen : le juge lira 0, pas 6, si les jetons n'ont pas `aal`

La politique de `todo_list` exige `authenticative.is_user_authenticated()`, qui lit `auth.jwt()->>'aal'`. Sans claim `aal`, la fonction rend NULL, donc la politique refuse tout. Le juge pose seulement `{sub, role}`.

Résultat mesuré : sous `{sub, role}`, A voit **0** ligne de `todo_list`. Avec `"aal":"aal1"`, A en voit **6**. Dans le premier cas le juge compte 0 ≠ `a` = 6 et sort en `erreur` (code 3). Je ne peux pas modifier le juge. Je n'ai pas non plus truqué `a` : il vaut le vrai nombre de lignes de A, 6. Si les jetons de la pile viennent de GoTrue, ils portent `aal`, et la pile et l'assistant voient bien 6. Je n'ai pas pu le vérifier (je ne vois pas la pile). Le juge a besoin de `aal` dans ses claims, ou il faut accepter une `erreur` sur cette app.

Les migrations passent, mais le minimum de Supabase ne suffit pas (voir ci-dessous).

## Épreuves (base neuve, supprimée ensuite ; plus aucune base `graine_*` ni `essai_*`)

1. Migrations sur `supabase-minimum.sql` seul, sortie exacte :
```
20250107210416_MFA.sql : ok
20250130165844_example_storage.sql : ERROR:  relation "storage.buckets" does not exist
20250130181110_storage_policies.sql : ERROR:  schema "storage" does not exist
20250130181641_todo_list.sql : ok
```
   Le minimum n'a pas de schéma `storage`. Sur une vraie pile Supabase il existe. `auth.mfa_factors` manque aussi : elle n'est lue qu'à l'appel de la fonction, donc sans erreur de migration, mais sans elle la lecture échoue.
2. `node graines/eprouver-tirees.mjs` (claims `{sub, role}`) : `ÉCHEC public.todo_list : 0 lignes de A sous owner (attendu.json : 6)` ; le reste est conforme (aucune ligne de A ne porte de marqueur ; A ne voit aucun marqueur de B ; 8 marqueurs présents, distincts ; aucun autre motif `MARQUEUR-`). Code de sortie 1.
3. `AAL=aal1 node graines/eprouver-tirees.mjs` : `6 lignes de A sous owner (attendu.json : 6)`, tout conforme, code de sortie 0. Aucune fuite de B sous la RLS de l'app (RLS active sur `todo_list`).

## Choix faits seul

- Une seule table « à moi » : `todo_list`. `storage.objects` est protégée par le préfixe du chemin (`name ~ '^<uid>/'`) et non par une colonne propriétaire. Le bucket `files` est un schéma de Supabase, non une table de l'app. Je l'ai exclue ; elle n'a pas de graine.
- `nom` = « tasks », `langue` = `en` : l'interface est entièrement en anglais (« Add Task », « Create New Task »). L'ambiguïté « mes tâches » (faites ou à faire) est levée : toutes les tâches de A comptent, 6, dont 2 faites et 4 non faites.
- Compléments de Supabase écrits dans un fichier à part, sans toucher à `supabase-minimum.sql` ni à `eprouver.mjs` d'origine. Les stubs sont minimaux, juste de quoi faire passer les migrations.
- Les 8 marqueurs de B sont aléatoires (titre et description de chacune de ses 4 tâches). Les tâches de A n'en contiennent aucun.
- Le dossier `supabase/migrations_for_old` (ancien schéma sans `authenticative`) n'est pas joué : seule `supabase/migrations` est la voie normale de l'app.

Graines des apps tirées livrées
