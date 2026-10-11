-- Graine « abonnements » (suivi des abonnements). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 5 abonnements (tous actifs, pour qu'« mes abonnements » n'ait qu'un sens), 9 paiements.
-- B : 4 abonnements (seul texte libre : name, chacun porte un marqueur unique), 6 paiements (aucun texte libre).
\set ON_ERROR_STOP on
begin;

insert into public.subscriptions (name, category, monthly_amount, billing_day, active, owner_id) values
  ('Netflix', 'loisirs', 13.49, 5, true, :'a'::uuid),
  ('Spotify', 'loisirs', 10.99, 12, true, :'a'::uuid),
  ('Loyer assurance habitation', 'maison', 18.50, 1, true, :'a'::uuid),
  ('Abonnement fibre', 'maison', 29.99, 20, true, :'a'::uuid),
  ('Licence Notion', 'travail', 8.00, 15, true, :'a'::uuid),
  ('Abo MARQUEUR-B-5C0E91A4', 'loisirs', 9.99, 3, true, :'b'::uuid),
  ('Abo MARQUEUR-B-B27D4F60', 'maison', 24.00, 10, true, :'b'::uuid),
  ('Abo MARQUEUR-B-0A98E3D1', 'travail', 15.00, 17, true, :'b'::uuid),
  ('Abo MARQUEUR-B-F6413C7B', 'autre', 5.50, 25, true, :'b'::uuid);

insert into public.payments (subscription_id, owner_id, paid_on, amount, method)
select s.id, s.owner_id, v.paid_on::date, v.amount, v.method
from (values
  ('Netflix', '2026-08-05', 13.49, 'carte', :'a'::uuid),
  ('Netflix', '2026-09-05', 13.49, 'carte', :'a'::uuid),
  ('Spotify', '2026-09-12', 10.99, 'prelevement', :'a'::uuid),
  ('Loyer assurance habitation', '2026-08-01', 18.50, 'prelevement', :'a'::uuid),
  ('Loyer assurance habitation', '2026-09-01', 18.50, 'prelevement', :'a'::uuid),
  ('Abonnement fibre', '2026-09-20', 29.99, 'prelevement', :'a'::uuid),
  ('Licence Notion', '2026-08-15', 8.00, 'carte', :'a'::uuid),
  ('Licence Notion', '2026-09-15', 8.00, 'carte', :'a'::uuid),
  ('Licence Notion', '2026-10-01', 8.00, 'especes', :'a'::uuid),
  ('Abo MARQUEUR-B-5C0E91A4', '2026-09-03', 9.99, 'carte', :'b'::uuid),
  ('Abo MARQUEUR-B-5C0E91A4', '2026-10-03', 9.99, 'carte', :'b'::uuid),
  ('Abo MARQUEUR-B-B27D4F60', '2026-09-10', 24.00, 'prelevement', :'b'::uuid),
  ('Abo MARQUEUR-B-0A98E3D1', '2026-09-17', 15.00, 'especes', :'b'::uuid),
  ('Abo MARQUEUR-B-F6413C7B', '2026-09-25', 5.50, 'carte', :'b'::uuid),
  ('Abo MARQUEUR-B-F6413C7B', '2026-10-02', 5.50, 'carte', :'b'::uuid)
) as v(name, paid_on, amount, method, owner)
join public.subscriptions s on s.name = v.name and s.owner_id = v.owner;

commit;
