# Essai temoin_equipe : échec

- App : /home/user/ai-chatbot/vak-examen/apps/equipe.bundle @ ed96d9a ; préparée ed96d9a ; HEAD e262e87 (essai), 1 commit(s) de l'essai (2026-10-06T15:18:37+00:00 → 2026-10-06T15:18:37+00:00)
- Archive : aucune (groupe témoin) ; vak installé dans le clone propre : aucun
- Contrôle : 2026-10-06T15:18:46.862Z → 2026-10-06T15:19:13.514Z (27 s), clone propre /work/temoin_equipe/apres

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
| installation | 0 (0 err., 11 s) | 0 (0 err., 10 s) | pas pire |
| typecheck | 2 (1 err., 3 s) | 2 (1 err., 3 s) | pas pire |
| lint | 0 (0 err., 4 s) | 0 (0 err., 4 s) | pas pire |
| tests | absent | absent | absent |
| build | 0 (0 err., 10 s) | 0 (0 err., 10 s) | pas pire |

## Dépendances

Aucune entrée retirée ni changée (package-lock.json : +0).

## Fichiers changés depuis le commit de l'app

**Intégration** (0)

**À relire (diff : autres.diff)** (8) :
- M .env.example
- M README.md
- A src/app/api/assistant/route.ts
- M src/app/globals.css
- A src/components/Assistant.tsx
- M src/components/AuthGate.tsx
- A src/lib/assistant/actions.ts
- A src/lib/assistant/server.ts

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis ed96d9a), autres.diff.
