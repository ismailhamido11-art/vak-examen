# Essai workout_plan_companion_2 : échec

- App : https://github.com/AndreuCrespo/workout-plan-companion @ ebf680c ; préparée 6db30b6 ; HEAD ded3670 (essai), 1 commit(s) de l'essai (2026-10-06T14:17:34+00:00 → 2026-10-06T14:17:34+00:00)
- Archive : vak-agent-0.24.3.tgz (sha256 2765b6929c14) ; vak installé dans le clone propre : 0.24.3
- Contrôle : 2026-10-06T14:17:49.410Z → 2026-10-06T14:18:09.788Z (20 s), clone propre /work/workout_plan_companion_2/apres

**Raisons de l'échec** (5) :
- vérification typecheck pire qu'avant : vérification disparue (ni script typecheck ni tsconfig.json)
- vérification lint pire qu'avant : vérification disparue (pas de script lint)
- vérification build pire qu'avant : vérification disparue (ni Next ni Expo)
- vak prove → 1 (preuve à deux comptes : non prouvé (5 éprouvée(s), 0 en échec, 3 non prouvée(s) ; 108 totaux de read_data comparés) ; reçu inchangé dans supabase/functions/vak/vak-proof.json ; base laissée intacte [code 1])
- vak doctor --db → 1 (doctor : à corriger (contrôles ✗ ; causes et corrections : node_modules/@vak/agent/docs/FAQ.md, section 19) [code 1])

**Notes** (3) :
- verrou ajouté par l'essai : package-lock.json (un autre gestionnaire ?)
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 1 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_aabce5'` | 1 | 13 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 1 | 3 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (4) :
- ✗ VAK005 TypeScript introuvable : typage du calibrage non vérifié
- ✗ VAK015 preuve à deux comptes du 2026-10-06 : non prouvé (exercise_catalog : non prouvé ; plan_session_exercises : non prouvé ; workout_log_sets : non prouvé)
- ! VAK107 avis de sécurité (avertissement) (fonction « complete_workout_log » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « grant_assistant_consent » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « import_local_training_history » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « publish_ai_plan_proposal » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « revoke_assistant_consent » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul)
- ! VAK108 colonnes qui décident des droits (avertissement) (workout_log_sets.workout_log_id : modifiable par l'utilisateur et lue par la politique « workout_log_sets_select_own » : elle décide qui voit la ligne)

**Lignes « ! », « ✗ » et « – » de prove** (3) :
- ✗ exercise_catalog non prouvé (table partagée non vérifiable : 23514 new row for relation "exercise_catalog" violates check constraint "exercise_catalog_owner_source_check")
- ✗ plan_session_exercises non prouvé (graine impossible : parent exercise_catalog absent ; totaux de read_data non comparés (verdict non prouvé))
- ✗ workout_log_sets non prouvé (graine impossible : parent plan_session_exercises absent ; totaux de read_data non comparés (verdict non prouvé))

## Preuve (vak-proof.json)

- reçu commité : non prouvé (vak 0.24.3) : exercise_catalog non prouvé, plan_session_exercises non prouvé, plan_sessions éprouvé, plan_versions éprouvé, plan_weeks éprouvé, profiles éprouvé, workout_log_sets non prouvé, workout_logs éprouvé
- preuve du contrôleur : non prouvé (vak 0.24.3) : exercise_catalog non prouvé, plan_session_exercises non prouvé, plan_sessions éprouvé, plan_versions éprouvé, plan_weeks éprouvé, profiles éprouvé, workout_log_sets non prouvé, workout_logs éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 16 s) | 0 (0 err., 1 s) | pas pire |
| typecheck | 0 (0 err., 4 s) | absent | pire : vérification disparue (ni script typecheck ni tsconfig.json) |
| lint | 0 (0 err., 6 s) | absent | pire : vérification disparue (pas de script lint) |
| tests | absent | absent | absent |
| build | 0 (0 err., 38 s) | absent | pire : vérification disparue (ni Next ni Expo) |

## Dépendances

Aucune entrée retirée ni changée (mobile/package-lock.json : +0 ; package-lock.json : +0).

## Fichiers changés depuis le commit de l'app

**Intégration** (35) :
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
- M AGENTS.md
- A CLAUDE.md
- A mobile/app/(tabs)/assistant.tsx
- A mobile/lib/vak.ts
- M mobile/package-lock.json
- M mobile/package.json
- A package-lock.json
- A package.json
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
- A supabase/migrations/20261006141145_vak_0001_core.sql
- A supabase/migrations/20261006141146_vak_0002_feedback.sql
- A supabase/migrations/20261006141147_vak_0003_history.sql
- A supabase/migrations/20261006141148_vak_0004_quota_erase.sql
- A vendor/vak/vak-agent-0.24.3.tgz

**À relire (diff : autres.diff)** (2) :
- M mobile/app/(tabs)/_layout.tsx
- A mobile/app/(tabs)/settings.tsx (branchement : cite vak)

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 6db30b6), autres.diff.
