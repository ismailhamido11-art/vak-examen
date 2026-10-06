# Essai track_training_app_1 : échec

- App : https://github.com/aprescod12/track-training-app @ 00acb94 ; préparée 5c19395 ; HEAD aa068a2 (essai), 1 commit(s) de l'essai (2026-10-06T13:01:24+00:00 → 2026-10-06T13:01:24+00:00)
- Archive : vak-agent-0.24.3.tgz (sha256 2765b6929c14) ; vak installé dans le clone propre : 0.24.3
- Contrôle : 2026-10-06T13:01:36.879Z → 2026-10-06T13:02:50.274Z (73 s), clone propre /work/track_training_app_1/apres

**Raisons de l'échec** (2) :
- vak prove → 1 (preuve à deux comptes : non prouvé (3 éprouvée(s) (dont 2 où l'app elle-même laisse A atteindre B), 0 en échec, 4 non prouvée(s) ; 95 totaux de read_data comparés) ; reçu inchangé dans supabase/functions/vak/vak-proof.json ; base laissée intacte [code 1])
- vak doctor --db → 1 (doctor : à corriger (contrôles ✗ ; causes et corrections : node_modules/@vak/agent/docs/FAQ.md, section 19) [code 1])

**Notes** (5) :
- vérification build : échec avant et après sans ligne fichier:ligne : fins des journaux différentes, à comparer
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)
- table(s) « à moi » écartée(s) par l'agent (ignore), sans échec de preuve au journal : choix de périmètre, à dire à l'humain : exercise_prs, achievements, coach_athlete_assignments, coach_training_permissions, entity_claims, friendships, organization_affiliation_requests, organization_memberships, organizations, team_group_memberships, team_groups, team_invitations, team_memberships, teams, verification_requests, workout_assignment_entries, workout_assignment_submissions, workout_template_entries, workout_templates, exercise_prs, achievements, coach_athlete_assignments, coach_training_permissions, entity_claims, friendships, organization_affiliation_requests, organization_memberships, organizations, team_group_memberships, team_groups, team_invitations, team_memberships, teams, verification_requests, workout_assignment_entries, workout_assignment_submissions, workout_template_entries, workout_templates
- « rls » (l'app montre à un utilisateur des lignes d'un autre ; à signaler à l'humain) : exercises, profiles

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 3 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_eb3c91'` | 1 | 15 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 1 | 4 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (7) :
- ✗ VAK003 fichiers gérés modifiés ou pas à jour (supabase/functions/vak/schema.gen.ts : modifié à la main (contenu ≠ hash déclaré))
- ! VAK006 supabase/functions/vak/agent.ts se charge, avec des avertissements (tables.exercises : la politique « exercises_authenticated_select » (using (true)) rend toutes les lignes lisibles par tout utilisateur connecté dans l'app ; l'assistant ne lit que les siennes (owner « created_by ») : si ce n'est pas voulu, corrigez la RLS de l'app ; jamais shared: true (vak prove dirait fuite) ; tables.profiles : la politique « profiles_authenticated_read » (using (true)) rend toutes les lignes lisibles par tout utilisateur connecté dans l'app ; l'assistant ne lit que les siennes (owner « id ») : si ce n'est pas voulu, corrigez la RLS de l'app ; jamais shared: true (vak prove dirait fuite))
- ! VAK013 chaque table de l'app est calibrée ou ignorée (7 dans tables ; ignore : 27 tables, 17 fonctions) ; dans ignore, tables de l'utilisateur : « exercise_prs », « achievements », « coach_athlete_assignments », « coach_training_permissions », « entity_claims », « friendships », « organization_affiliation_requests », « organization_memberships », « organizations », « team_group_memberships », « team_groups », « team_invitations », « team_memberships », « teams », « verification_requests », « workout_assignment_entries », « workout_assignment_submissions », « workout_template_entries », « workout_templates » (« exercise_prs » : calibre-la, owner ; « achievements » : calibre-la, owner ; « coach_athlete_assignments » : calibre-la, owner ; « coach_training_permissions » : calibre-la, owner ; « entity_claims » : calibre-la, owner ; « friendships » : calibre-la, owner ; « organization_affiliation_requests » : calibre-la, owner ; « organization_memberships » : calibre-la, owner ; « organizations » : calibre-la, owner ; « team_group_memberships » : calibre-la, through: "team_id" ; « team_groups » : calibre-la, owner ; « team_invitations » : calibre-la, owner ; « team_memberships » : calibre-la, owner ; « teams » : calibre-la, owner ; « verification_requests » : calibre-la, owner ; « workout_assignment_entries » : calibre-la, through: "exercise_id" ; « workout_assignment_submissions » : calibre-la, through: "workout_id" ; « workout_template_entries » : calibre-la, through: "template_id" ; « workout_templates » : calibre-la, through: "team_id")
- ✗ VAK015 preuve à deux comptes du 2026-10-06 : non prouvé (entry_sets : non prouvé ; field_attempts : non prouvé ; workout_entries : non prouvé ; workouts : non prouvé)
- ✗ VAK011 schema.gen.ts absent, illisible ou modifié à la main (base : sha256:392e50410da4c568da1db9c9b54e0673900c0b03222d27711511d5989f792d67 ; schema.gen.ts : —)
- ! VAK107 avis de sécurité (avertissement) (exercises : politique « exercises_authenticated_select » using (true) : publication par l'app : voulue ? ; profiles : politique « profiles_authenticated_read » using (true) : publication par l'app : voulue ?)
- ! VAK108 colonnes qui décident des droits (avertissement) (workout_entries.workout_id : modifiable par l'utilisateur et lue par la politique « workout_entries_authorized_select » : elle décide qui voit la ligne ; entry_sets.entry_id : modifiable par l'utilisateur et lue par la politique « entry_sets_authorized_select » : elle décide qui voit la ligne ; field_attempts.entry_id : modifiable par l'utilisateur et lue par la politique « field_attempts_authorized_select » : elle décide qui voit la ligne)

**Lignes « ! », « ✗ » et « – » de prove** (6) :
- ✗ entry_sets non prouvé (graine impossible : parent workout_entries absent ; totaux de read_data non comparés (verdict non prouvé))
- ! exercises rls (l'app montre à A 8 ligne(s) de B (partage, publication) ; l'assistant ne les montre pas (owner « created_by ») ; la RLS de l'app laisse A lire la ligne de B (fuite de l'app, assistant ou non) ; lecture par l'assistant : jamais la ligne de B ; lecture par l'assistant : la ligne de A ; ligne de C : l'app la montre à A comme celle de B (lignes ouvertes à tous), non comparée ; lecture de la ligne de B par son identifiant : refusée ; totaux de read_data : 107 ligne(s) de A ajoutée(s) aux bornes des périodes ; 55 appels idéaux, chaque total égal au comptage de l'app sous la RLS de A ; total inconnu, permis, pour 1 : search « name 0 a »)
- ✗ field_attempts non prouvé (graine impossible : parent workout_entries absent ; totaux de read_data non comparés (verdict non prouvé))
- ! profiles rls (l'app montre à A 1 ligne(s) de B (partage, publication) ; l'assistant ne les montre pas (owner « id ») ; la RLS de l'app laisse A lire la ligne de B (fuite de l'app, assistant ou non) ; lecture par l'assistant : jamais la ligne de B ; lecture par l'assistant : la ligne de A ; table du compte : l'assistant ne lit que la ligne de A ; lecture de la ligne de B par son identifiant : refusée ; totaux de read_data : 2 appels idéaux, chaque total égal au comptage de l'app sous la RLS de A)
- ✗ workout_entries non prouvé (graine impossible : parent workouts absent ; totaux de read_data non comparés (verdict non prouvé))
- ✗ workouts non prouvé (graine impossible : 23514 new row for relation "workouts" violates check constraint "workouts_workout_type_check" ; totaux de read_data non comparés (verdict non prouvé))

## Preuve (vak-proof.json)

- reçu commité : non prouvé (vak 0.24.3) : calendar_events éprouvé, entry_sets non prouvé, exercises rls, field_attempts non prouvé, profiles rls, workout_entries non prouvé, workouts non prouvé
- preuve du contrôleur : non prouvé (vak 0.24.3) : calendar_events éprouvé, entry_sets non prouvé, exercises rls, field_attempts non prouvé, profiles rls, workout_entries non prouvé, workouts non prouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 18 s) | 0 (0 err., 17 s) | pas pire |
| typecheck | 0 (0 err., 7 s) | 0 (0 err., 7 s) | pas pire |
| lint | 0 (0 err., 5 s) | 0 (0 err., 5 s) | pas pire |
| tests | 0 (0 err., 3 s) | 0 (0 err., 3 s) | pas pire |
| build | 1 (0 err., 60 s) | 1 (0 err., 19 s) | pas pire : échec avant et après sans ligne fichier:ligne : fins des journaux différentes, à comparer |

## Dépendances

Aucune entrée retirée ni changée (package-lock.json : +0).

## Fichiers changés depuis le commit de l'app

**Intégration** (33) :
- A .agents/skills/vak/SKILL.md
- A .agents/skills/vak/references/calibration.md
- A .agents/skills/vak/references/features.md
- A .agents/skills/vak/references/guardrails.md
- A .agents/skills/vak/references/local-first.md
- A .agents/skills/vak/references/ui.md
- A .claude/skills/vak/SKILL.md
- A .claude/skills/vak/references/calibration.md
- A .claude/skills/vak/references/features.md
- A .claude/skills/vak/references/guardrails.md
- A .claude/skills/vak/references/local-first.md
- A .claude/skills/vak/references/ui.md
- A AGENTS.md
- A CLAUDE.md
- A app/(tabs)/assistant.tsx
- A lib/vak.ts
- M package-lock.json
- M package.json
- A supabase/.gitignore
- M supabase/config.toml
- A supabase/functions/vak/agent.ts
- A supabase/functions/vak/deno.json
- A supabase/functions/vak/index.ts
- A supabase/functions/vak/schema.gen.ts
- A supabase/functions/vak/tsconfig.json
- A supabase/functions/vak/vak-proof.json
- A supabase/functions/vak/vak-server.mjs
- A supabase/functions/vak/vak.lock.json
- A supabase/migrations/20261006125710_vak_0001_core.sql
- A supabase/migrations/20261006125711_vak_0002_feedback.sql
- A supabase/migrations/20261006125712_vak_0003_history.sql
- A supabase/migrations/20261006125713_vak_0004_quota_erase.sql
- A vendor/vak/vak-agent-0.24.3.tgz

**À relire (diff : autres.diff)** (3) :
- M app/(tabs)/_layout.tsx
- M app/(tabs)/profile.tsx (branchement : cite vak)
- M tsconfig.json

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 5c19395), autres.diff.
