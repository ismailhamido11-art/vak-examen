# Essai equipe_2 : échec

- App : /home/user/ai-chatbot/vak-examen/apps/equipe.bundle @ ed96d9a ; préparée 15577d2 ; HEAD 70aff0f (essai), 1 commit(s) de l'essai (2026-10-06T13:35:44+00:00 → 2026-10-06T13:35:44+00:00)
- Archive : vak-agent-0.24.3.tgz (sha256 2765b6929c14) ; vak installé dans le clone propre : 0.24.3
- Contrôle : 2026-10-06T13:35:57.955Z → 2026-10-06T13:36:54.795Z (57 s), clone propre /work/equipe_2/apres

**Raisons de l'échec** (3) :
- vérification typecheck pire qu'avant : 1 nouvelle(s) ligne(s) d'erreur dans les fichiers ou la configuration changés par l'essai
- vak prove → 1 (preuve à deux comptes : non prouvé (4 éprouvée(s), 0 en échec, 1 non prouvée(s) ; 168 totaux de read_data comparés) ; reçu inchangé dans supabase/functions/vak/vak-proof.json ; base laissée intacte [code 1])
- vak doctor --db → 1 (doctor : à corriger (contrôles ✗ ; causes et corrections : node_modules/@vak/agent/docs/FAQ.md, section 19) [code 1])

**Notes** (2) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 1 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_da18a8'` | 1 | 18 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 1 | 2 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (4) :
- ! VAK006 supabase/functions/vak/agent.ts se charge, avec des avertissements (tables.team_members : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; déclarez through: "team_id" (la ligne appartient à l'utilisateur par sa table parente, calibrée))
- ✗ VAK015 preuve à deux comptes du 2026-10-06 : non prouvé (team_invitations : non prouvé)
- ! VAK107 avis de sécurité (avertissement) (fonction « create_team » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « invite_member » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « is_site_member » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « is_site_team_user » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « is_team_member » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « is_team_owner » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « team_roster » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul)
- ! VAK108 colonnes qui décident des droits (avertissement) (teams.name : modifiable par l'utilisateur ; la politique « teams_select » passe la ligne à une fonction : à vérifier ; teams.created_at : modifiable par l'utilisateur ; la politique « teams_select » passe la ligne à une fonction : à vérifier ; sites.team_id : modifiable par l'utilisateur et lue par la politique « sites_select » : elle décide qui voit la ligne ; tasks.site_id : modifiable par l'utilisateur et lue par la politique « tasks_select » : elle décide qui voit la ligne)

**Lignes « ! », « ✗ » et « – » de prove** (1) :
- ✗ team_invitations non prouvé (la RLS de l'app ne montre pas à A sa propre ligne : la graine ne suit pas une règle de l'app ; RLS de l'app : la ligne de B est invisible pour A ; lecture par l'assistant : jamais la ligne de B ; ligne de C, coéquipier de A : ni l'app ni l'assistant ne la montrent à A ; lecture de la ligne de B par son identifiant : refusée ; totaux de read_data non comparés (verdict non prouvé))

## Preuve (vak-proof.json)

- reçu commité : non prouvé (vak 0.24.3) : sites éprouvé, tasks éprouvé, team_invitations non prouvé, team_members éprouvé, teams éprouvé
- preuve du contrôleur : non prouvé (vak 0.24.3) : sites éprouvé, tasks éprouvé, team_invitations non prouvé, team_members éprouvé, teams éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 10 s) | 0 (0 err., 11 s) | pas pire |
| typecheck | 2 (1 err., 3 s) | 2 (1 err., 3 s) | pire : 1 nouvelle(s) ligne(s) d'erreur dans les fichiers ou la configuration changés par l'essai |
| lint | 0 (0 err., 3 s) | 0 (0 err., 9 s) | pas pire |
| tests | absent | absent | absent |
| build | 0 (0 err., 10 s) | 0 (0 err., 10 s) | pas pire |

**Nouvelles lignes d'erreur** (1) :
- typecheck : src/app/layout.tsx(11,50): error TS2304: Cannot find name 'LayoutProps'.

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
- A supabase/config.toml
- A supabase/functions/vak/agent.ts
- A supabase/functions/vak/deno.json
- A supabase/functions/vak/index.ts
- A supabase/functions/vak/schema.gen.ts
- A supabase/functions/vak/tsconfig.json
- A supabase/functions/vak/vak-proof.json
- A supabase/functions/vak/vak-server.mjs
- A supabase/functions/vak/vak.lock.json
- A supabase/migrations/20261006133235_vak_0001_core.sql
- A supabase/migrations/20261006133236_vak_0002_feedback.sql
- A supabase/migrations/20261006133237_vak_0003_history.sql
- A supabase/migrations/20261006133238_vak_0004_quota_erase.sql
- M tsconfig.json
- A vendor/vak/vak-agent-0.24.3.tgz

**À relire (diff : autres.diff)** (5) :
- M src/app/layout.tsx (branchement : cite vak)
- A src/app/reglages/agent-settings.tsx (branchement : cite vak)
- A src/app/reglages/page.tsx
- A src/components/AssistantButton.tsx (branchement : cite vak)
- M src/components/AuthGate.tsx

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 15577d2), autres.diff.
