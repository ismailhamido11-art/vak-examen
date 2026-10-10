# Essai pups_supabase_2 : réussi

- App : https://github.com/MarkMGill/pups-supabase @ 405d4df ; préparée 5f3fbc5 ; HEAD 64f44e7 (essai), 1 commit(s) de l'essai (2026-10-10T19:40:43+00:00 → 2026-10-10T19:40:43+00:00)
- Archive : vak-agent-0.26.1.tgz (sha256 e0516efc36a3) ; vak installé dans le clone propre : 0.26.1
- Contrôle : 2026-10-10T19:41:32.738Z → 2026-10-10T19:41:59.631Z (27 s), clone propre /work/pups_supabase_2/apres

**Notes** (2) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 0 s |
| `vak localdb` | 0 | 1 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_e4a2ec'` | 0 | 13 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 0 | 1 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (1) :
- ! VAK107 avis de sécurité (avertissement) (puppies : table calibrée lisible sans compte (anon) : faille de l'app, sauf contenu public voulu)

## Preuve (vak-proof.json)

- reçu commité : éprouvé (vak 0.26.1) : orders éprouvé, profiles éprouvé, puppies éprouvé
- preuve du contrôleur : éprouvé (vak 0.26.1) : orders éprouvé, profiles éprouvé, puppies éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 10 s) | 0 (0 err., 10 s) | pas pire |
| typecheck | 0 (0 err., 0 s) | 0 (0 err., 0 s) | pas pire |
| lint | absent | absent | absent |
| tests | absent | absent | absent |
| build | absent | absent | absent |

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
- A app/assistant.tsx
- A lib/vak.ts
- M package-lock.json
- M package.json
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
- A supabase/migrations/20261010193858_vak_0001_core.sql
- A supabase/migrations/20261010193859_vak_0002_feedback.sql
- A supabase/migrations/20261010193900_vak_0003_history.sql
- A supabase/migrations/20261010193901_vak_0004_quota_erase.sql
- A vendor/vak/vak-agent-0.26.1.tgz

**À relire (diff : autres.diff)** (5) :
- M app/(app)/home.tsx
- M app/_layout.tsx
- A app/settings.tsx (branchement : cite vak)
- A components/AssistantFab.tsx
- M tsconfig.json

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 5f3fbc5), autres.diff.
