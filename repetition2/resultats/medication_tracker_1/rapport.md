# Essai medication_tracker_1 : réussi

- App : https://github.com/PanagiotisKaraliolios/medication-tracker @ cfad841 ; préparée bafe9c8 ; HEAD e5f16c7 (essai), 1 commit(s) de l'essai (2026-10-22T17:29:01+00:00 → 2026-10-22T17:29:01+00:00)
- Archive : vak-agent-0.29.2.tgz (sha256 29a2856be79e) ; vak installé dans le clone propre : 0.29.2
- Contrôle : 2026-10-22T17:30:14.724Z → 2026-10-22T17:31:17.932Z (63 s), clone propre /work/medication_tracker_1/apres

**Notes** (4) :
- vérification build : échec avant et après sans ligne fichier:ligne : fins des journaux différentes, à comparer
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)
- table(s) « à moi » écartée(s) par l'agent (ignore), sans échec de preuve au journal : choix de périmètre, à dire à l'humain : adherence_logs, inventory, profiles, adherence_logs, inventory, profiles

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 1 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_80e276'` | 0 | 17 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 0 | 3 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (2) :
- ! VAK009 variable publique à vérifier : clé ou jeton inclus dans l'app (app/privacy-security.tsx:148 : EXPO_PUBLIC_SUPABASE_KEY ; app/set-password.tsx:66 : EXPO_PUBLIC_SUPABASE_KEY ; lib/supabase.ts:6 : EXPO_PUBLIC_SUPABASE_KEY)
- ! VAK013 chaque table de l'app est calibrée ou ignorée (4 dans tables ; ignore : 3 tables, 0 fonctions) ; dans ignore, tables de l'utilisateur : « adherence_logs », « inventory », « profiles » (« adherence_logs » : calibre-la, owner ; « inventory » : calibre-la, owner ; « profiles » : calibre-la, owner)

## Preuve (vak-proof.json)

- reçu commité : éprouvé (vak 0.29.2) : dose_logs éprouvé, medications éprouvé, schedules éprouvé, symptoms éprouvé
- preuve du contrôleur : éprouvé (vak 0.29.2) : dose_logs éprouvé, medications éprouvé, schedules éprouvé, symptoms éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 11 s) | 0 (0 err., 1 s) | pas pire |
| typecheck | 0 (0 err., 9 s) | 0 (0 err., 7 s) | pas pire |
| lint | 0 (0 err., 0 s) | 0 (0 err., 0 s) | pas pire |
| tests | 0 (0 err., 18 s) | 0 (0 err., 14 s) | pas pire |
| build | 1 (0 err., 31 s) | 1 (0 err., 17 s) | pas pire : échec avant et après sans ligne fichier:ligne : fins des journaux différentes, à comparer |

## Dépendances

Aucune entrée retirée ni changée (bun.lock : +0).

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
- A app/(tabs)/assistant.tsx
- M bun.lock
- A lib/vak.ts
- M package.json
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
- A supabase/migrations/20261022172312_vak_0001_core.sql
- A supabase/migrations/20261022172313_vak_0002_feedback.sql
- A supabase/migrations/20261022172314_vak_0003_history.sql
- A supabase/migrations/20261022172315_vak_0004_quota_erase.sql
- M tsconfig.json
- A vendor/vak/vak-agent-0.29.2.tgz

**À relire (diff : autres.diff)** (3) :
- M app/(tabs)/_layout.tsx
- M app/(tabs)/profile.tsx (branchement : cite vak)
- M biome.json (branchement : cite vak)

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis bafe9c8), autres.diff.
