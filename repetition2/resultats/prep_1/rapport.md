# Essai prep_1 : réussi

- App : https://github.com/Truella/prep @ 341c8dc ; préparée 03f0648 ; HEAD f9dc68f (essai), 1 commit(s) de l'essai (2026-10-22T17:09:51+00:00 → 2026-10-22T17:09:51+00:00)
- Archive : vak-agent-0.29.2.tgz (sha256 29a2856be79e) ; vak installé dans le clone propre : 0.29.2
- Contrôle : 2026-10-22T17:11:36.493Z → 2026-10-22T17:13:17.627Z (101 s), clone propre /work/prep_1/apres

**Notes** (2) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 2 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_5b6949'` | 0 | 18 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 0 | 4 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (2) :
- ! VAK006 supabase/functions/vak/agent.ts se charge, avec des avertissements (tables.questions.through : la colonne « quiz_id » accepte null : les lignes sans parent sont ignorées par l'assistant)
- ! VAK108 colonnes qui décident des droits (avertissement) (quizzes.status : modifiable par l'utilisateur et lue par la politique « Anyone can read published questions » : elle décide qui voit la ligne)

## Preuve (vak-proof.json)

- reçu commité : éprouvé (vak 0.29.2) : questions éprouvé, quiz_attempts éprouvé, quiz_ratings éprouvé, quizzes éprouvé
- preuve du contrôleur : éprouvé (vak 0.29.2) : questions éprouvé, quiz_attempts éprouvé, quiz_ratings éprouvé, quizzes éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 28 s) | 0 (0 err., 20 s) | pas pire |
| typecheck | 0 (0 err., 8 s) | 0 (0 err., 9 s) | pas pire |
| lint | 0 (0 err., 12 s) | 0 (0 err., 18 s) | pas pire |
| tests | 0 (0 err., 9 s) | 0 (0 err., 9 s) | pas pire |
| build | 1 (0 err., 17 s) | 1 (0 err., 19 s) | pas pire |

## Dépendances

Aucune entrée retirée ni changée (package-lock.json : +0).

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
- A AGENTS.md
- A CLAUDE.md
- A app/assistant/assistant.tsx
- A app/assistant/page.tsx
- M package-lock.json
- M package.json
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
- A supabase/migrations/20261022170010_vak_0001_core.sql
- A supabase/migrations/20261022170011_vak_0002_feedback.sql
- A supabase/migrations/20261022170012_vak_0003_history.sql
- A supabase/migrations/20261022170013_vak_0004_quota_erase.sql
- M tsconfig.json
- A vendor/vak/vak-agent-0.29.2.tgz

**À relire (diff : autres.diff)** (21) :
- A app/assistant/layout.tsx
- M app/layout.tsx (branchement : cite vak)
- A app/settings/agent-settings.tsx (branchement : cite vak)
- A app/settings/layout.tsx
- A app/settings/page.tsx
- M src/features/dashboard/constants/navItems.ts
- A src/lib/vak-theme.ts
- A src/shared/components/VakButton.tsx (branchement : cite vak)
- A supabase/test-migrations/20260722100406_create_quizzes_and_questions.sql
- A supabase/test-migrations/20260726041331_add_time_limit_to_quizzes.sql
- A supabase/test-migrations/20260726050000_add_quiz_bank_tables.sql
- A supabase/test-migrations/20260728000000_add_code_to_quizzes.sql
- A supabase/test-migrations/20260728000001_create_quizzes_code_index.sql
- A supabase/test-migrations/20260728100000_create_quiz_attempts.sql
- A supabase/test-migrations/20260728120000_add_attempt_counts_rpc.sql
- A supabase/test-migrations/20260729000000_add_quiz_lifecycle.sql
- A supabase/test-migrations/20261022170010_vak_0001_core.sql (branchement : cite vak)
- A supabase/test-migrations/20261022170011_vak_0002_feedback.sql (branchement : cite vak)
- A supabase/test-migrations/20261022170012_vak_0003_history.sql (branchement : cite vak)
- A supabase/test-migrations/20261022170013_vak_0004_quota_erase.sql (branchement : cite vak)
- A supabase/test-migrations/README.md (branchement : cite vak)

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 03f0648), autres.diff.
