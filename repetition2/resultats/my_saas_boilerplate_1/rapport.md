# Essai my_saas_boilerplate_1 : réussi

- App : https://github.com/bluebridgetechnology/my-saas-boilerplate @ bcb2049 ; préparée 7a664aa ; HEAD 59acf23 (essai), 1 commit(s) de l'essai (2026-10-10T18:41:17+00:00 → 2026-10-10T18:41:17+00:00)
- Archive : vak-agent-0.26.1.tgz (sha256 e0516efc36a3) ; vak installé dans le clone propre : 0.26.1
- Contrôle : 2026-10-10T18:42:17.852Z → 2026-10-10T18:44:21.612Z (124 s), clone propre /work/my_saas_boilerplate_1/apres

**Notes** (3) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)
- table(s) « à moi » écartée(s) par l'agent (ignore), sans échec de preuve au journal : choix de périmètre, à dire à l'humain : api_keys, payment_history, projects, social_presets, support_tickets, usage_tracking, watermark_templates, api_keys, payment_history, projects, social_presets, support_tickets, usage_tracking, watermark_templates

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 1 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_8461a8'` | 0 | 16 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 0 | 2 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (3) :
- ! VAK006 supabase/functions/vak/agent.ts se charge, avec des avertissements (tables.users : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; rien à déclarer : la RLS de l'app décide ; tables.activity_logs : ni propriétaire ni through : lue sous la seule RLS de l'app (le moteur ne vérifie pas ses lignes ; vak prove vérifie cette RLS) ; rien à déclarer : la RLS de l'app décide)
- ! VAK013 chaque table de l'app est calibrée ou ignorée (2 dans tables ; ignore : 12 tables, 5 fonctions) ; dans ignore, tables de l'utilisateur : « api_keys », « payment_history », « projects », « social_presets », « support_tickets », « usage_tracking », « watermark_templates » (« api_keys » : calibre-la, through: "user_id" ; « payment_history » : calibre-la, through: "user_id" ; « projects » : calibre-la, through: "user_id" ; « social_presets » : calibre-la, through: "user_id" ; « support_tickets » : calibre-la, through: "user_id" ; « usage_tracking » : calibre-la, through: "user_id" ; « watermark_templates » : calibre-la, through: "user_id")
- ! VAK108 colonnes qui décident des droits (avertissement) (users.is_admin : modifiable par l'utilisateur et lue par la politique « Admins can manage ad banners » : elle décide qui voit la ligne ; activity_logs.user_id : modifiable par l'utilisateur et lue par la politique « Users can view own activity logs » : elle décide qui voit la ligne)

## Preuve (vak-proof.json)

- reçu commité : éprouvé (vak 0.26.1) : activity_logs éprouvé, users éprouvé
- preuve du contrôleur : éprouvé (vak 0.26.1) : activity_logs éprouvé, users éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 21 s) | 0 (0 err., 15 s) | pas pire |
| typecheck | 0 (0 err., 14 s) | 0 (0 err., 15 s) | pas pire |
| lint | 1 (0 err., 1 s) | 1 (0 err., 1 s) | pas pire |
| tests | absent | absent | absent |
| build | 1 (0 err., 69 s) | 1 (0 err., 71 s) | pas pire |

## Dépendances

Aucune entrée retirée ni changée (package-lock.json : +0).

## Fichiers changés depuis le commit de l'app

**Intégration** (35) :
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
- A app/(dashboard)/assistant/assistant.tsx
- A app/(dashboard)/assistant/page.tsx
- A lib/vak.ts
- M package-lock.json
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
- A supabase/migrations/20261010183335_vak_0001_core.sql
- A supabase/migrations/20261010183336_vak_0002_feedback.sql
- A supabase/migrations/20261010183337_vak_0003_history.sql
- A supabase/migrations/20261010183338_vak_0004_quota_erase.sql
- M tsconfig.json
- A vendor/vak/vak-agent-0.26.1.tgz

**À relire (diff : autres.diff)** (5) :
- A app/(dashboard)/admin/settings/agent-settings.tsx (branchement : cite vak)
- M app/(dashboard)/admin/settings/page.tsx
- M app/(dashboard)/layout.tsx
- M app/layout.tsx (branchement : cite vak)
- A components/layout/vak-button.tsx (branchement : cite vak)

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis 7a664aa), autres.diff.
