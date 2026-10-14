# Essai streakmates_2 : réussi

- App : https://github.com/navysum/StreakMates @ 79c610d ; préparée 462a2f8 ; HEAD 1f15c83 (essai), 1 commit(s) de l'essai (2026-10-14T18:31:33+00:00 → 2026-10-14T18:31:33+00:00)
- Archive : vak-agent-0.28.1.tgz (sha256 b95df736c5b6) ; vak installé dans le clone propre : 0.28.1
- Contrôle : 2026-10-14T18:32:37.775Z → 2026-10-14T18:33:33.691Z (56 s), clone propre /work/streakmates_2/apres

**Notes** (4) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)
- table(s) « à moi » écartée(s) par l'agent (ignore), sans échec de preuve au journal : choix de périmètre, à dire à l'humain : group_members, groups, habit_order, nudges, reactions, task_completions, group_members, groups, habit_order, nudges, reactions, task_completions
- VAK013 « ! » sur des tables que vak refuse lui-même et que sync a mises dans ignore (défaut de vak, pas de l'agent) : invite_code_attempts

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 2 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_153d22'` | 0 | 18 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 0 | 4 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (4) :
- ! VAK006 supabase/functions/vak/agent.ts se charge, avec des avertissements (tables.check_ins : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; déclarez owner: "user_id" (colonne qui désigne l'utilisateur), ou through: "habit_id" (la ligne appartient à l'utilisateur par sa table parente, calibrée))
- ! VAK013 chaque table de l'app est calibrée ou ignorée (5 dans tables ; ignore : 7 tables, 13 fonctions) ; dans ignore, tables de l'utilisateur : « group_members », « groups », « habit_order », « nudges », « reactions », « task_completions » (« invite_code_attempts » : table serveur (illisible pour authenticated) : rien à faire ; « group_members » : calibre-la, owner ; « groups » : calibre-la, owner ; « habit_order » : calibre-la, owner ; « nudges » : calibre-la, owner ; « reactions » : calibre-la, owner ; « task_completions » : calibre-la, owner)
- ! VAK107 avis de sécurité (avertissement) (fonction « can_see_check_in » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « can_see_habit » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « can_see_task » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « is_group_member » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « is_group_owner » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « is_shared_once_task » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « shares_group_with » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul)
- ! VAK108 colonnes qui décident des droits (avertissement) (habits.group_id : modifiable par l'utilisateur et lue par la politique « habits_select » : elle décide qui voit la ligne ; tasks.group_id : modifiable par l'utilisateur et lue par la politique « tasks_select » : elle décide qui voit la ligne ; profiles.display_name : modifiable par l'utilisateur ; la politique « profiles_select » passe la ligne à une fonction : à vérifier ; profiles.avatar_url : modifiable par l'utilisateur ; la politique « profiles_select » passe la ligne à une fonction : à vérifier ; profiles.timezone : modifiable par l'utilisateur ; la politique « profiles_select » passe la ligne à une fonction : à vérifier ; profiles.username : modifiable par l'utilisateur ; la politique « profiles_select » passe la ligne à une fonction : à vérifier)

## Preuve (vak-proof.json)

- reçu commité : éprouvé (vak 0.28.1) : check_ins éprouvé, focus_sessions éprouvé, habits éprouvé, profiles éprouvé, tasks éprouvé
- preuve du contrôleur : éprouvé (vak 0.28.1) : check_ins éprouvé, focus_sessions éprouvé, habits éprouvé, profiles éprouvé, tasks éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 16 s) | 0 (0 err., 17 s) | pas pire |
| typecheck | 0 (0 err., 5 s) | 0 (0 err., 6 s) | pas pire |
| lint | absent | absent | absent |
| tests | 0 (0 err., 2 s) | 0 (0 err., 1 s) | pas pire |
| build | 0 (0 err., 4 s) | 0 (0 err., 5 s) | pas pire |

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
- A supabase/migrations/20261014182801_vak_0001_core.sql
- A supabase/migrations/20261014182802_vak_0002_feedback.sql
- A supabase/migrations/20261014182803_vak_0003_history.sql
- A supabase/migrations/20261014182804_vak_0004_quota_erase.sql
- A vendor/vak/vak-agent-0.28.1.tgz

**À relire (diff : autres.diff)** (3) :
- M app/(tabs)/_layout.tsx
- M app/you.tsx (branchement : cite vak)
- M tsconfig.json

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 462a2f8), autres.diff.
