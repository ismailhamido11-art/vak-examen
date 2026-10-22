# Essai troupe_2 : échec

- App : /home/user/ai-chatbot/vak-examen/apps/troupe.bundle @ e3c2605 ; préparée 71aa564 ; HEAD c31bc6a (essai), 1 commit(s) de l'essai (2026-10-22T17:52:56+00:00 → 2026-10-22T17:52:56+00:00)
- Archive : vak-agent-0.29.2.tgz (sha256 29a2856be79e) ; vak installé dans le clone propre : 0.29.2
- Contrôle : 2026-10-22T17:53:57.529Z → 2026-10-22T17:54:59.498Z (62 s), clone propre /work/troupe_2/apres

**Raisons de l'échec** (3) :
- vérification typecheck pire qu'avant : 1 nouvelle(s) ligne(s) d'erreur dans les fichiers ou la configuration changés par l'essai
- vak prove → 1 (preuve à deux comptes : non prouvé (3 éprouvée(s), 0 en échec, 2 non prouvée(s), fonctions comprises (1) ; 132 totaux de read_data comparés) ; reçu inchangé dans supabase/functions/vak/vak-proof.json ; base laissée intacte [code 1])
- vak doctor --db → 1 (doctor : à corriger (contrôles ✗ ; causes et corrections : node_modules/@vak/agent/docs/FAQ.md, section 19) [code 1])

**Notes** (2) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 2 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_8e2288'` | 1 | 18 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 1 | 3 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (3) :
- ! VAK006 supabase/functions/vak/agent.ts se charge, avec des avertissements (tables.troupes : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; politique « troupes_select » : équipe ou rôle ? sinon owner: "created_by" ; tables.troupe_members : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; politique « members_select » : équipe ou rôle ? sinon owner: "user_id" ; tables.shows : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; politique « shows_select » : équipe ou rôle ? sinon owner: "created_by" ; tables.characters : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; politique « characters_select » : équipe ou rôle ? sinon owner: "titulaire_id")
- ✗ VAK015 preuve à deux comptes du 2026-10-22 : non prouvé (characters : non prouvé ; mes_personnages() : non prouvé)
- ! VAK108 colonnes qui décident des droits (avertissement) (troupes.nom : modifiable par l'utilisateur ; la politique « troupes_select » passe la ligne à une fonction : à vérifier ; troupes.ville : modifiable par l'utilisateur ; la politique « troupes_select » passe la ligne à une fonction : à vérifier ; shows.troupe_id : modifiable par l'utilisateur et lue par la politique « shows_select » : elle décide qui voit la ligne ; characters.show_id : modifiable par l'utilisateur et lue par la politique « characters_select » : elle décide qui voit la ligne)

**Lignes « ! », « ✗ » et « – » de prove** (2) :
- ✗ characters non prouvé (graine impossible : 23514 new row for relation "characters" violates check constraint "characters_check" ; totaux de read_data non comparés (verdict non prouvé))
- ✗ mes_personnages() non prouvé (« characters » (citée par la fonction) : aucune ligne de B semée (23514 new row for relation "characters" violates check constraint "characters_check") : non vérifiée ; appel par l'assistant de A : aucune donnée de B ; résultat de A inchangé quand les 17 ligne(s) de B sont retirées, puis quand un second compte copie B (3 table(s)) aux valeurs plus grandes, puis plus petites ; fuite témoin (calcul sur tous les comptes, posée puis retirée) : vue)

## Preuve (vak-proof.json)

- reçu commité : non prouvé (vak 0.29.2) : characters non prouvé, shows éprouvé, troupe_members éprouvé, troupes éprouvé ; fonctions : mes_personnages non prouvé
- preuve du contrôleur : non prouvé (vak 0.29.2) : characters non prouvé, shows éprouvé, troupe_members éprouvé, troupes éprouvé ; fonctions : mes_personnages non prouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 13 s) | 0 (0 err., 12 s) | pas pire |
| typecheck | 2 (5 err., 3 s) | 2 (5 err., 3 s) | pire : 1 nouvelle(s) ligne(s) d'erreur dans les fichiers ou la configuration changés par l'essai |
| lint | 0 (0 err., 4 s) | 0 (0 err., 11 s) | pas pire |
| tests | absent | absent | absent |
| build | 0 (0 err., 10 s) | 0 (0 err., 11 s) | pas pire |

**Nouvelles lignes d'erreur** (1) :
- typecheck : app/layout.tsx(11,50): error TS2304: Cannot find name 'LayoutProps'.

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
- A app/assistant/assistant.tsx
- A app/assistant/page.tsx
- A lib/vak.ts
- M package-lock.json
- M package.json
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
- A supabase/migrations/20261022174735_vak_0001_core.sql
- A supabase/migrations/20261022174736_vak_0002_feedback.sql
- A supabase/migrations/20261022174737_vak_0003_history.sql
- A supabase/migrations/20261022174738_vak_0004_quota_erase.sql
- M tsconfig.json
- A vendor/vak/vak-agent-0.29.2.tgz

**À relire (diff : autres.diff)** (5) :
- M app/layout.tsx (branchement : cite vak)
- A app/reglages/agent-settings.tsx (branchement : cite vak)
- A app/reglages/page.tsx
- M components/Shell.tsx
- A components/VakButton.tsx (branchement : cite vak)

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 71aa564), autres.diff.
