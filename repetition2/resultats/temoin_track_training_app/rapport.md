# Essai temoin_track_training_app : échec

- App : https://github.com/aprescod12/track-training-app @ 00acb94 ; préparée 00acb94 ; HEAD bb7d4f3 (essai), 1 commit(s) de l'essai (2026-10-06T15:33:16+00:00 → 2026-10-06T15:33:16+00:00)
- Archive : aucune (groupe témoin) ; vak installé dans le clone propre : aucun
- Contrôle : 2026-10-06T15:33:26.486Z → 2026-10-06T15:34:04.126Z (38 s), clone propre /work/temoin_track_training_app/apres

**Raisons de l'échec** (1) :
- vak non installé : supabase/functions/vak/vak.lock.json absent du commit final

**Notes** (3) :
- vérification build : échec avant et après sans ligne fichier:ligne : fins des journaux différentes, à comparer
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|

## Preuve (vak-proof.json)

- reçu commité : absent
- preuve du contrôleur : absent

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 20 s) | 0 (0 err., 17 s) | pas pire |
| typecheck | 0 (0 err., 7 s) | 0 (0 err., 6 s) | pas pire |
| lint | 0 (0 err., 5 s) | 0 (0 err., 5 s) | pas pire |
| tests | 0 (0 err., 3 s) | 0 (0 err., 3 s) | pas pire |
| build | 1 (0 err., 6 s) | 1 (0 err., 7 s) | pas pire : échec avant et après sans ligne fichier:ligne : fins des journaux différentes, à comparer |

## Dépendances

Aucune entrée retirée ni changée (package-lock.json : +0).

## Fichiers changés depuis le commit de l'app

**Intégration** (2) :
- A app/assistant.tsx
- A lib/assistant.ts

**À relire (diff : autres.diff)** (7) :
- M app/(tabs)/profile.tsx
- M eslint.config.js
- M supabase/README.md
- A supabase/functions/assistant/index.ts
- A supabase/migrations/20260828150000_ai_assistant.sql
- A supabase/tests/database/ai_assistant.test.sql
- M tsconfig.json

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 00acb94), autres.diff.
