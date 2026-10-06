# Essai temoin_company_invoicing : échec

- App : https://github.com/xtshepana/company-invoicing @ e999749 ; préparée e999749 ; HEAD e999749 (essai), 0 commit(s) de l'essai
- Archive : aucune (groupe témoin) ; vak installé dans le clone propre : aucun
- Contrôle : 2026-10-06T15:47:10.911Z → 2026-10-06T15:48:45.952Z (95 s), clone propre /work/temoin_company_invoicing/apres

**Raisons de l'échec** (3) :
- aucun commit de l'essai
- vak non installé : supabase/functions/vak/vak.lock.json absent du commit final
- 1 sabotage(s) : restes

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
| installation | 0 (0 err., 28 s) | 0 (0 err., 18 s) | pas pire |
| typecheck | 0 (0 err., 11 s) | 0 (0 err., 10 s) | pas pire |
| lint | 0 (0 err., 12 s) | 0 (0 err., 11 s) | pas pire |
| tests | 0 (0 err., 2 s) | 0 (0 err., 2 s) | pas pire |
| build | 1 (0 err., 52 s) | 1 (0 err., 53 s) | pas pire : échec avant et après sans ligne fichier:ligne : fins des journaux différentes, à comparer |

## Dépendances

Aucune entrée retirée ni changée (package-lock.json : +0).

## Fichiers changés depuis le commit de l'app

**Intégration** (0)

**À relire (diff : autres.diff)** (0)

## Sabotages

- restes : restes non commités dans /work/temoin_company_invoicing/app :  M .env.example ;  M CLAUDE.md ;  M components/layout/nav-items.ts ;  M lib/env.ts ;  M package-lock.json ;  M package.json ;  M types/database.ts ; ?? app/(app)/assistant/page.tsx ; ?? components/assistant/assistant-chat.tsx ; ?? lib/ai/anthropic-client.ts ; ?? lib/ai/types.ts ; ?? lib/validations/assistant.ts ; ?? server/actions/assistant-actions.ts ; ?? server/services/assistant-pending.ts ; ?? server/services/assistant-tools.ts ; ?? server/services/assistant.ts ; ?? supabase/migrations/0036_assistant_pending_actions.sql ; ?? tests/sql/assistant_pending_actions.sql ; ?? tests/unit/assistant-confirm.test.ts ; ?? tests/unit/assistant.test.ts

Fichiers : rapport.json, avant.json, apres.json, journaux/.
