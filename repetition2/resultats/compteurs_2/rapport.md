# Essai compteurs_2 : échec

- App : /home/user/ai-chatbot/vak-examen/apps/compteurs.bundle @ 5c12ec9 ; préparée 61e9000 ; HEAD 83228e0 (essai), 1 commit(s) de l'essai (2026-10-10T19:25:33+00:00 → 2026-10-10T19:25:33+00:00)
- Archive : vak-agent-0.26.1.tgz (sha256 e0516efc36a3) ; vak installé dans le clone propre : 0.26.1
- Contrôle : 2026-10-10T19:26:10.630Z → 2026-10-10T19:26:52.518Z (42 s), clone propre /work/compteurs_2/apres

**Raisons de l'échec** (2) :
- vak prove → 1 (preuve à deux comptes : non prouvé (4 éprouvée(s), 0 en échec, 2 non prouvée(s), fonctions comprises (4) ; 84 totaux de read_data comparés) ; reçu inchangé dans supabase/functions/vak/vak-proof.json ; base laissée intacte [code 1])
- vak doctor --db → 1 (doctor : à corriger (contrôles ✗ ; causes et corrections : node_modules/@vak/agent/docs/FAQ.md, section 19) [code 1])

**Notes** (2) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 1 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_498c11'` | 1 | 14 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 1 | 4 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (1) :
- ✗ VAK015 preuve à deux comptes du 2026-10-10 : non prouvé (add_reading() : non prouvé ; upsert_meter() : non prouvé)

**Lignes « ! », « ✗ » et « – » de prove** (2) :
- ✗ add_reading() non prouvé (appel par l'assistant de A refusé par l'app avec ses 2 entrée(s) d'essai (Valeur invalide.) : la preuve ne se prononce pas ; argument « payload.meter_id » (non vérifié par le kit) : 3 valeur(s) visant B essayée(s), rien de B atteint ; argument « payload.read_on » (non vérifié par le kit) : 3 valeur(s) visant B essayée(s), rien de B atteint ; argument « payload.value » (non vérifié par le kit) : 3 valeur(s) visant B essayée(s), rien de B atteint ; fuite témoin (calcul sur tous les comptes, posée puis retirée) : vue)
- ✗ upsert_meter() non prouvé (appel par l'assistant de A refusé par l'app avec ses 3 entrée(s) d'essai (Valeur refusée par la contrainte « meters_type_check » de l'app.) : la preuve ne se prononce pas ; argument « payload.id » (non vérifié par le kit) : 3 valeur(s) visant B essayée(s), rien de B atteint ; argument « payload.name » (non vérifié par le kit) : 3 valeur(s) visant B essayée(s), rien de B atteint ; argument « payload.type » (non vérifié par le kit) : 3 valeur(s) visant B essayée(s), rien de B atteint ; argument « payload.unit » (non vérifié par le kit) : 3 valeur(s) visant B essayée(s), rien de B atteint ; fuite témoin (calcul sur tous les comptes, posée puis retirée) : vue)

## Preuve (vak-proof.json)

- reçu commité : non prouvé (vak 0.26.1) : meters éprouvé, readings éprouvé ; fonctions : add_reading non prouvé, month_consumption éprouvé, update_reading éprouvé, upsert_meter non prouvé
- preuve du contrôleur : non prouvé (vak 0.26.1) : meters éprouvé, readings éprouvé ; fonctions : add_reading non prouvé, month_consumption éprouvé, update_reading éprouvé, upsert_meter non prouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 13 s) | 0 (0 err., 13 s) | pas pire |
| typecheck | 0 (0 err., 2 s) | 0 (0 err., 2 s) | pas pire |
| lint | 0 (0 err., 4 s) | 0 (0 err., 4 s) | pas pire |
| tests | absent | absent | absent |
| build | 0 (0 err., 3 s) | 0 (0 err., 4 s) | pas pire |

## Dépendances

Aucune entrée retirée ni changée (package-lock.json : +0).

## Fichiers changés depuis le commit de l'app

**Intégration** (33) :
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
- A src/app/assistant.tsx
- A src/lib/vak.ts
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
- A supabase/migrations/20261010192203_vak_0001_core.sql
- A supabase/migrations/20261010192204_vak_0002_feedback.sql
- A supabase/migrations/20261010192205_vak_0003_history.sql
- A supabase/migrations/20261010192206_vak_0004_quota_erase.sql
- A vendor/vak/vak-agent-0.26.1.tgz

**À relire (diff : autres.diff)** (6) :
- M src/app/(app)/index.tsx
- M src/app/(app)/reading/edit.tsx
- M src/app/_layout.tsx
- A src/app/reglages.tsx (branchement : cite vak)
- A src/components/assistant-button.tsx
- M tsconfig.json

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 61e9000), autres.diff.
