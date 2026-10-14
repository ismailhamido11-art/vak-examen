# Essai split_free_frontend_2 : réussi

- App : https://github.com/abdullahozer11/split-free-frontend @ 74b6612 ; préparée b239724 ; HEAD 5114662 (essai), 1 commit(s) de l'essai (2026-10-14T17:35:57+00:00 → 2026-10-14T17:35:57+00:00)
- Archive : vak-agent-0.28.1.tgz (sha256 b95df736c5b6) ; vak installé dans le clone propre : 0.28.1
- Contrôle : 2026-10-14T17:37:04.928Z → 2026-10-14T17:39:38.051Z (153 s), clone propre /work/split_free_frontend_2/apres

**Notes** (6) :
- vérification build : échec avant et après sans ligne fichier:ligne : fins des journaux différentes, à comparer
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)
- table(s) « à moi » écartée(s) par l'agent (ignore), sans échec de preuve au journal : choix de périmètre, à dire à l'humain : debts_per_expense, expense_payers, expense_participants, friend_requests, group_invitations, debts_per_expense, expense_payers, expense_participants, friend_requests, group_invitations
- VAK013 « ! » sur des tables que vak refuse lui-même et que sync a mises dans ignore (défaut de vak, pas de l'agent) : invite_tokens
- « rls » (l'app montre à un utilisateur des lignes d'un autre ; à signaler à l'humain) : profiles

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 2 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_2c91d1'` | 0 | 17 s |
| `vak localdb --drop` | 0 | 1 s |
| `vak prove` | 0 | 6 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (5) :
- ! VAK006 supabase/functions/vak/agent.ts se charge, avec des avertissements (tables.groups : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; déclarez owner: "owner" (colonne qui désigne l'utilisateur) ; tables.members : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; déclarez owner: "profile" (colonne qui désigne l'utilisateur) ; tables.expenses : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; rien à déclarer : la RLS de l'app décide ; tables.transfers : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; rien à déclarer : la RLS de l'app décide ; tables.debts : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; rien à déclarer : la RLS de l'app décide ; tables.profiles : la politique « users can view all profiles » (using (true)) rend toutes les lignes lisibles par tout utilisateur connecté dans l'app ; l'assistant ne lit que les siennes (owner « id ») : si ce n'est pas voulu, corrigez la RLS de l'app ; jamais shared: true (vak prove dirait fuite) ; tables.friends : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; déclarez owner: "profile" ou "friend" (colonne qui désigne l'utilisateur))
- ! VAK013 chaque table de l'app est calibrée ou ignorée (7 dans tables ; ignore : 6 tables, 19 fonctions) ; dans ignore, tables de l'utilisateur : « debts_per_expense », « expense_payers », « expense_participants », « friend_requests », « group_invitations » (« debts_per_expense » : calibre-la, through: "lender" ; « expense_payers » : calibre-la, through: "expense" ; « expense_participants » : calibre-la, through: "expense" ; « friend_requests » : calibre-la, owner ; « group_invitations » : calibre-la, owner ; « invite_tokens » : table serveur (illisible pour authenticated) : rien à faire)
- ! VAK015 assistant éprouvé du 2026-10-14 ; mais l'app elle-même montre à un utilisateur des lignes d'un autre (profiles)
- ! VAK107 avis de sécurité (avertissement) (groups : politique « user can update group of his own » using (true) : publication par l'app : voulue ? ; members : politique « user can update members for his group » using (true) : publication par l'app : voulue ? ; expenses : politique « users can update expenses in their group » using (true) : publication par l'app : voulue ? ; debts : politique « users can update debts for their groups » using (true) : publication par l'app : voulue ? ; profiles : politique « users can view all profiles » using (true) : publication par l'app : voulue ? ; friends : politique « user can update friends for himself » using (true) : publication par l'app : voulue ? ; fonction « deleteuser » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « generate_invite_token » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « get_invite_group_id » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « get_unbound_members_for_token » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « join_group_with_token » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; profiles : table calibrée lisible sans compte (anon) : faille de l'app, sauf contenu public voulu)
- ! VAK108 colonnes qui décident des droits (avertissement) (groups.owner : modifiable par l'utilisateur et lue par la politique « select_groups_policy » : elle décide qui voit la ligne ; members.group_id : modifiable par l'utilisateur et lue par la politique « select_groups_policy » : elle décide qui voit la ligne ; members.profile : modifiable par l'utilisateur et lue par la politique « select_groups_policy » : elle décide qui voit la ligne ; expenses.group_id : modifiable par l'utilisateur et lue par la politique « users can access expenses in their groups » : elle décide qui voit la ligne ; transfers.group_id : modifiable par l'utilisateur et lue par la politique « users can interact with transfers in their group » : elle décide qui voit la ligne ; debts.group_id : modifiable par l'utilisateur et lue par la politique « users can access debts of their groups » : elle décide qui voit la ligne ; friends.profile : modifiable par l'utilisateur et lue par la politique « users can see their own friendships » : elle décide qui voit la ligne ; friends.friend : modifiable par l'utilisateur et lue par la politique « users can see their own friendships » : elle décide qui voit la ligne)

**Lignes « ! », « ✗ » et « – » de prove** (1) :
- ! profiles rls (l'app montre à A 1 ligne(s) de B (partage, publication) ; l'assistant ne les montre pas (owner « id ») ; la RLS de l'app laisse A lire la ligne de B (fuite de l'app, assistant ou non) ; lecture par l'assistant : jamais la ligne de B ; lecture par l'assistant : la ligne de A ; table du compte : l'assistant ne lit que la ligne de A ; lecture de la ligne de B par son identifiant : refusée ; totaux de read_data : 2 appels idéaux, chaque total égal au comptage de l'app sous la RLS de A)

## Preuve (vak-proof.json)

- reçu commité : éprouvé (vak 0.28.1) : debts éprouvé, expenses éprouvé, friends éprouvé, groups éprouvé, members éprouvé, profiles rls, transfers éprouvé
- preuve du contrôleur : éprouvé (vak 0.28.1) : debts éprouvé, expenses éprouvé, friends éprouvé, groups éprouvé, members éprouvé, profiles rls, transfers éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 18 s) | 0 (0 err., 19 s) | pas pire |
| typecheck | 0 (0 err., 5 s) | 0 (0 err., 6 s) | pas pire |
| lint | 0 (0 err., 7 s) | 0 (0 err., 21 s) | pas pire |
| tests | 0 (0 err., 9 s) | 0 (0 err., 10 s) | pas pire |
| build | 1 (0 err., 54 s) | 1 (0 err., 72 s) | pas pire : échec avant et après sans ligne fichier:ligne : fins des journaux différentes, à comparer |

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
- A supabase/migrations/20261014173318_vak_0001_core.sql
- A supabase/migrations/20261014173319_vak_0002_feedback.sql
- A supabase/migrations/20261014173320_vak_0003_history.sql
- A supabase/migrations/20261014173321_vak_0004_quota_erase.sql
- A vendor/vak/vak-agent-0.28.1.tgz

**À relire (diff : autres.diff)** (3) :
- M CODEBASE.md (branchement : cite vak)
- M src/app/(tabs)/_layout.tsx
- M src/app/(tabs)/account/settings/index.tsx (branchement : cite vak)

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis b239724), autres.diff.
