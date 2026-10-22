# Rapport : graines des apps tirées

## Livré

`apps/TIREES.tsv` ne contient qu'une app : `workout_app` (quitefrank/workout-app, commit 52599624…). Livré : `graines/workout_app/graine.sql` et `graines/workout_app/attendu.json`.

| app | table « à moi » | colonne | nom | compte de A | marqueurs de B |
|---|---|---|---|---|---|
| workout_app | public.workouts | user_id | workouts | 8 | 8 |
| workout_app | public.recoveries | user_id | recoveries | 2 | 9 |
| workout_app | public.user_settings | user_id | user settings | 1 | 0 |

Total : 17 marqueurs distincts (langue `en`, l'interface étant en anglais : `<html lang="en">`).

## Empreintes SHA-256

```
3928407d70fabd4c65d0bb95f2cadbadfd36d2e1dea499bdad6b70cef01f5647  graines/workout_app/attendu.json
1729154b1687f1d2e283f81638171c305df35fa548bdb79184529ff9058f54ea  graines/workout_app/graine.sql
```

## Épreuves

`node graines/eprouver.mjs workout_app` (outil inchangé : les 7 migrations sont dans `supabase/migrations`, le nom d'app n'a pas de tiret). Base neuve, minimum de Supabase, 7 migrations, deux comptes, graine, comptes sous RLS en tant que A, base supprimée. Résultat : « tout est conforme », sans aucun échec :
- workouts 8, recoveries 2, user_settings 1, égaux à `attendu.json` ;
- aucune ligne de A ne porte de marqueur ;
- A ne voit aucun marqueur de B (RLS active sur les 3 tables) ;
- les 17 marqueurs sont présents dans la base, distincts, et aucun autre motif `MARQUEUR-` n'y figure.

Les migrations passent sur le minimum sans erreur. Aucune base `graine_*` ne reste.

## Choix faits seul

- **Tables « à moi »** : seules les tables avec une colonne propriétaire directe (`user_id` → `auth.users`) : workouts, recoveries, user_settings. Les tables filles (workout_exercises, sets, clearances, events, rules, daily_checks) n'ont pas de colonne propriétaire : elles passent par une jointure dans la politique RLS. Je ne les ai pas déclarées. Elles sont peuplées, et leurs marqueurs de B sont listés sous la table mère.
- **user_settings** : table à une ligne par compte, sans texte libre. A en a 1 (nom « user settings »), B n'a donc aucun marqueur propre. Elle est incluse pour la couverture ; la question « How many of my user settings… » est un peu artificielle.
- **Ambiguïté des « workouts »** : tous ceux de A et de B sont terminés (`completed_at` renseigné), pour qu'« my workouts » ne se comprenne pas comme « les terminés » ou « les planifiés ».
- **recoveries** : nom gardé tel quel, celui de la table (pas de terme courant plus clair).
- **Bibliothèque partagée** (muscle_groups, exercises, templates, programs) : 2 lignes chacune, sans marqueur, requises par les clés étrangères. B a seulement des marqueurs dans ses propres lignes.
- Les `sets` et `workout_exercises` de A existent pour la première séance seulement ; leurs comptes ne servent pas au juge.
- Aucun défaut de l'app constaté : la RLS protège les trois tables.

Graines des apps tirées livrées
