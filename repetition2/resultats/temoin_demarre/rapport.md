# Essai temoin_demarre : échec

- App : /home/user/ai-chatbot/vak-examen/apps/demarre.bundle @ 891485f ; préparée 891485f ; HEAD 3c9d7ca (essai), 1 commit(s) de l'essai (2026-10-06T15:15:49+00:00 → 2026-10-06T15:15:49+00:00)
- Archive : aucune (groupe témoin) ; vak installé dans le clone propre : aucun
- Contrôle : 2026-10-06T15:18:22.675Z → 2026-10-06T15:18:57.852Z (35 s), clone propre /work/temoin_demarre/apres

**Raisons de l'échec** (1) :
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
| installation | 0 (0 err., 18 s) | 0 (0 err., 14 s) | pas pire |
| typecheck | 0 (0 err., 2 s) | 0 (0 err., 2 s) | pas pire |
| lint | 0 (0 err., 3 s) | 0 (0 err., 4 s) | pas pire |
| tests | absent | absent | absent |
| build | 0 (0 err., 3 s) | 0 (0 err., 3 s) | pas pire |

## Dépendances

Aucune entrée retirée ni changée (package-lock.json : +0).

## Fichiers changés depuis le commit de l'app

**Intégration** (2) :
- A src/app/assistant.tsx
- A src/lib/assistant.ts

**À relire (diff : autres.diff)** (4) :
- M src/app/_layout.tsx
- M src/app/index.tsx
- A supabase/functions/assistant/index.ts
- M tsconfig.json

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 891485f), autres.diff.
