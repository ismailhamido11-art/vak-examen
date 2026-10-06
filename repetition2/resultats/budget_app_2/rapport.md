# Essai budget_app_2 : réussi

- App : https://github.com/AndrerezaMedya/budget-app @ f1f3ef1 ; préparée 2fdc683 ; HEAD 4a008b5 (essai), 1 commit(s) de l'essai (2026-10-06T13:54:02+00:00 → 2026-10-06T13:54:02+00:00)
- Archive : vak-agent-0.24.3.tgz (sha256 2765b6929c14) ; vak installé dans le clone propre : 0.24.3
- Contrôle : 2026-10-06T13:55:01.845Z → 2026-10-06T13:56:09.349Z (68 s), clone propre /work/budget_app_2/apres

**Notes** (3) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)
- table(s) « à moi » écartée(s) par l'agent (ignore), sans échec de preuve au journal : choix de périmètre, à dire à l'humain : account_daily_summaries, daily_cashflow_summaries, receipt_ingestion_jobs, receipt_line_items, receipts, tags, transaction_tags, account_daily_summaries, daily_cashflow_summaries, receipt_ingestion_jobs, receipt_line_items, receipts, tags, transaction_tags

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 1 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_d30e25'` | 0 | 15 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 0 | 2 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (2) :
- ! VAK013 chaque table de l'app est calibrée ou ignorée (7 dans tables ; ignore : 7 tables, 3 fonctions) ; dans ignore, tables de l'utilisateur : « account_daily_summaries », « daily_cashflow_summaries », « receipt_ingestion_jobs », « receipt_line_items », « receipts », « tags », « transaction_tags » (« account_daily_summaries » : calibre-la, owner ; « daily_cashflow_summaries » : calibre-la, owner ; « receipt_ingestion_jobs » : calibre-la, owner ; « receipt_line_items » : calibre-la, through: "receipt_id" ; « receipts » : calibre-la, owner ; « tags » : calibre-la, owner ; « transaction_tags » : calibre-la, through: "transaction_id")
- ! VAK107 avis de sécurité (avertissement) (fonction « create_workspace_seed » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « refresh_category_monthly_summary » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « refresh_daily_cashflow_summary » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul)

## Preuve (vak-proof.json)

- reçu commité : éprouvé (vak 0.24.3) : accounts éprouvé, budgets éprouvé, categories éprouvé, category_monthly_summaries éprouvé, payees éprouvé, profiles éprouvé, transactions éprouvé
- preuve du contrôleur : éprouvé (vak 0.24.3) : accounts éprouvé, budgets éprouvé, categories éprouvé, category_monthly_summaries éprouvé, payees éprouvé, profiles éprouvé, transactions éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 2 s) | 0 (0 err., 2 s) | pas pire |
| typecheck | 0 (0 err., 7 s) | 0 (0 err., 7 s) | pas pire |
| lint | 0 (0 err., 9 s) | 0 (0 err., 19 s) | pas pire |
| tests | absent | absent | absent |
| build | 1 (0 err., 18 s) | 1 (0 err., 19 s) | pas pire |

## Dépendances

Aucune entrée retirée ni changée (package-lock.json : +0 ; pnpm-lock.yaml : +0).

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
- M package.json
- M pnpm-lock.yaml
- A src/app/assistant/assistant.tsx
- A src/app/assistant/page.tsx
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
- A supabase/migrations/20261006134949_vak_0001_core.sql
- A supabase/migrations/20261006134950_vak_0002_feedback.sql
- A supabase/migrations/20261006134951_vak_0003_history.sql
- A supabase/migrations/20261006134952_vak_0004_quota_erase.sql
- M tsconfig.json
- A vendor/vak/vak-agent-0.24.3.tgz

**À relire (diff : autres.diff)** (4) :
- A src/app/app/settings/agent-settings.tsx (branchement : cite vak)
- M src/app/app/settings/page.tsx
- M src/app/layout.tsx (branchement : cite vak)
- A src/components/vak-button.tsx (branchement : cite vak)

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 2fdc683), autres.diff.
