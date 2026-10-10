# Essai expense_sharing_1 : échec

- App : https://github.com/itejaskumbhar/Expense-Sharing @ 8e6020c ; préparée 38ef636 ; HEAD 1ffeee1 (essai), 1 commit(s) de l'essai (2026-10-10T18:20:21+00:00 → 2026-10-10T18:20:21+00:00)
- Archive : vak-agent-0.26.1.tgz (sha256 e0516efc36a3) ; vak installé dans le clone propre : 0.26.1
- Contrôle : 2026-10-10T18:20:33.615Z → 2026-10-10T18:21:50.437Z (77 s), clone propre /work/expense_sharing_1/apres

**Raisons de l'échec** (2) :
- vak prove → 1 (preuve à deux comptes : non prouvé (5 éprouvée(s), 0 en échec, 1 non prouvée(s) ; 140 totaux de read_data comparés) ; reçu inchangé dans supabase/functions/vak/vak-proof.json ; base laissée intacte [code 1])
- vak doctor --db → 1 (doctor : à corriger (contrôles ✗ ; causes et corrections : node_modules/@vak/agent/docs/FAQ.md, section 19) [code 1])

**Notes** (2) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 2 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_7ca1b8'` | 1 | 14 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 1 | 2 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (4) :
- ! VAK006 supabase/functions/vak/agent.ts se charge, avec des avertissements (tables.groups : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; politique « groups_select » : équipe ou rôle ? sinon owner: "created_by" ; tables.group_members : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; politique « group_members_select » : équipe ou rôle ? sinon owner: "user_id" ; tables.expenses : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; politique « expenses_all » : équipe ou rôle ? sinon owner: "created_by" ; tables.expense_splits : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; rien à déclarer : la RLS de l'app décide ; tables.settlements : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; rien à déclarer : la RLS de l'app décide)
- ✗ VAK015 preuve à deux comptes du 2026-10-10 : non prouvé (settlements : non prouvé)
- ! VAK107 avis de sécurité (avertissement) (fonction « create_group » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « find_user_by_email » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « is_group_member » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « is_group_owner » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « shares_group_with » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; groups : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; group_members : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; expenses : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; expense_splits : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; settlements : politique ouverte à anon : à vérifier (aucune ligne lue sans compte))
- ! VAK108 colonnes qui décident des droits (avertissement) (groups.name : modifiable par l'utilisateur ; la politique « groups_select » passe la ligne à une fonction : à vérifier ; groups.created_by : modifiable par l'utilisateur ; la politique « groups_select » passe la ligne à une fonction : à vérifier ; groups.currency : modifiable par l'utilisateur ; la politique « groups_select » passe la ligne à une fonction : à vérifier ; groups.created_at : modifiable par l'utilisateur ; la politique « groups_select » passe la ligne à une fonction : à vérifier ; groups.simplify_debts : modifiable par l'utilisateur ; la politique « groups_select » passe la ligne à une fonction : à vérifier ; group_members.group_id : modifiable par l'utilisateur et lue par la politique « group_members_select » : elle décide qui voit la ligne ; expenses.group_id : modifiable par l'utilisateur et lue par la politique « expense_splits_all » : elle décide qui voit la ligne ; expense_splits.expense_id : modifiable par l'utilisateur et lue par la politique « expense_splits_all » : elle décide qui voit la ligne ; settlements.group_id : modifiable par l'utilisateur et lue par la politique « settlements_all » : elle décide qui voit la ligne ; profiles.full_name : modifiable par l'utilisateur ; la politique « profiles_select » passe la ligne à une fonction : à vérifier ; profiles.email : modifiable par l'utilisateur ; la politique « profiles_select » passe la ligne à une fonction : à vérifier ; profiles.phone : modifiable par l'utilisateur ; la politique « profiles_select » passe la ligne à une fonction : à vérifier ; profiles.avatar_url : modifiable par l'utilisateur ; la politique « profiles_select » passe la ligne à une fonction : à vérifier ; profiles.created_at : modifiable par l'utilisateur ; la politique « profiles_select » passe la ligne à une fonction : à vérifier)

**Lignes « ! », « ✗ » et « – » de prove** (1) :
- ✗ settlements non prouvé (graine impossible : 23514 new row for relation "settlements" violates check constraint "settlements_distinct_members" ; totaux de read_data non comparés (verdict non prouvé))

## Preuve (vak-proof.json)

- reçu commité : non prouvé (vak 0.26.1) : expense_splits éprouvé, expenses éprouvé, group_members éprouvé, groups éprouvé, profiles éprouvé, settlements non prouvé
- preuve du contrôleur : non prouvé (vak 0.26.1) : expense_splits éprouvé, expenses éprouvé, group_members éprouvé, groups éprouvé, profiles éprouvé, settlements non prouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 21 s) | 0 (0 err., 14 s) | pas pire |
| typecheck | 0 (0 err., 3 s) | 0 (0 err., 4 s) | pas pire |
| lint | 1 (8 err., 18 s) | 1 (8 err., 22 s) | pas pire |
| tests | 0 (0 err., 4 s) | 0 (0 err., 4 s) | pas pire |
| build | 0 (0 err., 23 s) | 0 (0 err., 14 s) | pas pire |

## Dépendances

Aucune entrée retirée ni changée (package-lock.json : +0).

## Fichiers changés depuis le commit de l'app

**Intégration** (32) :
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
- A src/app/(app)/(tabs)/assistant.tsx
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
- A supabase/migrations/20261010181737_vak_0001_core.sql
- A supabase/migrations/20261010181738_vak_0002_feedback.sql
- A supabase/migrations/20261010181739_vak_0003_history.sql
- A supabase/migrations/20261010181740_vak_0004_quota_erase.sql
- A vendor/vak/vak-agent-0.26.1.tgz

**À relire (diff : autres.diff)** (3) :
- M src/app/(app)/(tabs)/_layout.tsx
- M src/app/(app)/(tabs)/account.tsx (branchement : cite vak)
- M tsconfig.json

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 38ef636), autres.diff.
