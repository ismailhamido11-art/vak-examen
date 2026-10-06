# Essai temoin_workout_plan_companion : échec

- App : https://github.com/AndreuCrespo/workout-plan-companion @ ebf680c ; préparée ebf680c ; HEAD 37e8d14 (essai), 1 commit(s) de l'essai (2026-10-06T15:37:06+00:00 → 2026-10-06T15:37:06+00:00)
- Archive : aucune (groupe témoin) ; vak installé dans le clone propre : aucun
- Contrôle : 2026-10-06T15:37:16.976Z → 2026-10-06T15:37:48.783Z (32 s), clone propre /work/temoin_workout_plan_companion/apres

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
| installation | 0 (0 err., 15 s) | 0 (0 err., 18 s) | pas pire |
| typecheck | 0 (0 err., 4 s) | 0 (0 err., 3 s) | pas pire |
| lint | 0 (0 err., 8 s) | 0 (0 err., 6 s) | pas pire |
| tests | absent | absent | absent |
| build | 0 (0 err., 5 s) | 0 (0 err., 4 s) | pas pire |

## Dépendances

Aucune entrée retirée ni changée (mobile/package-lock.json : +0).

## Fichiers changés depuis le commit de l'app

**Intégration** (0)

**À relire (diff : autres.diff)** (4) :
- M docs/assistant-turn-preflight.md
- A supabase/tests/assistant_isolation.sql
- A supabase/tests/auth_stub.sql
- A supabase/tests/run.sh

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis ebf680c), autres.diff.
