# Essai supabase_nextjs_template_2 : échec

- App : https://github.com/Razikus/supabase-nextjs-template @ d519bf1 ; préparée 713c809 ; HEAD fb36988 (essai), 1 commit(s) de l'essai (2026-10-11T02:50:38+00:00 → 2026-10-11T02:50:38+00:00)
- Archive : vak-agent-0.27.0.tgz (sha256 8e695dc7571b) ; vak installé dans le clone propre : 0.27.0
- Contrôle : 2026-10-11T02:51:12.948Z → 2026-10-11T02:51:30.611Z (18 s), clone propre /work/supabase_nextjs_template_2/apres

**Raisons de l'échec** (3) :
- vak prove → 1 (preuve à deux comptes : non prouvé (0 éprouvée(s), 0 en échec, 1 non prouvée(s) ; 0 totaux de read_data comparés) ; reçu écrit dans supabase/functions/vak/vak-proof.json ; base laissée intacte [code 1])
- vak doctor --db → 1 (doctor : à corriger (contrôles ✗ ; causes et corrections : node_modules/@vak/agent/docs/FAQ.md, section 19) [code 1])
- 1 sabotage(s) : restes

**Notes** (5) :
- verrou ajouté par l'essai : package-lock.json (un autre gestionnaire ?)
- package.json : dépendance(s) ajoutée(s) autre(s) que @vak/agent : devDependencies/typescript "~5.9.2"
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)
- reçu de preuve absent du commit final (supabase/functions/vak/vak-proof.json)

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 0 s |
| `vak localdb` | 0 | 1 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_ec5f94'` | 1 | 13 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 1 | 1 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (1) :
- ✗ VAK015 preuve à deux comptes jamais faite (reçu absent) : l'intégration n'est pas finie

**Lignes « ! », « ✗ » et « – » de prove** (1) :
- ✗ todo_list non prouvé (vérification impossible : Donnée indisponible (schéma modifié ?).)

## Preuve (vak-proof.json)

- reçu commité : absent
- preuve du contrôleur : non prouvé (vak 0.27.0) : todo_list non prouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | absent | 0 (0 err., 1 s) | nouveau |
| typecheck | absent | absent | absent |
| lint | absent | absent | absent |
| tests | absent | absent | absent |
| build | absent | absent | absent |

## Dépendances

Aucune entrée retirée ni changée (nextjs/yarn.lock : +0 ; package-lock.json : +0 ; supabase-expo-template/yarn.lock : +23).

## Fichiers changés depuis le commit de l'app

**Intégration** (34) :
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
- A package-lock.json
- A package.json
- A supabase-expo-template/app/(app)/assistant.tsx
- A supabase-expo-template/lib/vak.ts
- M supabase-expo-template/package.json
- M supabase-expo-template/yarn.lock
- M supabase/.gitignore
- M supabase/config.toml
- A supabase/functions/vak/agent.ts
- A supabase/functions/vak/deno.json
- A supabase/functions/vak/index.ts
- A supabase/functions/vak/schema.gen.ts
- A supabase/functions/vak/tsconfig.json
- A supabase/functions/vak/vak-server.mjs
- A supabase/functions/vak/vak.lock.json
- A supabase/migrations/20261011024833_vak_0001_core.sql
- A supabase/migrations/20261011024834_vak_0002_feedback.sql
- A supabase/migrations/20261011024835_vak_0003_history.sql
- A supabase/migrations/20261011024836_vak_0004_quota_erase.sql
- A vendor/vak/vak-agent-0.27.0.tgz

**À relire (diff : autres.diff)** (2) :
- M supabase-expo-template/app/(app)/_layout.tsx
- M supabase-expo-template/app/(app)/settings.tsx (branchement : cite vak)

## Sabotages

- restes : restes non commités dans /work/supabase_nextjs_template_2/app : ?? node_modules/.bin/tsc ; ?? node_modules/.bin/tsserver ; ?? node_modules/.bin/vak ; ?? node_modules/.cache/vak/localdb.json ; ?? node_modules/.package-lock.json ; ?? node_modules/@vak/agent/README.md ; ?? node_modules/@vak/agent/agents/AGENTS-block.md ; ?? node_modules/@vak/agent/agents/skill/SKILL.md ; ?? node_modules/@vak/agent/agents/skill/references/calibration.md ; ?? node_modules/@vak/agent/agents/skill/references/features.md ; ?? node_modules/@vak/agent/agents/skill/references/guardrails.md ; ?? node_modules/@vak/agent/agents/skill/references/local-first.md ; ?? node_modules/@vak/agent/agents/skill/references/ui.md ; ?? node_modules/@vak/agent/bin/vak.mjs ; ?? node_modules/@vak/agent/dist/chunks/chunk-3P2T5GOG.js ; ?? node_modules/@vak/agent/dist/chunks/chunk-DOAA23XE.js ; ?? node_modules/@vak/agent/dist/chunks/chunk-G2TYYHLU.js ; ?? node_modules/@vak/agent/dist/chunks/chunk-SUIVRAVY.js ; ?? node_modules/@vak/agent/dist/chunks/chunk-SV6XSQTZ.js ; ?? node_modules/@vak/agent/dist/chunks/chunk-WZNHYK5K.js … et 1376

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 713c809), autres.diff.
