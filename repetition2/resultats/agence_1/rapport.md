# Essai agence_1 : échec

- App : /home/user/ai-chatbot/vak-examen/apps/agence.bundle @ fed6082 ; préparée c19dc41 ; HEAD b9aeb65 (essai), 1 commit(s) de l'essai (2026-10-10T18:02:57+00:00 → 2026-10-10T18:02:57+00:00)
- Archive : vak-agent-0.26.1.tgz (sha256 e0516efc36a3) ; vak installé dans le clone propre : 0.26.1
- Contrôle : 2026-10-10T18:03:52.113Z → 2026-10-10T18:04:45.202Z (53 s), clone propre /work/agence_1/apres

**Raisons de l'échec** (1) :
- vérification typecheck pire qu'avant : 1 nouvelle(s) ligne(s) d'erreur dans les fichiers ou la configuration changés par l'essai

**Notes** (2) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 1 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_ace0f8'` | 0 | 14 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 0 | 3 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (2) :
- ! VAK006 supabase/functions/vak/agent.ts se charge, avec des avertissements (tables.agencies : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; politique « agencies_select » : équipe ou rôle ? sinon owner: "created_by" ; tables.agency_members : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; politique « members_select » : équipe ou rôle ? sinon owner: "user_id" ; tables.agency_invitations : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; politique « invitations_select » : équipe ou rôle ? sinon owner: "invited_by" ; tables.trips : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; politique « trips_select » : équipe ou rôle ? sinon owner: "created_by" ; tables.bookings : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; politique « bookings_select » : équipe ou rôle ? sinon owner: "assigned_to" ; tables.bookings.update : la politique « bookings_select » de l'app ouvre la lecture autrement que par « assigned_to » (équipe, rôle…), qui n'est donc pas devinée propriétaire : écriture sous la seule RLS de l'app, toujours avec « Valider » ; permise si vak prove prouve que l'assistant de A n'écrit rien chez B (sinon doctor VAK015 ✗))
- ! VAK108 colonnes qui décident des droits (avertissement) (agencies.name : modifiable par l'utilisateur ; la politique « agencies_select » passe la ligne à une fonction : à vérifier ; agencies.created_by : modifiable par l'utilisateur ; la politique « agencies_select » passe la ligne à une fonction : à vérifier ; agencies.created_at : modifiable par l'utilisateur ; la politique « agencies_select » passe la ligne à une fonction : à vérifier ; agency_members.role : modifiable par l'utilisateur ; la politique « members_select » passe la ligne à une fonction : à vérifier ; agency_members.created_at : modifiable par l'utilisateur ; la politique « members_select » passe la ligne à une fonction : à vérifier ; trips.agency_id : modifiable par l'utilisateur et lue par la politique « trips_select » : elle décide qui voit la ligne ; bookings.agency_id : modifiable par l'utilisateur et lue par la politique « bookings_select » : elle décide qui voit la ligne)

## Preuve (vak-proof.json)

- reçu commité : éprouvé (vak 0.26.1) : agencies éprouvé, agency_invitations éprouvé, agency_members éprouvé, bookings éprouvé, trips éprouvé
- preuve du contrôleur : éprouvé (vak 0.26.1) : agencies éprouvé, agency_invitations éprouvé, agency_members éprouvé, bookings éprouvé, trips éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 16 s) | 0 (0 err., 9 s) | pas pire |
| typecheck | 2 (7 err., 2 s) | 2 (7 err., 3 s) | pire : 1 nouvelle(s) ligne(s) d'erreur dans les fichiers ou la configuration changés par l'essai |
| lint | 0 (0 err., 3 s) | 0 (0 err., 9 s) | pas pire |
| tests | absent | absent | absent |
| build | 0 (0 err., 9 s) | 0 (0 err., 13 s) | pas pire |

**Nouvelles lignes d'erreur** (1) :
- typecheck : app/layout.tsx(37,50): error TS2304: Cannot find name 'LayoutProps'.

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
- A supabase/migrations/20261010175856_vak_0001_core.sql
- A supabase/migrations/20261010175857_vak_0002_feedback.sql
- A supabase/migrations/20261010175858_vak_0003_history.sql
- A supabase/migrations/20261010175859_vak_0004_quota_erase.sql
- M tsconfig.json
- A vendor/vak/vak-agent-0.26.1.tgz

**À relire (diff : autres.diff)** (5) :
- A app/assistant-button.tsx (branchement : cite vak)
- M app/layout.tsx (branchement : cite vak)
- A app/reglages/agent-settings.tsx (branchement : cite vak)
- A app/reglages/page.tsx
- A lib/supabase/client.ts

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis c19dc41), autres.diff.
