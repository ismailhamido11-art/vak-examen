# Essai company_invoicing_1 : réussi

- App : https://github.com/xtshepana/company-invoicing @ e999749 ; préparée e149185 ; HEAD 75243c4 (essai), 1 commit(s) de l'essai (2026-10-06T13:13:31+00:00 → 2026-10-06T13:13:31+00:00)
- Archive : vak-agent-0.24.3.tgz (sha256 2765b6929c14) ; vak installé dans le clone propre : 0.24.3
- Contrôle : 2026-10-06T13:14:31.205Z → 2026-10-06T13:16:42.830Z (132 s), clone propre /work/company_invoicing_1/apres

**Notes** (4) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)
- table(s) « à moi » écartée(s) par l'agent (ignore), sans échec de preuve au journal : choix de périmètre, à dire à l'humain : audit_logs, bank_import_batches, credit_note_items, customer_credits, expenses, invoice_items, invoice_reminders_sent, payment_allocations, payment_checkpoints_sent, products, profiles, quote_items, recurring_invoice_items, recurring_invoices, suppliers, audit_logs, bank_import_batches, credit_note_items, customer_credits, expenses, invoice_items, invoice_reminders_sent, payment_allocations, payment_checkpoints_sent, products, profiles, quote_items, recurring_invoice_items, recurring_invoices, suppliers
- « rls » (l'app montre à un utilisateur des lignes d'un autre ; à signaler à l'humain) : bank_transactions, credit_notes, customers, invoices, payments, quotes

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|
| `vak test` | 0 | 1 s |
| `vak localdb` | 0 | 3 s |
| `vak doctor --db --db-url 'postgresql://root@127.0.0.1:5432/vak_local_7bf74a'` | 0 | 15 s |
| `vak localdb --drop` | 0 | 0 s |
| `vak prove` | 0 | 5 s |

**Lignes « ! », « ✗ » et « – » de doctor --db (reçu commité)** (3) :
- ! VAK013 chaque table de l'app est calibrée ou ignorée (6 dans tables ; ignore : 19 tables, 29 fonctions) ; dans ignore, tables de l'utilisateur : « audit_logs », « bank_import_batches », « credit_note_items », « customer_credits », « expenses », « invoice_items », « invoice_reminders_sent », « payment_allocations », « payment_checkpoints_sent », « products », « profiles », « quote_items », « recurring_invoice_items », « recurring_invoices », « suppliers » (« audit_logs » : calibre-la, owner ; « bank_import_batches » : calibre-la, owner ; « credit_note_items » : calibre-la, through: "credit_note_id" ; « customer_credits » : calibre-la, owner ; « expenses » : calibre-la, owner ; « invoice_items » : calibre-la, through: "invoice_id" ; « invoice_reminders_sent » : calibre-la, through: "invoice_id" ; « payment_allocations » : calibre-la, owner ; « payment_checkpoints_sent » : calibre-la, through: "invoice_id" ; « products » : calibre-la, owner ; « profiles » : calibre-la, owner ; « quote_items » : calibre-la, through: "quote_id" ; « recurring_invoice_items » : calibre-la, through: "recurring_invoice_id" ; « recurring_invoices » : calibre-la, owner ; « suppliers » : calibre-la, owner)
- ! VAK015 assistant éprouvé du 2026-10-06 ; mais l'app elle-même montre à un utilisateur des lignes d'un autre (bank_transactions, credit_notes, customers, invoices, payments, quotes)
- ! VAK107 avis de sécurité (avertissement) (fonction « next_customer_account_number » : security definer appelable sans compte (anon) : vérifie qu'elle refuse un auth.uid() nul ; customers : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; invoices : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; payments : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; bank_transactions : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; quotes : politique ouverte à anon : à vérifier (aucune ligne lue sans compte) ; credit_notes : politique ouverte à anon : à vérifier (aucune ligne lue sans compte))

**Lignes « ! », « ✗ » et « – » de prove** (6) :
- ! bank_transactions rls (l'app montre à A 1 ligne(s) de B (partage, publication) ; l'assistant ne les montre pas (owner « matched_by ») ; la RLS de l'app laisse A lire la ligne de B (fuite de l'app, assistant ou non) ; coéquipier de A non semé (ligne en conflit avec une contrainte d'unicité de l'app, et aucune ligne existante de cet utilisateur) : le partage entre membres n'est pas vérifié ; lecture par l'assistant : jamais la ligne de B ; lecture par l'assistant : la ligne de A ; lecture de la ligne de B par son identifiant : refusée ; totaux de read_data : 48 appels idéaux, chaque total égal au comptage de l'app sous la RLS de A)
- ! credit_notes rls (l'app montre à A 8 ligne(s) de B (partage, publication) ; l'assistant ne les montre pas (owner « created_by ») ; la RLS de l'app laisse A lire la ligne de B (fuite de l'app, assistant ou non) ; lecture par l'assistant : jamais la ligne de B ; lecture par l'assistant : la ligne de A ; ligne de C : l'app la montre à A comme celle de B (lignes ouvertes à tous), non comparée ; lecture de la ligne de B par son identifiant : refusée ; totaux de read_data : 52 ligne(s) de A ajoutée(s) aux bornes des périodes ; 47 appels idéaux, chaque total égal au comptage de l'app sous la RLS de A ; total inconnu, permis, pour 1 : search « credit_note_number 0 a »)
- ! customers rls (l'app montre à A 8 ligne(s) de B (partage, publication) ; l'assistant ne les montre pas (owner « created_by ») ; la RLS de l'app laisse A lire la ligne de B (fuite de l'app, assistant ou non) ; lecture par l'assistant : jamais la ligne de B ; lecture par l'assistant : la ligne de A ; ligne de C : l'app la montre à A comme celle de B (lignes ouvertes à tous), non comparée ; lecture de la ligne de B par son identifiant : refusée ; totaux de read_data : 107 ligne(s) de A ajoutée(s) aux bornes des périodes ; 46 appels idéaux, chaque total égal au comptage de l'app sous la RLS de A ; total inconnu, permis, pour 1 : search « company_name 0 a »)
- ! invoices rls (l'app montre à A 8 ligne(s) de B (partage, publication) ; l'assistant ne les montre pas (owner « created_by ») ; la RLS de l'app laisse A lire la ligne de B (fuite de l'app, assistant ou non) ; lecture par l'assistant : jamais la ligne de B ; lecture par l'assistant : la ligne de A ; ligne de C : l'app la montre à A comme celle de B (lignes ouvertes à tous), non comparée ; lecture de la ligne de B par son identifiant : refusée ; totaux de read_data : 52 ligne(s) de A ajoutée(s) aux bornes des périodes ; 56 appels idéaux, chaque total égal au comptage de l'app sous la RLS de A ; total inconnu, permis, pour 1 : search « invoice_number 0 a »)
- ! payments rls (l'app montre à A 8 ligne(s) de B (partage, publication) ; l'assistant ne les montre pas (owner « created_by ») ; la RLS de l'app laisse A lire la ligne de B (fuite de l'app, assistant ou non) ; lecture par l'assistant : jamais la ligne de B ; lecture par l'assistant : la ligne de A ; ligne de C : l'app la montre à A comme celle de B (lignes ouvertes à tous), non comparée ; lecture de la ligne de B par son identifiant : refusée ; totaux de read_data : 52 ligne(s) de A ajoutée(s) aux bornes des périodes ; 62 appels idéaux, chaque total égal au comptage de l'app sous la RLS de A)
- ! quotes rls (l'app montre à A 8 ligne(s) de B (partage, publication) ; l'assistant ne les montre pas (owner « created_by ») ; la RLS de l'app laisse A lire la ligne de B (fuite de l'app, assistant ou non) ; lecture par l'assistant : jamais la ligne de B ; lecture par l'assistant : la ligne de A ; ligne de C : l'app la montre à A comme celle de B (lignes ouvertes à tous), non comparée ; lecture de la ligne de B par son identifiant : refusée ; totaux de read_data : 52 ligne(s) de A ajoutée(s) aux bornes des périodes ; 56 appels idéaux, chaque total égal au comptage de l'app sous la RLS de A ; total inconnu, permis, pour 1 : search « quote_number 0 a »)

## Preuve (vak-proof.json)

- reçu commité : éprouvé (vak 0.24.3) : bank_transactions rls, credit_notes rls, customers rls, invoices rls, payments rls, quotes rls
- preuve du contrôleur : éprouvé (vak 0.24.3) : bank_transactions rls, credit_notes rls, customers rls, invoices rls, payments rls, quotes rls

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 22 s) | 0 (0 err., 20 s) | pas pire |
| typecheck | 0 (0 err., 11 s) | 0 (0 err., 11 s) | pas pire |
| lint | 0 (0 err., 12 s) | 0 (0 err., 17 s) | pas pire |
| tests | 0 (0 err., 2 s) | 0 (0 err., 2 s) | pas pire |
| build | 1 (0 err., 53 s) | 1 (0 err., 57 s) | pas pire |

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
- A supabase/migrations/20261006130853_vak_0001_core.sql
- A supabase/migrations/20261006130854_vak_0002_feedback.sql
- A supabase/migrations/20261006130855_vak_0003_history.sql
- A supabase/migrations/20261006130856_vak_0004_quota_erase.sql
- M tsconfig.json
- A vendor/vak/vak-agent-0.24.3.tgz

**À relire (diff : autres.diff)** (6) :
- A app/(app)/settings/agent-settings.tsx (branchement : cite vak)
- M app/(app)/settings/page.tsx
- M app/layout.tsx (branchement : cite vak)
- M components/layout/app-shell.tsx (branchement : cite vak)
- M components/layout/nav-items.ts
- A components/layout/vak-button.tsx (branchement : cite vak)

## Sabotages

Aucun.

Fichiers : rapport.json, avant.json, apres.json, journaux/, essai.bundle (prérequis e149185), autres.diff.
