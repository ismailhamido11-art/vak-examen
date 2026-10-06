# Essai fonctions_1 : échec

- App : /home/user/ai-chatbot/vak-examen/apps/fonctions.bundle @ 8246749 ; préparée 5f86006 ; HEAD e4d0c57 (essai), 1 commit(s) de l'essai (2026-10-06T12:35:07+00:00 → 2026-10-06T12:35:07+00:00)
- Archive : vak-agent-0.24.3.tgz (sha256 2765b6929c14) ; vak installé dans le clone propre : 0.24.3
- Contrôle : 2026-10-06T12:35:18.964Z → 2026-10-06T12:36:10.860Z (52 s), clone propre /work/fonctions_1/apres

**Raisons de l'échec** (4) :
- vak test → 1 (vak test : à corriger [code 1])
- vak prove → 1 (preuve à deux comptes : non prouvé (1 éprouvée(s), 0 en échec, 5 non prouvée(s), fonctions comprises (4) ; 38 totaux de read_data comparés) ; reçu écrit dans supabase/functions/vak/vak-proof.json ; base laissée intacte [code 1])
- vak doctor --db → 1 (doctor : à corriger (contrôles ✗ ; causes et corrections : node_modules/@vak/agent/docs/FAQ.md, section 19) [code 1])
- 1 sabotage(s) : restes

**Notes** (3) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)
- reçu de preuve absent du commit final (supabase/functions/vak/vak-proof.json)

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 1 | 1 s |
| `vak localdb` | 0 | 1 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_40f6a7'` | 1 | 15 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 1 | 2 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (3) :
- ✗ VAK003 fichiers gérés modifiés ou pas à jour (supabase/functions/vak/schema.gen.ts : modifié à la main (contenu ≠ hash déclaré))
- ✗ VAK015 preuve à deux comptes jamais faite (reçu absent) : l'intégration n'est pas finie ; fonctions de l'app (add_expense(), month_summary(), update_expense(), upsert_category()) : preuve exigée
- ✗ VAK011 schema.gen.ts absent, illisible ou modifié à la main (base : sha256:43a53bcb0cce7a4db42f1fde3e393f6724943e667e186aeddab49eb53c551df8 ; schema.gen.ts : —)

**Lignes « ! », « ✗ » et « – » de prove** (5) :
- ✗ expenses non prouvé (graine impossible : 23503 insert or update on table "expenses" violates foreign key constraint "expenses_category_id_owner_id_fkey" ; totaux de read_data non comparés (verdict non prouvé))
- ✗ add_expense() non prouvé (appel par l'assistant de A refusé par l'app avec ses 1 entrée(s) d'essai (Données de l'app indisponibles pour le moment.) : la preuve ne se prononce pas ; « expenses » (citée par la fonction) : aucune ligne de B semée (23503 insert or update on table "expenses" violates foreign key constraint "expenses_category_id_owner_id_fkey") : non vérifiée ; fuite témoin (calcul sur tous les comptes, posée puis retirée) : vue)
- ✗ month_summary() non prouvé (« expenses » (citée par la fonction) : aucune ligne de B semée (23503 insert or update on table "expenses" violates foreign key constraint "expenses_category_id_owner_id_fkey") : non vérifiée ; appel par l'assistant de A : aucune donnée de B ; résultat de A inchangé quand les 8 ligne(s) de B sont retirées, puis quand un second compte copie B (1 table(s)) aux valeurs plus grandes, puis plus petites ; argument « month » (non vérifié par le kit) : 2 valeur(s) visant B essayée(s), rien de B atteint ; fuite témoin (calcul sur tous les comptes, posée puis retirée) : vue)
- ✗ update_expense() non prouvé (appel impossible : ligne de A non semée dans « expenses » ; fuite témoin (calcul sur tous les comptes, posée puis retirée) : vue)
- ✗ upsert_category() non prouvé (appel par l'assistant de A refusé par l'app avec ses 1 entrée(s) d'essai (Champ obligatoire manquant : « name ».) : la preuve ne se prononce pas ; fuite témoin (calcul sur tous les comptes, posée puis retirée) : vue)

## Preuve (vak-proof.json)

- reçu commité : absent
- preuve du contrôleur : non prouvé (vak 0.24.3) : categories éprouvé, expenses non prouvé ; fonctions : add_expense non prouvé, month_summary non prouvé, update_expense non prouvé, upsert_category non prouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 16 s) | 0 (0 err., 15 s) | pas pire |
| typecheck | 0 (0 err., 2 s) | 0 (0 err., 2 s) | pas pire |
| lint | 0 (0 err., 4 s) | 0 (0 err., 3 s) | pas pire |
| tests | absent | absent | absent |
| build | 0 (0 err., 3 s) | 0 (0 err., 13 s) | pas pire |

## Dépendances

Aucune entrée retirée ni changée (package-lock.json : +0).

## Fichiers changés depuis le commit de l'app

**Intégration** (32) :
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
- M package-lock.json
- M package.json
- A src/app/(tabs)/assistant.tsx
- A src/lib/vak.ts
- A supabase/.gitignore
- A supabase/config.toml
- A supabase/functions/vak/agent.ts
- A supabase/functions/vak/deno.json
- A supabase/functions/vak/index.ts
- A supabase/functions/vak/schema.gen.ts
- A supabase/functions/vak/tsconfig.json
- A supabase/functions/vak/vak-server.mjs
- A supabase/functions/vak/vak.lock.json
- A supabase/migrations/20261006123150_vak_0001_core.sql
- A supabase/migrations/20261006123151_vak_0002_feedback.sql
- A supabase/migrations/20261006123152_vak_0003_history.sql
- A supabase/migrations/20261006123153_vak_0004_quota_erase.sql
- A vendor/vak/vak-agent-0.24.3.tgz

**À relire (diff : autres.diff)** (3) :
- M src/app/(tabs)/_layout.tsx
- A src/app/(tabs)/reglages.tsx (branchement : cite vak)
- M tsconfig.json

## Sabotages

- restes : restes non commités dans /work/fonctions_1/app : ?? supabase/functions/vak/vak-proof.json

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 5f86006), autres.diff.
