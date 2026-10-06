# Rapport : graines des apps tirées

Une seule app dans `apps/TIREES.tsv` : `track_training_app` (github.com/aprescod12/track-training-app, commit `00acb94c39f8ffe3664a789fe35cec4e50e5c204`).

## Point d'attention : les migrations ne passent pas sur le minimum de Supabase tel quel

Sur `graines/supabase-minimum.sql`, deux migrations échouent (le minimum n'a pas de schéma `storage`) :

```
psql:.../20260730041000_auth_storage_baseline.sql:17: ERROR:  relation "storage.buckets" does not exist
psql:.../20260730043000_production_foundation_security.sql:279: ERROR:  schema "storage" does not exist
```

La première insère le bucket `avatars` ; la seconde crée quatre politiques sur `storage.objects` (avatars). Rien d'autre n'échoue : les 25 autres migrations passent.

Si l'éligibilité de l'app dépend du minimum non modifié, c'est un point à trancher côté examen : l'app ne passerait pas `candidats/verifier.mjs` sans stub `storage`.

Pour livrer quand même, sans rien inventer sur l'app, j'ai ajouté `graines/track_training_app/prelude.sql` : un stub minimal de `storage` (`buckets`, `objects` avec RLS, `foldername()`), appliqué avant les migrations. Avec lui, les 27 migrations passent sans erreur. `eprouver.mjs` applique ce `prelude.sql` s'il existe pour l'app. Les autres apps ne sont pas touchées.

## Livré

`graines/track_training_app/graine.sql`, `graines/track_training_app/attendu.json`, plus `prelude.sql` (voir ci-dessus) et `eprouver.mjs` modifié (ligne du prélude). `mesdonnees/` n'est pas modifié.

| App | Table « à moi » | Colonne | Nom | Compte de A | Marqueurs de B |
|---|---|---|---|---|---|
| track_training_app | public.workouts | user_id | workouts | 6 | 8 |
| track_training_app | public.workout_entries | user_id | workout entries | 9 | 15 |
| track_training_app | public.calendar_events | user_id | calendar events | 5 | 6 |
| track_training_app | public.achievements | user_id | achievements | 4 | 3 |
| track_training_app | public.exercise_prs | user_id | personal records | 3 | 2 |
| track_training_app | public.teams | created_by | teams | 2 | 4 |
| track_training_app | public.team_memberships | user_id | team memberships | 2 | 2 |

Langue : `en` (l'interface de l'app est en anglais). 40 marqueurs distincts au total.

## Empreintes SHA-256

```
f7b956304adc2808ebba8904ddcb36f82b6a1f9643b1e10d71cd9a7c9a579655  graines/track_training_app/attendu.json
1ee2f0a95fc4a71a51b5983bd8113d714836f1ed72adbab0ed870b35f1f54b13  graines/track_training_app/graine.sql
ef235f1562e1539d2cfdd764d68f90efaeaa48383d91549166e900bba3e29536  graines/track_training_app/prelude.sql
8db1338704982ba45c78914477ee86b3c0a27de511f85f95eb0d934898a1dee8  graines/eprouver.mjs
```

## Épreuves

- `node graines/eprouver.mjs track_training_app` → code 0, 78 vérifications `ok`, aucun `ÉCHEC`, aucune `note`, « tout est conforme ». Il crée une base neuve, applique le minimum, le prélude, les 27 migrations, deux comptes, la graine, puis vérifie en tant que A (rôle `authenticated`, `request.jwt.claims` posé) :
  - les comptes de A sous le filtre du propriétaire : 6, 9, 5, 4, 3, 2, 2, égaux à `attendu.json` ;
  - aucune ligne de A ne porte de marqueur ;
  - A ne voit aucun marqueur de B sous la RLS de l'app, sur les 7 tables (la RLS est active partout) ;
  - les 40 marqueurs sont présents, distincts, de la bonne forme, et aucun autre motif `MARQUEUR-` n'existe dans la base.
  La base est supprimée ensuite.
- Sans prélude, sur le minimum seul : les deux erreurs ci-dessus (base supprimée ensuite).
- `node graines/eprouver.mjs` sans argument échoue sur `demarre` (son app n'est pas ici : `ENOENT apps/demarre/supabase/migrations`). C'est attendu, je n'y ai pas touché ; j'ai passé le nom de l'app en argument.
- Non fait : `mesdonnees/juger.mjs` n'a pas été lancé (il lit un `agent.ts` de vak que je n'ai pas).

## Choix faits seul

1. **Tables retenues.** La règle vise toute table dont une colonne désigne l'utilisateur. J'ai gardé les 7 où « mes … » se comprend d'une seule façon et où une ligne de B n'est jamais lisible par A. J'ai écarté :
   - `profiles` (clé vers `auth.users`), `exercises` (`created_by`) et `organizations` (`created_by`) : leur politique SELECT est `true`, donc A lirait légitimement un marqueur de B, ce qui ruinerait la preuve. `exercises` est de plus un catalogue partagé (8 lignes venues des migrations), et « mes exercices » serait ambigu.
   - `friendships` (deux colonnes d'appartenance, aucun texte libre pour un marqueur), `organization_memberships`, `team_groups`, `team_invitations`, `entity_claims`, `verification_requests`, `organization_affiliation_requests`, `coach_athlete_assignments`, `coach_training_permissions` : colonnes `created_by` / `granted_by` / `requested_by` / `submitted_by` / `invited_user_id` visibles aussi par d'autres rôles (gouvernance d'équipe ou d'organisation), ou sans lien simple avec « mes … ». Elles supposeraient des graines de gouvernance (organisations, entraîneurs) lourdes et fragiles.
   - Les tables liées par `membership_id` (`workout_assignment_*`, `workout_templates`) ou par jointure (`entry_sets`, `field_attempts`) : elles n'ont pas de colonne propriétaire directe.
   Si l'examen veut tout le périmètre structurel, il faudra compléter la graine ; la couverture publiée (`lues / 7`) ne compte que ces 7 tables.
2. **Marqueurs de B et RLS.** Les équipes de B sont `private`, donc invisibles à A (les équipes `public` / `unlisted` le seraient). B n'a aucune amitié avec A, ni équipe commune. Les politiques de lecture des `workouts`, `achievements`, `exercise_prs` n'ouvrent qu'aux amis, aux coéquipiers ou à l'équipe : sans lien, rien ne fuit.
3. **« Mes équipes » levé.** A est propriétaire et seul membre de ses 2 équipes (`team_memberships` : 2 lignes pour A), donc « équipes créées » et « équipes dont je suis membre » donnent 2. Les équipes de B ont chacune un seul membre : B. L'appartenance est `athlete` / `owner` / `active`, pour ne pas déclencher le déclencheur de permissions d'entraîneur.
4. **Nom `workout entries`** pour `workout_entries` (un « exercice » dans une séance) : « my exercises » aurait été confondu avec le catalogue `exercises`. `exercise_prs` s'appelle `personal records`.
5. **Pas de lignes dans `entry_sets` ni `field_attempts`.** Leurs déclencheurs recalculent `exercise_prs` : les comptes de A auraient bougé. Les records de A sont insérés directement. Les 8 exercices du catalogue sont réutilisés par nom.
6. **Texte libre de B marqué** : titre, notes, étiquette, exercice, description, nom d'équipe, intitulé de rôle, valeur de succès, record. Les valeurs de A sont ordinaires, sans marqueur.
7. **Prélude `storage`** : un stub minimal, qui n'invente rien sur l'app (voir plus haut).

Graines des apps tirées livrées
