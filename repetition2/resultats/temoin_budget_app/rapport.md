# Essai temoin_budget_app : échec

- App : https://github.com/AndrerezaMedya/budget-app @ f1f3ef1 ; préparée f1f3ef1 ; HEAD f1f3ef1 (essai), 0 commit(s) de l'essai
- Archive : aucune (groupe témoin) ; vak installé dans le clone propre : aucun
- Contrôle : 2026-10-06T15:26:11.194Z → 2026-10-06T15:27:04.580Z (53 s), clone propre /work/temoin_budget_app/apres

**Raisons de l'échec** (3) :
- aucun commit de l'essai
- vak non installé : supabase/functions/vak/vak.lock.json absent du commit final
- 1 sabotage(s) : restes

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
| installation | 0 (0 err., 3 s) | 0 (0 err., 18 s) | pas pire |
| typecheck | 0 (0 err., 7 s) | 0 (0 err., 7 s) | pas pire |
| lint | 0 (0 err., 10 s) | 0 (0 err., 9 s) | pas pire |
| tests | absent | absent | absent |
| build | 1 (0 err., 19 s) | 1 (0 err., 18 s) | pas pire |

## Dépendances

Aucune entrée retirée ni changée (package-lock.json : +0 ; pnpm-lock.yaml : +0).

## Fichiers changés depuis le commit de l'app

**Intégration** (0)

**À relire (diff : autres.diff)** (0)

## Sabotages

- restes : restes non commités dans /work/temoin_budget_app/app :  M src/config/env.ts ;  M src/config/navigation.ts ;  M src/i18n/translations.ts ;  M src/types/supabase.ts ; ?? src/app/api/assistant/proposals/[id]/route.ts ; ?? src/app/api/assistant/route.ts ; ?? src/app/app/assistant/page.tsx ; ?? src/components/assistant/chat.tsx ; ?? src/lib/assistant/apply.ts ; ?? src/lib/assistant/chat.ts ; ?? src/lib/assistant/schemas.ts ; ?? src/lib/assistant/tools.ts ; ?? supabase/migrations/202611060001_assistant_proposals.sql

Fichiers : rapport.json, avant.json, apres.json, journaux/.
