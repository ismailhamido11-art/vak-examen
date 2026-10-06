-- Graine « fonctions » (budget du foyer). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 5 catégories, 11 dépenses. B : 4 catégories, 7 dépenses, chaque texte libre porte un marqueur unique.
\set ON_ERROR_STOP on
begin;

insert into public.categories (owner_id, name, monthly_limit) values
  (:'a'::uuid, 'Courses', 450),
  (:'a'::uuid, 'Loyer', 900),
  (:'a'::uuid, 'Transport', 120),
  (:'a'::uuid, 'Loisirs', 150),
  (:'a'::uuid, 'Santé', null),
  (:'b'::uuid, 'Catégorie MARQUEUR-B-A85539F6', 300),
  (:'b'::uuid, 'Catégorie MARQUEUR-B-53AECA05', 80),
  (:'b'::uuid, 'Catégorie MARQUEUR-B-A991AC25', null),
  (:'b'::uuid, 'Catégorie MARQUEUR-B-E882D726', 200);

insert into public.expenses (owner_id, category_id, amount, spent_on, label)
select c.owner_id, c.id, v.amount, v.spent_on::date, v.label
from (values
  (:'a'::uuid, 'Courses', 62.4, '2026-09-02', 'Marché du samedi'),
  (:'a'::uuid, 'Courses', 85.15, '2026-09-09', 'Supermarché'),
  (:'a'::uuid, 'Courses', 47.9, '2026-09-16', 'Boulangerie et primeur'),
  (:'a'::uuid, 'Loyer', 900, '2026-09-01', 'Loyer de septembre'),
  (:'a'::uuid, 'Loyer', 900, '2026-10-01', 'Loyer d''octobre'),
  (:'a'::uuid, 'Transport', 38.5, '2026-09-05', 'Abonnement de bus'),
  (:'a'::uuid, 'Transport', 24, '2026-09-20', 'Train'),
  (:'a'::uuid, 'Loisirs', 18, '2026-09-12', 'Cinéma'),
  (:'a'::uuid, 'Loisirs', 42.75, '2026-09-26', 'Concert'),
  (:'a'::uuid, 'Santé', 25, '2026-09-14', 'Consultation'),
  (:'a'::uuid, 'Santé', 13.6, '2026-09-15', 'Pharmacie'),
  (:'b'::uuid, 'Catégorie MARQUEUR-B-A85539F6', 33.3, '2026-09-03', 'Libellé MARQUEUR-B-48AEA83B'),
  (:'b'::uuid, 'Catégorie MARQUEUR-B-A85539F6', 71.2, '2026-09-05', 'Libellé MARQUEUR-B-C39C8817'),
  (:'b'::uuid, 'Catégorie MARQUEUR-B-53AECA05', 15, '2026-09-07', 'Libellé MARQUEUR-B-64EF4A9A'),
  (:'b'::uuid, 'Catégorie MARQUEUR-B-53AECA05', 22.5, '2026-09-09', 'Libellé MARQUEUR-B-489B3B53'),
  (:'b'::uuid, 'Catégorie MARQUEUR-B-A991AC25', 99.99, '2026-09-11', 'Libellé MARQUEUR-B-D6FC4771'),
  (:'b'::uuid, 'Catégorie MARQUEUR-B-E882D726', 8.4, '2026-09-13', 'Libellé MARQUEUR-B-72122BB8'),
  (:'b'::uuid, 'Catégorie MARQUEUR-B-E882D726', 120, '2026-09-15', 'Libellé MARQUEUR-B-3C68F5E3')
) as v(owner, category, amount, spent_on, label)
join public.categories c on c.name = v.category and c.owner_id = v.owner;

commit;
