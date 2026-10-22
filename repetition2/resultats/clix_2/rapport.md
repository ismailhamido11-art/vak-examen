# Essai clix_2 : échec

- App : https://github.com/dmayes77/CLIX @ 03a71b8 ; préparée e82e922 ; HEAD 82a2fcd (essai), 1 commit(s) de l'essai (2026-10-22T18:19:00+00:00 → 2026-10-22T18:19:00+00:00)
- Archive : vak-agent-0.29.2.tgz (sha256 29a2856be79e) ; vak installé dans le clone propre : 0.29.2
- Contrôle : 2026-10-22T18:20:03.005Z → 2026-10-22T18:20:57.389Z (54 s), clone propre /work/clix_2/apres

**Raisons de l'échec** (1) :
- 1 dépendance(s) de l'app retirée(s) ou changée(s)

**Notes** (3) :
- package.json : dépendance(s) ajoutée(s) autre(s) que @vak/agent : devDependencies/@types/node "26.6.5", devDependencies/@types/react "^19.3.0", devDependencies/typescript "^5.9.3"
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 2 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_71a71a'` | 0 | 16 s |
| `vak localdb --drop` | 0 | 1 s |
| `vak prove` | 0 | 2 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (0)

## Preuve (vak-proof.json)

- reçu commité : éprouvé (vak 0.29.2) : admin_profiles éprouvé
- preuve du contrôleur : éprouvé (vak 0.29.2) : admin_profiles éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 2 s) | 0 (0 err., 2 s) | pas pire |
| typecheck | absent | 0 (0 err., 2 s) | nouveau |
| lint | 0 (0 err., 6 s) | 0 (0 err., 16 s) | pas pire |
| tests | absent | absent | absent |
| build | 1 (0 err., 9 s) | 1 (0 err., 13 s) | pas pire |

## Dépendances

1 entrée(s) retirée(s) ou changée(s) :
- pnpm-lock.yaml : retirée packages/typescript@6.0.3 présent

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
- M AGENTS.md
- A app/assistant/assistant.tsx
- A app/assistant/page.tsx
- A lib/vak.ts
- M package.json
- M pnpm-lock.yaml
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
- A supabase/migrations/20261022181337_vak_0001_core.sql
- A supabase/migrations/20261022181338_vak_0002_feedback.sql
- A supabase/migrations/20261022181339_vak_0003_history.sql
- A supabase/migrations/20261022181340_vak_0004_quota_erase.sql
- A vendor/vak/vak-agent-0.29.2.tgz

**À relire (diff : autres.diff)** (8) :
- M app/layout.js (branchement : cite vak)
- A app/settings/agent-settings.tsx (branchement : cite vak)
- A app/settings/page.tsx
- A components/layout/AssistantLauncher/index.jsx (branchement : cite vak)
- M components/layout/Footer/Footer.module.css
- M components/layout/Footer/index.jsx
- D jsconfig.json
- A tsconfig.json

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis e82e922), autres.diff.
