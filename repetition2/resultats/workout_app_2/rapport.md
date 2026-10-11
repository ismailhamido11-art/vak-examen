# Essai workout_app_2 : échec

- App : https://github.com/quitefrank/workout-app @ 5259962 ; préparée 353d6fd ; HEAD 59f1616 (essai), 1 commit(s) de l'essai (2026-10-11T03:15:32+00:00 → 2026-10-11T03:15:32+00:00)
- Archive : vak-agent-0.27.0.tgz (sha256 8e695dc7571b) ; vak installé dans le clone propre : 0.27.0
- Contrôle : 2026-10-11T03:16:11.482Z → 2026-10-11T03:17:28.058Z (77 s), clone propre /work/workout_app_2/apres

**Raisons de l'échec** (2) :
- vak prove → 1 (preuve à deux comptes : non prouvé (6 éprouvée(s), 0 en échec, 2 non prouvée(s) ; 82 totaux de read_data comparés) ; reçu inchangé dans supabase/functions/vak/vak-proof.json ; base laissée intacte [code 1])
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
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_9254b1'` | 1 | 13 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 1 | 3 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (2) :
- ✗ VAK015 preuve à deux comptes du 2026-10-11 : non prouvé (v_workout_exercise_e1rm : non prouvé ; v_workout_exercise_top_set : non prouvé)
- ! VAK108 colonnes qui décident des droits (avertissement) (workout_exercises.workout_id : modifiable par l'utilisateur et lue par la politique « sets_owner_all » : elle décide qui voit la ligne ; sets.workout_exercise_id : modifiable par l'utilisateur et lue par la politique « sets_owner_all » : elle décide qui voit la ligne)

**Lignes « ! », « ✗ » et « – » de prove** (2) :
- ✗ v_workout_exercise_e1rm non prouvé (l'app ne montre à A aucune de ses données dans cette relation (graine hors de ses règles, ou aucune colonne ne l'identifie) ; sans identifiant de ligne (vue, table sans clé) : vérifiée par les valeurs semées (identifiants, textes) ; RLS de l'app : aucune donnée de B visible pour A ; lecture par l'assistant : aucune donnée de B ; totaux de read_data non comparés (verdict non prouvé))
- ✗ v_workout_exercise_top_set non prouvé (l'app ne montre à A aucune de ses données dans cette relation (graine hors de ses règles, ou aucune colonne ne l'identifie) ; sans identifiant de ligne (vue, table sans clé) : vérifiée par les valeurs semées (identifiants, textes) ; RLS de l'app : aucune donnée de B visible pour A ; lecture par l'assistant : aucune donnée de B ; totaux de read_data non comparés (verdict non prouvé))

## Preuve (vak-proof.json)

- reçu commité : non prouvé (vak 0.27.0) : exercises éprouvé, sets éprouvé, templates éprouvé, user_settings éprouvé, v_workout_exercise_e1rm non prouvé, v_workout_exercise_top_set non prouvé, workout_exercises éprouvé, workouts éprouvé
- preuve du contrôleur : non prouvé (vak 0.27.0) : exercises éprouvé, sets éprouvé, templates éprouvé, user_settings éprouvé, v_workout_exercise_e1rm non prouvé, v_workout_exercise_top_set non prouvé, workout_exercises éprouvé, workouts éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 0 s) | 0 (0 err., 3 s) | pas pire |
| typecheck | 0 (0 err., 4 s) | 0 (0 err., 3 s) | pas pire |
| lint | 0 (0 err., 4 s) | 0 (0 err., 11 s) | pas pire |
| tests | 0 (0 err., 7 s) | 0 (0 err., 8 s) | pas pire |
| build | 0 (0 err., 21 s) | 0 (0 err., 28 s) | pas pire |

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
- A supabase/migrations/20261011030939_vak_0001_core.sql
- A supabase/migrations/20261011030940_vak_0002_feedback.sql
- A supabase/migrations/20261011030941_vak_0003_history.sql
- A supabase/migrations/20261011030942_vak_0004_quota_erase.sql
- M tsconfig.json
- A vendor/vak/vak-agent-0.27.0.tgz

**À relire (diff : autres.diff)** (7) :
- M scripts/__tests__/migrations.test.ts
- M src/app/layout.tsx (branchement : cite vak)
- M src/app/page.tsx
- A src/app/settings/agent-settings.tsx (branchement : cite vak)
- A src/app/settings/page.tsx
- A src/app/vak-button.tsx (branchement : cite vak)
- A src/lib/supabase/client.ts

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 353d6fd), autres.diff.
