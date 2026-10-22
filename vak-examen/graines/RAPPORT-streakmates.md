# Rapport : graines des apps tirées

L'archive `apps/TIREES.tsv` ne contient qu'une app : `streakmates` (github.com/navysum/StreakMates, commit 79c610d7…). Une seule graine est donc livrée.

## Livré

| app | table « à moi » | colonne | nom | compte de A | marqueurs de B |
|---|---|---|---|---|---|
| streakmates | public.profiles | id | profiles | 1 | 1 |
| streakmates | public.groups | created_by | groups | 2 | 1 |
| streakmates | public.group_members | user_id | group memberships | 2 | 0 |
| streakmates | public.habits | owner_id | habits | 6 | 4 |
| streakmates | public.habit_order | user_id | habit order entries | 6 | 0 |
| streakmates | public.check_ins | user_id | check-ins | 15 | 5 |
| streakmates | public.reactions | user_id | reactions | 4 | 0 |
| streakmates | public.nudges | from_user | sent nudges | 3 | 0 |
| streakmates | public.tasks | user_id | tasks | 5 | 3 |
| streakmates | public.task_completions | user_id | task completions | 3 | 0 |
| streakmates | public.focus_sessions | user_id | focus sessions | 4 | 0 |

Les tables sans marqueur n'ont aucun texte libre (identifiants, emoji à liste fermée, dates). Leurs lignes de B existent quand c'est possible, avec des nombres différents de ceux de A (sauf `nudges`, voir plus bas) : une fuite s'y verrait au comptage.

## Empreintes SHA-256

```
fd2c3ad691f8bc7c84a35e791a39a41b0e191a638a233d659269660ca9cc2794  graines/streakmates/graine.sql
9f6792b9190dcf6103aa90bbf1d80d6b28816f3aec6a178cb66e45ed2868059b  graines/streakmates/attendu.json
0caea8e6133b23742f2ab94a7bec063660c86efd958a2d4fe311266393aa645e  graines/eprouver-tirees.mjs
eb1c50416b40b5685e584ec097d7bd17b730e8f149243fbb1e13c32c818294a2  graines/supabase-minimum-tirees.sql
```
Fichiers d'origine, non modifiés : `eprouver.mjs` c6c0e036…, `supabase-minimum.sql` e9675d55….

## Épreuve

Commande : `node graines/eprouver-tirees.mjs streakmates` (base neuve `graine_streakmates_<hex>`, supprimée ensuite ; aucune base `graine_*` restante).

- Sur le minimum d'origine, `0002_realtime.sql` échoue : `ERROR:  publication "supabase_realtime" does not exist` (CONTEXT : `alter publication supabase_realtime add table public.check_ins`). La clause `exception when duplicate_object` ne couvre pas `undefined_object`. Supabase fournit cette publication ; ma copie du minimum (`supabase-minimum-tirees.sql`) ajoute `create publication supabase_realtime;`. Un avertissement `wal_level is insufficient to publish logical changes` est sans effet ici.
- Avec cet ajout, les 14 migrations (dont les deux `0013_*`, passées dans l'ordre alphabétique) passent, la graine s'applique, et toutes les vérifications sont `ok` : les 11 comptes de A sous RLS correspondent à `attendu.json` ; aucune ligne de A ne porte de marqueur ; A ne voit aucun marqueur de B sous la RLS de l'app (toutes les tables ont la RLS) ; les 14 marqueurs sont présents, distincts, et il n'y a aucun autre motif `MARQUEUR-`. Résultat : « tout est conforme ».
- Si la pile n'a pas la publication `supabase_realtime`, les migrations de streakmates y échoueront : ce serait un défaut de la pile, pas de l'app.
- Lancé sans argument, l'`eprouver.mjs` d'origine parcourt aussi `streakmates/` et échoue sur ce point ; utiliser la copie `-tirees`.

## Choix faits seul

- **Interface en anglais** (aucune i18n dans l'app) : `langue: "en"`, noms anglais au pluriel. Les textes de B sont pourtant en français et en anglais, sans conséquence.
- **Tables retenues** : toutes celles dont une colonne désigne l'utilisateur et que A peut lire. Exclue : `invite_code_attempts` (`user_id`, mais RLS sans politique : A n'y lit rien, le comptage vaudrait 0).
- **Ambiguïtés levées par la graine** :
  - A et B ne partagent aucun groupe ; A est seul membre et créateur de ses 2 groupes, donc « mes groupes », « mes appartenances », « mes habitudes » et « mes tâches » ont un seul sens. Nulle donnée partagée n'est visible de A.
  - `profiles` : 1 ligne par compte (le « mes profils » est trivial, mais respecte la définition de la règle).
  - `nudges` a deux colonnes d'utilisateur (`from_user`, `to_user`). Je filtre sur `from_user` et nomme « sent nudges ». A envoie 3 rappels à B et n'en reçoit aucun, sinon « my nudges » aurait deux sens. B n'en envoie aucun : il faudrait les adresser à A, qui les verrait (`nudges_select`) ; il n'y a pas de troisième compte. Pas de marqueur possible (aucun texte libre). Reste un risque : un assistant qui comprendrait « my nudges » comme les rappels reçus répondrait 0.
  - `check_ins` : B n'a pas de check-in sur les habitudes de A, ni A sur celles de B.
- **Marqueurs** : placés dans `profiles.display_name`, `groups.name`, `habits.title`, `check_ins.note`, `tasks.title`. Non marqués : `profiles.username` (contrainte `^[a-zA-Z][a-zA-Z0-9_]{2,19}$`, B n'en a pas), `groups.invite_code` (forme imposée par contrainte), `*.emoji` (≤ 16 caractères, vrais emoji), `profiles.avatar_url` (null).
- **Valeurs acceptées par l'app** : dates des check-ins relatives à `current_date` (0 à 5 jours en arrière) et séances de focus dans les dernières heures, pour rester dans les fenêtres des politiques d'insertion ; codes d'invitation conformes à la contrainte `groups_invite_code_shape` ; les profils sont ceux créés par le déclencheur `on_auth_user_created`, que la graine met à jour ; `habit_order` renseigné pour A (6) et B (3).
- La graine s'exécute en super-utilisateur : les politiques d'insertion et les limites de débit (qui exigent `auth.uid()`) ne s'appliquent pas, mais les contraintes et déclencheurs de données oui.
- Les dates relatives rendent les valeurs de `local_date` et de `started_at` différentes d'un jour à l'autre ; les comptes ne changent pas.

Graines des apps tirées livrées
