# Essai hikari_1 : réussi

- App : https://github.com/antoineross/Hikari @ c1f16f5 ; préparée 68cf129 ; HEAD 8a5c618 (essai), 1 commit(s) de l'essai (2026-10-11T02:16:13+00:00 → 2026-10-11T02:16:13+00:00)
- Archive : vak-agent-0.27.0.tgz (sha256 8e695dc7571b) ; vak installé dans le clone propre : 0.27.0
- Contrôle : 2026-10-11T02:17:13.811Z → 2026-10-11T02:18:36.786Z (83 s), clone propre /work/hikari_1/apres

**Notes** (2) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 1 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_02a709'` | 0 | 14 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 0 | 2 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (3) :
- ! VAK005 typecheck d'agent.ts sauté : TypeScript 5.4.5 de l'app < 5.8 ; agent.ts reste vérifié par vak test
- ! VAK009 variable publique à vérifier : clé ou jeton inclus dans l'app (utils/stripe/client.ts:8 : NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY_LIVE)
- ! VAK107 avis de sécurité (avertissement) (prices : table calibrée lisible sans compte (anon) : faille de l'app, sauf contenu public voulu ; products : table calibrée lisible sans compte (anon) : faille de l'app, sauf contenu public voulu)

## Preuve (vak-proof.json)

- reçu commité : éprouvé (vak 0.27.0) : posts éprouvé, prices éprouvé, products éprouvé, subscriptions éprouvé, users éprouvé
- preuve du contrôleur : éprouvé (vak 0.27.0) : posts éprouvé, prices éprouvé, products éprouvé, subscriptions éprouvé, users éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 19 s) | 0 (0 err., 2 s) | pas pire |
| typecheck | 0 (0 err., 8 s) | 0 (0 err., 8 s) | pas pire |
| lint | 1 (0 err., 1 s) | 1 (0 err., 1 s) | pas pire |
| tests | absent | absent | absent |
| build | 1 (0 err., 51 s) | 1 (0 err., 54 s) | pas pire |

## Dépendances

Aucune entrée retirée ni changée (pnpm-lock.yaml : +0).

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
- A supabase/migrations/20261011021330_vak_0001_core.sql
- A supabase/migrations/20261011021331_vak_0002_feedback.sql
- A supabase/migrations/20261011021332_vak_0003_history.sql
- A supabase/migrations/20261011021333_vak_0004_quota_erase.sql
- M tsconfig.json
- A vendor/vak/vak-agent-0.27.0.tgz

**À relire (diff : autres.diff)** (5) :
- M app/(dashboard)/dashboard/layout.tsx
- A app/(dashboard)/dashboard/settings/agent-settings.tsx (branchement : cite vak)
- M app/(dashboard)/dashboard/settings/page.tsx
- M app/layout.tsx (branchement : cite vak)
- A components/vak-button.tsx (branchement : cite vak)

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 68cf129), autres.diff.
