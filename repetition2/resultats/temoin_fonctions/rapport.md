# Essai temoin_fonctions : échec

- App : /home/user/ai-chatbot/vak-examen/apps/fonctions.bundle @ 8246749 ; préparée 8246749 ; HEAD 0e31ffe (essai), 1 commit(s) de l'essai (2026-10-06T15:21:53+00:00 → 2026-10-06T15:21:53+00:00)
- Archive : aucune (groupe témoin) ; vak installé dans le clone propre : aucun
- Contrôle : 2026-10-06T15:22:01.865Z → 2026-10-06T15:22:31.544Z (30 s), clone propre /work/temoin_fonctions/apres

**Raisons de l'échec** (2) :
- vérification typecheck pire qu'avant : code 0 → 2
- vak non installé : supabase/functions/vak/vak.lock.json absent du commit final

**Notes** (2) :
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
| installation | 0 (0 err., 17 s) | 0 (0 err., 20 s) | pas pire |
| typecheck | 0 (0 err., 2 s) | 2 (6 err., 2 s) | pire : code 0 → 2 |
| lint | 0 (0 err., 4 s) | 0 (0 err., 4 s) | pas pire |
| tests | absent | absent | absent |
| build | 0 (0 err., 3 s) | 0 (0 err., 4 s) | pas pire |

**Nouvelles lignes d'erreur** (6) :
- typecheck : supabase/functions/assistant/index.ts(9,30): error TS2307: Cannot find module 'npm:@supabase/supabase-js@2' or its corresponding type declarations.
- typecheck : supabase/functions/assistant/index.ts(127,1): error TS2304: Cannot find name 'Deno'.
- typecheck : supabase/functions/assistant/index.ts(127,19): error TS7006: Parameter 'req' implicitly has an 'any' type.
- typecheck : supabase/functions/assistant/index.ts(131,18): error TS2304: Cannot find name 'Deno'.
- typecheck : supabase/functions/assistant/index.ts(135,27): error TS2304: Cannot find name 'Deno'.
- typecheck : supabase/functions/assistant/index.ts(135,58): error TS2304: Cannot find name 'Deno'.

## Dépendances

Aucune entrée retirée ni changée (package-lock.json : +0).

## Fichiers changés depuis le commit de l'app

**Intégration** (2) :
- A src/app/(tabs)/assistant.tsx
- A src/lib/assistant.ts

**À relire (diff : autres.diff)** (2) :
- M src/app/(tabs)/_layout.tsx
- A supabase/functions/assistant/index.ts

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 8246749), autres.diff.
