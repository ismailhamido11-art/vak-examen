# Essai revisions_2 : réussi

- App : /home/user/ai-chatbot/vak-examen/apps/revisions.bundle @ fd44d33 ; préparée 7514e45 ; HEAD 841ef3d (essai), 1 commit(s) de l'essai (2026-10-22T18:02:53+00:00 → 2026-10-22T18:02:53+00:00)
- Archive : vak-agent-0.29.2.tgz (sha256 29a2856be79e) ; vak installé dans le clone propre : 0.29.2
- Contrôle : 2026-10-22T18:04:01.554Z → 2026-10-22T18:04:58.112Z (57 s), clone propre /work/revisions_2/apres

**Notes** (2) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 1 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_86c867'` | 0 | 18 s |
| `vak localdb --drop` | 0 | 1 s |
| `vak prove` | 0 | 8 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (1) :
- ! VAK006 supabase/functions/vak/agent.ts se charge, avec des avertissements (tables.reviews.columns.card_id : nom sensible exposé à l'assistant, vérifiez que c'est voulu)

## Preuve (vak-proof.json)

- reçu commité : éprouvé (vak 0.29.2) : cards éprouvé, decks éprouvé, reviews éprouvé ; fonctions : add_card éprouvé, cards_due éprouvé, create_deck éprouvé, edit_card éprouvé, review_card éprouvé
- preuve du contrôleur : éprouvé (vak 0.29.2) : cards éprouvé, decks éprouvé, reviews éprouvé ; fonctions : add_card éprouvé, cards_due éprouvé, create_deck éprouvé, edit_card éprouvé, review_card éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 19 s) | 0 (0 err., 18 s) | pas pire |
| typecheck | 0 (0 err., 3 s) | 0 (0 err., 3 s) | pas pire |
| lint | 0 (0 err., 4 s) | 0 (0 err., 4 s) | pas pire |
| tests | absent | absent | absent |
| build | 0 (0 err., 4 s) | 0 (0 err., 4 s) | pas pire |

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
- A supabase/migrations/20261022175921_vak_0001_core.sql
- A supabase/migrations/20261022175922_vak_0002_feedback.sql
- A supabase/migrations/20261022175923_vak_0003_history.sql
- A supabase/migrations/20261022175924_vak_0004_quota_erase.sql
- A vendor/vak/vak-agent-0.29.2.tgz

**À relire (diff : autres.diff)** (4) :
- M src/app/_layout.tsx (branchement : cite vak)
- M src/app/index.tsx
- A src/app/reglages.tsx (branchement : cite vak)
- M tsconfig.json

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 7514e45), autres.diff.
