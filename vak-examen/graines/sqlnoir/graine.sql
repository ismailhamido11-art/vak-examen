-- Graine « sqlnoir » (enquêtes SQL). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- La migration crée une ligne user_info à chaque inscription (déclencheur) : la graine la complète (upsert).
-- A : 1 profil (user_info), 3 licences réclamées (pending_licenses). B : 1 profil, 2 licences, textes marqués.
\set ON_ERROR_STOP on
begin;

insert into public.user_info
  (id, xp, completed_cases, case_answers, has_license, license_purchased_at, stripe_customer_id, stripe_session_id, payment_intent)
values
  (:'a'::uuid, 150, '["case-001", "case-002"]'::jsonb,
   '{"case-001": "SELECT name FROM suspects", "case-002": "SELECT * FROM alibis"}'::jsonb,
   true, '2026-03-20 10:00:00+00', 'cus_test_alpha', 'cs_test_session_alpha', 'pi_test_alpha'),
  (:'b'::uuid, 350, '["case-001", "case-004"]'::jsonb,
   '{"case-001":"SELECT MARQUEUR-B-3C754150","case-004":"SELECT MARQUEUR-B-C0FBEBC3"}'::jsonb,
   true, '2026-03-22 12:00:00+00', 'cus_MARQUEUR-B-507F5555', 'cs_MARQUEUR-B-8714C6FE', 'pi_MARQUEUR-B-DE3FD0DF')
on conflict (id) do update set
  xp = excluded.xp, completed_cases = excluded.completed_cases, case_answers = excluded.case_answers,
  has_license = excluded.has_license, license_purchased_at = excluded.license_purchased_at,
  stripe_customer_id = excluded.stripe_customer_id, stripe_session_id = excluded.stripe_session_id,
  payment_intent = excluded.payment_intent;

update public.user_info set license_revoked_at = '2026-04-01 09:00:00+00', license_revoked_reason = 'Remboursement MARQUEUR-B-8A3BE189'
 where id = :'b'::uuid;

insert into public.pending_licenses (email, stripe_session_id, stripe_customer_id, payment_intent, created_at, claimed_at, claimed_by) values
  ('alpha@example.test', 'cs_test_a_001', 'cus_test_a_001', 'pi_test_a_001', '2026-03-10 08:00:00+00', '2026-03-10 09:00:00+00', :'a'::uuid),
  ('alpha@example.test', 'cs_test_a_002', 'cus_test_a_001', 'pi_test_a_002', '2026-03-11 08:00:00+00', '2026-03-11 09:00:00+00', :'a'::uuid),
  ('alpha.bis@example.test', 'cs_test_a_003', 'cus_test_a_002', 'pi_test_a_003', '2026-03-12 08:00:00+00', '2026-03-12 09:00:00+00', :'a'::uuid),
  ('bravo-MARQUEUR-B-93CF81C6@example.test', 'cs_MARQUEUR-B-93CF81C6', 'cus_MARQUEUR-B-CA2CDC0E', 'pi_MARQUEUR-B-3F92C104', '2026-03-13 08:00:00+00', '2026-03-13 09:00:00+00', :'b'::uuid),
  ('bravo-MARQUEUR-B-D82D2A88@example.test', 'cs_MARQUEUR-B-D82D2A88', 'cus_MARQUEUR-B-63A5A876', 'pi_MARQUEUR-B-E356F3A7', '2026-03-14 08:00:00+00', '2026-03-14 09:00:00+00', :'b'::uuid);

commit;
