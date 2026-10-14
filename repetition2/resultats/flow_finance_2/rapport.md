# Essai flow_finance_2 : réussi

- App : https://github.com/Alexandre-Pascal/flow-finance @ 6428801 ; préparée 7b90bc9 ; HEAD 1ccc79b (essai), 1 commit(s) de l'essai (2026-10-14T18:17:15+00:00 → 2026-10-14T18:17:15+00:00)
- Archive : vak-agent-0.28.1.tgz (sha256 b95df736c5b6) ; vak installé dans le clone propre : 0.28.1
- Contrôle : 2026-10-14T18:19:19.944Z → 2026-10-14T18:21:23.165Z (123 s), clone propre /work/flow_finance_2/apres

**Notes** (3) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)
- table(s) « à moi » écartée(s) par l'agent (ignore), sans échec de preuve au journal : choix de périmètre, à dire à l'humain : bank_connections, crypto_holdings, crypto_portfolio_settings, crypto_transactions, pea_holdings, pea_investment_plans, pea_settings, pea_transactions, profiles, recurring_payments, recurring_suggestion_dismissals, savings_adjustments, savings_goal_allocations, spaces, bank_connections, crypto_holdings, crypto_portfolio_settings, crypto_transactions, pea_holdings, pea_investment_plans, pea_settings, pea_transactions, profiles, recurring_payments, recurring_suggestion_dismissals, savings_adjustments, savings_goal_allocations, spaces

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 4 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_ebaa13'` | 0 | 16 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 0 | 5 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (2) :
- ! VAK013 chaque table de l'app est calibrée ou ignorée (5 dans tables ; ignore : 14 tables, 0 fonctions) ; dans ignore, tables de l'utilisateur : « bank_connections », « crypto_holdings », « crypto_portfolio_settings », « crypto_transactions », « pea_holdings », « pea_investment_plans », « pea_settings », « pea_transactions », « profiles », « recurring_payments », « recurring_suggestion_dismissals », « savings_adjustments », « savings_goal_allocations », « spaces » (« bank_connections » : calibre-la, owner ; « crypto_holdings » : calibre-la, owner ; « crypto_portfolio_settings » : calibre-la, owner ; « crypto_transactions » : calibre-la, owner ; « pea_holdings » : calibre-la, owner ; « pea_investment_plans » : calibre-la, owner ; « pea_settings » : calibre-la, owner ; « pea_transactions » : calibre-la, owner ; « profiles » : calibre-la, owner ; « recurring_payments » : calibre-la, owner ; « recurring_suggestion_dismissals » : calibre-la, owner ; « savings_adjustments » : calibre-la, owner ; « savings_goal_allocations » : calibre-la, owner ; « spaces » : calibre-la, owner)
- ! VAK108 colonnes qui décident des droits (avertissement) (transactions.account_id : modifiable par l'utilisateur et lue par la politique « transactions_select_own » : elle décide qui voit la ligne)

## Preuve (vak-proof.json)

- reçu commité : éprouvé (vak 0.28.1) : accounts éprouvé, categories éprouvé, savings_accounts éprouvé, savings_goals éprouvé, transactions éprouvé
- preuve du contrôleur : éprouvé (vak 0.28.1) : accounts éprouvé, categories éprouvé, savings_accounts éprouvé, savings_goals éprouvé, transactions éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 16 s) | 0 (0 err., 19 s) | pas pire |
| typecheck | 0 (0 err., 10 s) | 0 (0 err., 11 s) | pas pire |
| lint | 0 (0 err., 14 s) | 0 (0 err., 38 s) | pas pire |
| tests | 1 (1 err., 5 s) | 1 (1 err., 4 s) | pas pire |
| build | 0 (0 err., 25 s) | 0 (0 err., 26 s) | pas pire |

## Dépendances

Aucune entrée retirée ni changée (package-lock.json : +0).

## Fichiers changés depuis le commit de l'app

**Intégration** (34) :
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
- M package-lock.json
- M package.json
- A src/app/[locale]/(dashboard)/assistant/assistant.tsx
- A src/app/[locale]/(dashboard)/assistant/page.tsx
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
- A supabase/migrations/20261014181048_vak_0001_core.sql
- A supabase/migrations/20261014181049_vak_0002_feedback.sql
- A supabase/migrations/20261014181050_vak_0003_history.sql
- A supabase/migrations/20261014181051_vak_0004_quota_erase.sql
- M tsconfig.json
- A vendor/vak/vak-agent-0.28.1.tgz

**À relire (diff : autres.diff)** (9) :
- M messages/en.json
- M messages/fr.json
- M src/app/[locale]/(dashboard)/layout.tsx
- A src/app/[locale]/(dashboard)/settings/agent-settings.tsx (branchement : cite vak)
- M src/app/[locale]/(dashboard)/settings/page.tsx
- M src/app/[locale]/layout.tsx (branchement : cite vak)
- M src/components/features/app-sidebar.tsx
- A src/components/features/assistant-button.tsx (branchement : cite vak)
- M src/components/features/mobile-nav.tsx

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 7b90bc9), autres.diff.
