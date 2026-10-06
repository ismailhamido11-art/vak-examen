# Essai company_invoicing_2 : réussi

- App : https://github.com/xtshepana/company-invoicing @ e999749 ; préparée e149185 ; HEAD a4fc83b (essai), 1 commit(s) de l'essai (2026-10-06T14:28:03+00:00 → 2026-10-06T14:28:03+00:00)
- Archive : vak-agent-0.24.3.tgz (sha256 2765b6929c14) ; vak installé dans le clone propre : 0.24.3
- Contrôle : 2026-10-06T14:29:04.298Z → 2026-10-06T14:31:19.671Z (135 s), clone propre /work/company_invoicing_2/apres

**Notes** (5) :
- vérification build : échec avant et après sans ligne fichier:ligne : fins des journaux différentes, à comparer
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)
- table(s) « à moi » écartée(s) par l'agent (ignore), sans échec de preuve au journal : choix de périmètre, à dire à l'humain : audit_logs, expenses, invoice_items, invoice_reminders_sent, payment_allocations, payment_checkpoints_sent, products, profiles, quote_items, recurring_invoice_items, recurring_invoices, suppliers, customer_credits, credit_note_items, audit_logs, expenses, invoice_items, invoice_reminders_sent, payment_allocations, payment_checkpoints_sent, products, profiles, quote_items, recurring_invoice_items, recurring_invoices, suppliers, customer_credits, credit_note_items
- « rls » (l'app montre à un utilisateur des lignes d'un autre ; à signaler à l'humain) : bank_import_batches, bank_transactions, credit_notes, customers, invoices, payments, quotes

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 3 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_6c1608'` | 0 | 15 s |
| `vak localdb --drop` | 0 | 1 s |
| `vak prove` | 0 | 6 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (3) :
- ! VAK013 chaque table de l'app est calibrée ou ignorée (7 dans tables ; ignore : 18 tables, 28 fonctions) ; dans ignore, tables de l'utilisateur : « audit_logs », « expenses », « invoice_items », « invoice_reminders_sent », « payment_allocations », « payment_checkpoints_sent », « products », « profiles », « quote_items », « recurring_invoice_items », « recurring_invoices », « suppliers », « customer_credits », « credit_note_items » (« audit_logs » : calibre-la, owner ; « expenses » : calibre-la, owner ; « invoice_items » : calibre-la, through: "invoice_id" ; « invoice_reminders_sent » : calibre-la, through: "invoice_id" ; « payment_allocations » : calibre-la, owner ; « payment_checkpoints_sent » : calibre-la, through: "invoice_id" ; « products » : calibre-la, owner ; « profiles » : calibre-la, owner ; « quote_items » : calibre-la, through: "quote_id" ; « recurring_invoice_items » : calibre-la, through: "recurring_invoice_id" ; « recurring_invoices » : calibre-la, owner ; « suppliers » : calibre-la, owner ; « customer_credits » : calibre-la, owner ; « credit_note_items » : calibre-la, through: "credit_note_id")
- ! VAK015 assistant éprouvé du 2026-10-06 ; mais l'app elle-même montre à un utilisateur des lignes d'un autre (bank_import_batches, bank_transactions, credit_notes, customers, invoices, payments, quotes)
- ! VAK107 avis de sécurité (avertissement) (fonction « next_customer_account_number » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; customers : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; invoices : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; quotes : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; payments : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; credit_notes : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; bank_import_batches : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; bank_transactions : politique ouverte à anon : à vérifier (aucune ligne lue sans compte))

**Lignes « ! », « ✗ » et « – » de prove** (7) :
- ! bank_import_batches rls (l'app montre à A 8 ligne(s) de B (partage, publication) ; l'assistant ne les montre pas (owner « imported_by ») ; la RLS de l'app laisse A lire la ligne de B (fuite de l'app, assistant ou non) ; lecture par l'assistant : jamais la ligne de B ; lecture par l'assistant : la ligne de A ; ligne de C : l'app la montre à A comme celle de B (lignes ouvertes à tous), non comparée ; lecture de la ligne de B par son identifiant : refusée ; totaux de read_data : 107 ligne(s) de A ajoutée(s) aux bornes des périodes ; 39 appels idéaux, chaque total égal au comptage de l'app sous la RLS de A ; total inconnu, permis, pour 1 : search « filename 0 a »)
- ! bank_transactions rls (la RLS de l'app laisse A lire la ligne de B (fuite de l'app, assistant ou non) ; coéquipier de A non semé (ligne en conflit avec une contrainte d'unicité de l'app, et aucune ligne existante de cet utilisateur) : le partage entre membres n'est pas vérifié ; lecture par l'assistant : jamais la ligne de B ; lecture par l'assistant : la ligne de A ; lecture de la ligne de B par son identifiant : refusée ; totaux de read_data non comparés (verdict rls))
- ! credit_notes rls (l'app montre à A 8 ligne(s) de B (partage, publication) ; l'assistant ne les montre pas (owner « created_by ») ; la RLS de l'app laisse A lire la ligne de B (fuite de l'app, assistant ou non) ; lecture par l'assistant : jamais la ligne de B ; lecture par l'assistant : la ligne de A ; ligne de C : l'app la montre à A comme celle de B (lignes ouvertes à tous), non comparée ; lecture de la ligne de B par son identifiant : refusée ; totaux de read_data : 52 ligne(s) de A ajoutée(s) aux bornes des périodes ; 47 appels idéaux, chaque total égal au comptage de l'app sous la RLS de A ; total inconnu, permis, pour 1 : search « credit_note_number 0 a »)
- ! customers rls (l'app montre à A 8 ligne(s) de B (partage, publication) ; l'assistant ne les montre pas (owner « created_by ») ; la RLS de l'app laisse A lire la ligne de B (fuite de l'app, assistant ou non) ; lecture par l'assistant : jamais la ligne de B ; lecture par l'assistant : la ligne de A ; ligne de C : l'app la montre à A comme celle de B (lignes ouvertes à tous), non comparée ; lecture de la ligne de B par son identifiant : refusée ; totaux de read_data : 107 ligne(s) de A ajoutée(s) aux bornes des périodes ; 46 appels idéaux, chaque total égal au comptage de l'app sous la RLS de A ; total inconnu, permis, pour 1 : search « company_name 0 a »)
- ! invoices rls (l'app montre à A 8 ligne(s) de B (partage, publication) ; l'assistant ne les montre pas (owner « created_by ») ; la RLS de l'app laisse A lire la ligne de B (fuite de l'app, assistant ou non) ; lecture par l'assistant : jamais la ligne de B ; lecture par l'assistant : la ligne de A ; ligne de C : l'app la montre à A comme celle de B (lignes ouvertes à tous), non comparée ; lecture de la ligne de B par son identifiant : refusée ; totaux de read_data : 52 ligne(s) de A ajoutée(s) aux bornes des périodes ; 56 appels idéaux, chaque total égal au comptage de l'app sous la RLS de A ; total inconnu, permis, pour 1 : search « invoice_number 0 a »)
- ! payments rls (l'app montre à A 8 ligne(s) de B (partage, publication) ; l'assistant ne les montre pas (owner « created_by ») ; la RLS de l'app laisse A lire la ligne de B (fuite de l'app, assistant ou non) ; lecture par l'assistant : jamais la ligne de B ; lecture par l'assistant : la ligne de A ; ligne de C : l'app la montre à A comme celle de B (lignes ouvertes à tous), non comparée ; lecture de la ligne de B par son identifiant : refusée ; totaux de read_data : 52 ligne(s) de A ajoutée(s) aux bornes des périodes ; 62 appels idéaux, chaque total égal au comptage de l'app sous la RLS de A)
- ! quotes rls (l'app montre à A 8 ligne(s) de B (partage, publication) ; l'assistant ne les montre pas (owner « created_by ») ; la RLS de l'app laisse A lire la ligne de B (fuite de l'app, assistant ou non) ; lecture par l'assistant : jamais la ligne de B ; lecture par l'assistant : la ligne de A ; ligne de C : l'app la montre à A comme celle de B (lignes ouvertes à tous), non comparée ; lecture de la ligne de B par son identifiant : refusée ; totaux de read_data : 52 ligne(s) de A ajoutée(s) aux bornes des périodes ; 56 appels idéaux, chaque total égal au comptage de l'app sous la RLS de A ; total inconnu, permis, pour 1 : search « quote_number 0 a »)

## Preuve (vak-proof.json)

- reçu commité : éprouvé (vak 0.24.3) : bank_import_batches rls, bank_transactions rls, credit_notes rls, customers rls, invoices rls, payments rls, quotes rls ; fonctions : get_aging_report éprouvé
- preuve du contrôleur : éprouvé (vak 0.24.3) : bank_import_batches rls, bank_transactions rls, credit_notes rls, customers rls, invoices rls, payments rls, quotes rls ; fonctions : get_aging_report éprouvé

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 17 s) | 0 (0 err., 21 s) | pas pire |
| typecheck | 0 (0 err., 11 s) | 0 (0 err., 11 s) | pas pire |
| lint | 0 (0 err., 12 s) | 0 (0 err., 17 s) | pas pire |
| tests | 0 (0 err., 2 s) | 0 (0 err., 2 s) | pas pire |
| build | 1 (0 err., 54 s) | 1 (0 err., 58 s) | pas pire : échec avant et après sans ligne fichier:ligne : fins des journaux différentes, à comparer |

## Dépendances

Aucune entrée retirée ni changée (package-lock.json : +0).

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
- M AGENTS.md
- A app/(app)/assistant/assistant.tsx
- A app/(app)/assistant/page.tsx
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
- A supabase/migrations/20261006142241_vak_0001_core.sql
- A supabase/migrations/20261006142242_vak_0002_feedback.sql
- A supabase/migrations/20261006142243_vak_0003_history.sql
- A supabase/migrations/20261006142244_vak_0004_quota_erase.sql
- M tsconfig.json
- A vendor/vak/vak-agent-0.24.3.tgz

**À relire (diff : autres.diff)** (6) :
- M app/(app)/layout.tsx
- A app/(app)/settings/agent-settings.tsx (branchement : cite vak)
- M app/(app)/settings/page.tsx
- M app/layout.tsx (branchement : cite vak)
- A components/layout/floating-assistant.tsx (branchement : cite vak)
- M components/layout/nav-items.ts

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis e149185), autres.diff.
