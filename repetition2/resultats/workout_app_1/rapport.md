# Essai workout_app_1 : échec

- App : https://github.com/quitefrank/workout-app @ 5259962 ; préparée 353d6fd ; HEAD 9c22d65 (essai), 1 commit(s) de l'essai (2026-10-11T02:09:20+00:00 → 2026-10-11T02:09:20+00:00)
- Archive : vak-agent-0.27.0.tgz (sha256 8e695dc7571b) ; vak installé dans le clone propre : 0.27.0
- Contrôle : 2026-10-11T02:09:59.007Z → 2026-10-11T02:11:14.671Z (76 s), clone propre /work/workout_app_1/apres

**Raisons de l'échec** (2) :
- vak prove → 1 (preuve à deux comptes : non prouvé (5 éprouvée(s), 0 en échec, 3 non prouvée(s) ; 112 totaux de read_data comparés) ; reçu inchangé dans supabase/functions/vak/vak-proof.json ; base laissée intacte [code 1])
- vak doctor --db → 1 (doctor : à corriger (contrôles ✗ ; causes et corrections : node_modules/@vak/agent/docs/FAQ.md, section 19) [code 1])

**Notes** (3) :
- verrou commité encore désynchronisé : npx -y bun@1 install --frozen-lockfile refusé après l'essai
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 1 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_6be095'` | 1 | 13 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 1 | 3 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (2) :
- ✗ VAK015 preuve à deux comptes du 2026-10-11 : non prouvé (v_user_weekly_workouts : non prouvé ; v_workout_exercise_tonnage : non prouvé ; v_workout_exercise_top_set : non prouvé)
- ! VAK108 colonnes qui décident des droits (avertissement) (workout_exercises.workout_id : modifiable par l'utilisateur et lue par la politique « sets_owner_all » : elle décide qui voit la ligne ; sets.workout_exercise_id : modifiable par l'utilisateur et lue par la politique « sets_owner_all » : elle décide qui voit la ligne)

**Lignes « ! », « ✗ » et « – » de prove** (3) :
- ✗ v_user_weekly_workouts non prouvé (l'app ne montre à A aucune de ses données dans cette relation (graine hors de ses règles, ou aucune colonne ne l'identifie) ; sans identifiant de ligne (vue, table sans clé) : vérifiée par les valeurs semées (identifiants, textes) ; RLS de l'app : aucune donnée de B visible pour A ; lecture par l'assistant : aucune donnée de B ; totaux de read_data non comparés (verdict non prouvé))
- ✗ v_workout_exercise_tonnage non prouvé (l'app ne montre à A aucune de ses données dans cette relation (graine hors de ses règles, ou aucune colonne ne l'identifie) ; sans identifiant de ligne (vue, table sans clé) : vérifiée par les valeurs semées (identifiants, textes) ; RLS de l'app : aucune donnée de B visible pour A ; lecture par l'assistant : aucune donnée de B ; totaux de read_data non comparés (verdict non prouvé))
- ✗ v_workout_exercise_top_set non prouvé (l'app ne montre à A aucune de ses données dans cette relation (graine hors de ses règles, ou aucune colonne ne l'identifie) ; sans identifiant de ligne (vue, table sans clé) : vérifiée par les valeurs semées (identifiants, textes) ; RLS de l'app : aucune donnée de B visible pour A ; lecture par l'assistant : aucune donnée de B ; totaux de read_data non comparés (verdict non prouvé))

## Preuve (vak-proof.json)

- reçu commité : non prouvé (vak 0.27.0) : exercises éprouvé, muscle_groups éprouvé, sets éprouvé, v_user_weekly_workouts non prouvé, v_workout_exercise_tonnage non prouvé, v_workout_exercise_top_set non prouvé, workout_exercises éprouvé, workouts éprouvé
- preuve du contrôleur : non prouvé (vak 0.27.0) : exercises éprouvé, muscle_groups éprouvé, sets éprouvé, v_user_weekly_workouts non prouvé, v_workout_exercise_tonnage non prouvé, v_workout_exercise_top_set non prouvé, workout_exercises éprouvé, workouts éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 16 s) | 0 (0 err., 3 s) | pas pire |
| typecheck | 0 (0 err., 4 s) | 0 (0 err., 4 s) | pas pire |
| lint | 0 (0 err., 4 s) | 0 (0 err., 11 s) | pas pire |
| tests | 0 (0 err., 6 s) | 0 (0 err., 8 s) | pas pire |
| build | 0 (0 err., 20 s) | 0 (0 err., 26 s) | pas pire |

## Dépendances

Aucune entrée retirée ni changée (bun.lock : +0).

## Fichiers changés depuis le commit de l'app

**Intégration** (28) :
- A .agents/skills/vak/SKILL.md
- A .agents/skills/vak/references/calibration.md
- A .agents/skills/vak/references/features.md
- A .agents/skills/vak/references/guardrails.md
- A .agents/skills/vak/references/local-first.md
- A .agents/skills/vak/references/ui.md
- A AGENTS.md
- M CLAUDE.md
- M package.json
- A src/app/assistant/assistant.tsx
- A src/app/assistant/page.tsx
- A src/lib/vak.ts
- M supabase/.gitignore
- M supabase/config.toml
- A supabase/functions/vak/agent.ts
- A supabase/functions/vak/deno.json
- A supabase/functions/vak/index.ts
- A supabase/functions/vak/schema.gen.ts
- A supabase/functions/vak/tsconfig.json
- A supabase/functions/vak/vak-proof.json
- A supabase/functions/vak/vak-server.mjs
- A supabase/functions/vak/vak.lock.json
- A supabase/migrations/20261011020341_vak_0001_core.sql
- A supabase/migrations/20261011020342_vak_0002_feedback.sql
- A supabase/migrations/20261011020343_vak_0003_history.sql
- A supabase/migrations/20261011020344_vak_0004_quota_erase.sql
- M tsconfig.json
- A vendor/vak/vak-agent-0.27.0.tgz

**À relire (diff : autres.diff)** (8) :
- M scripts/__tests__/migrations.test.ts
- A src/app/assistant-button.tsx (branchement : cite vak)
- M src/app/layout.tsx (branchement : cite vak)
- A src/app/login/page.tsx
- M src/app/page.tsx
- A src/app/settings/agent-settings.tsx (branchement : cite vak)
- A src/app/settings/page.tsx
- A src/lib/supabase/client.ts

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 353d6fd), autres.diff.
