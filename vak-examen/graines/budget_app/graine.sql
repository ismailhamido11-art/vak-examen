-- Graine « budget_app » (suivi de budget, interface en anglais). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 1 profil, 3 comptes, 5 catégories, 4 étiquettes, 6 bénéficiaires, 14 transactions, 6 budgets, 4 reçus, 3 tâches d'import
--     de reçus ; les tables de synthèse (category_monthly_summaries, daily_cashflow_summaries) sont remplies par les
--     déclencheurs de l'app, account_daily_summaries à la main (aucun déclencheur ne l'écrit).
-- B : des lignes différentes, chaque texte libre porte un marqueur unique.
-- Aucun compte archivé, aucune catégorie fille, aucun virement : « mes … » n'a qu'un sens.
\set ON_ERROR_STOP on
begin;

insert into public.profiles (id, full_name, default_currency, time_zone, locale) values
  (:'a'::uuid, 'Alice Martin', 'IDR', 'Asia/Jakarta', 'en'),
  (:'b'::uuid, 'Nom MARQUEUR-B-FD15C006', 'USD', 'America/New_York', 'en');

insert into public.accounts (user_id, name, type, currency, opening_balance_minor, order_index) values
  (:'a'::uuid, 'Main Checking', 'bank', 'IDR', 100000000, 0),
  (:'a'::uuid, 'Cash Wallet', 'cash', 'IDR', 15000000, 1),
  (:'a'::uuid, 'Rainy Day Savings', 'savings', 'IDR', 50000000, 2),
  (:'b'::uuid, 'Compte MARQUEUR-B-AA19E2F9', 'bank', 'USD', 900000, 0),
  (:'b'::uuid, 'Compte MARQUEUR-B-22478F9A', 'credit', 'USD', 0, 1);

insert into public.categories (user_id, name, icon, color, order_index) values
  (:'a'::uuid, 'Salary', 'lucide:piggy-bank', '#2e7d32', 0),
  (:'a'::uuid, 'Groceries', 'lucide:shopping-cart', '#ef6c00', 1),
  (:'a'::uuid, 'Transport', 'lucide:bus', '#1565c0', 2),
  (:'a'::uuid, 'Dining Out', 'lucide:utensils', '#ad1457', 3),
  (:'a'::uuid, 'Utilities', 'lucide:zap', '#6a1b9a', 4),
  (:'b'::uuid, 'Cat MARQUEUR-B-C781F611', 'lucide:tag', '#000000', 0),
  (:'b'::uuid, 'Cat MARQUEUR-B-B881E1D7', 'lucide:tag', '#111111', 1),
  (:'b'::uuid, 'Cat MARQUEUR-B-C682FFC4', 'lucide:tag', '#222222', 2);

insert into public.tags (user_id, name, color) values
  (:'a'::uuid, 'essential', '#2e7d32'),
  (:'a'::uuid, 'treat', '#ad1457'),
  (:'a'::uuid, 'recurring', '#1565c0'),
  (:'a'::uuid, 'shared', '#ef6c00'),
  (:'b'::uuid, 'Tag MARQUEUR-B-DCDBA2E5', '#333333'),
  (:'b'::uuid, 'Tag MARQUEUR-B-9DAAF235', '#444444'),
  (:'b'::uuid, 'Tag MARQUEUR-B-E37FEB96', '#555555');

insert into public.payees (user_id, name) values
  (:'a'::uuid, 'Employer Ltd'),
  (:'a'::uuid, 'Fresh Market'),
  (:'a'::uuid, 'City Bus Co'),
  (:'a'::uuid, 'Warung Sari'),
  (:'a'::uuid, 'Power Utility'),
  (:'a'::uuid, 'Corner Bakery'),
  (:'b'::uuid, 'Payee MARQUEUR-B-FB46EBD8'),
  (:'b'::uuid, 'Payee MARQUEUR-B-4591B846'),
  (:'b'::uuid, 'Payee MARQUEUR-B-EADC0DB9'),
  (:'b'::uuid, 'Payee MARQUEUR-B-AB12D351');

-- Transactions : 14 pour A, 5 pour B (résolution des clés par nom, propre à chaque compte).
insert into public.transactions (user_id, account_id, category_id, payee_id, type, description, amount_minor, currency, occurred_at, booked_at, notes)
select v.uid, ac.id, ca.id, pa.id, v.typ::transaction_type, v.descr, v.amount, v.cur, v.occ::timestamptz, v.occ::timestamptz, v.note
from (values
  (:'a'::uuid, 'Main Checking', 'Salary', 'Employer Ltd', 'income', 'March salary', 85000000, 'IDR', '2026-03-01 08:00+00', 'Monthly pay'),
  (:'a'::uuid, 'Main Checking', 'Salary', 'Employer Ltd', 'income', 'April salary', 85000000, 'IDR', '2026-04-01 08:00+00', 'Monthly pay'),
  (:'a'::uuid, 'Main Checking', 'Salary', 'Employer Ltd', 'income', 'May salary', 85000000, 'IDR', '2026-05-01 08:00+00', 'Monthly pay'),
  (:'a'::uuid, 'Cash Wallet', 'Groceries', 'Fresh Market', 'expense', 'Weekly groceries', 1850000, 'IDR', '2026-03-03 10:00+00', 'Fruit and rice'),
  (:'a'::uuid, 'Cash Wallet', 'Groceries', 'Fresh Market', 'expense', 'Weekly groceries', 2100000, 'IDR', '2026-03-10 10:00+00', 'Vegetables'),
  (:'a'::uuid, 'Cash Wallet', 'Groceries', 'Corner Bakery', 'expense', 'Bread and pastries', 450000, 'IDR', '2026-04-04 09:00+00', 'Breakfast'),
  (:'a'::uuid, 'Cash Wallet', 'Groceries', 'Fresh Market', 'expense', 'Weekly groceries', 1950000, 'IDR', '2026-04-11 10:00+00', 'Eggs and milk'),
  (:'a'::uuid, 'Main Checking', 'Transport', 'City Bus Co', 'expense', 'Monthly bus pass', 600000, 'IDR', '2026-03-02 07:00+00', 'Pass'),
  (:'a'::uuid, 'Main Checking', 'Transport', 'City Bus Co', 'expense', 'Monthly bus pass', 600000, 'IDR', '2026-04-02 07:00+00', 'Pass'),
  (:'a'::uuid, 'Main Checking', 'Dining Out', 'Warung Sari', 'expense', 'Dinner with friends', 780000, 'IDR', '2026-03-14 19:00+00', 'Birthday dinner'),
  (:'a'::uuid, 'Main Checking', 'Dining Out', 'Warung Sari', 'expense', 'Lunch', 320000, 'IDR', '2026-04-18 12:00+00', 'Team lunch'),
  (:'a'::uuid, 'Main Checking', 'Utilities', 'Power Utility', 'expense', 'Electricity bill', 1250000, 'IDR', '2026-03-20 09:00+00', 'March bill'),
  (:'a'::uuid, 'Main Checking', 'Utilities', 'Power Utility', 'expense', 'Electricity bill', 1320000, 'IDR', '2026-04-20 09:00+00', 'April bill'),
  (:'a'::uuid, 'Main Checking', 'Utilities', 'Power Utility', 'expense', 'Electricity bill', 1180000, 'IDR', '2026-05-20 09:00+00', 'May bill'),
  (:'b'::uuid, 'Compte MARQUEUR-B-AA19E2F9', 'Cat MARQUEUR-B-C781F611', 'Payee MARQUEUR-B-FB46EBD8', 'income', 'Op MARQUEUR-B-A4351C60', 300000, 'USD', '2026-03-05 08:00+00', 'Note MARQUEUR-B-052C2B51'),
  (:'b'::uuid, 'Compte MARQUEUR-B-AA19E2F9', 'Cat MARQUEUR-B-B881E1D7', 'Payee MARQUEUR-B-4591B846', 'expense', 'Op MARQUEUR-B-C6719424', 12000, 'USD', '2026-03-06 08:00+00', 'Note MARQUEUR-B-5A3F1AFE'),
  (:'b'::uuid, 'Compte MARQUEUR-B-22478F9A', 'Cat MARQUEUR-B-B881E1D7', 'Payee MARQUEUR-B-EADC0DB9', 'expense', 'Op MARQUEUR-B-5D09209D', 4500, 'USD', '2026-04-07 08:00+00', 'Note MARQUEUR-B-CE539F92'),
  (:'b'::uuid, 'Compte MARQUEUR-B-AA19E2F9', 'Cat MARQUEUR-B-C682FFC4', 'Payee MARQUEUR-B-AB12D351', 'expense', 'Op MARQUEUR-B-2C1D9422', 8800, 'USD', '2026-04-08 08:00+00', 'Note MARQUEUR-B-B7500C0B'),
  (:'b'::uuid, 'Compte MARQUEUR-B-22478F9A', 'Cat MARQUEUR-B-C682FFC4', 'Payee MARQUEUR-B-AB12D351', 'expense', 'Op MARQUEUR-B-67BE4B27', 2300, 'USD', '2026-05-09 08:00+00', 'Note MARQUEUR-B-CB515D84')
) as v(uid, acc, cat, payee, typ, descr, amount, cur, occ, note)
join public.accounts ac on ac.user_id = v.uid and ac.name = v.acc
join public.categories ca on ca.user_id = v.uid and ca.name = v.cat
join public.payees pa on pa.user_id = v.uid and pa.name = v.payee;

insert into public.transaction_tags (transaction_id, tag_id)
select t.id, g.id from public.transactions t
join public.tags g on g.user_id = t.user_id and g.name = 'essential'
where t.user_id = :'a'::uuid and t.description in ('Weekly groceries', 'Electricity bill');

-- Budgets : 6 pour A, 2 pour B (les synthèses mensuelles suivent par déclencheur).
insert into public.budgets (user_id, category_id, period, amount_minor, rollover)
select v.uid, c.id, v.period, v.amount, v.roll
from (values
  (:'a'::uuid, 'Groceries', '2026-03', 4000000, true),
  (:'a'::uuid, 'Groceries', '2026-04', 4000000, false),
  (:'a'::uuid, 'Transport', '2026-03', 700000, false),
  (:'a'::uuid, 'Dining Out', '2026-04', 1000000, false),
  (:'a'::uuid, 'Utilities', '2026-03', 1500000, false),
  (:'a'::uuid, 'Utilities', '2026-05', 1500000, true),
  (:'b'::uuid, 'Cat MARQUEUR-B-B881E1D7', '2026-03', 50000, false),
  (:'b'::uuid, 'Cat MARQUEUR-B-C682FFC4', '2026-04', 30000, false)
) as v(uid, cat, period, amount, roll)
join public.categories c on c.user_id = v.uid and c.name = v.cat;

-- Soldes quotidiens : aucun déclencheur ne les écrit.
insert into public.account_daily_summaries (user_id, account_id, date, net_change_minor, closing_balance_minor)
select v.uid, ac.id, v.d::date, v.net, v.closing
from (values
  (:'a'::uuid, 'Main Checking', '2026-03-01', 85000000, 185000000),
  (:'a'::uuid, 'Main Checking', '2026-03-02', -600000, 184400000),
  (:'a'::uuid, 'Main Checking', '2026-04-01', 85000000, 269400000),
  (:'a'::uuid, 'Cash Wallet', '2026-03-03', -1850000, 13150000),
  (:'a'::uuid, 'Cash Wallet', '2026-03-10', -2100000, 11050000),
  (:'b'::uuid, 'Compte MARQUEUR-B-AA19E2F9', '2026-03-05', 300000, 1200000),
  (:'b'::uuid, 'Compte MARQUEUR-B-AA19E2F9', '2026-03-06', -12000, 1188000)
) as v(uid, acc, d, net, closing)
join public.accounts ac on ac.user_id = v.uid and ac.name = v.acc;

-- Reçus : 4 pour A, 3 pour B ; tâches d'import : 3 pour A, 2 pour B.
insert into public.receipt_ingestion_jobs (user_id, status, source_filename, storage_path, image_hash, error_code, error_message, attempt_count, progress_stage, progress_message, progress_value) values
  (:'a'::uuid, 'succeeded', 'market-0301.jpg', :'a' || '/market-0301.jpg', 'hash-a-1', null, null, 1, 'completed', 'Done', 100),
  (:'a'::uuid, 'succeeded', 'bakery-0404.jpg', :'a' || '/bakery-0404.jpg', 'hash-a-2', null, null, 1, 'completed', 'Done', 100),
  (:'a'::uuid, 'failed', 'blurry-0420.jpg', :'a' || '/blurry-0420.jpg', 'hash-a-3', 'ocr_failed', 'Image too blurry', 2, 'failed', 'Could not read the receipt', 40),
  (:'b'::uuid, 'succeeded', 'Fichier MARQUEUR-B-4FEF1EDA.jpg', :'b' || '/f1.jpg', 'hash-b-1', null, null, 1, 'completed', 'Message MARQUEUR-B-1E05662E', 100),
  (:'b'::uuid, 'failed', 'Fichier MARQUEUR-B-CA2F14E1.jpg', :'b' || '/f2.jpg', 'hash-b-2', 'ocr_failed', 'Erreur MARQUEUR-B-1D0251D7', 3, 'failed', 'Message MARQUEUR-B-11716485', 10);

insert into public.receipts (user_id, job_id, storage_path, image_hash, merchant_name, merchant_address, purchase_at, currency, subtotal_minor, tax_minor, discount_minor, total_minor, payment_method, notes, model_response, ocr_text, confidence)
select v.uid, j.id, v.path, v.hash, v.merchant, v.addr, v.purchase::timestamptz, v.cur, v.sub, v.tax, 0, v.total, v.pay, v.note, v.resp::jsonb, v.ocr, 0.95
from (values
  (:'a'::uuid, 'market-0301.jpg', :'a' || '/market-0301.jpg', 'hash-a-1', 'Fresh Market', '12 Market Street', '2026-03-03 10:00+00', 'IDR', 1700000, 150000, 1850000, 'cash', 'Weekly shop', '{"merchant":"Fresh Market","total":1850000}', 'FRESH MARKET TOTAL 1850000'),
  (:'a'::uuid, null, :'a' || '/market-0310.jpg', 'hash-a-4', 'Fresh Market', '12 Market Street', '2026-03-10 10:00+00', 'IDR', 1900000, 200000, 2100000, 'cash', 'Weekly shop', '{"merchant":"Fresh Market","total":2100000}', 'FRESH MARKET TOTAL 2100000'),
  (:'a'::uuid, 'bakery-0404.jpg', :'a' || '/bakery-0404.jpg', 'hash-a-2', 'Corner Bakery', '3 Baker Lane', '2026-04-04 09:00+00', 'IDR', 410000, 40000, 450000, 'cash', 'Breakfast', '{"merchant":"Corner Bakery","total":450000}', 'CORNER BAKERY TOTAL 450000'),
  (:'a'::uuid, null, :'a' || '/warung-0418.jpg', 'hash-a-5', 'Warung Sari', '8 Sari Road', '2026-04-18 12:00+00', 'IDR', 290000, 30000, 320000, 'card', 'Team lunch', '{"merchant":"Warung Sari","total":320000}', 'WARUNG SARI TOTAL 320000'),
  (:'b'::uuid, 'Fichier MARQUEUR-B-4FEF1EDA.jpg', :'b' || '/f1.jpg', 'hash-b-1', 'Marchand MARQUEUR-B-9F707CAA', 'Adresse MARQUEUR-B-6E12A222', '2026-03-05 08:00+00', 'USD', 9000, 1000, 10000, 'card', 'Note MARQUEUR-B-0D0BBEDD', '{"merchant":"Marchand MARQUEUR-B-589FFD5A"}', 'OCR MARQUEUR-B-2686F565'),
  (:'b'::uuid, null, :'b' || '/f3.jpg', 'hash-b-3', 'Marchand MARQUEUR-B-7B7DBEAB', 'Adresse MARQUEUR-B-AE336855', '2026-04-05 08:00+00', 'USD', 4000, 500, 4500, 'cash', 'Note MARQUEUR-B-B2A14CA6', '{"merchant":"Marchand MARQUEUR-B-B1FA04D1"}', 'OCR MARQUEUR-B-2F31F69B'),
  (:'b'::uuid, null, :'b' || '/f4.jpg', 'hash-b-4', 'Marchand MARQUEUR-B-34DED477', 'Adresse MARQUEUR-B-BEE757F7', '2026-05-05 08:00+00', 'USD', 7000, 700, 7700, 'card', 'Note MARQUEUR-B-0CB40809', '{"merchant":"Marchand MARQUEUR-B-D124B2BC"}', 'OCR MARQUEUR-B-15420BCC')
) as v(uid, jobfile, path, hash, merchant, addr, purchase, cur, sub, tax, total, pay, note, resp, ocr)
left join public.receipt_ingestion_jobs j on j.user_id = v.uid and j.source_filename = v.jobfile;

insert into public.receipt_line_items (receipt_id, description, category, quantity, unit_price_minor, line_total_minor)
select r.id, v.descr, v.cat, 1, v.total, v.total
from (values
  (:'a'::uuid, 'hash-a-1', 'Rice 5kg', 'Groceries', 1850000),
  (:'b'::uuid, 'hash-b-1', 'Ligne MARQUEUR-B-42541454', 'Cat MARQUEUR-B-C781F611', 10000)
) as v(uid, hash, descr, cat, total)
join public.receipts r on r.user_id = v.uid and r.image_hash = v.hash;

commit;
