# Essai streakmates_1 : réussi

- App : https://github.com/navysum/StreakMates @ 79c610d ; préparée 462a2f8 ; HEAD c2924de (essai), 1 commit(s) de l'essai (2026-10-14T16:51:56+00:00 → 2026-10-14T16:51:56+00:00)
- Archive : vak-agent-0.28.1.tgz (sha256 b95df736c5b6) ; vak installé dans le clone propre : 0.28.1
- Contrôle : 2026-10-14T16:53:14.754Z → 2026-10-14T16:54:25.207Z (70 s), clone propre /work/streakmates_1/apres

**Notes** (4) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)
- table(s) « à moi » écartée(s) par l'agent (ignore), sans échec de preuve au journal : choix de périmètre, à dire à l'humain : habit_order, nudges, profiles, reactions, habit_order, nudges, profiles, reactions
- VAK013 « ! » sur des tables que vak refuse lui-même et que sync a mises dans ignore (défaut de vak, pas de l'agent) : invite_code_attempts

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 2 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_82fa84'` | 0 | 18 s |
| `vak localdb --drop` | 0 | 1 s |
| `vak prove` | 0 | 4 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (4) :
- ! VAK006 supabase/functions/vak/agent.ts se charge, avec des avertissements (tables.habits : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; déclarez owner: "owner_id" (colonne qui désigne l'utilisateur) ; tables.check_ins : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; déclarez owner: "user_id" (colonne qui désigne l'utilisateur) ; tables.tasks : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; déclarez owner: "user_id" (colonne qui désigne l'utilisateur) ; tables.task_completions : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; déclarez owner: "user_id" (colonne qui désigne l'utilisateur) ; tables.group_members : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; déclarez owner: "user_id" (colonne qui désigne l'utilisateur) ; tables.groups : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; déclarez owner: "created_by" (colonne qui désigne l'utilisateur))
- ! VAK013 chaque table de l'app est calibrée ou ignorée (7 dans tables ; ignore : 5 tables, 13 fonctions) ; dans ignore, tables de l'utilisateur : « habit_order », « nudges », « profiles », « reactions » (« habit_order » : calibre-la, owner ; « nudges » : calibre-la, owner ; « profiles » : calibre-la, owner ; « reactions » : calibre-la, owner ; « invite_code_attempts » : table serveur (illisible pour authenticated) : rien à faire)
- ! VAK107 avis de sécurité (avertissement) (fonction « can_see_check_in » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « can_see_habit » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « can_see_task » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « is_group_member » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « is_group_owner » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « is_shared_once_task » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « shares_group_with » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; task_completions : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; group_members : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; groups : politique ouverte à anon : à vérifier (aucune ligne lue sans compte))
- ! VAK108 colonnes qui décident des droits (avertissement) (habits.group_id : modifiable par l'utilisateur et lue par la politique « habits_select » : elle décide qui voit la ligne ; tasks.group_id : modifiable par l'utilisateur et lue par la politique « tasks_select » : elle décide qui voit la ligne ; groups.name : modifiable par l'utilisateur ; la politique « groups_select » passe la ligne à une fonction : à vérifier ; groups.emoji : modifiable par l'utilisateur ; la politique « groups_select » passe la ligne à une fonction : à vérifier)

## Preuve (vak-proof.json)

- reçu commité : éprouvé (vak 0.28.1) : check_ins éprouvé, focus_sessions éprouvé, group_members éprouvé, groups éprouvé, habits éprouvé, task_completions éprouvé, tasks éprouvé
- preuve du contrôleur : éprouvé (vak 0.28.1) : check_ins éprouvé, focus_sessions éprouvé, group_members éprouvé, groups éprouvé, habits éprouvé, task_completions éprouvé, tasks éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 20 s) | 0 (0 err., 18 s) | pas pire |
| typecheck | 0 (0 err., 5 s) | 0 (0 err., 6 s) | pas pire |
| lint | absent | absent | absent |
| tests | 0 (0 err., 1 s) | 0 (0 err., 1 s) | pas pire |
| build | 0 (0 err., 23 s) | 0 (0 err., 18 s) | pas pire |

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
- A app/(tabs)/assistant.tsx
- M package-lock.json
- M package.json
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
- A supabase/migrations/20261014164721_vak_0001_core.sql
- A supabase/migrations/20261014164722_vak_0002_feedback.sql
- A supabase/migrations/20261014164723_vak_0003_history.sql
- A supabase/migrations/20261014164724_vak_0004_quota_erase.sql
- A vendor/vak/vak-agent-0.28.1.tgz

**À relire (diff : autres.diff)** (3) :
- M app/(tabs)/_layout.tsx
- M app/you.tsx (branchement : cite vak)
- M tsconfig.json

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 462a2f8), autres.diff.
