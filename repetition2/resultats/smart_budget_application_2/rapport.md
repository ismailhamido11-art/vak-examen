# Essai smart_budget_application_2 : réussi

- App : https://github.com/NikolayAngelov90/Smart-Budget-Application @ d8173d6 ; préparée e184d3b ; HEAD b49d484 (essai), 1 commit(s) de l'essai (2026-10-14T17:57:58+00:00 → 2026-10-14T17:57:58+00:00)
- Archive : vak-agent-0.28.1.tgz (sha256 b95df736c5b6) ; vak installé dans le clone propre : 0.28.1
- Contrôle : 2026-10-14T17:59:17.426Z → 2026-10-14T18:01:40.392Z (143 s), clone propre /work/smart_budget_application_2/apres

**Notes** (3) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)
- table(s) « à moi » écartée(s) par l'agent (ignore), sans échec de preuve au journal : choix de périmètre, à dire à l'humain : analytics_events, comeback_challenges, detected_subscriptions, goal_contributions, household_invitations, insights, notification_deliveries, personal_allowances, push_subscriptions, recovery_plans, streaks, user_achievements, user_feature_state, user_profiles, user_sessions, user_values, value_categories, weekly_digests, wishlist_items, analytics_events, comeback_challenges, detected_subscriptions, goal_contributions, household_invitations, insights, notification_deliveries, personal_allowances, push_subscriptions, recovery_plans, streaks, user_achievements, user_feature_state, user_profiles, user_sessions, user_values, value_categories, weekly_digests, wishlist_items

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 4 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_49bfa8'` | 0 | 18 s |
| `vak localdb --drop` | 0 | 1 s |
| `vak prove` | 0 | 6 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (3) :
- ! VAK006 supabase/functions/vak/agent.ts se charge, avec des avertissements (tables.categories : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; déclarez owner: "user_id" (publication par l'app : prove dira « rls ») ; tables.transactions : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; déclarez owner: "user_id" (publication par l'app : prove dira « rls ») ; tables.goals : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; politique « Users can read own goals » : équipe ou rôle ? sinon owner: "user_id" ; tables.households : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; politique « Members can view their household » : équipe ou rôle ? sinon owner: "created_by" ; tables.household_members : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; politique « Members can view co-members » : équipe ou rôle ? sinon owner: "user_id")
- ! VAK013 chaque table de l'app est calibrée ou ignorée (6 dans tables ; ignore : 20 tables, 13 fonctions) ; dans ignore, tables de l'utilisateur : « analytics_events », « comeback_challenges », « detected_subscriptions », « goal_contributions », « household_invitations », « insights », « notification_deliveries », « personal_allowances », « push_subscriptions », « recovery_plans », « streaks », « user_achievements », « user_feature_state », « user_profiles », « user_sessions », « user_values », « value_categories », « weekly_digests », « wishlist_items » (« analytics_events » : calibre-la, owner ; « comeback_challenges » : calibre-la, owner ; « detected_subscriptions » : calibre-la, owner ; « goal_contributions » : calibre-la, owner ; « household_invitations » : calibre-la, owner ; « insights » : calibre-la, owner ; « notification_deliveries » : calibre-la, owner ; « personal_allowances » : calibre-la, owner ; « push_subscriptions » : calibre-la, owner ; « recovery_plans » : calibre-la, owner ; « streaks » : calibre-la, owner ; « user_achievements » : calibre-la, owner ; « user_feature_state » : calibre-la, owner ; « user_profiles » : calibre-la, owner ; « user_sessions » : calibre-la, owner ; « user_values » : calibre-la, owner ; « value_categories » : calibre-la, owner ; « weekly_digests » : calibre-la, owner ; « wishlist_items » : calibre-la, owner)
- ! VAK108 colonnes qui décident des droits (avertissement) (categories.user_id : modifiable par l'utilisateur et lue par la politique « Users can view their own categories » : elle décide qui voit la ligne ; categories.household_id : modifiable par l'utilisateur et lue par la politique « Users can view their own categories » : elle décide qui voit la ligne ; categories.visibility_level : modifiable par l'utilisateur et lue par la politique « Users can view their own categories » : elle décide qui voit la ligne ; transactions.user_id : modifiable par l'utilisateur et lue par la politique « Users can view their own transactions » : elle décide qui voit la ligne ; transactions.category_id : modifiable par l'utilisateur et lue par la politique « Users can view their own transactions » : elle décide qui voit la ligne ; transactions.household_id : modifiable par l'utilisateur et lue par la politique « Users can view their own transactions » : elle décide qui voit la ligne ; goals.user_id : modifiable par l'utilisateur et lue par la politique « Users can read own goals » : elle décide qui voit la ligne ; goals.household_id : modifiable par l'utilisateur et lue par la politique « Users can read own goals » : elle décide qui voit la ligne ; households.name : modifiable par l'utilisateur ; la politique « Members can view their household » passe la ligne à une fonction : à vérifier ; households.created_by : modifiable par l'utilisateur ; la politique « Members can view their household » passe la ligne à une fonction : à vérifier ; households.created_at : modifiable par l'utilisateur ; la politique « Members can view their household » passe la ligne à une fonction : à vérifier ; households.updated_at : modifiable par l'utilisateur ; la politique « Members can view their household » passe la ligne à une fonction : à vérifier)

## Preuve (vak-proof.json)

- reçu commité : éprouvé (vak 0.28.1) : categories éprouvé, category_budgets éprouvé, goals éprouvé, household_members éprouvé, households éprouvé, transactions éprouvé
- preuve du contrôleur : éprouvé (vak 0.28.1) : categories éprouvé, category_budgets éprouvé, goals éprouvé, household_members éprouvé, households éprouvé, transactions éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 29 s) | 0 (0 err., 33 s) | pas pire |
| typecheck | 0 (0 err., 26 s) | 0 (0 err., 24 s) | pas pire |
| lint | 0 (0 err., 20 s) | 0 (0 err., 19 s) | pas pire |
| tests | 0 (49 err., 37 s) | 0 (49 err., 35 s) | pas pire |
| build | 1 (0 err., 2 s) | 1 (0 err., 2 s) | pas pire |

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
- M package-lock.json
- M package.json
- A src/app/assistant/assistant.tsx
- A src/app/assistant/page.tsx
- A src/lib/vak.ts
- A supabase/.gitignore
- M supabase/config.toml
- A supabase/functions/vak/agent.ts
- A supabase/functions/vak/deno.json
- A supabase/functions/vak/index.ts
- A supabase/functions/vak/schema.gen.ts
- A supabase/functions/vak/tsconfig.json
- A supabase/functions/vak/vak-proof.json
- A supabase/functions/vak/vak-server.mjs
- A supabase/functions/vak/vak.lock.json
- A supabase/migrations/20261014174851_vak_0001_core.sql
- A supabase/migrations/20261014174852_vak_0002_feedback.sql
- A supabase/migrations/20261014174853_vak_0003_history.sql
- A supabase/migrations/20261014174854_vak_0004_quota_erase.sql
- M tsconfig.json
- A vendor/vak/vak-agent-0.28.1.tgz

**À relire (diff : autres.diff)** (9) :
- M messages/bg.json
- M messages/en.json
- M src/app/(dashboard)/settings/__tests__/index-page.test.tsx (branchement : cite vak)
- A src/app/(dashboard)/settings/agent-settings.tsx (branchement : cite vak)
- M src/app/(dashboard)/settings/page.tsx
- M src/app/globals.css (branchement : cite vak)
- M src/app/layout.tsx (branchement : cite vak)
- A src/components/assistant/VakLauncher.tsx (branchement : cite vak)
- M src/components/layout/Sidebar.tsx

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis e184d3b), autres.diff.
