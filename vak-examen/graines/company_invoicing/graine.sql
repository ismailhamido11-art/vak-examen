-- Graine « company_invoicing » (facturation, équipe). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A (employé actif, modules clients, produits, devis, factures, paiements, récurrentes) : 6 clients, 5 produits, 4 devis,
--   8 factures, 2 notes de crédit, 5 paiements, 4 affectations, 3 avoirs clients, 3 factures récurrentes.
-- B (administrateur) : uniquement des lignes dans des tables que l'app cache à A (fournisseurs, dépenses, banque,
--   journal d'audit) : 4 fournisseurs, 5 dépenses, 2 lots bancaires, 5 transactions, 4 entrées d'audit ; chaque texte
--   libre porte un marqueur unique. L'app partage ses données entre collègues (RLS par module, pas par créateur) :
--   donner à B des lignes dans les tables de A les rendrait visibles à A légitimement et ruinerait la preuve.
\set ON_ERROR_STOP on
begin;

-- Rôles : le premier compte créé devient owner_admin (déclencheur), l'ordre de création de A et B n'est pas garanti.
-- Le déclencheur de garde des profils veut un administrateur : on se met dans la peau de l'administrateur courant.
select set_config('request.jwt.claims', json_build_object('sub', (select id from public.profiles where role = 'owner_admin' and is_active order by created_at limit 1), 'role', 'authenticated')::text, true);
update public.profiles set role = 'owner_admin', is_active = true, full_name = 'Admin B' where id = :'b'::uuid;
update public.profiles set role = 'staff', is_active = true, full_name = 'Alice A',
  staff_module_permissions = '{"customers": true, "products": true, "quotes": true, "invoices": true, "payments": true, "recurring_invoices": true}'::jsonb
  where id = :'a'::uuid;
select set_config('request.jwt.claims', '', true);

insert into public.customers (company_name, contact_person, email, customer_reference, payment_terms_days, created_by) values
  ('Karoo Fresh Produce', 'Anele Dlamini', 'accounts@karoo.example.test', 'CUST-001', 30, :'a'::uuid),
  ('Table Bay Logistics', 'Pieter van Wyk', 'accounts@table.example.test', 'CUST-002', 14, :'a'::uuid),
  ('Jacaranda Interiors', 'Thandi Nkosi', 'accounts@jacaranda.example.test', 'CUST-003', 30, :'a'::uuid),
  ('Protea Dental Practice', 'Dr Sarah Cohen', 'accounts@protea.example.test', 'CUST-004', 7, :'a'::uuid),
  ('Drakensberg Outfitters', 'Johan Botha', 'accounts@drakensberg.example.test', 'CUST-005', 30, :'a'::uuid),
  ('Fynbos Catering', 'Lerato Mokoena', 'accounts@fynbos.example.test', 'CUST-006', 60, :'a'::uuid);

insert into public.products (type, name, sku, description, cost_price, selling_price, vat_rate, unit, created_by) values
  ('service'::public.product_type, 'Annual bookkeeping retainer', 'RET-001', '', 1000, 1500, 15, 'hour', :'a'::uuid),
  ('service'::public.product_type, 'Payroll processing', 'PAY-001', '', 400, 600, 15, 'hour', :'a'::uuid),
  ('product'::public.product_type, 'Receipt book A5', 'BOOK-A5', '', 25, 45, 15, 'each', :'a'::uuid),
  ('product'::public.product_type, 'Laser toner cartridge', 'TON-001', '', 350, 520, 15, 'each', :'a'::uuid),
  ('service'::public.product_type, 'On-site IT support hour', 'SUP-001', '', 250, 400, 15, 'hour', :'a'::uuid);

insert into public.quotes (quote_number, customer_id, quote_date, expiry_date, status, subtotal, vat_total, total, notes, created_by) values
  ('QUO-0001', (select id from public.customers where customer_reference = 'CUST-001' and created_by = :'a'::uuid), '2026-01-05', '2026-01-28', 'sent', 2000, 300, 2300, 'Quote 1 for the spring season', :'a'::uuid),
  ('QUO-0002', (select id from public.customers where customer_reference = 'CUST-003' and created_by = :'a'::uuid), '2026-02-05', '2026-02-28', 'accepted', 2000, 300, 2300, 'Quote 2 for the spring season', :'a'::uuid),
  ('QUO-0003', (select id from public.customers where customer_reference = 'CUST-005' and created_by = :'a'::uuid), '2026-03-05', '2026-03-28', 'draft', 2400, 360, 2760, 'Quote 3 for the spring season', :'a'::uuid),
  ('QUO-0004', (select id from public.customers where customer_reference = 'CUST-006' and created_by = :'a'::uuid), '2026-04-05', '2026-04-28', 'rejected', 2400, 360, 2760, 'Quote 4 for the spring season', :'a'::uuid);

insert into public.quote_items (quote_id, description, quantity, unit_price, vat_rate, line_subtotal, line_vat, line_total)
select qt.id, v.d, v.qy, v.up, 15, v.qy * v.up, round(v.qy * v.up * 0.15, 2), round(v.qy * v.up * 1.15, 2)
from (values
  ('QUO-0001', 'Service line for quote 1', 2, 1000),
  ('QUO-0002', 'Service line for quote 2', 4, 500),
  ('QUO-0003', 'Service line for quote 3', 1, 2400),
  ('QUO-0004', 'Service line for quote 4', 3, 800)
) as v(num, d, qy, up) join public.quotes qt on qt.quote_number = v.num;

insert into public.invoices (invoice_number, customer_id, invoice_date, due_date, status, subtotal, vat_total, total, amount_paid, reference, voided_at, created_by) values
  ('INV-0001', (select id from public.customers where customer_reference = 'CUST-001' and created_by = :'a'::uuid), '2026-01-02', '2026-01-22', 'paid', 2000, 300, 2300, 2300, 'PO-101', null, :'a'::uuid),
  ('INV-0002', (select id from public.customers where customer_reference = 'CUST-002' and created_by = :'a'::uuid), '2026-02-02', '2026-02-22', 'partially_paid', 5000, 750, 5750, 2000, 'PO-102', null, :'a'::uuid),
  ('INV-0003', (select id from public.customers where customer_reference = 'CUST-003' and created_by = :'a'::uuid), '2026-03-02', '2026-03-22', 'paid', 1200, 180, 1380, 1380, 'PO-103', null, :'a'::uuid),
  ('INV-0004', (select id from public.customers where customer_reference = 'CUST-004' and created_by = :'a'::uuid), '2026-04-02', '2026-04-22', 'sent', 800, 120, 920, 0, 'PO-104', null, :'a'::uuid),
  ('INV-0005', (select id from public.customers where customer_reference = 'CUST-005' and created_by = :'a'::uuid), '2026-05-02', '2026-05-22', 'sent', 1000, 150, 1150, 0, 'PO-105', null, :'a'::uuid),
  ('INV-0006', (select id from public.customers where customer_reference = 'CUST-006' and created_by = :'a'::uuid), '2026-06-02', '2026-06-22', 'draft', 3000, 450, 3450, 0, 'PO-106', null, :'a'::uuid),
  ('INV-0007', (select id from public.customers where customer_reference = 'CUST-001' and created_by = :'a'::uuid), '2026-07-02', '2026-07-22', 'sent', 600, 90, 690, 0, 'PO-107', null, :'a'::uuid),
  ('INV-0008', (select id from public.customers where customer_reference = 'CUST-002' and created_by = :'a'::uuid), '2026-08-02', '2026-08-22', 'void', 600, 90, 690, 0, 'PO-108', '2026-08-20T10:00:00Z', :'a'::uuid);

insert into public.invoice_items (invoice_id, description, quantity, unit_price, vat_rate, line_subtotal, line_vat, line_total)
select i.id, v.d, v.qy, v.up, 15, v.qy * v.up, round(v.qy * v.up * 0.15, 2), round(v.qy * v.up * 1.15, 2)
from (values
  ('INV-0001', 'Billed work for invoice 1', 2, 1000),
  ('INV-0002', 'Billed work for invoice 2', 1, 5000),
  ('INV-0003', 'Billed work for invoice 3', 3, 400),
  ('INV-0004', 'Billed work for invoice 4', 1, 800),
  ('INV-0005', 'Billed work for invoice 5', 4, 250),
  ('INV-0006', 'Billed work for invoice 6', 2, 1500),
  ('INV-0007', 'Billed work for invoice 7', 1, 600),
  ('INV-0008', 'Billed work for invoice 8', 5, 120)
) as v(num, d, qy, up) join public.invoices i on i.invoice_number = v.num;

insert into public.credit_notes (credit_note_number, customer_id, invoice_id, credit_note_date, reason, status, subtotal, vat_total, total, issued_at, created_by) values
  ('CN-0001', (select id from public.customers where customer_reference = 'CUST-001' and created_by = :'a'::uuid), (select id from public.invoices where invoice_number = 'INV-0001'), '2026-02-10', 'Returned goods', 'issued', 200, 30, 230, '2026-02-10T09:00:00Z', :'a'::uuid),
  ('CN-0002', (select id from public.customers where customer_reference = 'CUST-002' and created_by = :'a'::uuid), (select id from public.invoices where invoice_number = 'INV-0002'), '2026-03-12', 'Pricing correction', 'draft', 100, 15, 115, null, :'a'::uuid);
insert into public.credit_note_items (credit_note_id, description, quantity, unit_price, vat_rate, line_subtotal, line_vat, line_total)
select c.id, v.d, 1, v.up, 15, v.up, round(v.up * 0.15, 2), round(v.up * 1.15, 2)
from (values ('CN-0001', 'Returned goods credit', 200), ('CN-0002', 'Pricing correction credit', 100)) as v(num, d, up)
join public.credit_notes c on c.credit_note_number = v.num;

insert into public.payments (customer_id, payment_date, amount, payment_method, bank_reference, description, allocation_status, created_by) values
  ((select id from public.customers where customer_reference = 'CUST-001' and created_by = :'a'::uuid), '2026-02-15', 2300, 'eft', 'REF-A1', 'Payment for INV-0001', 'fully_allocated', :'a'::uuid),
  ((select id from public.customers where customer_reference = 'CUST-002' and created_by = :'a'::uuid), '2026-03-15', 2000, 'card', 'REF-A2', 'Part payment for INV-0002', 'fully_allocated', :'a'::uuid),
  ((select id from public.customers where customer_reference = 'CUST-003' and created_by = :'a'::uuid), '2026-04-15', 1380, 'cash', 'REF-A3', 'Payment for INV-0003', 'fully_allocated', :'a'::uuid),
  ((select id from public.customers where customer_reference = 'CUST-004' and created_by = :'a'::uuid), '2026-05-15', 500, 'eft', 'REF-A4', 'Deposit received', 'unallocated', :'a'::uuid),
  ((select id from public.customers where customer_reference = 'CUST-005' and created_by = :'a'::uuid), '2026-06-15', 700, 'instant_eft', 'REF-A5', 'Advance received', 'unallocated', :'a'::uuid);

insert into public.payment_allocations (payment_id, invoice_id, amount, created_by)
select p.id, i.id, v.am, :'a'::uuid
from (values ('REF-A1', 'INV-0001', 2300), ('REF-A2', 'INV-0002', 2000), ('REF-A3', 'INV-0003', 1000), ('REF-A3', 'INV-0003', 380)) as v(ref, num, am)
join public.payments p on p.bank_reference = v.ref and p.created_by = :'a'::uuid
join public.invoices i on i.invoice_number = v.num;

insert into public.customer_credits (customer_id, amount, source, payment_id, credit_note_id, notes, created_by) values
  ((select id from public.customers where customer_reference = 'CUST-004' and created_by = :'a'::uuid), 500, 'overpayment', (select id from public.payments where bank_reference = 'REF-A4'), null, 'Deposit held as credit', :'a'::uuid),
  ((select id from public.customers where customer_reference = 'CUST-005' and created_by = :'a'::uuid), 700, 'overpayment', (select id from public.payments where bank_reference = 'REF-A5'), null, 'Advance held as credit', :'a'::uuid),
  ((select id from public.customers where customer_reference = 'CUST-001' and created_by = :'a'::uuid), 230, 'credit_note', null, (select id from public.credit_notes where credit_note_number = 'CN-0001'), 'Credit note balance', :'a'::uuid);

insert into public.recurring_invoices (customer_id, description, frequency, start_date, next_invoice_date, status, created_by) values
  ((select id from public.customers where customer_reference = 'CUST-001' and created_by = :'a'::uuid), 'Monthly bookkeeping retainer', 'monthly', '2026-01-01', '2026-11-01', 'active', :'a'::uuid),
  ((select id from public.customers where customer_reference = 'CUST-003' and created_by = :'a'::uuid), 'Quarterly interior maintenance', 'quarterly', '2026-01-01', '2026-11-01', 'active', :'a'::uuid),
  ((select id from public.customers where customer_reference = 'CUST-004' and created_by = :'a'::uuid), 'Weekly equipment servicing', 'weekly', '2026-01-01', '2026-11-01', 'active', :'a'::uuid);

insert into public.recurring_invoice_items (recurring_invoice_id, description, quantity, unit_price, vat_rate)
select r.id, v.d, 1, v.up, 15 from (values
  ('Monthly bookkeeping retainer', 1000),
  ('Quarterly interior maintenance', 1800),
  ('Weekly equipment servicing', 250)
) as v(d, up) join public.recurring_invoices r on r.description = v.d and r.created_by = :'a'::uuid;

insert into public.suppliers (company_name, contact_person, notes, created_by) values
  ('Fournisseur MARQUEUR-B-CF7D9DA3', 'Contact MARQUEUR-B-330F51C6', 'Note MARQUEUR-B-17378A85', :'b'::uuid),
  ('Fournisseur MARQUEUR-B-A569D7E5', 'Contact MARQUEUR-B-36CAFF9F', 'Note MARQUEUR-B-B641F117', :'b'::uuid),
  ('Fournisseur MARQUEUR-B-953E5479', 'Contact MARQUEUR-B-EAD9864B', 'Note MARQUEUR-B-245C0787', :'b'::uuid),
  ('Fournisseur MARQUEUR-B-DC136EFA', 'Contact MARQUEUR-B-3E6DE67B', 'Note MARQUEUR-B-F22F2F1B', :'b'::uuid);

insert into public.expenses (supplier_id, expense_date, description, category, amount, notes, created_by) values
  ((select id from public.suppliers where company_name = 'Fournisseur MARQUEUR-B-CF7D9DA3'), '2026-01-20', 'Dépense MARQUEUR-B-72B78FB2', 'Catégorie MARQUEUR-B-09308E1F', 110, 'Note MARQUEUR-B-86F2663C', :'b'::uuid),
  ((select id from public.suppliers where company_name = 'Fournisseur MARQUEUR-B-A569D7E5'), '2026-02-20', 'Dépense MARQUEUR-B-8D6EF979', 'Catégorie MARQUEUR-B-57462869', 220, 'Note MARQUEUR-B-15E5623D', :'b'::uuid),
  ((select id from public.suppliers where company_name = 'Fournisseur MARQUEUR-B-953E5479'), '2026-03-20', 'Dépense MARQUEUR-B-E570D61F', 'Catégorie MARQUEUR-B-F1C831EB', 330, 'Note MARQUEUR-B-0EDA5E22', :'b'::uuid),
  ((select id from public.suppliers where company_name = 'Fournisseur MARQUEUR-B-DC136EFA'), '2026-04-20', 'Dépense MARQUEUR-B-53CDCA0C', 'Catégorie MARQUEUR-B-18DB67D3', 440, 'Note MARQUEUR-B-580360B8', :'b'::uuid),
  ((select id from public.suppliers where company_name = 'Fournisseur MARQUEUR-B-CF7D9DA3'), '2026-05-20', 'Dépense MARQUEUR-B-2E443E86', 'Catégorie MARQUEUR-B-8A51C359', 550, 'Note MARQUEUR-B-EAC63247', :'b'::uuid);

insert into public.bank_import_batches (filename, imported_by, row_count, imported_count) values
  ('releve-MARQUEUR-B-8818C73B.csv', :'b'::uuid, 3, 3),
  ('releve-MARQUEUR-B-30AA8FB1.csv', :'b'::uuid, 2, 2);

insert into public.bank_transactions (import_batch_id, transaction_date, description, reference, amount, dedupe_hash, notes, matched_by) values
  ((select id from public.bank_import_batches where filename = 'releve-MARQUEUR-B-8818C73B.csv'), '2026-01-10', 'Virement MARQUEUR-B-2E35BC29', 'Réf MARQUEUR-B-67AF3F6C', 90, md5('MARQUEUR-B-2E35BC29'), 'Note MARQUEUR-B-29793D7F', null),
  ((select id from public.bank_import_batches where filename = 'releve-MARQUEUR-B-8818C73B.csv'), '2026-02-10', 'Virement MARQUEUR-B-A00C775C', 'Réf MARQUEUR-B-670B5486', 180, md5('MARQUEUR-B-A00C775C'), 'Note MARQUEUR-B-186C4A03', null),
  ((select id from public.bank_import_batches where filename = 'releve-MARQUEUR-B-8818C73B.csv'), '2026-03-10', 'Virement MARQUEUR-B-187ECBCA', 'Réf MARQUEUR-B-61AA0D84', 270, md5('MARQUEUR-B-187ECBCA'), 'Note MARQUEUR-B-CFDD58FA', null),
  ((select id from public.bank_import_batches where filename = 'releve-MARQUEUR-B-30AA8FB1.csv'), '2026-04-10', 'Virement MARQUEUR-B-E50AAAD4', 'Réf MARQUEUR-B-C14EC561', 360, md5('MARQUEUR-B-E50AAAD4'), 'Note MARQUEUR-B-76CE6463', null),
  ((select id from public.bank_import_batches where filename = 'releve-MARQUEUR-B-30AA8FB1.csv'), '2026-05-10', 'Virement MARQUEUR-B-6EFC2A8A', 'Réf MARQUEUR-B-159B8DBA', 450, md5('MARQUEUR-B-6EFC2A8A'), 'Note MARQUEUR-B-DF08F5F9', null);

insert into public.audit_logs (user_id, action, entity, entity_id, new_value) values
  (:'b'::uuid, 'action-MARQUEUR-B-A484B5F9', 'entité-MARQUEUR-B-903C01B7', 'MARQUEUR-B-A3922258', '{"note":"MARQUEUR-B-4EB02EF0"}'::jsonb),
  (:'b'::uuid, 'action-MARQUEUR-B-FD65D67C', 'entité-MARQUEUR-B-8994D7EB', 'MARQUEUR-B-7D9D6DC3', '{"note":"MARQUEUR-B-266687FC"}'::jsonb),
  (:'b'::uuid, 'action-MARQUEUR-B-65F9BB15', 'entité-MARQUEUR-B-2B82DCBD', 'MARQUEUR-B-651EDCA4', '{"note":"MARQUEUR-B-40D6CCA0"}'::jsonb),
  (:'b'::uuid, 'action-MARQUEUR-B-D9047700', 'entité-MARQUEUR-B-DF086F75', 'MARQUEUR-B-8AC07597', '{"note":"MARQUEUR-B-73469B3A"}'::jsonb);

commit;
