-- Graine « disques » (collection de vinyles). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 6 disques, 9 écoutes. B : 4 disques, 5 écoutes, chaque texte libre porte un marqueur unique.
\set ON_ERROR_STOP on
begin;

insert into public.vinyls (titre, artiste, annee, etat, genres, prix_achat, created_at, user_id) values
  ('Kind of Blue', 'Miles Davis', 1959, 'tres_bon', '{jazz}', 25, '2026-01-01 10:00+00', :'a'::uuid),
  ('Abbey Road', 'The Beatles', 1969, 'bon', '{rock,pop}', 18.5, '2026-01-01 10:00+00', :'a'::uuid),
  ('Thriller', 'Michael Jackson', 1982, 'neuf', '{pop,funk}', 30, '2026-01-01 10:00+00', :'a'::uuid),
  ('Rumours', 'Fleetwood Mac', 1977, 'bon', '{rock}', null, '2026-01-01 10:00+00', :'a'::uuid),
  ('Blue Train', 'John Coltrane', 1957, 'abime', '{jazz}', 12, '2026-01-01 10:00+00', :'a'::uuid),
  ('Random Access Memories', 'Daft Punk', 2013, 'neuf', '{electro,disco}', 45.9, '2026-01-01 10:00+00', :'a'::uuid),
  ('Titre MARQUEUR-B-BC0EA07B', 'Artiste MARQUEUR-B-78E0164A', 1960, 'neuf', '{MARQUEUR-B-8B807E47}', 9.99, '2026-01-02 10:00+00', :'b'::uuid),
  ('Titre MARQUEUR-B-60C895CA', 'Artiste MARQUEUR-B-D60825AA', 1965, 'bon', '{MARQUEUR-B-5C94DB2A}', 9.99, '2026-01-02 10:00+00', :'b'::uuid),
  ('Titre MARQUEUR-B-9D657CF8', 'Artiste MARQUEUR-B-583F0B20', 1970, 'tres_bon', '{MARQUEUR-B-88C69C0E}', 9.99, '2026-01-02 10:00+00', :'b'::uuid),
  ('Titre MARQUEUR-B-0A2E8737', 'Artiste MARQUEUR-B-1F6A603B', 1975, 'abime', '{MARQUEUR-B-6F585392}', 9.99, '2026-01-02 10:00+00', :'b'::uuid);

insert into public.listenings (vinyl_id, ecoute_le, face, note, commentaire, user_id)
select v.id, e.ecoute_le::timestamptz, e.face, e.note, e.commentaire, v.user_id
from (values
  ('Kind of Blue', '2026-01-04 20:00+00', 'A', 5, 'Un classique', :'a'::uuid),
  ('Kind of Blue', '2026-01-18 21:30+00', 'AB', 5, 'Toujours aussi bon', :'a'::uuid),
  ('Abbey Road', '2026-02-02 18:15+00', 'A', 4, 'Face A superbe', :'a'::uuid),
  ('Abbey Road', '2026-02-09 19:00+00', 'B', 4, 'Medley final', :'a'::uuid),
  ('Thriller', '2026-02-21 22:00+00', 'AB', 5, 'Pour danser', :'a'::uuid),
  ('Rumours', '2026-03-07 17:45+00', 'A', 3, 'Correct', :'a'::uuid),
  ('Blue Train', '2026-03-15 20:20+00', 'B', 2, 'Craque un peu', :'a'::uuid),
  ('Random Access Memories', '2026-04-01 21:00+00', 'AB', 4, 'Très bien produit', :'a'::uuid),
  ('Random Access Memories', '2026-04-10 20:10+00', 'A', 5, 'Get Lucky en boucle', :'a'::uuid),
  ('Titre MARQUEUR-B-BC0EA07B', '2026-02-10 20:00+00', 'A', 1, 'Note MARQUEUR-B-3A7FAF37', :'b'::uuid),
  ('Titre MARQUEUR-B-BC0EA07B', '2026-02-11 20:00+00', 'B', 2, 'Note MARQUEUR-B-BF923356', :'b'::uuid),
  ('Titre MARQUEUR-B-60C895CA', '2026-02-12 20:00+00', 'AB', 3, 'Note MARQUEUR-B-0CE47AB7', :'b'::uuid),
  ('Titre MARQUEUR-B-9D657CF8', '2026-02-13 20:00+00', 'A', 4, 'Note MARQUEUR-B-87B66CA4', :'b'::uuid),
  ('Titre MARQUEUR-B-0A2E8737', '2026-02-14 20:00+00', 'B', 5, 'Note MARQUEUR-B-6C085AE8', :'b'::uuid)
) as e(titre, ecoute_le, face, note, commentaire, proprio)
join public.vinyls v on v.titre = e.titre and v.user_id = e.proprio;

commit;
