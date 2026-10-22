-- Graine « randonnee » (carnet de randonnée). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 6 itinéraires, 9 sorties. B : 4 itinéraires, 5 sorties ; chaque texte libre de B porte un marqueur unique.
\set ON_ERROR_STOP on
begin;

insert into public.trails (name, region, distance_km, elevation_gain_m, difficulty, is_loop, owner_id) values
  ('Tour du lac Blanc', 'Alpes', 9.5, 520, 'moyenne', true, :'a'::uuid),
  ('Sentier des Crêtes', 'Vosges', 14.2, 780, 'difficile', false, :'a'::uuid),
  ('Gorges du Verdon', 'Provence', 18.0, 650, 'difficile', false, :'a'::uuid),
  ('Boucle de la Dune du Pilat', 'Aquitaine', 6.3, 110, 'facile', true, :'a'::uuid),
  ('Mont Aiguille', 'Vercors', 12.8, 1150, 'experte', false, :'a'::uuid),
  ('Chemin des Douaniers', 'Bretagne', 11.0, 300, 'facile', false, :'a'::uuid),
  ('Itinéraire MARQUEUR-B-18695D91', 'Région MARQUEUR-B-4B1F0E0A', 8.0, 400, 'moyenne', true, :'b'::uuid),
  ('Itinéraire MARQUEUR-B-CFA22916', 'Région MARQUEUR-B-51F5EE22', 15.5, 900, 'difficile', false, :'b'::uuid),
  ('Itinéraire MARQUEUR-B-CD01991B', 'Région MARQUEUR-B-E63C9472', 5.2, 80, 'facile', false, :'b'::uuid),
  ('Itinéraire MARQUEUR-B-898A3687', 'Région MARQUEUR-B-98F53143', 21.0, 1400, 'experte', true, :'b'::uuid);

insert into public.outings (trail_id, started_at, duration_min, weather, rating, companions, comment, owner_id)
select t.id, v.started_at::timestamptz, v.duration, v.weather::public.meteo, v.rating, v.companions, v.comment, t.owner_id
from (values
  ('Tour du lac Blanc', '2026-05-03 08:30+00', 210, 'soleil', 5, '{Camille,Julien}'::text[], 'Lac superbe au lever du jour', :'a'::uuid),
  ('Tour du lac Blanc', '2026-07-12 09:00+00', 195, 'nuages', 4, '{Camille}'::text[], 'Un peu de brume', :'a'::uuid),
  ('Sentier des Crêtes', '2026-06-01 07:45+00', 330, 'soleil', 5, '{}'::text[], 'Vue dégagée sur toute la vallée', :'a'::uuid),
  ('Sentier des Crêtes', '2026-09-20 08:00+00', 360, 'pluie', 3, '{Julien}'::text[], 'Sentier glissant', :'a'::uuid),
  ('Gorges du Verdon', '2026-06-14 09:30+00', 420, 'soleil', 5, '{Camille,Julien,Inès}'::text[], 'Eau turquoise', :'a'::uuid),
  ('Boucle de la Dune du Pilat', '2026-08-02 17:00+00', 120, 'soleil', 4, '{Inès}'::text[], 'Coucher de soleil sur la dune', :'a'::uuid),
  ('Mont Aiguille', '2026-08-23 06:00+00', 540, 'nuages', 4, '{Julien}'::text[], 'Passage exposé', :'a'::uuid),
  ('Chemin des Douaniers', '2026-04-11 10:00+00', 180, 'pluie', 3, '{}'::text[], 'Embruns et vent', :'a'::uuid),
  ('Chemin des Douaniers', '2026-10-04 10:30+00', 170, 'soleil', 5, '{Camille}'::text[], 'Mer calme', :'a'::uuid),
  ('Itinéraire MARQUEUR-B-18695D91', '2026-05-10 08:00+00', 150, 'soleil', 4, '{"Compagnon MARQUEUR-B-4150E6FD"}'::text[], 'Commentaire MARQUEUR-B-37BE0D2A', :'b'::uuid),
  ('Itinéraire MARQUEUR-B-18695D91', '2026-06-10 08:00+00', 140, 'nuages', 3, '{"Compagnon MARQUEUR-B-ADE19193"}'::text[], 'Commentaire MARQUEUR-B-CE943A4F', :'b'::uuid),
  ('Itinéraire MARQUEUR-B-CFA22916', '2026-07-10 08:00+00', 300, 'pluie', 2, '{"Compagnon MARQUEUR-B-D1C0E26A"}'::text[], 'Commentaire MARQUEUR-B-4F7B378F', :'b'::uuid),
  ('Itinéraire MARQUEUR-B-CD01991B', '2026-08-10 08:00+00', 90, 'soleil', 5, '{"Compagnon MARQUEUR-B-5186C40A"}'::text[], 'Commentaire MARQUEUR-B-3E955481', :'b'::uuid),
  ('Itinéraire MARQUEUR-B-898A3687', '2026-09-10 08:00+00', 600, 'neige', 4, '{"Compagnon MARQUEUR-B-2E6FF68D"}'::text[], 'Commentaire MARQUEUR-B-6587468C', :'b'::uuid)
) as v(trail, started_at, duration, weather, rating, companions, comment, owner)
join public.trails t on t.name = v.trail and t.owner_id = v.owner;

commit;
