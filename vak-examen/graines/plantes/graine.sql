-- Graine « plantes » (carnet de plantes d'intérieur). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 6 plantes, 11 arrosages. B : 4 plantes, 6 arrosages ; chaque texte libre de B porte un marqueur unique.
\set ON_ERROR_STOP on
begin;

insert into public.plants (name, species, room, light, watering_interval_days, purchased_on, owner_id) values
  ('Monstera deliciosa', 'Monstera deliciosa', 'Salon', 'moyenne', 7, '2025-03-02', :'a'::uuid),
  ('Pothos', 'Epipremnum aureum', 'Cuisine', 'faible', 10, '2025-04-12', :'a'::uuid),
  ('Ficus lyrata', 'Ficus lyrata', 'Salon', 'forte', 7, '2025-05-20', :'a'::uuid),
  ('Sansevieria', 'Dracaena trifasciata', 'Chambre', 'faible', 21, '2025-06-01', :'a'::uuid),
  ('Calathea', 'Calathea orbifolia', 'Bureau', 'moyenne', 5, '2025-07-15', :'a'::uuid),
  ('Aloe vera', 'Aloe barbadensis', 'Balcon', 'forte', 14, '2025-08-09', :'a'::uuid),
  ('Plante MARQUEUR-B-6A848D88', 'Espèce MARQUEUR-B-83B30903', 'Pièce MARQUEUR-B-F360F2A6', 'faible', 7, '2026-01-10', :'b'::uuid),
  ('Plante MARQUEUR-B-A6FA9A6E', 'Espèce MARQUEUR-B-1AC9043C', 'Pièce MARQUEUR-B-ABAA54BA', 'moyenne', 14, '2026-01-10', :'b'::uuid),
  ('Plante MARQUEUR-B-9C1B8781', 'Espèce MARQUEUR-B-B4A1EE73', 'Pièce MARQUEUR-B-C011C62D', 'forte', 10, '2026-01-10', :'b'::uuid),
  ('Plante MARQUEUR-B-078FCFFF', 'Espèce MARQUEUR-B-3B4F0537', 'Pièce MARQUEUR-B-AB26A55A', 'moyenne', 30, '2026-01-10', :'b'::uuid);

insert into public.waterings (plant_id, watered_on, quantity_ml, note, owner_id)
select p.id, v.d::date, v.ml, v.note, p.owner_id
from (values
  ('Monstera deliciosa', '2026-09-01', 250, 'Arrosage du matin', :'a'::uuid),
  ('Monstera deliciosa', '2026-09-08', 300, 'Un peu plus', :'a'::uuid),
  ('Monstera deliciosa', '2026-09-15', 250, null, :'a'::uuid),
  ('Pothos', '2026-09-03', 150, 'Terreau sec', :'a'::uuid),
  ('Pothos', '2026-09-13', 200, null, :'a'::uuid),
  ('Ficus lyrata', '2026-09-02', 400, 'Bien arrosé', :'a'::uuid),
  ('Ficus lyrata', '2026-09-09', 350, null, :'a'::uuid),
  ('Sansevieria', '2026-08-20', 100, 'Arrosage rare', :'a'::uuid),
  ('Calathea', '2026-09-05', 200, 'Eau de pluie', :'a'::uuid),
  ('Calathea', '2026-09-10', 180, null, :'a'::uuid),
  ('Aloe vera', '2026-09-01', 120, 'Très léger', :'a'::uuid),
  ('Plante MARQUEUR-B-6A848D88', '2026-09-01', 100, 'Note MARQUEUR-B-45A6A280', :'b'::uuid),
  ('Plante MARQUEUR-B-6A848D88', '2026-09-01', 100, 'Note MARQUEUR-B-B2C89BCA', :'b'::uuid),
  ('Plante MARQUEUR-B-A6FA9A6E', '2026-09-02', 110, 'Note MARQUEUR-B-D4D19E40', :'b'::uuid),
  ('Plante MARQUEUR-B-9C1B8781', '2026-09-03', 120, 'Note MARQUEUR-B-7715CB82', :'b'::uuid),
  ('Plante MARQUEUR-B-9C1B8781', '2026-09-03', 120, 'Note MARQUEUR-B-AFBF0E7E', :'b'::uuid),
  ('Plante MARQUEUR-B-078FCFFF', '2026-09-04', 130, 'Note MARQUEUR-B-6DC765BB', :'b'::uuid)
) as v(name, d, ml, note, owner)
join public.plants p on p.name = v.name and p.owner_id = v.owner;

commit;
