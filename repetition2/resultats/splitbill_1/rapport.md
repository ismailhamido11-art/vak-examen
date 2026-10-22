# Essai splitbill_1 : échec

- App : https://github.com/j769chen/splitbill @ 59a1683 ; préparée bfeb3b0 ; HEAD bfeb3b0 (essai), 0 commit(s) de l'essai
- Archive : vak-agent-0.29.2.tgz (sha256 29a2856be79e) ; vak installé dans le clone propre : aucun
- Contrôle : 2026-10-22T16:45:03.955Z → 2026-10-22T16:46:05.991Z (62 s), clone propre /work/splitbill_1/apres

**Raisons de l'échec** (2) :
- aucun commit de l'essai
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
| installation | 0 (0 err., 38 s) | 0 (0 err., 16 s) | pas pire |
| typecheck | 0 (0 err., 7 s) | 0 (0 err., 6 s) | pas pire |
| lint | 0 (0 err., 4 s) | 0 (0 err., 3 s) | pas pire |
| tests | 0 (0 err., 29 s) | 0 (0 err., 27 s) | pas pire |
| build | 0 (0 err., 36 s) | 0 (0 err., 9 s) | pas pire |

## Dépendances

Aucune entrée retirée ni changée (package-lock.json : +0).

## Fichiers changés depuis le commit de l'app

**Intégration** (1) :
- A vendor/vak/vak-agent-0.29.2.tgz

**À relire (diff : autres.diff)** (0)

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/.
