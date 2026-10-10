-- Graine « expense_sharing » (Splitwise-like). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 1 profil, 3 groupes (seul membre de chacun), 3 adhésions, 9 dépenses (toutes créées par A).
-- B : 1 profil, 2 groupes, 5 membres (dont 3 sans compte), 5 dépenses, 2 règlements ; chaque texte libre porte un marqueur unique.
-- Aucun groupe n'est partagé entre A et B, et A n'a aucun membre sans compte : « mes groupes », « mes dépenses »… n'ont qu'un sens.
-- N'utilise que des colonnes de 0001_init.sql (0005 et 0006 ajoutent simplify_debts et receipt_url, qui ont des défauts / sont facultatives).
\set ON_ERROR_STOP on
begin;

-- Les profils existent déjà (déclencheur handle_new_user sur auth.users) ; on les renseigne avant toute adhésion.
update public.profiles set full_name = 'Asha Verma', phone = '+91 98765 43210' where id = :'a'::uuid;
update public.profiles set full_name = 'Nom MARQUEUR-B-E9A6EAA2', phone = 'Tel MARQUEUR-B-212E1359', avatar_url = 'https://example.test/avatars/MARQUEUR-B-5B97464C.png' where id = :'b'::uuid;

insert into public.groups (id, name, created_by, currency, created_at) values
  ('a0000000-0000-4000-8000-000000000001', 'Goa Trip', :'a'::uuid, 'INR', '2026-01-01 10:00+00'),
  ('a0000000-0000-4000-8000-000000000002', 'Flat 4B', :'a'::uuid, 'INR', '2026-01-02 10:00+00'),
  ('a0000000-0000-4000-8000-000000000003', 'Office Lunch', :'a'::uuid, 'USD', '2026-01-03 10:00+00');

insert into public.group_members (id, group_id, user_id, display_name, email, role, joined_at)
select ('a1000000-0000-4000-8000-00000000000' || right(g.id::text, 1))::uuid, g.id, :'a'::uuid, 'Asha Verma', p.email, 'owner', g.created_at
from public.groups g, public.profiles p where g.created_by = :'a'::uuid and p.id = :'a'::uuid;

insert into public.expenses (id, group_id, description, amount, currency, paid_by, split_type, spent_at, created_by, notes) values
  ('a2000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'Beach shack dinner', 2400.5, 'INR', 'a1000000-0000-4000-8000-000000000001', 'equal', '2026-01-10', :'a'::uuid, 'Paid in cash'),
  ('a2000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001', 'Scooter rental', 1200, 'INR', 'a1000000-0000-4000-8000-000000000001', 'equal', '2026-01-11', :'a'::uuid, null),
  ('a2000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000001', 'Hotel night', 5600, 'INR', 'a1000000-0000-4000-8000-000000000001', 'equal', '2026-01-12', :'a'::uuid, 'Paid in cash'),
  ('a2000000-0000-4000-8000-000000000004', 'a0000000-0000-4000-8000-000000000002', 'Electricity bill', 3100, 'INR', 'a1000000-0000-4000-8000-000000000002', 'equal', '2026-02-01', :'a'::uuid, null),
  ('a2000000-0000-4000-8000-000000000005', 'a0000000-0000-4000-8000-000000000002', 'Groceries', 1875.25, 'INR', 'a1000000-0000-4000-8000-000000000002', 'equal', '2026-02-05', :'a'::uuid, 'Paid in cash'),
  ('a2000000-0000-4000-8000-000000000006', 'a0000000-0000-4000-8000-000000000002', 'Wi-Fi', 999, 'INR', 'a1000000-0000-4000-8000-000000000002', 'equal', '2026-02-07', :'a'::uuid, null),
  ('a2000000-0000-4000-8000-000000000007', 'a0000000-0000-4000-8000-000000000003', 'Team pizza', 64.9, 'USD', 'a1000000-0000-4000-8000-000000000003', 'equal', '2026-03-03', :'a'::uuid, 'Paid in cash'),
  ('a2000000-0000-4000-8000-000000000008', 'a0000000-0000-4000-8000-000000000003', 'Coffee run', 18.4, 'USD', 'a1000000-0000-4000-8000-000000000003', 'equal', '2026-03-04', :'a'::uuid, null),
  ('a2000000-0000-4000-8000-000000000009', 'a0000000-0000-4000-8000-000000000003', 'Birthday cake', 32, 'USD', 'a1000000-0000-4000-8000-000000000003', 'equal', '2026-03-06', :'a'::uuid, 'Paid in cash');

insert into public.expense_splits (expense_id, member_id, amount_owed)
select e.id, e.paid_by, e.amount from public.expenses e where e.created_by = :'a'::uuid;

insert into public.groups (id, name, created_by, currency, created_at) values
  ('b0000000-0000-4000-8000-000000000001', 'Groupe MARQUEUR-B-9B22B478', :'b'::uuid, 'INR', '2026-01-10 10:00+00'),
  ('b0000000-0000-4000-8000-000000000002', 'Groupe MARQUEUR-B-66C626FF', :'b'::uuid, 'INR', '2026-01-11 10:00+00');

insert into public.group_members (id, group_id, user_id, display_name, role) values
  ('b1000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', :'b'::uuid, 'Nom MARQUEUR-B-4F00D158', 'owner'),
  ('b1000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000001', null, 'Invité MARQUEUR-B-7AC1E7CE', 'member'),
  ('b1000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000001', null, 'Invité MARQUEUR-B-F3149F16', 'member'),
  ('b1000000-0000-4000-8000-000000000004', 'b0000000-0000-4000-8000-000000000002', :'b'::uuid, 'Nom MARQUEUR-B-6467F2AB', 'owner'),
  ('b1000000-0000-4000-8000-000000000005', 'b0000000-0000-4000-8000-000000000002', null, 'Invité MARQUEUR-B-83044C2E', 'member');

insert into public.expenses (id, group_id, description, amount, currency, paid_by, split_type, spent_at, created_by, notes) values
  ('b2000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'Dépense MARQUEUR-B-CB2C00BA', 111.5, 'INR', 'b1000000-0000-4000-8000-000000000001', 'equal', '2026-02-10', :'b'::uuid, 'Note MARQUEUR-B-C55BA991'),
  ('b2000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000001', 'Dépense MARQUEUR-B-3445B580', 222.5, 'INR', 'b1000000-0000-4000-8000-000000000002', 'equal', '2026-02-11', :'b'::uuid, 'Note MARQUEUR-B-8A32FB70'),
  ('b2000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000001', 'Dépense MARQUEUR-B-83230522', 333.5, 'INR', 'b1000000-0000-4000-8000-000000000003', 'equal', '2026-02-12', :'b'::uuid, 'Note MARQUEUR-B-130D2AC5'),
  ('b2000000-0000-4000-8000-000000000004', 'b0000000-0000-4000-8000-000000000002', 'Dépense MARQUEUR-B-80FB2CC5', 444.5, 'INR', 'b1000000-0000-4000-8000-000000000004', 'equal', '2026-02-13', :'b'::uuid, 'Note MARQUEUR-B-EC84C255'),
  ('b2000000-0000-4000-8000-000000000005', 'b0000000-0000-4000-8000-000000000002', 'Dépense MARQUEUR-B-DA472C14', 555.5, 'INR', 'b1000000-0000-4000-8000-000000000004', 'equal', '2026-02-14', :'b'::uuid, 'Note MARQUEUR-B-658D76D1');

insert into public.expense_splits (expense_id, member_id, amount_owed)
select e.id, e.paid_by, e.amount from public.expenses e where e.created_by = :'b'::uuid;

insert into public.settlements (group_id, from_member, to_member, amount, settled_at, note) values
  ('b0000000-0000-4000-8000-000000000001', 'b1000000-0000-4000-8000-000000000002', 'b1000000-0000-4000-8000-000000000001', 50, '2026-02-20', 'Règlement MARQUEUR-B-FB939B04'),
  ('b0000000-0000-4000-8000-000000000002', 'b1000000-0000-4000-8000-000000000005', 'b1000000-0000-4000-8000-000000000004', 75, '2026-02-21', 'Règlement MARQUEUR-B-F1B9F51B');

commit;
