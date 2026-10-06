# Essai demarre_1 : échec

- App : /home/user/ai-chatbot/vak-examen/apps/demarre.bundle @ 891485f ; préparée a3082ce ; HEAD e6799be (essai), 1 commit(s) de l'essai (2026-10-06T12:17:48+00:00 → 2026-10-06T12:17:48+00:00)
- Archive : vak-agent-0.24.3.tgz (sha256 2765b6929c14) ; vak installé dans le clone propre : 0.24.3
- Contrôle : 2026-10-06T12:17:58.524Z → 2026-10-06T12:18:49.410Z (51 s), clone propre /work/demarre_1/apres

**Raisons de l'échec** (3) :
- vak prove → 1 (preuve à deux comptes : non prouvé (1 éprouvée(s), 0 en échec, 1 non prouvée(s) ; 47 totaux de read_data comparés) ; reçu écrit dans supabase/functions/vak/vak-proof.json ; base laissée intacte [code 1])
- vak doctor --db → 1 (doctor : à corriger (contrôles ✗ ; causes et corrections : node_modules/@vak/agent/docs/FAQ.md, section 19) [code 1])
- 1 sabotage(s) : restes

**Notes** (3) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)
- reçu de preuve absent du commit final (supabase/functions/vak/vak-proof.json)

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 1 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_c97acf'` | 1 | 14 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 1 | 1 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (3) :
- ✗ VAK003 fichiers gérés modifiés ou pas à jour (supabase/functions/vak/schema.gen.ts : modifié à la main (contenu ≠ hash déclaré))
- ✗ VAK015 preuve à deux comptes jamais faite (reçu absent) : l'intégration n'est pas finie
- ✗ VAK011 schema.gen.ts absent, illisible ou modifié à la main (base : sha256:1c17add2f567fdb3e0baa716543a017a2ca18723cc6cbb6b3cec2f884f599ec6 ; schema.gen.ts : —)

**Lignes « ! », « ✗ » et « – » de prove** (1) :
- ✗ reading_sessions non prouvé (graine impossible : 23503 insert or update on table "reading_sessions" violates foreign key constraint "reading_sessions_book_fk" ; totaux de read_data non comparés (verdict non prouvé))

## Preuve (vak-proof.json)

- reçu commité : absent
- preuve du contrôleur : non prouvé (vak 0.24.3) : books éprouvé, reading_sessions non prouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 14 s) | 0 (0 err., 15 s) | pas pire |
| typecheck | 0 (0 err., 2 s) | 0 (0 err., 2 s) | pas pire |
| lint | 0 (0 err., 3 s) | 0 (0 err., 3 s) | pas pire |
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
- A src/app/assistant.tsx
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
- A supabase/migrations/20261006121233_vak_0001_core.sql
- A supabase/migrations/20261006121234_vak_0002_feedback.sql
- A supabase/migrations/20261006121235_vak_0003_history.sql
- A supabase/migrations/20261006121236_vak_0004_quota_erase.sql
- A vendor/vak/vak-agent-0.24.3.tgz

**À relire (diff : autres.diff)** (4) :
- M src/app/_layout.tsx (branchement : cite vak)
- M src/app/index.tsx
- A src/app/reglages.tsx (branchement : cite vak)
- M tsconfig.json

## Sabotages

- restes : restes non commités dans /work/demarre_1/app : ?? supabase/functions/vak/vak-proof.json

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis a3082ce), autres.diff.
