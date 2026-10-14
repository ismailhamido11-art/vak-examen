# Essai split_free_frontend_1 : réussi

- App : https://github.com/abdullahozer11/split-free-frontend @ 74b6612 ; préparée b239724 ; HEAD 4629568 (essai), 1 commit(s) de l'essai (2026-10-14T15:50:26+00:00 → 2026-10-14T15:50:26+00:00)
- Archive : vak-agent-0.28.1.tgz (sha256 b95df736c5b6) ; vak installé dans le clone propre : 0.28.1
- Contrôle : 2026-10-14T15:51:40.508Z → 2026-10-14T15:54:25.909Z (165 s), clone propre /work/split_free_frontend_1/apres

**Notes** (5) :
- vérification build : échec avant et après sans ligne fichier:ligne : fins des journaux différentes, à comparer
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)
- table(s) « à moi » écartée(s) par l'agent (ignore), sans échec de preuve au journal : choix de périmètre, à dire à l'humain : debts_per_expense, expense_participants, expense_payers, friend_requests, friends, group_invitations, profiles, debts_per_expense, expense_participants, expense_payers, friend_requests, friends, group_invitations, profiles
- VAK013 « ! » sur des tables que vak refuse lui-même et que sync a mises dans ignore (défaut de vak, pas de l'agent) : invite_tokens

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 3 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_968504'` | 0 | 19 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 0 | 7 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (4) :
- ! VAK006 supabase/functions/vak/agent.ts se charge, avec des avertissements (tables.groups : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; déclarez owner: "owner" (colonne qui désigne l'utilisateur) ; tables.members : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; déclarez owner: "profile" (colonne qui désigne l'utilisateur) ; tables.expenses : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; rien à déclarer : la RLS de l'app décide ; tables.debts : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; rien à déclarer : la RLS de l'app décide ; tables.transfers : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; rien à déclarer : la RLS de l'app décide)
- ! VAK013 chaque table de l'app est calibrée ou ignorée (5 dans tables ; ignore : 8 tables, 19 fonctions) ; dans ignore, tables de l'utilisateur : « debts_per_expense », « expense_participants », « expense_payers », « friend_requests », « friends », « group_invitations », « profiles » (« debts_per_expense » : calibre-la, through: "lender" ; « expense_participants » : calibre-la, through: "expense" ; « expense_payers » : calibre-la, through: "expense" ; « friend_requests » : calibre-la, owner ; « friends » : calibre-la, owner ; « group_invitations » : calibre-la, owner ; « profiles » : calibre-la, owner ; « invite_tokens » : table serveur (illisible pour authenticated) : rien à faire)
- ! VAK107 avis de sécurité (avertissement) (groups : politique « user can update group of his own » using (true) : publication par l'app : voulue ? ; members : politique « user can update members for his group » using (true) : publication par l'app : voulue ? ; expenses : politique « users can update expenses in their group » using (true) : publication par l'app : voulue ? ; debts : politique « users can update debts for their groups » using (true) : publication par l'app : voulue ? ; fonction « deleteuser » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « generate_invite_token » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « get_invite_group_id » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « get_unbound_members_for_token » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « join_group_with_token » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul)
- ! VAK108 colonnes qui décident des droits (avertissement) (groups.owner : modifiable par l'utilisateur et lue par la politique « select_groups_policy » : elle décide qui voit la ligne ; members.group_id : modifiable par l'utilisateur et lue par la politique « select_groups_policy » : elle décide qui voit la ligne ; members.profile : modifiable par l'utilisateur et lue par la politique « select_groups_policy » : elle décide qui voit la ligne ; expenses.group_id : modifiable par l'utilisateur et lue par la politique « users can access expenses in their groups » : elle décide qui voit la ligne ; debts.group_id : modifiable par l'utilisateur et lue par la politique « users can access debts of their groups » : elle décide qui voit la ligne ; transfers.group_id : modifiable par l'utilisateur et lue par la politique « users can interact with transfers in their group » : elle décide qui voit la ligne)

## Preuve (vak-proof.json)

- reçu commité : éprouvé (vak 0.28.1) : debts éprouvé, expenses éprouvé, groups éprouvé, members éprouvé, transfers éprouvé
- preuve du contrôleur : éprouvé (vak 0.28.1) : debts éprouvé, expenses éprouvé, groups éprouvé, members éprouvé, transfers éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 22 s) | 0 (0 err., 20 s) | pas pire |
| typecheck | 0 (0 err., 5 s) | 0 (0 err., 7 s) | pas pire |
| lint | 0 (0 err., 7 s) | 0 (0 err., 20 s) | pas pire |
| tests | 0 (0 err., 11 s) | 0 (0 err., 11 s) | pas pire |
| build | 1 (0 err., 60 s) | 1 (0 err., 78 s) | pas pire : échec avant et après sans ligne fichier:ligne : fins des journaux différentes, à comparer |

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
- M AGENTS.md
- A CLAUDE.md
- M package-lock.json
- M package.json
- A src/app/(tabs)/assistant.tsx
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
- A supabase/migrations/20261014154723_vak_0001_core.sql
- A supabase/migrations/20261014154724_vak_0002_feedback.sql
- A supabase/migrations/20261014154725_vak_0003_history.sql
- A supabase/migrations/20261014154726_vak_0004_quota_erase.sql
- A vendor/vak/vak-agent-0.28.1.tgz

**À relire (diff : autres.diff)** (3) :
- M CODEBASE.md (branchement : cite vak)
- M src/app/(tabs)/_layout.tsx
- M src/app/(tabs)/account/settings/index.tsx (branchement : cite vak)

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis b239724), autres.diff.
