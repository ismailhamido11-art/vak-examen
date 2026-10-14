# Essai journal_2 : échec

- App : /home/user/ai-chatbot/vak-examen/apps/journal.bundle @ af3d891 ; préparée 6b82129 ; HEAD 39daf4e (essai), 2 commit(s) de l'essai (2026-10-14T17:13:31+00:00 → 2026-10-14T17:14:03+00:00)
- Archive : vak-agent-0.28.1.tgz (sha256 b95df736c5b6) ; vak installé dans le clone propre : 0.28.1
- Contrôle : 2026-10-14T17:14:17.625Z → 2026-10-14T17:15:39.517Z (82 s), clone propre /work/journal_2/apres

**Raisons de l'échec** (3) :
- vérification typecheck pire qu'avant : 1 nouvelle(s) ligne(s) d'erreur dans les fichiers ou la configuration changés par l'essai
- vak prove → 1 (preuve à deux comptes : non prouvé (3 éprouvée(s), 0 en échec, 2 non prouvée(s) ; 85 totaux de read_data comparés) ; reçu inchangé dans supabase/functions/vak/vak-proof.json ; base laissée intacte [code 1])
- vak doctor --db → 1 (doctor : à corriger (contrôles ✗ ; causes et corrections : node_modules/@vak/agent/docs/FAQ.md, section 19) [code 1])

**Notes** (3) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)
- table(s) « à moi » écartée(s) par l'agent (ignore), sans échec de preuve au journal : choix de périmètre, à dire à l'humain : newspaper_invitations, newspaper_invitations

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 2 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_a335e3'` | 1 | 17 s |
| `vak localdb --drop` | 0 | 1 s |
| `vak prove` | 1 | 3 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (5) :
- ! VAK006 supabase/functions/vak/agent.ts se charge, avec des avertissements (tables.newspapers : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; politique « newspapers_select » : équipe ou rôle ? sinon owner: "created_by" ; tables.articles : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; politique « articles_select » : équipe ou rôle ? sinon owner: "assignee_id" ; tables.article_photos : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; politique « photos_select » : équipe ou rôle ? sinon owner: "added_by" ; tables.newspaper_members : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; politique « members_select » : équipe ou rôle ? sinon owner: "user_id")
- ! VAK013 chaque table de l'app est calibrée ou ignorée (5 dans tables ; ignore : 1 tables, 4 fonctions) ; dans ignore, tables de l'utilisateur : « newspaper_invitations » (« newspaper_invitations » : calibre-la, owner)
- ✗ VAK015 preuve à deux comptes du 2026-10-14 : non prouvé (article_photos : non prouvé ; articles : non prouvé)
- ! VAK107 avis de sécurité (avertissement) (fonction « claim_invitations » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « create_newspaper » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « invite_member » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; fonction « remove_member » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul)
- ! VAK108 colonnes qui décident des droits (avertissement) (newspapers.name : modifiable par l'utilisateur ; la politique « newspapers_select » passe la ligne à une fonction : à vérifier ; newspapers.district : modifiable par l'utilisateur ; la politique « newspapers_select » passe la ligne à une fonction : à vérifier ; newspaper_members.role : modifiable par l'utilisateur ; la politique « members_select » passe la ligne à une fonction : à vérifier ; profiles.display_name : modifiable par l'utilisateur ; la politique « profiles_select » passe la ligne à une fonction : à vérifier)

**Lignes « ! », « ✗ » et « – » de prove** (2) :
- ✗ article_photos non prouvé (graine impossible : parent articles absent ; totaux de read_data non comparés (verdict non prouvé))
- ✗ articles non prouvé (graine impossible : 23514 l'article ne peut être confié qu'à un rédacteur ou propriétaire du journal ; totaux de read_data non comparés (verdict non prouvé))

## Preuve (vak-proof.json)

- reçu commité : non prouvé (vak 0.28.1) : article_photos non prouvé, articles non prouvé, newspaper_members éprouvé, newspapers éprouvé, profiles éprouvé
- preuve du contrôleur : non prouvé (vak 0.28.1) : article_photos non prouvé, articles non prouvé, newspaper_members éprouvé, newspapers éprouvé, profiles éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 12 s) | 0 (0 err., 13 s) | pas pire |
| typecheck | 2 (1 err., 4 s) | 2 (1 err., 4 s) | pire : 1 nouvelle(s) ligne(s) d'erreur dans les fichiers ou la configuration changés par l'essai |
| lint | 0 (0 err., 4 s) | 0 (0 err., 28 s) | pas pire |
| tests | absent | absent | absent |
| build | 0 (0 err., 11 s) | 0 (0 err., 13 s) | pas pire |

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
- A supabase/migrations/20261014170840_vak_0001_core.sql
- A supabase/migrations/20261014170841_vak_0002_feedback.sql
- A supabase/migrations/20261014170842_vak_0003_history.sql
- A supabase/migrations/20261014170843_vak_0004_quota_erase.sql
- M tsconfig.json
- A vendor/vak/vak-agent-0.28.1.tgz

**À relire (diff : autres.diff)** (5) :
- M src/app/layout.tsx (branchement : cite vak)
- A src/app/reglages/agent-settings.tsx (branchement : cite vak)
- A src/app/reglages/page.tsx
- A src/app/vak-button.tsx (branchement : cite vak)
- M src/components/Shell.tsx

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 6b82129), autres.diff.
