-- Graine « pups_supabase » (vente de chiots). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 1 profil, 5 commandes. B : 1 profil, 4 commandes, chaque texte libre porte un marqueur unique.
-- Les chiots (public.puppies) sont un catalogue public : aucun marqueur n'y est mis.
\set ON_ERROR_STOP on
begin;

insert into public.profiles (id, email, name) values
  (:'a'::uuid, 'alice.martin@example.test', 'Alice Martin'),
  (:'b'::uuid, 'b-MARQUEUR-B-01BCF519@example.test', 'Nom MARQUEUR-B-658C24AC');

insert into public.orders (user_id, puppy_id, amount_cents, stripe_payment_intent_id, status, created_at)
select v.uid, p.id, v.amount, v.pi, v.status, v.created_at::timestamptz
from (values
  ('Goldie', 180000, 'pi_3Qa1AliceGoldie01', 'paid', '2026-02-03 10:00:00+00', :'a'::uuid),
  ('Milo',   220000, 'pi_3Qa1AliceMilo002', 'paid', '2026-03-11 14:30:00+00', :'a'::uuid),
  ('Poppy',  195000, 'pi_3Qa1AlicePoppy03', 'paid', '2026-04-20 09:15:00+00', :'a'::uuid),
  ('Goldie', 180000, 'pi_3Qa1AliceGoldie04', 'pending', '2026-05-02 16:45:00+00', :'a'::uuid),
  ('Milo',   220000, 'pi_3Qa1AliceMilo005', 'paid', '2026-06-18 11:00:00+00', :'a'::uuid),
  ('Poppy',  195000, 'pi_MARQUEUR-B-584E2465', 'paid', '2026-02-10 10:00:00+00', :'b'::uuid),
  ('Goldie', 180000, 'pi_MARQUEUR-B-A079F1BF', 'paid', '2026-03-12 10:00:00+00', :'b'::uuid),
  ('Milo',   220000, 'pi_MARQUEUR-B-D0EAEA8C', 'pending', '2026-04-14 10:00:00+00', :'b'::uuid),
  ('Poppy',  195000, 'pi_MARQUEUR-B-288A8353', 'paid', '2026-05-16 10:00:00+00', :'b'::uuid)
) as v(pname, amount, pi, status, created_at, uid)
join public.puppies p on p.name = v.pname;

commit;
