# Essai plantes_1 : réussi

- App : /home/user/ai-chatbot/vak-examen/apps/plantes.bundle @ bea4192 ; préparée fbb7433 ; HEAD 8aea829 (essai), 1 commit(s) de l'essai (2026-10-10T17:52:59+00:00 → 2026-10-10T17:52:59+00:00)
- Archive : vak-agent-0.26.1.tgz (sha256 e0516efc36a3) ; vak installé dans le clone propre : 0.26.1
- Contrôle : 2026-10-10T17:53:55.269Z → 2026-10-10T17:54:48.442Z (53 s), clone propre /work/plantes_1/apres

**Notes** (2) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 1 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_7c49fd'` | 0 | 15 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 0 | 2 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (0)

## Preuve (vak-proof.json)

- reçu commité : éprouvé (vak 0.26.1) : plants éprouvé, waterings éprouvé
- preuve du contrôleur : éprouvé (vak 0.26.1) : plants éprouvé, waterings éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 36 s) | 0 (0 err., 16 s) | pas pire |
| typecheck | 0 (0 err., 2 s) | 0 (0 err., 2 s) | pas pire |
| lint | 0 (0 err., 4 s) | 0 (0 err., 3 s) | pas pire |
| tests | absent | absent | absent |
| build | 0 (0 err., 17 s) | 0 (0 err., 14 s) | pas pire |

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
- A supabase/migrations/20261010175050_vak_0001_core.sql
- A supabase/migrations/20261010175051_vak_0002_feedback.sql
- A supabase/migrations/20261010175052_vak_0003_history.sql
- A supabase/migrations/20261010175053_vak_0004_quota_erase.sql
- A vendor/vak/vak-agent-0.26.1.tgz

**À relire (diff : autres.diff)** (4) :
- M src/app/_layout.tsx (branchement : cite vak)
- M src/app/index.tsx
- A src/app/reglages.tsx (branchement : cite vak)
- M tsconfig.json

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis fbb7433), autres.diff.
