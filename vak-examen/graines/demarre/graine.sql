-- Graine « demarre » (carnet de lecture). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 7 livres, 12 séances. B : 4 livres, 6 séances, chaque texte libre porte un marqueur unique.
\set ON_ERROR_STOP on
begin;

insert into public.books (title, author, status, added_at, owner_id) values
  ('Les Misérables', 'Victor Hugo', 'lu', '2026-01-05', :'a'::uuid),
  ('Germinal', 'Émile Zola', 'lu', '2026-01-19', :'a'::uuid),
  ('Le Petit Prince', 'Antoine de Saint-Exupéry', 'lu', '2026-02-02', :'a'::uuid),
  ('L''Étranger', 'Albert Camus', 'en_cours', '2026-02-16', :'a'::uuid),
  ('Dune', 'Frank Herbert', 'en_cours', '2026-03-01', :'a'::uuid),
  ('Fahrenheit 451', 'Ray Bradbury', 'a_lire', '2026-03-15', :'a'::uuid),
  ('La Peste', 'Albert Camus', 'a_lire', '2026-04-01', :'a'::uuid),
  ('Titre MARQUEUR-B-688D5C05', 'Auteur MARQUEUR-B-A7623D07', 'lu', '2026-01-10', :'b'::uuid),
  ('Titre MARQUEUR-B-7A22A34C', 'Auteur MARQUEUR-B-1C69539A', 'en_cours', '2026-02-10', :'b'::uuid),
  ('Titre MARQUEUR-B-FCC90408', 'Auteur MARQUEUR-B-81119A10', 'a_lire', '2026-03-10', :'b'::uuid),
  ('Titre MARQUEUR-B-D419620E', 'Auteur MARQUEUR-B-3A632FA7', 'lu', '2026-04-10', :'b'::uuid);

insert into public.reading_sessions (book_id, read_on, pages_read, note, owner_id)
select bk.id, v.read_on::date, v.pages, v.note, bk.owner_id
from (values
  ('Les Misérables', '2026-01-06', 40, 'Début du tome un', :'a'::uuid),
  ('Les Misérables', '2026-01-09', 55, 'Les chapitres sur Fantine', :'a'::uuid),
  ('Les Misérables', '2026-01-14', 62, 'Fin de la première partie', :'a'::uuid),
  ('Germinal', '2026-01-20', 35, 'La mine', :'a'::uuid),
  ('Germinal', '2026-01-27', 48, 'La grève approche', :'a'::uuid),
  ('Le Petit Prince', '2026-02-03', 30, 'Lu d''une traite', :'a'::uuid),
  ('L''Étranger', '2026-02-17', 25, 'Première partie', :'a'::uuid),
  ('L''Étranger', '2026-02-24', 33, 'Le procès', :'a'::uuid),
  ('Dune', '2026-03-02', 50, 'Le désert d''Arrakis', :'a'::uuid),
  ('Dune', '2026-03-05', 44, 'Les Fremen', :'a'::uuid),
  ('Dune', '2026-03-09', 38, 'L''épice', :'a'::uuid),
  ('Dune', '2026-03-12', 51, 'Le conseil des Harkonnen', :'a'::uuid),
  ('Titre MARQUEUR-B-688D5C05', '2026-01-11', 20, 'Note MARQUEUR-B-E52E661A', :'b'::uuid),
  ('Titre MARQUEUR-B-688D5C05', '2026-01-12', 22, 'Note MARQUEUR-B-93262276', :'b'::uuid),
  ('Titre MARQUEUR-B-7A22A34C', '2026-02-11', 18, 'Note MARQUEUR-B-D91CE594', :'b'::uuid),
  ('Titre MARQUEUR-B-7A22A34C', '2026-02-14', 27, 'Note MARQUEUR-B-E75A0F51', :'b'::uuid),
  ('Titre MARQUEUR-B-FCC90408', '2026-03-11', 15, 'Note MARQUEUR-B-263775C7', :'b'::uuid),
  ('Titre MARQUEUR-B-D419620E', '2026-04-11', 31, 'Note MARQUEUR-B-9A9758B7', :'b'::uuid)
) as v(title, read_on, pages, note, owner)
join public.books bk on bk.title = v.title and bk.owner_id = v.owner;

commit;
