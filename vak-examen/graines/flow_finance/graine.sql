-- Graine « flow_finance » (suivi de finances personnelles). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 2 espaces, 3 comptes bancaires, 2 connexions bancaires, 6 catégories, 5 paiements récurrents, 4 suggestions écartées,
--     3 livrets, 5 ajustements, 2 objectifs d'épargne, 3 affectations, 4 titres PEA, 2 plans PEA, 7 opérations PEA,
--     3 cryptomonnaies, 6 transactions crypto, 1 profil, 1 réglage PEA, 1 réglage crypto (+ 8 transactions bancaires).
-- B : d'autres lignes, chaque texte libre porte un marqueur unique. Les profils de A et B existent déjà (déclencheur sur auth.users).
\set ON_ERROR_STOP on
begin;

-- Profils : créés par le déclencheur sur auth.users ; on les garantit, puis B reçoit des réglages marqués.
insert into public.profiles (id, locale, currency) values (:'a'::uuid, 'fr', 'EUR'), (:'b'::uuid, 'fr', 'EUR')
  on conflict (id) do nothing;
update public.profiles set settings = jsonb_build_object(
  'payroll', jsonb_build_object('keyword', 'MARQUEUR-B-95627431', 'budgetShiftMonths', 1),
  'trackedOutgoingPeople', jsonb_build_array(jsonb_build_object('id', 'p1', 'label', 'MARQUEUR-B-0E52D615', 'keyword', 'MARQUEUR-B-7045AFBF'))
) where id = :'b'::uuid;

-- Espaces
insert into public.spaces (id, user_id, name, kind, color, position) values
  ('a1000000-0000-4000-8000-000000000001', :'a'::uuid, 'Perso', 'personal', '#0F172A', 0),
  ('a1000000-0000-4000-8000-000000000002', :'a'::uuid, 'Foyer', 'shared', '#CA8A04', 1),
  ('b1000000-0000-4000-8000-000000000001', :'b'::uuid, 'Espace MARQUEUR-B-BB2A6962', 'personal', '#0F172A', 0),
  ('b1000000-0000-4000-8000-000000000002', :'b'::uuid, 'Espace MARQUEUR-B-481E9632', 'shared', '#CA8A04', 1),
  ('b1000000-0000-4000-8000-000000000003', :'b'::uuid, 'Espace MARQUEUR-B-CDE2480E', 'shared', '#1E3A8A', 2);

-- Connexions bancaires
insert into public.bank_connections (id, user_id, provider, session_id, aspsp_name, valid_until, status) values
  ('a2000000-0000-4000-8000-000000000001', :'a'::uuid, 'enable_banking', 'session-a-001', 'Boursorama', '2027-03-01', 'active'),
  ('a2000000-0000-4000-8000-000000000002', :'a'::uuid, 'enable_banking', 'session-a-002', 'Crédit Agricole', '2027-04-15', 'active'),
  ('b2000000-0000-4000-8000-000000000001', :'b'::uuid, 'enable_banking', 'session-MARQUEUR-B-9999FFEB', 'Banque MARQUEUR-B-44DB47E3', '2027-02-01', 'active'),
  ('b2000000-0000-4000-8000-000000000002', :'b'::uuid, 'enable_banking', 'session-MARQUEUR-B-21637288', 'Banque MARQUEUR-B-979FCA51', '2026-01-01', 'expired'),
  ('b2000000-0000-4000-8000-000000000003', :'b'::uuid, 'enable_banking', 'session-MARQUEUR-B-85D8D4A9', 'Banque MARQUEUR-B-E5A74C83', '2027-05-01', 'pending');

-- Comptes bancaires (tous de type checking pour que « comptes bancaires » ne se confonde pas avec les livrets)
insert into public.accounts (id, user_id, connection_id, external_uid, name, iban, type, balance, base_balance, space_id, display_name) values
  ('a3000000-0000-4000-8000-000000000001', :'a'::uuid, 'a2000000-0000-4000-8000-000000000001', 'ext-a-1', 'Compte courant', 'FR7612345000010000000000101', 'checking', 1520.40, 1000, 'a1000000-0000-4000-8000-000000000001', 'Courant perso'),
  ('a3000000-0000-4000-8000-000000000002', :'a'::uuid, 'a2000000-0000-4000-8000-000000000002', 'ext-a-2', 'Compte joint', 'FR7612345000010000000000102', 'checking', 830.15, 500, 'a1000000-0000-4000-8000-000000000002', 'Joint foyer'),
  ('a3000000-0000-4000-8000-000000000003', :'a'::uuid, 'a2000000-0000-4000-8000-000000000001', 'ext-a-3', 'Compte secondaire', 'FR7612345000010000000000103', 'checking', 210.00, 200, 'a1000000-0000-4000-8000-000000000001', null),
  ('b3000000-0000-4000-8000-000000000001', :'b'::uuid, 'b2000000-0000-4000-8000-000000000001', 'ext-b-1', 'Compte MARQUEUR-B-44B3EE7F', 'FR76MARQUEUR-B-606CF995', 'checking', 9876.54, 100, 'b1000000-0000-4000-8000-000000000001', 'Nom MARQUEUR-B-78B6B4C2'),
  ('b3000000-0000-4000-8000-000000000002', :'b'::uuid, 'b2000000-0000-4000-8000-000000000001', 'ext-b-2', 'Compte MARQUEUR-B-7495F495', 'FR76MARQUEUR-B-2C4AF038', 'checking', 4321.00, 100, 'b1000000-0000-4000-8000-000000000002', 'Nom MARQUEUR-B-57D9C17C');

-- Catégories
insert into public.categories (id, user_id, name, color, keyword_rules) values
  ('a4000000-0000-4000-8000-000000000001', :'a'::uuid, 'Courses', '#16A34A', '{CARREFOUR,LECLERC}'),
  ('a4000000-0000-4000-8000-000000000002', :'a'::uuid, 'Loyer', '#1E3A8A', '{LOYER}'),
  ('a4000000-0000-4000-8000-000000000003', :'a'::uuid, 'Transports', '#CA8A04', '{SNCF,NAVIGO}'),
  ('a4000000-0000-4000-8000-000000000004', :'a'::uuid, 'Restaurants', '#DC2626', '{RESTO}'),
  ('a4000000-0000-4000-8000-000000000005', :'a'::uuid, 'Santé', '#0891B2', '{PHARMACIE}'),
  ('a4000000-0000-4000-8000-000000000006', :'a'::uuid, 'Loisirs', '#9333EA', '{CINEMA}'),
  ('b4000000-0000-4000-8000-000000000001', :'b'::uuid, 'Cat MARQUEUR-B-677F0895', '#16A34A', '{KW-MARQUEUR-B-BF649DCC}'),
  ('b4000000-0000-4000-8000-000000000002', :'b'::uuid, 'Cat MARQUEUR-B-7A1864CC', '#1E3A8A', '{KW-MARQUEUR-B-63A6617E}'),
  ('b4000000-0000-4000-8000-000000000003', :'b'::uuid, 'Cat MARQUEUR-B-C7FA7004', '#CA8A04', '{KW-MARQUEUR-B-380C2A77}'),
  ('b4000000-0000-4000-8000-000000000004', :'b'::uuid, 'Cat MARQUEUR-B-EB59727A', '#DC2626', '{KW-MARQUEUR-B-9B5E296A}');

-- Paiements récurrents (aucun fusionné ni terminé : « mes paiements récurrents » = toutes les lignes)
insert into public.recurring_payments (id, user_id, name, amount, amount_tolerance, description_pattern, billing_day, cadence, billing_month, space_id) values
  ('a5000000-0000-4000-8000-000000000001', :'a'::uuid, 'Netflix', 13.49, 0.05, 'NETFLIX', 5, 'monthly', null, 'a1000000-0000-4000-8000-000000000001'),
  ('a5000000-0000-4000-8000-000000000002', :'a'::uuid, 'Loyer', 850.00, 0.00, 'LOYER', 1, 'monthly', null, 'a1000000-0000-4000-8000-000000000002'),
  ('a5000000-0000-4000-8000-000000000003', :'a'::uuid, 'Assurance habitation', 240.00, 0.00, 'MAIF', 15, 'yearly', 3, 'a1000000-0000-4000-8000-000000000002'),
  ('a5000000-0000-4000-8000-000000000004', :'a'::uuid, 'Électricité', 62.30, 5.00, 'EDF', 10, 'monthly', null, 'a1000000-0000-4000-8000-000000000002'),
  ('a5000000-0000-4000-8000-000000000005', :'a'::uuid, 'Taxe ordures', 120.00, 0.00, 'TAXE', 20, 'semiannual', 4, null),
  ('b5000000-0000-4000-8000-000000000001', :'b'::uuid, 'Abo MARQUEUR-B-56D5400E', 9.99, 0.05, 'DESC-MARQUEUR-B-97C4D62B', 3, 'monthly', null, 'b1000000-0000-4000-8000-000000000001'),
  ('b5000000-0000-4000-8000-000000000002', :'b'::uuid, 'Abo MARQUEUR-B-2F5284F2', 19.99, 0.05, 'DESC-MARQUEUR-B-5E77729B', 8, 'monthly', null, null),
  ('b5000000-0000-4000-8000-000000000003', :'b'::uuid, 'Abo MARQUEUR-B-7CA0E616', 99.00, 0.05, 'DESC-MARQUEUR-B-3020FE1C', 12, 'yearly', 6, null);

-- Suggestions de paiements récurrents écartées
insert into public.recurring_suggestion_dismissals (user_id, cluster_key, source, amount, billing_day, billing_month, cadence, description_pattern) values
  (:'a'::uuid, 'general:spotify:10', 'general', 10.99, 10, null, 'monthly', 'SPOTIFY'),
  (:'a'::uuid, 'general:deezer:12', 'general', 11.99, 12, null, 'monthly', 'DEEZER'),
  (:'a'::uuid, 'paypal:steam:20', 'paypal', 24.99, 20, null, 'monthly', 'PAYPAL STEAM'),
  (:'a'::uuid, 'general:amazon:5', 'general', 49.00, 5, 7, 'yearly', 'AMAZON PRIME'),
  (:'b'::uuid, 'general:MARQUEUR-B-E18D9C9C', 'general', 7.00, 7, null, 'monthly', 'PAT-MARQUEUR-B-8F0807B3'),
  (:'b'::uuid, 'paypal:MARQUEUR-B-7C46BF60', 'paypal', 8.00, 8, null, 'monthly', 'PAT-MARQUEUR-B-D5B36EAB'),
  (:'b'::uuid, 'general:MARQUEUR-B-C376DAA2', 'general', 9.00, 9, null, 'monthly', 'PAT-MARQUEUR-B-686662A0');

-- Livrets d'épargne
insert into public.savings_accounts (id, user_id, name, kind, color, base_balance, base_date, interest_rate, ceiling, opening_date, deposit_keywords, withdrawal_keywords) values
  ('a6000000-0000-4000-8000-000000000001', :'a'::uuid, 'Livret A', 'livret_a', '#1E3A8A', 5000, '2026-01-01', 1.700, 22950, '2018-05-01', '{VIR LIVRET A}', '{RETRAIT LIVRET A}'),
  ('a6000000-0000-4000-8000-000000000002', :'a'::uuid, 'LDDS', 'ldd', '#16A34A', 2500, '2026-01-01', 1.700, 12000, '2019-02-01', '{VIR LDDS}', '{}'),
  ('a6000000-0000-4000-8000-000000000003', :'a'::uuid, 'PEL', 'pel', '#CA8A04', 8000, '2026-01-01', 2.000, 61200, '2020-09-01', '{VIR PEL}', '{}'),
  ('b6000000-0000-4000-8000-000000000001', :'b'::uuid, 'Livret MARQUEUR-B-2EA656DC', 'livret_a', '#1E3A8A', 111, '2026-01-01', 1.700, 22950, '2018-05-01', '{DEP-MARQUEUR-B-4E62833D}', '{RET-MARQUEUR-B-65DE85B2}'),
  ('b6000000-0000-4000-8000-000000000002', :'b'::uuid, 'Livret MARQUEUR-B-5CEFFFBE', 'lep', '#16A34A', 222, '2026-01-01', 2.700, 10000, '2019-02-01', '{DEP-MARQUEUR-B-1B4F8C33}', '{}');

-- Ajustements d'épargne
insert into public.savings_adjustments (user_id, savings_account_id, kind, amount, adjustment_date, note) values
  (:'a'::uuid, 'a6000000-0000-4000-8000-000000000001', 'interest', 85.00, '2026-01-01', 'Intérêts 2025'),
  (:'a'::uuid, 'a6000000-0000-4000-8000-000000000001', 'cash', 200.00, '2026-03-04', 'Espèces déposées'),
  (:'a'::uuid, 'a6000000-0000-4000-8000-000000000002', 'interest', 42.50, '2026-01-01', 'Intérêts 2025'),
  (:'a'::uuid, 'a6000000-0000-4000-8000-000000000002', 'check', 150.00, '2026-05-12', 'Chèque de remboursement'),
  (:'a'::uuid, 'a6000000-0000-4000-8000-000000000003', 'interest', 160.00, '2026-01-01', 'Intérêts 2025'),
  (:'b'::uuid, 'b6000000-0000-4000-8000-000000000001', 'cash', 10.00, '2026-02-01', 'Note MARQUEUR-B-5EB6942C'),
  (:'b'::uuid, 'b6000000-0000-4000-8000-000000000001', 'check', 20.00, '2026-02-02', 'Note MARQUEUR-B-0DCD67B9'),
  (:'b'::uuid, 'b6000000-0000-4000-8000-000000000002', 'interest', 30.00, '2026-02-03', 'Note MARQUEUR-B-7C5A8B79'),
  (:'b'::uuid, 'b6000000-0000-4000-8000-000000000002', 'cash', 40.00, '2026-02-04', 'Note MARQUEUR-B-8255EF2C'),
  (:'b'::uuid, 'b6000000-0000-4000-8000-000000000002', 'check', 50.00, '2026-02-05', 'Note MARQUEUR-B-6D2BFD59'),
  (:'b'::uuid, 'b6000000-0000-4000-8000-000000000002', 'interest', 60.00, '2026-02-06', 'Note MARQUEUR-B-998B1765');

-- Objectifs d'épargne
insert into public.savings_goals (id, user_id, name, target_amount, target_date, color, note, position) values
  ('a7000000-0000-4000-8000-000000000001', :'a'::uuid, 'Vacances d''été', 3000, '2027-06-30', '#CA8A04', 'Voyage en famille', 0),
  ('a7000000-0000-4000-8000-000000000002', :'a'::uuid, 'Apport immobilier', 40000, '2030-01-01', '#1E3A8A', 'Achat de la résidence principale', 1),
  ('b7000000-0000-4000-8000-000000000001', :'b'::uuid, 'Objectif MARQUEUR-B-6A8DDBB4', 1000, '2027-01-01', '#CA8A04', 'Note MARQUEUR-B-B3A2E3F4', 0),
  ('b7000000-0000-4000-8000-000000000002', :'b'::uuid, 'Objectif MARQUEUR-B-1256ADE3', 2000, '2028-01-01', '#1E3A8A', 'Note MARQUEUR-B-79ACEC90', 1),
  ('b7000000-0000-4000-8000-000000000003', :'b'::uuid, 'Objectif MARQUEUR-B-9AEC6652', 3000, null, '#16A34A', 'Note MARQUEUR-B-09C2911B', 2),
  ('b7000000-0000-4000-8000-000000000004', :'b'::uuid, 'Objectif MARQUEUR-B-044F4301', 4000, null, '#DC2626', 'Note MARQUEUR-B-EA9ABCDB', 3);

-- Affectations aux objectifs (sans texte libre : pas de marqueur possible)
insert into public.savings_goal_allocations (user_id, goal_id, savings_account_id, amount, allocation_mode, source_kind) values
  (:'a'::uuid, 'a7000000-0000-4000-8000-000000000001', 'a6000000-0000-4000-8000-000000000001', 1500, 'fixed', 'savings'),
  (:'a'::uuid, 'a7000000-0000-4000-8000-000000000001', 'a6000000-0000-4000-8000-000000000002', 800, 'fixed', 'savings'),
  (:'a'::uuid, 'a7000000-0000-4000-8000-000000000002', null, 0, 'full', 'pea'),
  (:'b'::uuid, 'b7000000-0000-4000-8000-000000000001', 'b6000000-0000-4000-8000-000000000001', 55, 'fixed', 'savings'),
  (:'b'::uuid, 'b7000000-0000-4000-8000-000000000002', 'b6000000-0000-4000-8000-000000000002', 66, 'fixed', 'savings'),
  (:'b'::uuid, 'b7000000-0000-4000-8000-000000000003', 'b6000000-0000-4000-8000-000000000001', 77, 'fixed', 'savings'),
  (:'b'::uuid, 'b7000000-0000-4000-8000-000000000004', null, 0, 'full', 'pea');

-- PEA : titres
insert into public.pea_holdings (id, user_id, isin, ticker, name, quantity, cost_basis_eur, manual_price_eur) values
  ('a8000000-0000-4000-8000-000000000001', :'a'::uuid, 'IE00B4L5Y983', 'CW8', 'Amundi MSCI World', 12, 5400.00, 520.4000),
  ('a8000000-0000-4000-8000-000000000002', :'a'::uuid, 'FR0013412020', 'PAEEM', 'Amundi MSCI Emerging Markets', 40, 1000.00, 27.1000),
  ('a8000000-0000-4000-8000-000000000003', :'a'::uuid, 'FR0000120271', 'TTE', 'TotalEnergies', 25, 1400.00, 58.2000),
  ('a8000000-0000-4000-8000-000000000004', :'a'::uuid, 'FR0000120073', 'AI', 'Air Liquide', 8, 1200.00, 168.0000),
  ('b8000000-0000-4000-8000-000000000001', :'b'::uuid, 'IE00B4L5Y983', 'T-MARQUEUR-B-45C3BD43', 'Titre MARQUEUR-B-7BB9DF41', 3, 300.00, 100.0000),
  ('b8000000-0000-4000-8000-000000000002', :'b'::uuid, 'FR0013412020', 'T-MARQUEUR-B-813A3E1D', 'Titre MARQUEUR-B-43804588', 5, 400.00, 90.0000);

-- PEA : plans d'investissement
insert into public.pea_investment_plans (id, user_id, label, keywords, holding_id, expected_amount_eur, active) values
  ('a9000000-0000-4000-8000-000000000001', :'a'::uuid, 'Plan World mensuel', '{VIR PEA WORLD}', 'a8000000-0000-4000-8000-000000000001', 200, true),
  ('a9000000-0000-4000-8000-000000000002', :'a'::uuid, 'Plan Émergents', '{VIR PEA EM}', 'a8000000-0000-4000-8000-000000000002', 100, true),
  ('b9000000-0000-4000-8000-000000000001', :'b'::uuid, 'Plan MARQUEUR-B-F936EE1F', '{PLAN-MARQUEUR-B-9567D9A2}', 'b8000000-0000-4000-8000-000000000001', 50, true),
  ('b9000000-0000-4000-8000-000000000002', :'b'::uuid, 'Plan MARQUEUR-B-2D94B6F6', '{PLAN-MARQUEUR-B-DAA5C8DA}', null, 60, false),
  ('b9000000-0000-4000-8000-000000000003', :'b'::uuid, 'Plan MARQUEUR-B-C99A49E1', '{PLAN-MARQUEUR-B-48FDA596}', null, 70, true);

-- PEA : opérations
insert into public.pea_transactions (user_id, holding_id, kind, quantity, amount_eur, transaction_date, note, source, external_ref) values
  (:'a'::uuid, null, 'deposit', 0, 6000.00, '2025-01-10', 'Versement initial', 'manual', 'a-ref-1'),
  (:'a'::uuid, 'a8000000-0000-4000-8000-000000000001', 'buy', 10, 4500.00, '2025-01-15', 'Premier achat World', 'csv', 'a-ref-2'),
  (:'a'::uuid, 'a8000000-0000-4000-8000-000000000001', 'buy', 2, 900.00, '2025-06-15', 'Renforcement World', 'csv', 'a-ref-3'),
  (:'a'::uuid, 'a8000000-0000-4000-8000-000000000002', 'buy', 40, 1000.00, '2025-07-01', 'Achat émergents', 'csv', 'a-ref-4'),
  (:'a'::uuid, 'a8000000-0000-4000-8000-000000000003', 'dividend', 0, 35.00, '2025-09-20', 'Dividende Total', 'csv', 'a-ref-5'),
  (:'a'::uuid, 'a8000000-0000-4000-8000-000000000003', 'buy', 25, 1400.00, '2025-10-02', 'Achat Total', 'csv', 'a-ref-6'),
  (:'a'::uuid, null, 'fee', 0, 4.99, '2025-10-03', 'Frais de courtage', 'manual', 'a-ref-7'),
  (:'b'::uuid, null, 'deposit', 0, 111.00, '2025-02-10', 'Note MARQUEUR-B-177DB072', 'manual', 'ref-MARQUEUR-B-D083056E'),
  (:'b'::uuid, 'b8000000-0000-4000-8000-000000000001', 'buy', 3, 300.00, '2025-02-15', 'Note MARQUEUR-B-852D695E', 'csv', 'ref-MARQUEUR-B-FF16BE53'),
  (:'b'::uuid, 'b8000000-0000-4000-8000-000000000002', 'buy', 5, 400.00, '2025-03-15', 'Note MARQUEUR-B-88367CF0', 'csv', 'ref-MARQUEUR-B-CD1E209B'),
  (:'b'::uuid, 'b8000000-0000-4000-8000-000000000002', 'sell', 1, 95.00, '2025-04-15', 'Note MARQUEUR-B-C58C11FC', 'manual', 'ref-MARQUEUR-B-AAECC30C'),
  (:'b'::uuid, null, 'interest', 0, 1.50, '2025-05-15', 'Note MARQUEUR-B-53C992CA', 'manual', 'ref-MARQUEUR-B-B1FE1E7E');

-- PEA et crypto : réglages (une ligne par utilisateur, aucun texte libre)
insert into public.pea_settings (user_id, opening_date, cash_balance_eur) values
  (:'a'::uuid, '2025-01-10', 842.17),
  (:'b'::uuid, '2024-05-05', 4242.42);
insert into public.crypto_portfolio_settings (user_id, total_invested_eur) values
  (:'a'::uuid, 2500.00),
  (:'b'::uuid, 7777.00);

-- Crypto
insert into public.crypto_holdings (id, user_id, name, xpub, symbol, quantity, cost_basis_eur) values
  ('aa000000-0000-4000-8000-000000000001', :'a'::uuid, 'Bitcoin', null, 'BTC', 0.05000000, 1800.00),
  ('aa000000-0000-4000-8000-000000000002', :'a'::uuid, 'Ethereum', null, 'ETH', 0.80000000, 1500.00),
  ('aa000000-0000-4000-8000-000000000003', :'a'::uuid, 'Solana', null, 'SOL', 12.00000000, 900.00),
  ('ba000000-0000-4000-8000-000000000001', :'b'::uuid, 'Coin MARQUEUR-B-A09648B0', 'xpub-MARQUEUR-B-458DAC73', 'BTC', 1, 100.00),
  ('ba000000-0000-4000-8000-000000000002', :'b'::uuid, 'Coin MARQUEUR-B-60ECF6E8', null, 'ETH', 2, 200.00);

insert into public.crypto_transactions (user_id, holding_id, kind, quantity, amount_eur, transaction_date, note) values
  (:'a'::uuid, 'aa000000-0000-4000-8000-000000000001', 'buy', 0.03000000, 1000.00, '2025-03-01', 'Premier achat BTC'),
  (:'a'::uuid, 'aa000000-0000-4000-8000-000000000001', 'buy', 0.02000000, 800.00, '2025-08-01', 'Second achat BTC'),
  (:'a'::uuid, 'aa000000-0000-4000-8000-000000000002', 'buy', 0.80000000, 1500.00, '2025-04-10', 'Achat ETH'),
  (:'a'::uuid, 'aa000000-0000-4000-8000-000000000003', 'buy', 15.00000000, 1000.00, '2025-05-20', 'Achat SOL'),
  (:'a'::uuid, 'aa000000-0000-4000-8000-000000000003', 'sell', 3.00000000, 250.00, '2025-11-02', 'Vente partielle SOL'),
  (:'a'::uuid, 'aa000000-0000-4000-8000-000000000002', 'deposit', 0.00000000, 100.00, '2025-12-01', 'Dépôt de fonds'),
  (:'b'::uuid, 'ba000000-0000-4000-8000-000000000001', 'buy', 1, 100.00, '2025-03-02', 'Note MARQUEUR-B-84F0E282'),
  (:'b'::uuid, 'ba000000-0000-4000-8000-000000000002', 'buy', 2, 200.00, '2025-03-03', 'Note MARQUEUR-B-E6480DD8'),
  (:'b'::uuid, 'ba000000-0000-4000-8000-000000000002', 'sell', 1, 150.00, '2025-03-04', 'Note MARQUEUR-B-1B52DF52'),
  (:'b'::uuid, 'ba000000-0000-4000-8000-000000000001', 'withdrawal', 0, 10.00, '2025-03-05', 'Note MARQUEUR-B-3CD859DA');

-- Transactions bancaires (table sans colonne propriétaire : le propriétaire passe par le compte ; hors attendu.json)
insert into public.transactions (account_id, entry_reference, booking_date, amount, description, status, category_id, raw_json, note) values
  ('a3000000-0000-4000-8000-000000000001', 'a-tx-1', '2026-09-02', -54.30, 'CARTE CARREFOUR MARKET', 'BOOK', 'a4000000-0000-4000-8000-000000000001', null, null),
  ('a3000000-0000-4000-8000-000000000001', 'a-tx-2', '2026-09-03', -13.49, 'PRLV NETFLIX', 'BOOK', 'a4000000-0000-4000-8000-000000000006', null, null),
  ('a3000000-0000-4000-8000-000000000001', 'a-tx-3', '2026-09-05', 2100.00, 'VIR SALAIRE', 'BOOK', null, null, 'Salaire de septembre'),
  ('a3000000-0000-4000-8000-000000000002', 'a-tx-4', '2026-09-01', -850.00, 'PRLV LOYER', 'BOOK', 'a4000000-0000-4000-8000-000000000002', null, null),
  ('a3000000-0000-4000-8000-000000000002', 'a-tx-5', '2026-09-10', -62.30, 'PRLV EDF', 'BOOK', null, null, null),
  ('a3000000-0000-4000-8000-000000000003', 'a-tx-6', '2026-09-12', -28.00, 'RESTO LE PETIT BISTROT', 'BOOK', 'a4000000-0000-4000-8000-000000000004', null, null),
  ('a3000000-0000-4000-8000-000000000003', 'a-tx-7', '2026-09-14', -75.00, 'NAVIGO ABONNEMENT', 'PDNG', 'a4000000-0000-4000-8000-000000000003', null, null),
  ('a3000000-0000-4000-8000-000000000001', 'a-tx-8', '2026-09-15', -18.90, 'PHARMACIE DU CENTRE', 'BOOK', 'a4000000-0000-4000-8000-000000000005', null, null),
  ('b3000000-0000-4000-8000-000000000001', 'b-tx-1', '2026-09-02', -11.11, 'CARTE MARQUEUR-B-028AC449', 'BOOK', 'b4000000-0000-4000-8000-000000000001', jsonb_build_object('remittance', 'MARQUEUR-B-002D4AE5'), 'Note MARQUEUR-B-A580BD01'),
  ('b3000000-0000-4000-8000-000000000001', 'b-tx-2', '2026-09-03', -22.22, 'PRLV MARQUEUR-B-3E17809C', 'BOOK', null, jsonb_build_object('remittance', 'MARQUEUR-B-DC1F7F6D'), null),
  ('b3000000-0000-4000-8000-000000000002', 'b-tx-3', '2026-09-04', 3333.33, 'VIR MARQUEUR-B-AD20D722', 'BOOK', 'b4000000-0000-4000-8000-000000000002', jsonb_build_object('remittance', 'MARQUEUR-B-DDBD5626'), 'Note MARQUEUR-B-18AD7E69');

commit;
