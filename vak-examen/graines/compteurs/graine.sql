-- Graine « compteurs » (relevés d'eau, d'électricité et de gaz). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 4 compteurs, 15 relevés. B : 4 compteurs, 6 relevés ; chaque nom de compteur de B porte un marqueur unique.
-- (meters.unit est limité à 16 caractères et readings n'a aucun texte libre : les marqueurs ne tiennent que dans meters.name.)
\set ON_ERROR_STOP on
begin;

insert into public.meters (name, type, unit, owner_id) values
  ('Eau cuisine', 'eau', 'm³', :'a'::uuid),
  ('Électricité maison', 'electricite', 'kWh', :'a'::uuid),
  ('Gaz chaudière', 'gaz', 'm³', :'a'::uuid),
  ('Eau jardin', 'eau', 'm³', :'a'::uuid),
  ('Compteur MARQUEUR-B-262941FF', 'eau', 'm³', :'b'::uuid),
  ('Compteur MARQUEUR-B-E76F3029', 'electricite', 'kWh', :'b'::uuid),
  ('Compteur MARQUEUR-B-E6D195F6', 'gaz', 'm³', :'b'::uuid),
  ('Compteur MARQUEUR-B-A4E8CC4E', 'eau', 'm³', :'b'::uuid);

-- Valeurs croissantes par compteur, comme l'exige add_reading.
insert into public.readings (meter_id, read_on, value, owner_id)
select m.id, v.read_on::date, v.value, m.owner_id
from (values
  ('Eau cuisine', '2026-07-01', 120.5, :'a'::uuid),
  ('Eau cuisine', '2026-08-01', 131.0, :'a'::uuid),
  ('Eau cuisine', '2026-09-01', 142.8, :'a'::uuid),
  ('Eau cuisine', '2026-10-01', 150.2, :'a'::uuid),
  ('Électricité maison', '2026-07-01', 15200, :'a'::uuid),
  ('Électricité maison', '2026-08-01', 15480, :'a'::uuid),
  ('Électricité maison', '2026-09-01', 15790, :'a'::uuid),
  ('Électricité maison', '2026-10-01', 16110, :'a'::uuid),
  ('Gaz chaudière', '2026-07-01', 800, :'a'::uuid),
  ('Gaz chaudière', '2026-08-01', 812, :'a'::uuid),
  ('Gaz chaudière', '2026-09-01', 835, :'a'::uuid),
  ('Eau jardin', '2026-08-01', 40, :'a'::uuid),
  ('Eau jardin', '2026-09-01', 58, :'a'::uuid),
  ('Eau jardin', '2026-10-01', 71, :'a'::uuid),
  ('Eau jardin', '2026-10-05', 74, :'a'::uuid),
  ('Compteur MARQUEUR-B-262941FF', '2026-08-01', 10, :'b'::uuid),
  ('Compteur MARQUEUR-B-262941FF', '2026-09-01', 19, :'b'::uuid),
  ('Compteur MARQUEUR-B-E76F3029', '2026-08-01', 500, :'b'::uuid),
  ('Compteur MARQUEUR-B-E76F3029', '2026-09-01', 640, :'b'::uuid),
  ('Compteur MARQUEUR-B-E6D195F6', '2026-09-01', 300, :'b'::uuid),
  ('Compteur MARQUEUR-B-A4E8CC4E', '2026-09-15', 77, :'b'::uuid)
) as v(name, read_on, value, owner)
join public.meters m on m.name = v.name and m.owner_id = v.owner;

commit;
