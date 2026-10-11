-- Graine « budget_web_app » (suivi de budget, Next.js + Supabase). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 1 profil, 3 comptes, 22 catégories (17 par défaut + 5), 12 transactions, 4 budgets, 3 charges fixes, 2 objectifs,
-- 3 règles d'import, 3 espaces, 3 adhésions, 3 invitations, 3 dépenses partagées, 2 remboursements.
-- B : mêmes tables, d'autres nombres ; chaque texte libre de B porte un marqueur unique.
-- A et B ne partagent aucun espace. Deux comptes de service (c, d) sont co-membres des espaces partagés le temps de
-- poser les remboursements et les parts, puis quittent ces espaces : ainsi A (ou B) ne voit que ses propres lignes.
-- Aucune ligne supprimée (deleted_at reste nul). Le déclencheur d'inscription a déjà créé, pour chaque compte, le profil,
-- l'espace « Personnel », son adhésion et 17 catégories par défaut ; la graine les complète.
\set ON_ERROR_STOP on
begin;

select public.personal_space_id(:'a'::uuid) as sa, public.personal_space_id(:'b'::uuid) as sb \gset

-- Comptes de service : co-membres temporaires (leurs profils et espaces perso ne sont visibles ni de A ni de B).
insert into auth.users (id, email) values
  ('c0000000-0000-4000-8000-000000000001', 'service-c@example.test'),
  ('d0000000-0000-4000-8000-000000000001', 'service-d@example.test');

-- profiles
update public.profiles set full_name = 'Alice Martin' where id = :'a'::uuid;
update public.profiles set full_name = 'Bruno MARQUEUR-B-32D85FB9' where id = :'b'::uuid;

-- spaces / space_members
update public.spaces set name = 'Perso MARQUEUR-B-3B5257A4' where id = :'sb'::uuid;
insert into public.spaces (id, name, kind, created_by, default_share_percent) values
  ('50000000-0000-4000-8000-000000000001', 'Vacances Corse', 'shared', :'a'::uuid, 50),
  ('50000000-0000-4000-8000-000000000002', 'Colocation Lyon', 'shared', :'a'::uuid, 50),
  ('50000000-0000-4000-8000-000000000003', 'Voyage MARQUEUR-B-AAE592CD', 'shared', :'b'::uuid, 50);
insert into public.space_members (space_id, user_id, role) values
  ('50000000-0000-4000-8000-000000000001', :'a'::uuid, 'owner'), ('50000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000001', 'member'),
  ('50000000-0000-4000-8000-000000000002', :'a'::uuid, 'owner'), ('50000000-0000-4000-8000-000000000002', 'c0000000-0000-4000-8000-000000000001', 'member'),
  ('50000000-0000-4000-8000-000000000003', :'b'::uuid, 'owner'), ('50000000-0000-4000-8000-000000000003', 'd0000000-0000-4000-8000-000000000001', 'member');

-- accounts
insert into public.accounts (id, space_id, user_id, name, type, initial_balance_cents, bank) values
  ('a0000000-0000-4000-8000-000000000001', :'sa'::uuid, :'a'::uuid, 'Compte courant', 'courant', 120000, 'BNP Paribas'),
  ('a0000000-0000-4000-8000-000000000002', :'sa'::uuid, :'a'::uuid, 'Livret A', 'livret', 350000, 'Crédit Agricole'),
  ('a0000000-0000-4000-8000-000000000003', :'sa'::uuid, :'a'::uuid, 'PEL', 'PEL', 1000000, 'Crédit Agricole'),
  ('b0000000-0000-4000-8000-000000000001', :'sb'::uuid, :'b'::uuid, 'Compte MARQUEUR-B-80BAD842', 'courant', 80000, 'Banque MARQUEUR-B-A3BE66F2'),
  ('b0000000-0000-4000-8000-000000000002', :'sb'::uuid, :'b'::uuid, 'Épargne MARQUEUR-B-3A9E8481', 'épargne', 150000, 'Banque MARQUEUR-B-ABC532D5'),
  ('b0000000-0000-4000-8000-000000000003', :'sb'::uuid, :'b'::uuid, 'Compte MARQUEUR-B-4A0340FE', 'autre', 20000, 'Banque MARQUEUR-B-36F30AB9');

-- categories (B : on retire les catégories par défaut, sans texte marqué, pour que tout texte libre de B porte un marqueur)
delete from public.categories where user_id = :'b'::uuid and is_default;
insert into public.categories (id, space_id, user_id, name, kind, color, icon) values
  ('70000000-0000-4000-8000-000000000001', :'sa'::uuid, :'a'::uuid, 'Animaux', 'expense', '#10b981', '🏷️'),
  ('70000000-0000-4000-8000-000000000002', :'sa'::uuid, :'a'::uuid, 'Sport', 'expense', '#10b981', '🏷️'),
  ('70000000-0000-4000-8000-000000000003', :'sa'::uuid, :'a'::uuid, 'Dons', 'expense', '#10b981', '🏷️'),
  ('70000000-0000-4000-8000-000000000004', '50000000-0000-4000-8000-000000000001', :'a'::uuid, 'Hébergement', 'expense', '#10b981', '🏷️'),
  ('70000000-0000-4000-8000-000000000005', '50000000-0000-4000-8000-000000000002', :'a'::uuid, 'Courses communes', 'expense', '#10b981', '🏷️'),
  ('80000000-0000-4000-8000-000000000001', :'sb'::uuid, :'b'::uuid, 'Jardin MARQUEUR-B-907F59A3', 'expense', '#10b981', '🏷️'),
  ('80000000-0000-4000-8000-000000000002', :'sb'::uuid, :'b'::uuid, 'Bricolage MARQUEUR-B-F1170E48', 'expense', '#10b981', '🏷️'),
  ('80000000-0000-4000-8000-000000000003', :'sb'::uuid, :'b'::uuid, 'Primes MARQUEUR-B-5230C060', 'income', '#10b981', '🏷️'),
  ('80000000-0000-4000-8000-000000000004', '50000000-0000-4000-8000-000000000003', :'b'::uuid, 'Activités MARQUEUR-B-580D490C', 'expense', '#10b981', '🏷️');

-- transactions
insert into public.transactions (id, space_id, user_id, account_id, category_id, transfer_id, kind, amount_cents, date, description, notes) values
  ('90000000-0000-4000-8000-000000000001', :'sa'::uuid, :'a'::uuid, 'a0000000-0000-4000-8000-000000000001', (select id from public.categories where space_id = :'sa'::uuid and name = 'Salaire' and kind = 'income'), null, 'income', 250000, '2026-08-28', 'Salaire août', 'Virement employeur'),
  ('90000000-0000-4000-8000-000000000002', :'sa'::uuid, :'a'::uuid, 'a0000000-0000-4000-8000-000000000001', (select id from public.categories where space_id = :'sa'::uuid and name = 'Logement' and kind = 'expense'), null, 'expense', -85000, '2026-09-01', 'Loyer septembre', 'Prélèvement'),
  ('90000000-0000-4000-8000-000000000003', :'sa'::uuid, :'a'::uuid, 'a0000000-0000-4000-8000-000000000001', (select id from public.categories where space_id = :'sa'::uuid and name = 'Alimentation' and kind = 'expense'), null, 'expense', -6420, '2026-09-03', 'Courses Carrefour', 'Courses de la semaine'),
  ('90000000-0000-4000-8000-000000000004', :'sa'::uuid, :'a'::uuid, 'a0000000-0000-4000-8000-000000000001', (select id from public.categories where space_id = :'sa'::uuid and name = 'Restaurants' and kind = 'expense'), null, 'expense', -3850, '2026-09-05', 'Restaurant avec Camille', 'Anniversaire'),
  ('90000000-0000-4000-8000-000000000005', :'sa'::uuid, :'a'::uuid, 'a0000000-0000-4000-8000-000000000001', (select id from public.categories where space_id = :'sa'::uuid and name = 'Abonnements' and kind = 'expense'), null, 'expense', -1299, '2026-09-06', 'Abonnement streaming', 'Mensuel'),
  ('90000000-0000-4000-8000-000000000006', :'sa'::uuid, :'a'::uuid, 'a0000000-0000-4000-8000-000000000001', (select id from public.categories where space_id = :'sa'::uuid and name = 'Transport' and kind = 'expense'), null, 'expense', -5210, '2026-09-08', 'Plein d''essence', 'Station Total'),
  ('90000000-0000-4000-8000-000000000007', :'sa'::uuid, :'a'::uuid, 'a0000000-0000-4000-8000-000000000001', (select id from public.categories where space_id = :'sa'::uuid and name = 'Santé' and kind = 'expense'), null, 'expense', -1840, '2026-09-10', 'Pharmacie', 'Ordonnance'),
  ('90000000-0000-4000-8000-000000000008', :'sa'::uuid, :'a'::uuid, 'a0000000-0000-4000-8000-000000000001', (select id from public.categories where space_id = :'sa'::uuid and name = 'Freelance' and kind = 'income'), null, 'income', 45000, '2026-09-12', 'Mission freelance', 'Facture 2026-014'),
  ('90000000-0000-4000-8000-000000000009', :'sa'::uuid, :'a'::uuid, 'a0000000-0000-4000-8000-000000000001', (select id from public.categories where space_id = :'sa'::uuid and name = 'Cadeaux' and kind = 'expense'), null, 'expense', -4500, '2026-09-14', 'Cadeau d''anniversaire', 'Pour Thomas'),
  ('90000000-0000-4000-8000-000000000010', :'sa'::uuid, :'a'::uuid, 'a0000000-0000-4000-8000-000000000001', (select id from public.categories where space_id = :'sa'::uuid and name = 'Virement interne' and kind = 'transfer'), 'f0000000-0000-4000-8000-000000000001', 'transfer_debit', -20000, '2026-09-15', 'Virement vers le livret', 'Épargne mensuelle'),
  ('90000000-0000-4000-8000-000000000011', :'sa'::uuid, :'a'::uuid, 'a0000000-0000-4000-8000-000000000002', (select id from public.categories where space_id = :'sa'::uuid and name = 'Virement interne' and kind = 'transfer'), 'f0000000-0000-4000-8000-000000000001', 'transfer_credit', 20000, '2026-09-15', 'Virement depuis le courant', 'Épargne mensuelle'),
  ('90000000-0000-4000-8000-000000000012', :'sa'::uuid, :'a'::uuid, 'a0000000-0000-4000-8000-000000000002', (select id from public.categories where space_id = :'sa'::uuid and name = 'Autre revenu' and kind = 'income'), null, 'income', 312, '2026-09-30', 'Intérêts du livret', 'Trimestre'),
  ('e0000000-0000-4000-8000-000000000001', :'sb'::uuid, :'b'::uuid, 'b0000000-0000-4000-8000-000000000001', null, null, 'income', 210000, '2026-08-29', 'Salaire MARQUEUR-B-014BD55C', 'Virement MARQUEUR-B-DE8086AA'),
  ('e0000000-0000-4000-8000-000000000002', :'sb'::uuid, :'b'::uuid, 'b0000000-0000-4000-8000-000000000001', null, null, 'expense', -72000, '2026-09-01', 'Loyer MARQUEUR-B-65502D9C', 'Prélèvement MARQUEUR-B-BDCA6F1A'),
  ('e0000000-0000-4000-8000-000000000003', :'sb'::uuid, :'b'::uuid, 'b0000000-0000-4000-8000-000000000001', null, null, 'expense', -5400, '2026-09-04', 'Courses MARQUEUR-B-FF7E6705', 'Marché MARQUEUR-B-300AAE0D'),
  ('e0000000-0000-4000-8000-000000000004', :'sb'::uuid, :'b'::uuid, 'b0000000-0000-4000-8000-000000000001', null, null, 'expense', -2400, '2026-09-07', 'Cinéma MARQUEUR-B-F0663165', 'Sortie MARQUEUR-B-CB49FB8E'),
  ('e0000000-0000-4000-8000-000000000005', :'sb'::uuid, :'b'::uuid, 'b0000000-0000-4000-8000-000000000001', null, 'f0000000-0000-4000-8000-000000000002', 'transfer_debit', -15000, '2026-09-12', 'Virement épargne MARQUEUR-B-F5D6C96C', 'Mensuel MARQUEUR-B-11008FB6'),
  ('e0000000-0000-4000-8000-000000000006', :'sb'::uuid, :'b'::uuid, 'b0000000-0000-4000-8000-000000000002', null, 'f0000000-0000-4000-8000-000000000002', 'transfer_credit', 15000, '2026-09-12', 'Virement épargne reçu MARQUEUR-B-1CD13E09', 'Mensuel MARQUEUR-B-CB8E67C0'),
  ('e0000000-0000-4000-8000-000000000007', :'sb'::uuid, :'b'::uuid, 'b0000000-0000-4000-8000-000000000001', null, null, 'income', 3500, '2026-09-20', 'Remboursement mutuelle MARQUEUR-B-A0609616', 'Soins MARQUEUR-B-4733DB95');

-- budgets
insert into public.budgets (space_id, user_id, category_id, month, amount_cents) values
  (:'sa'::uuid, :'a'::uuid, (select id from public.categories where space_id = :'sa'::uuid and name = 'Alimentation' and kind = 'expense'), '2026-09-01', 40000),
  (:'sa'::uuid, :'a'::uuid, (select id from public.categories where space_id = :'sa'::uuid and name = 'Restaurants' and kind = 'expense'), '2026-09-01', 15000),
  (:'sa'::uuid, :'a'::uuid, (select id from public.categories where space_id = :'sa'::uuid and name = 'Transport' and kind = 'expense'), '2026-09-01', 12000),
  (:'sa'::uuid, :'a'::uuid, (select id from public.categories where space_id = :'sa'::uuid and name = 'Loisirs' and kind = 'expense'), '2026-09-01', 8000),
  (:'sb'::uuid, :'b'::uuid, '80000000-0000-4000-8000-000000000001', '2026-09-01', 5000),
  (:'sb'::uuid, :'b'::uuid, '80000000-0000-4000-8000-000000000002', '2026-09-01', 9000),
  (:'sb'::uuid, :'b'::uuid, '80000000-0000-4000-8000-000000000001', '2026-10-01', 6000);

-- fixed_charges
insert into public.fixed_charges (space_id, user_id, name, amount_cents, frequency, next_due_date, account_id, category_id, notes, status) values
  (:'sa'::uuid, :'a'::uuid, 'Loyer', 85000, 'monthly', '2026-10-01', 'a0000000-0000-4000-8000-000000000001', (select id from public.categories where space_id = :'sa'::uuid and name = 'Logement' and kind = 'expense'), 'Prélevé le 1er', 'active'),
  (:'sa'::uuid, :'a'::uuid, 'Assurance habitation', 28000, 'yearly', '2027-01-15', 'a0000000-0000-4000-8000-000000000001', (select id from public.categories where space_id = :'sa'::uuid and name = 'Logement' and kind = 'expense'), 'Contrat MAIF', 'active'),
  (:'sa'::uuid, :'a'::uuid, 'Streaming', 1299, 'monthly', '2026-10-06', 'a0000000-0000-4000-8000-000000000001', (select id from public.categories where space_id = :'sa'::uuid and name = 'Abonnements' and kind = 'expense'), 'À résilier un jour', 'suspended'),
  (:'sb'::uuid, :'b'::uuid, 'Loyer MARQUEUR-B-0F3C2591', 72000, 'monthly', '2026-10-01', 'b0000000-0000-4000-8000-000000000001', null, 'Note MARQUEUR-B-0BF5B3A5', 'active'),
  (:'sb'::uuid, :'b'::uuid, 'Assurance MARQUEUR-B-D1143106', 9000, 'quarterly', '2026-12-01', 'b0000000-0000-4000-8000-000000000001', null, 'Note MARQUEUR-B-98AA9482', 'active');

-- savings_goals
insert into public.savings_goals (space_id, user_id, name, target_amount_cents, current_amount_cents, deadline, linked_category_id) values
  (:'sa'::uuid, :'a'::uuid, 'Voyage au Japon', 400000, 120000, '2027-04-01', null),
  (:'sa'::uuid, :'a'::uuid, 'Fonds d''urgence', 300000, 200000, null, null),
  (:'sb'::uuid, :'b'::uuid, 'Vélo MARQUEUR-B-74065F0F', 150000, 30000, '2027-03-01', null),
  (:'sb'::uuid, :'b'::uuid, 'Cuisine MARQUEUR-B-41EE2B1C', 900000, 100000, null, '80000000-0000-4000-8000-000000000002');

-- csv_import_rules
insert into public.csv_import_rules (space_id, user_id, keyword, category_id, kind, priority) values
  (:'sa'::uuid, :'a'::uuid, 'CARREFOUR', (select id from public.categories where space_id = :'sa'::uuid and name = 'Alimentation' and kind = 'expense'), 'expense', 0),
  (:'sa'::uuid, :'a'::uuid, 'TOTAL ENERGIES', (select id from public.categories where space_id = :'sa'::uuid and name = 'Transport' and kind = 'expense'), 'expense', 1),
  (:'sa'::uuid, :'a'::uuid, 'VIREMENT SALAIRE', (select id from public.categories where space_id = :'sa'::uuid and name = 'Salaire' and kind = 'income'), 'income', 2),
  (:'sb'::uuid, :'b'::uuid, 'LECLERC MARQUEUR-B-43BF97E6', null, 'expense', 0),
  (:'sb'::uuid, :'b'::uuid, 'PAIE MARQUEUR-B-48883944', null, 'income', 1);

-- invitations (acceptée par un compte de service, jamais par A ni B)
insert into public.invitations (space_id, inviter_user_id, accepted_by_user_id, invitee_email, token, status, accepted_at) values
  ('50000000-0000-4000-8000-000000000001', :'a'::uuid, null, 'camille@example.test', 'jeton-a-0001', 'pending', null),
  ('50000000-0000-4000-8000-000000000001', :'a'::uuid, 'c0000000-0000-4000-8000-000000000001', 'service-c@example.test', 'jeton-a-0002', 'accepted', '2026-09-02'),
  ('50000000-0000-4000-8000-000000000002', :'a'::uuid, null, 'sam@example.test', 'jeton-a-0003', 'revoked', null),
  ('50000000-0000-4000-8000-000000000003', :'b'::uuid, null, 'MARQUEUR-B-9FD8AFE4@example.test', 'jeton-MARQUEUR-B-0A15055E', 'pending', null),
  ('50000000-0000-4000-8000-000000000003', :'b'::uuid, 'd0000000-0000-4000-8000-000000000001', 'MARQUEUR-B-13631BAA@example.test', 'jeton-MARQUEUR-B-C5084261', 'accepted', '2026-09-03');

-- shared_expenses (montant, date et libellé sont recopiés de la transaction source par le déclencheur)
insert into public.shared_expenses (space_id, source_transaction_id, paid_by, category_id, shares) values
  ('50000000-0000-4000-8000-000000000001', '90000000-0000-4000-8000-000000000004', :'a'::uuid, '70000000-0000-4000-8000-000000000004', jsonb_build_object(:'a'::text, 60, 'c0000000-0000-4000-8000-000000000001'::text, 40)),
  ('50000000-0000-4000-8000-000000000001', '90000000-0000-4000-8000-000000000003', :'a'::uuid, '70000000-0000-4000-8000-000000000004', jsonb_build_object(:'a'::text, 50, 'c0000000-0000-4000-8000-000000000001'::text, 50)),
  ('50000000-0000-4000-8000-000000000002', '90000000-0000-4000-8000-000000000009', :'a'::uuid, '70000000-0000-4000-8000-000000000005', jsonb_build_object(:'a'::text, 50, 'c0000000-0000-4000-8000-000000000001'::text, 50)),
  ('50000000-0000-4000-8000-000000000003', 'e0000000-0000-4000-8000-000000000003', :'b'::uuid, '80000000-0000-4000-8000-000000000004', jsonb_build_object(:'b'::text, 50, 'd0000000-0000-4000-8000-000000000001'::text, 50)),
  ('50000000-0000-4000-8000-000000000003', 'e0000000-0000-4000-8000-000000000004', :'b'::uuid, '80000000-0000-4000-8000-000000000004', jsonb_build_object(:'b'::text, 70, 'd0000000-0000-4000-8000-000000000001'::text, 30));

-- settlements
insert into public.settlements (space_id, from_user, to_user, amount_cents, date, created_by) values
  ('50000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000001', :'a'::uuid, 4000, '2026-09-20', :'a'::uuid),
  ('50000000-0000-4000-8000-000000000002', :'a'::uuid, 'c0000000-0000-4000-8000-000000000001', 1500, '2026-09-22', :'a'::uuid),
  ('50000000-0000-4000-8000-000000000003', 'd0000000-0000-4000-8000-000000000001', :'b'::uuid, 2500, '2026-09-21', :'b'::uuid);

-- Les comptes de service quittent les espaces partagés : A et B n'ont plus aucun co-membre.
delete from public.space_members where user_id in ('c0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000001') and space_id in ('50000000-0000-4000-8000-000000000001', '50000000-0000-4000-8000-000000000002', '50000000-0000-4000-8000-000000000003');

commit;
