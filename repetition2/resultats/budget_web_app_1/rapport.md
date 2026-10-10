# Essai budget_web_app_1 : réussi

- App : https://github.com/Ant3xes/budget_web_app @ 88061f2 ; préparée 65e276a ; HEAD 72c03bd (essai), 1 commit(s) de l'essai (2026-10-10T18:56:49+00:00 → 2026-10-10T18:56:49+00:00)
- Archive : vak-agent-0.26.1.tgz (sha256 e0516efc36a3) ; vak installé dans le clone propre : 0.26.1
- Contrôle : 2026-10-10T18:57:51.151Z → 2026-10-10T18:59:30.634Z (99 s), clone propre /work/budget_web_app_1/apres

**Notes** (2) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 2 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_fd0ecf'` | 0 | 15 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 0 | 5 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (3) :
- ! VAK006 supabase/functions/vak/agent.ts se charge, avec des avertissements (tables.accounts : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; déclarez owner: "user_id" (colonne qui désigne l'utilisateur), ou through: "space_id" (la ligne appartient à l'utilisateur par sa table parente, calibrée) ; tables.categories : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; déclarez owner: "user_id" (colonne qui désigne l'utilisateur), ou through: "space_id" (la ligne appartient à l'utilisateur par sa table parente, calibrée) ; tables.transactions : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; déclarez owner: "user_id" (colonne qui désigne l'utilisateur), ou through: "space_id" (la ligne appartient à l'utilisateur par sa table parente, calibrée) ; tables.budgets : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; déclarez owner: "user_id" (colonne qui désigne l'utilisateur), ou through: "space_id" (la ligne appartient à l'utilisateur par sa table parente, calibrée) ; tables.fixed_charges : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; déclarez owner: "user_id" (colonne qui désigne l'utilisateur), ou through: "space_id" (la ligne appartient à l'utilisateur par sa table parente, calibrée) ; tables.savings_goals : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; déclarez owner: "user_id" (colonne qui désigne l'utilisateur), ou through: "space_id" (la ligne appartient à l'utilisateur par sa table parente, calibrée))
- ! VAK107 avis de sécurité (avertissement) (fonction « get_space_invitation » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « is_space_member » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « is_space_owner » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « shares_space_with » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; accounts : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; categories : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; transactions : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; budgets : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; fixed_charges : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; savings_goals : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; spaces : politique ouverte à anon : à vérifier (aucune ligne lue sans compte))
- ! VAK108 colonnes qui décident des droits (avertissement) (accounts.space_id : modifiable par l'utilisateur et lue par la politique « accounts_select_member » : elle décide qui voit la ligne ; categories.space_id : modifiable par l'utilisateur et lue par la politique « categories_select_member » : elle décide qui voit la ligne ; transactions.space_id : modifiable par l'utilisateur et lue par la politique « transactions_select_member » : elle décide qui voit la ligne ; budgets.space_id : modifiable par l'utilisateur et lue par la politique « budgets_select_member » : elle décide qui voit la ligne ; fixed_charges.space_id : modifiable par l'utilisateur et lue par la politique « fixed_charges_select_member » : elle décide qui voit la ligne ; savings_goals.space_id : modifiable par l'utilisateur et lue par la politique « savings_goals_select_member » : elle décide qui voit la ligne ; profiles.full_name : modifiable par l'utilisateur ; la politique « profiles_select_self_or_comember » passe la ligne à une fonction : à vérifier ; profiles.default_currency : modifiable par l'utilisateur ; la politique « profiles_select_self_or_comember » passe la ligne à une fonction : à vérifier ; profiles.created_at : modifiable par l'utilisateur ; la politique « profiles_select_self_or_comember » passe la ligne à une fonction : à vérifier ; profiles.updated_at : modifiable par l'utilisateur ; la politique « profiles_select_self_or_comember » passe la ligne à une fonction : à vérifier ; spaces.name : modifiable par l'utilisateur ; la politique « spaces_select_member » passe la ligne à une fonction : à vérifier ; spaces.kind : modifiable par l'utilisateur ; la politique « spaces_select_member » passe la ligne à une fonction : à vérifier ; spaces.created_at : modifiable par l'utilisateur ; la politique « spaces_select_member » passe la ligne à une fonction : à vérifier ; spaces.updated_at : modifiable par l'utilisateur ; la politique « spaces_select_member » passe la ligne à une fonction : à vérifier ; spaces.default_share_percent : modifiable par l'utilisateur ; la politique « spaces_select_member » passe la ligne à une fonction : à vérifier)

## Preuve (vak-proof.json)

- reçu commité : éprouvé (vak 0.26.1) : accounts éprouvé, budgets éprouvé, categories éprouvé, fixed_charges éprouvé, profiles éprouvé, savings_goals éprouvé, spaces éprouvé, transactions éprouvé
- preuve du contrôleur : éprouvé (vak 0.26.1) : accounts éprouvé, budgets éprouvé, categories éprouvé, fixed_charges éprouvé, profiles éprouvé, savings_goals éprouvé, spaces éprouvé, transactions éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 25 s) | 0 (0 err., 20 s) | pas pire |
| typecheck | 0 (0 err., 2 s) | 0 (0 err., 2 s) | pas pire |
| lint | 0 (0 err., 13 s) | 0 (0 err., 18 s) | pas pire |
| tests | 0 (0 err., 5 s) | 0 (0 err., 5 s) | pas pire |
| build | 0 (0 err., 28 s) | 0 (0 err., 31 s) | pas pire |

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
- M AGENTS.md
- A app/(app)/assistant/assistant.tsx
- A app/(app)/assistant/page.tsx
- A app/(app)/settings/assistant/page.tsx
- A lib/vak.ts
- M package-lock.json
- M package.json
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
- A supabase/migrations/20261010185226_vak_0001_core.sql
- A supabase/migrations/20261010185227_vak_0002_feedback.sql
- A supabase/migrations/20261010185228_vak_0003_history.sql
- A supabase/migrations/20261010185229_vak_0004_quota_erase.sql
- M tsconfig.json
- A vendor/vak/vak-agent-0.26.1.tgz

**À relire (diff : autres.diff)** (8) :
- M app/(app)/layout.tsx
- A app/(app)/settings/agent-settings.tsx (branchement : cite vak)
- M app/(app)/settings/layout.tsx
- M app/globals.css (branchement : cite vak)
- M app/layout.tsx (branchement : cite vak)
- A components/layout/assistant-button.tsx (branchement : cite vak)
- M lib/i18n/dictionaries/en/nav.ts
- M lib/i18n/dictionaries/fr/nav.ts

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 65e276a), autres.diff.
