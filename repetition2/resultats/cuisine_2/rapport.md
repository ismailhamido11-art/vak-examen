# Essai cuisine_2 : réussi

- App : /home/user/ai-chatbot/vak-examen/apps/cuisine.bundle @ 791c04d ; préparée cbe2200 ; HEAD 30814db (essai), 1 commit(s) de l'essai (2026-10-11T02:25:36+00:00 → 2026-10-11T02:25:36+00:00)
- Archive : vak-agent-0.27.0.tgz (sha256 8e695dc7571b) ; vak installé dans le clone propre : 0.27.0
- Contrôle : 2026-10-11T02:26:28.124Z → 2026-10-11T02:27:13.164Z (45 s), clone propre /work/cuisine_2/apres

**Notes** (2) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 0 s |
| `vak localdb` | 0 | 1 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_a3adf6'` | 0 | 13 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 0 | 2 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (1) :
- ! VAK108 colonnes qui décident des droits (avertissement) (cookings.user_id : modifiable par l'utilisateur et lue par la politique « cookings_owner » : elle décide qui voit la ligne)

## Preuve (vak-proof.json)

- reçu commité : éprouvé (vak 0.27.0) : cookings éprouvé, recipes éprouvé
- preuve du contrôleur : éprouvé (vak 0.27.0) : cookings éprouvé, recipes éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 11 s) | 0 (0 err., 11 s) | pas pire |
| typecheck | 0 (0 err., 2 s) | 0 (0 err., 2 s) | pas pire |
| lint | 0 (0 err., 3 s) | 0 (0 err., 3 s) | pas pire |
| tests | absent | absent | absent |
| build | 0 (0 err., 14 s) | 0 (0 err., 12 s) | pas pire |

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
- M package-lock.json
- M package.json
- A src/app/assistant.tsx
- A src/lib/vak.ts
- A supabase/.gitignore
- A supabase/config.toml
- A supabase/functions/vak/agent.ts
- A supabase/functions/vak/deno.json
- A supabase/functions/vak/index.ts
- A supabase/functions/vak/schema.gen.ts
- A supabase/functions/vak/tsconfig.json
- A supabase/functions/vak/vak-proof.json
- A supabase/functions/vak/vak-server.mjs
- A supabase/functions/vak/vak.lock.json
- A supabase/migrations/20261011022349_vak_0001_core.sql
- A supabase/migrations/20261011022350_vak_0002_feedback.sql
- A supabase/migrations/20261011022351_vak_0003_history.sql
- A supabase/migrations/20261011022352_vak_0004_quota_erase.sql
- A vendor/vak/vak-agent-0.27.0.tgz

**À relire (diff : autres.diff)** (4) :
- M src/app/_layout.tsx (branchement : cite vak)
- M src/app/index.tsx
- A src/app/reglages.tsx (branchement : cite vak)
- M tsconfig.json

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis cbe2200), autres.diff.
