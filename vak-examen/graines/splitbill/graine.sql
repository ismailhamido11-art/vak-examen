-- Graine « splitbill » (partage de dépenses). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 4 groupes (seul membre de chacun), 3 contacts. B : données distinctes, chaque texte libre porte un marqueur unique.
-- Les comptes d'aide (contacts, ancien membre) ont des ids ffffffff-0000-… supérieurs à ceux de A et de B : A et B sont
-- donc toujours user_lo des paires (contrainte user_lo < user_hi), de sorte que le filtre « user_lo = moi » est sans ambiguïté.
\set ON_ERROR_STOP on
begin;

-- Garde : A et B doivent être inférieurs aux comptes d'aide (sinon division par zéro, donc arrêt).
select 1 / (case when :'a'::uuid < 'ffffffff-0000-4000-8000-000000000000'::uuid and :'b'::uuid < 'ffffffff-0000-4000-8000-000000000000'::uuid then 1 else 0 end) as garde;

-- Comptes d'aide : le déclencheur on_auth_user_created crée leurs profils.
insert into auth.users (id, email, raw_user_meta_data) values
  ('ffffffff-0000-4000-8000-000000000001', 'priya.nair@example.test', '{"full_name":"Priya Nair"}'::jsonb),
  ('ffffffff-0000-4000-8000-000000000002', 'tom.becker@example.test', '{"full_name":"Tom Becker"}'::jsonb),
  ('ffffffff-0000-4000-8000-000000000003', 'lena.fischer@example.test', '{"full_name":"Lena Fischer"}'::jsonb),
  ('ffffffff-0000-4000-8000-000000000004', 'marc.dubois@example.test', '{"full_name":"Marc Dubois"}'::jsonb),
  ('ffffffff-0000-4000-8000-000000000005', 'ines.costa@example.test', '{"full_name":"Ines Costa"}'::jsonb),
  ('ffffffff-0000-4000-8000-000000000006', 'sam.rivera@example.test', '{"full_name":"Sam Rivera"}'::jsonb),
  ('ffffffff-0000-4000-8000-000000000011', 'bhelper1@example.test', '{"full_name":"Contact MARQUEUR-B-AF64725B"}'::jsonb),
  ('ffffffff-0000-4000-8000-000000000012', 'bhelper2@example.test', '{"full_name":"Contact MARQUEUR-B-767C1581"}'::jsonb),
  ('ffffffff-0000-4000-8000-000000000013', 'bhelper3@example.test', '{"full_name":"Contact MARQUEUR-B-A7C9149A"}'::jsonb),
  ('ffffffff-0000-4000-8000-000000000014', 'bhelper4@example.test', '{"full_name":"Contact MARQUEUR-B-81BEA482"}'::jsonb);

-- Profils de A et de B (créés par le déclencheur à l'inscription ; mis à jour, ou créés s'ils manquent).
insert into public.profiles (id, full_name) values (:'a'::uuid, 'Alex Martin'), (:'b'::uuid, 'Member MARQUEUR-B-15339A04')
  on conflict (id) do update set full_name = excluded.full_name;

-- ===== A =====
-- A : groupes
insert into public.groups (id, name, created_by, created_at, currency) values
  ('a0000001-0000-4000-8000-b3f91f3ccec6', 'Home budget', :'a'::uuid, '2026-01-01', 'USD'),
  ('a0000002-0000-4000-8000-0932761a5553', 'Lisbon trip', :'a'::uuid, '2026-02-01', 'EUR'),
  ('a0000003-0000-4000-8000-b09e147f77b6', 'Office lunches', :'a'::uuid, '2026-03-01', 'USD'),
  ('a0000004-0000-4000-8000-904689a1cb2f', 'Book club', :'a'::uuid, '2026-04-01', 'GBP');

-- A : membres (le compte seul)
insert into public.group_members (group_id, user_id) values
  ('a0000001-0000-4000-8000-b3f91f3ccec6', :'a'::uuid),
  ('a0000002-0000-4000-8000-0932761a5553', :'a'::uuid),
  ('a0000003-0000-4000-8000-b09e147f77b6', :'a'::uuid),
  ('a0000004-0000-4000-8000-904689a1cb2f', :'a'::uuid);

-- A : dépenses
insert into public.expenses (id, group_id, paid_by, amount, description, category, split_type, date, currency, exchange_rate, base_amount) values
  ('a0000005-0000-4000-8000-280eaa61620f', 'a0000001-0000-4000-8000-b3f91f3ccec6', :'a'::uuid, 84.50, 'Groceries', 'Food', 'equal', '2026-03-02', 'USD', 1, 84.50),
  ('a0000006-0000-4000-8000-245080865ae6', 'a0000001-0000-4000-8000-b3f91f3ccec6', :'a'::uuid, 62.10, 'Electricity bill', 'Utilities', 'equal', '2026-03-09', 'USD', 1, 62.10),
  ('a0000007-0000-4000-8000-32f1dea3b76c', 'a0000001-0000-4000-8000-b3f91f3ccec6', :'a'::uuid, 45.00, 'Internet', 'Utilities', 'equal', '2026-03-15', 'USD', 1, 45.00),
  ('a0000008-0000-4000-8000-c26df6ec04f9', 'a0000002-0000-4000-8000-0932761a5553', :'a'::uuid, 320.00, 'Flights', 'Travel', 'equal', '2026-04-01', 'EUR', 1, 320.00),
  ('a0000009-0000-4000-8000-e8b374d0738e', 'a0000002-0000-4000-8000-0932761a5553', :'a'::uuid, 410.40, 'Hotel', 'Travel', 'equal', '2026-04-03', 'EUR', 1, 410.40),
  ('a000000a-0000-4000-8000-ddcdf0aa4858', 'a0000002-0000-4000-8000-0932761a5553', :'a'::uuid, 28.00, 'Pastéis de nata tour', 'Leisure', 'equal', '2026-04-04', 'USD', 0.92, 25.76),
  ('a000000b-0000-4000-8000-043cc2896dec', 'a0000003-0000-4000-8000-b09e147f77b6', :'a'::uuid, 96.00, 'Team lunch', 'Food', 'equal', '2026-05-06', 'USD', 1, 96.00),
  ('a000000c-0000-4000-8000-fb6fede0564a', 'a0000003-0000-4000-8000-b09e147f77b6', :'a'::uuid, 31.25, 'Coffee beans', 'Food', 'equal', '2026-05-13', 'USD', 1, 31.25),
  ('a000000d-0000-4000-8000-f618b90c3ba9', 'a0000004-0000-4000-8000-904689a1cb2f', :'a'::uuid, 54.90, 'Book order', 'Books', 'equal', '2026-06-01', 'GBP', 1, 54.90);

-- A : parts (le compte seul dans ses groupes)
insert into public.expense_splits (expense_id, user_id, amount, base_amount) values
  ('a0000005-0000-4000-8000-280eaa61620f', :'a'::uuid, 84.50, 84.50),
  ('a0000006-0000-4000-8000-245080865ae6', :'a'::uuid, 62.10, 62.10),
  ('a0000007-0000-4000-8000-32f1dea3b76c', :'a'::uuid, 45.00, 45.00),
  ('a0000008-0000-4000-8000-c26df6ec04f9', :'a'::uuid, 320.00, 320.00),
  ('a0000009-0000-4000-8000-e8b374d0738e', :'a'::uuid, 410.40, 410.40),
  ('a000000a-0000-4000-8000-ddcdf0aa4858', :'a'::uuid, 28.00, 25.76),
  ('a000000b-0000-4000-8000-043cc2896dec', :'a'::uuid, 96.00, 96.00),
  ('a000000c-0000-4000-8000-fb6fede0564a', :'a'::uuid, 31.25, 31.25),
  ('a000000d-0000-4000-8000-f618b90c3ba9', :'a'::uuid, 54.90, 54.90);

-- A : paiements (au compte d'aide qui a quitté les groupes)
insert into public.payments (group_id, paid_by, paid_to, amount, note, currency, exchange_rate, base_amount, created_at) values
  ('a0000001-0000-4000-8000-b3f91f3ccec6', :'a'::uuid, 'ffffffff-0000-4000-8000-000000000006'::uuid, 40.00, 'Rent share', 'USD', 1, 40.00, '2026-03-20'),
  ('a0000001-0000-4000-8000-b3f91f3ccec6', :'a'::uuid, 'ffffffff-0000-4000-8000-000000000006'::uuid, 25.00, 'Deposit back', 'USD', 1, 25.00, '2026-03-27'),
  ('a0000002-0000-4000-8000-0932761a5553', :'a'::uuid, 'ffffffff-0000-4000-8000-000000000006'::uuid, 100.00, 'Flights refund', 'EUR', 1, 100.00, '2026-04-10'),
  ('a0000002-0000-4000-8000-0932761a5553', :'a'::uuid, 'ffffffff-0000-4000-8000-000000000006'::uuid, 55.50, 'Taxi', 'EUR', 1, 55.50, '2026-04-12'),
  ('a0000003-0000-4000-8000-b09e147f77b6', :'a'::uuid, 'ffffffff-0000-4000-8000-000000000006'::uuid, 20.00, 'Lunch', 'USD', 1, 20.00, '2026-05-20');

-- A : changements du mode « simplifier les dettes »
insert into public.group_simplify_debts_events (group_id, actor_id, enabled, created_at) values
  ('a0000001-0000-4000-8000-b3f91f3ccec6', :'a'::uuid, false, '2026-03-05'),
  ('a0000001-0000-4000-8000-b3f91f3ccec6', :'a'::uuid, true, '2026-03-25'),
  ('a0000002-0000-4000-8000-0932761a5553', :'a'::uuid, false, '2026-04-02');

-- A : contacts (paires réciproques, comme create_contact_pair)
insert into public.contacts (owner_id, contact_user_id) values
  (:'a'::uuid, 'ffffffff-0000-4000-8000-000000000001'::uuid),
  ('ffffffff-0000-4000-8000-000000000001'::uuid, :'a'::uuid),
  (:'a'::uuid, 'ffffffff-0000-4000-8000-000000000002'::uuid),
  ('ffffffff-0000-4000-8000-000000000002'::uuid, :'a'::uuid),
  (:'a'::uuid, 'ffffffff-0000-4000-8000-000000000003'::uuid),
  ('ffffffff-0000-4000-8000-000000000003'::uuid, :'a'::uuid);

-- A : demandes de contact envoyées
insert into public.contact_requests (requester_id, recipient_id, status, created_at, responded_at) values
  (:'a'::uuid, 'ffffffff-0000-4000-8000-000000000001'::uuid, 'accepted', '2026-03-01', '2026-03-02'),
  (:'a'::uuid, 'ffffffff-0000-4000-8000-000000000002'::uuid, 'accepted', '2026-03-02', '2026-03-03'),
  (:'a'::uuid, 'ffffffff-0000-4000-8000-000000000003'::uuid, 'accepted', '2026-03-03', '2026-03-04'),
  (:'a'::uuid, 'ffffffff-0000-4000-8000-000000000004'::uuid, 'pending', '2026-03-04', null),
  (:'a'::uuid, 'ffffffff-0000-4000-8000-000000000005'::uuid, 'declined', '2026-03-05', '2026-03-06');

-- A : dépenses entre contacts (le compte paie ; le compte est user_lo)
insert into public.contact_expenses (id, paid_by, user_lo, user_hi, amount, description, category, split_type, date, currency, exchange_rate, base_amount) values
  ('a000000e-0000-4000-8000-0d226e8701a3', :'a'::uuid, :'a'::uuid, 'ffffffff-0000-4000-8000-000000000001'::uuid, 58.00, 'Dinner out', 'Food', 'equal', '2026-04-20', 'EUR', 1, 58.00),
  ('a000000f-0000-4000-8000-a6a94355d2de', :'a'::uuid, :'a'::uuid, 'ffffffff-0000-4000-8000-000000000001'::uuid, 120.00, 'Concert tickets', 'Leisure', 'equal', '2026-05-02', 'EUR', 1, 120.00),
  ('a0000010-0000-4000-8000-d7ece2071541', :'a'::uuid, :'a'::uuid, 'ffffffff-0000-4000-8000-000000000001'::uuid, 18.40, 'Taxi home', 'Transport', 'equal', '2026-05-02', 'EUR', 1, 18.40),
  ('a0000011-0000-4000-8000-43e5cb821096', :'a'::uuid, :'a'::uuid, 'ffffffff-0000-4000-8000-000000000002'::uuid, 36.00, 'Pub quiz', 'Leisure', 'equal', '2026-05-11', 'GBP', 1, 36.00),
  ('a0000012-0000-4000-8000-a5a3623671d0', :'a'::uuid, :'a'::uuid, 'ffffffff-0000-4000-8000-000000000002'::uuid, 72.00, 'Birthday gift', 'Gifts', 'equal', '2026-05-30', 'GBP', 1, 72.00),
  ('a0000013-0000-4000-8000-8049e3186444', :'a'::uuid, :'a'::uuid, 'ffffffff-0000-4000-8000-000000000003'::uuid, 24.00, 'Museum entry', 'Leisure', 'equal', '2026-06-07', 'USD', 1, 24.00);

-- A : parts des dépenses entre contacts (moitié-moitié)
insert into public.contact_expense_splits (expense_id, user_id, amount, base_amount) values
  ('a000000e-0000-4000-8000-0d226e8701a3', :'a'::uuid, 29.00, 29.00),
  ('a000000e-0000-4000-8000-0d226e8701a3', 'ffffffff-0000-4000-8000-000000000001'::uuid, 29.00, 29.00),
  ('a000000f-0000-4000-8000-a6a94355d2de', :'a'::uuid, 60.00, 60.00),
  ('a000000f-0000-4000-8000-a6a94355d2de', 'ffffffff-0000-4000-8000-000000000001'::uuid, 60.00, 60.00),
  ('a0000010-0000-4000-8000-d7ece2071541', :'a'::uuid, 9.20, 9.20),
  ('a0000010-0000-4000-8000-d7ece2071541', 'ffffffff-0000-4000-8000-000000000001'::uuid, 9.20, 9.20),
  ('a0000011-0000-4000-8000-43e5cb821096', :'a'::uuid, 18.00, 18.00),
  ('a0000011-0000-4000-8000-43e5cb821096', 'ffffffff-0000-4000-8000-000000000002'::uuid, 18.00, 18.00),
  ('a0000012-0000-4000-8000-a5a3623671d0', :'a'::uuid, 36.00, 36.00),
  ('a0000012-0000-4000-8000-a5a3623671d0', 'ffffffff-0000-4000-8000-000000000002'::uuid, 36.00, 36.00),
  ('a0000013-0000-4000-8000-8049e3186444', :'a'::uuid, 12.00, 12.00),
  ('a0000013-0000-4000-8000-8049e3186444', 'ffffffff-0000-4000-8000-000000000003'::uuid, 12.00, 12.00);

-- A : paiements entre contacts (le compte paie)
insert into public.contact_payments (paid_by, paid_to, user_lo, user_hi, amount, note, currency, exchange_rate, base_amount, created_at) values
  (:'a'::uuid, 'ffffffff-0000-4000-8000-000000000001'::uuid, :'a'::uuid, 'ffffffff-0000-4000-8000-000000000001'::uuid, 50.00, 'Dinner share', 'EUR', 1, 50.00, '2026-04-25'),
  (:'a'::uuid, 'ffffffff-0000-4000-8000-000000000001'::uuid, :'a'::uuid, 'ffffffff-0000-4000-8000-000000000001'::uuid, 30.00, 'Concert share', 'EUR', 1, 30.00, '2026-05-10'),
  (:'a'::uuid, 'ffffffff-0000-4000-8000-000000000002'::uuid, :'a'::uuid, 'ffffffff-0000-4000-8000-000000000002'::uuid, 18.00, 'Pub quiz share', 'GBP', 1, 18.00, '2026-05-15'),
  (:'a'::uuid, 'ffffffff-0000-4000-8000-000000000003'::uuid, :'a'::uuid, 'ffffffff-0000-4000-8000-000000000003'::uuid, 12.00, 'Museum share', 'USD', 1, 12.00, '2026-06-10');

-- A : devise des paires de contacts
insert into public.contact_pair_settings (user_lo, user_hi, currency) values
  (:'a'::uuid, 'ffffffff-0000-4000-8000-000000000001'::uuid, 'EUR'),
  (:'a'::uuid, 'ffffffff-0000-4000-8000-000000000002'::uuid, 'GBP');

-- ===== B =====
-- B : groupes
insert into public.groups (id, name, created_by, created_at, currency) values
  ('a0000014-0000-4000-8000-0f1a8d1dd3d1', 'MARQUEUR-B-631245AD', :'b'::uuid, '2026-01-01', 'EUR'),
  ('a0000015-0000-4000-8000-1f6eff92011b', 'MARQUEUR-B-9C2AAAE6', :'b'::uuid, '2026-02-01', 'USD'),
  ('a0000016-0000-4000-8000-93fa24f78a75', 'MARQUEUR-B-7D62DA73', :'b'::uuid, '2026-03-01', 'USD');

-- B : membres (le compte seul)
insert into public.group_members (group_id, user_id) values
  ('a0000014-0000-4000-8000-0f1a8d1dd3d1', :'b'::uuid),
  ('a0000015-0000-4000-8000-1f6eff92011b', :'b'::uuid),
  ('a0000016-0000-4000-8000-93fa24f78a75', :'b'::uuid);

-- B : dépenses
insert into public.expenses (id, group_id, paid_by, amount, description, category, split_type, date, currency, exchange_rate, base_amount) values
  ('a0000017-0000-4000-8000-1e8f72caafbe', 'a0000014-0000-4000-8000-0f1a8d1dd3d1', :'b'::uuid, 210.00, 'MARQUEUR-B-59AF2176', 'MARQUEUR-B-7C831E50', 'equal', '2026-02-10', 'EUR', 1, 210.00),
  ('a0000018-0000-4000-8000-781a79cf6897', 'a0000014-0000-4000-8000-0f1a8d1dd3d1', :'b'::uuid, 75.30, 'MARQUEUR-B-E05F18B5', 'MARQUEUR-B-C8A8D2A0', 'equal', '2026-02-12', 'EUR', 1, 75.30),
  ('a0000019-0000-4000-8000-e88f9e24e234', 'a0000015-0000-4000-8000-1f6eff92011b', :'b'::uuid, 133.75, 'MARQUEUR-B-CF0AA0FD', 'MARQUEUR-B-76140359', 'equal', '2026-03-18', 'USD', 1, 133.75),
  ('a000001a-0000-4000-8000-5ccf08a43ec1', 'a0000015-0000-4000-8000-1f6eff92011b', :'b'::uuid, 49.99, 'MARQUEUR-B-0918106C', 'MARQUEUR-B-03866F5E', 'equal', '2026-03-22', 'USD', 1, 49.99),
  ('a000001b-0000-4000-8000-5411b8e4b43b', 'a0000016-0000-4000-8000-93fa24f78a75', :'b'::uuid, 88.00, 'MARQUEUR-B-56BE4E1F', 'MARQUEUR-B-7BB4B7C7', 'equal', '2026-04-14', 'USD', 1, 88.00);

-- B : parts (le compte seul dans ses groupes)
insert into public.expense_splits (expense_id, user_id, amount, base_amount) values
  ('a0000017-0000-4000-8000-1e8f72caafbe', :'b'::uuid, 210.00, 210.00),
  ('a0000018-0000-4000-8000-781a79cf6897', :'b'::uuid, 75.30, 75.30),
  ('a0000019-0000-4000-8000-e88f9e24e234', :'b'::uuid, 133.75, 133.75),
  ('a000001a-0000-4000-8000-5ccf08a43ec1', :'b'::uuid, 49.99, 49.99),
  ('a000001b-0000-4000-8000-5411b8e4b43b', :'b'::uuid, 88.00, 88.00);

-- B : paiements (au compte d'aide qui a quitté les groupes)
insert into public.payments (group_id, paid_by, paid_to, amount, note, currency, exchange_rate, base_amount, created_at) values
  ('a0000014-0000-4000-8000-0f1a8d1dd3d1', :'b'::uuid, 'ffffffff-0000-4000-8000-000000000014'::uuid, 60.00, 'MARQUEUR-B-6F611C6A', 'EUR', 1, 60.00, '2026-02-20'),
  ('a0000015-0000-4000-8000-1f6eff92011b', :'b'::uuid, 'ffffffff-0000-4000-8000-000000000014'::uuid, 35.00, 'MARQUEUR-B-52F5C5B9', 'USD', 1, 35.00, '2026-03-30');

-- B : changements du mode « simplifier les dettes »
insert into public.group_simplify_debts_events (group_id, actor_id, enabled, created_at) values
  ('a0000014-0000-4000-8000-0f1a8d1dd3d1', :'b'::uuid, false, '2026-02-11'),
  ('a0000015-0000-4000-8000-1f6eff92011b', :'b'::uuid, true, '2026-03-19');

-- B : contacts (paires réciproques, comme create_contact_pair)
insert into public.contacts (owner_id, contact_user_id) values
  (:'b'::uuid, 'ffffffff-0000-4000-8000-000000000011'::uuid),
  ('ffffffff-0000-4000-8000-000000000011'::uuid, :'b'::uuid),
  (:'b'::uuid, 'ffffffff-0000-4000-8000-000000000012'::uuid),
  ('ffffffff-0000-4000-8000-000000000012'::uuid, :'b'::uuid);

-- B : demandes de contact envoyées
insert into public.contact_requests (requester_id, recipient_id, status, created_at, responded_at) values
  (:'b'::uuid, 'ffffffff-0000-4000-8000-000000000011'::uuid, 'accepted', '2026-03-01', '2026-03-02'),
  (:'b'::uuid, 'ffffffff-0000-4000-8000-000000000012'::uuid, 'accepted', '2026-03-02', '2026-03-03'),
  (:'b'::uuid, 'ffffffff-0000-4000-8000-000000000013'::uuid, 'pending', '2026-03-03', null);

-- B : dépenses entre contacts (le compte paie ; le compte est user_lo)
insert into public.contact_expenses (id, paid_by, user_lo, user_hi, amount, description, category, split_type, date, currency, exchange_rate, base_amount) values
  ('a000001c-0000-4000-8000-9d068ccf4a54', :'b'::uuid, :'b'::uuid, 'ffffffff-0000-4000-8000-000000000011'::uuid, 44.00, 'MARQUEUR-B-29D11805', 'MARQUEUR-B-CF7C675C', 'equal', '2026-03-01', 'EUR', 1, 44.00),
  ('a000001d-0000-4000-8000-3c43305d0e6c', :'b'::uuid, :'b'::uuid, 'ffffffff-0000-4000-8000-000000000011'::uuid, 61.20, 'MARQUEUR-B-B4117160', 'MARQUEUR-B-5ED48C1D', 'equal', '2026-03-08', 'EUR', 1, 61.20),
  ('a000001e-0000-4000-8000-98c7a5d6d053', :'b'::uuid, :'b'::uuid, 'ffffffff-0000-4000-8000-000000000012'::uuid, 27.00, 'MARQUEUR-B-F9E7DBD4', 'MARQUEUR-B-0F116D92', 'equal', '2026-03-15', 'USD', 1, 27.00),
  ('a000001f-0000-4000-8000-dabb6377f91f', :'b'::uuid, :'b'::uuid, 'ffffffff-0000-4000-8000-000000000012'::uuid, 15.50, 'MARQUEUR-B-DF105782', 'MARQUEUR-B-A3B9B4F4', 'equal', '2026-03-29', 'USD', 1, 15.50);

-- B : parts des dépenses entre contacts (moitié-moitié)
insert into public.contact_expense_splits (expense_id, user_id, amount, base_amount) values
  ('a000001c-0000-4000-8000-9d068ccf4a54', :'b'::uuid, 22.00, 22.00),
  ('a000001c-0000-4000-8000-9d068ccf4a54', 'ffffffff-0000-4000-8000-000000000011'::uuid, 22.00, 22.00),
  ('a000001d-0000-4000-8000-3c43305d0e6c', :'b'::uuid, 30.60, 30.60),
  ('a000001d-0000-4000-8000-3c43305d0e6c', 'ffffffff-0000-4000-8000-000000000011'::uuid, 30.60, 30.60),
  ('a000001e-0000-4000-8000-98c7a5d6d053', :'b'::uuid, 13.50, 13.50),
  ('a000001e-0000-4000-8000-98c7a5d6d053', 'ffffffff-0000-4000-8000-000000000012'::uuid, 13.50, 13.50),
  ('a000001f-0000-4000-8000-dabb6377f91f', :'b'::uuid, 7.75, 7.75),
  ('a000001f-0000-4000-8000-dabb6377f91f', 'ffffffff-0000-4000-8000-000000000012'::uuid, 7.75, 7.75);

-- B : paiements entre contacts (le compte paie)
insert into public.contact_payments (paid_by, paid_to, user_lo, user_hi, amount, note, currency, exchange_rate, base_amount, created_at) values
  (:'b'::uuid, 'ffffffff-0000-4000-8000-000000000011'::uuid, :'b'::uuid, 'ffffffff-0000-4000-8000-000000000011'::uuid, 22.00, 'MARQUEUR-B-42DEF012', 'EUR', 1, 22.00, '2026-03-05'),
  (:'b'::uuid, 'ffffffff-0000-4000-8000-000000000012'::uuid, :'b'::uuid, 'ffffffff-0000-4000-8000-000000000012'::uuid, 13.50, 'MARQUEUR-B-55D97CB6', 'USD', 1, 13.50, '2026-03-20'),
  (:'b'::uuid, 'ffffffff-0000-4000-8000-000000000012'::uuid, :'b'::uuid, 'ffffffff-0000-4000-8000-000000000012'::uuid, 8.00, 'MARQUEUR-B-C55E2C8F', 'USD', 1, 8.00, '2026-04-02');

-- B : devise des paires de contacts
insert into public.contact_pair_settings (user_lo, user_hi, currency) values
  (:'b'::uuid, 'ffffffff-0000-4000-8000-000000000011'::uuid, 'EUR');

commit;
