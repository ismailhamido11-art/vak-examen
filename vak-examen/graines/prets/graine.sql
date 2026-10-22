-- Graine « prets » (prêt d'objets entre proches). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 10 objets, 8 prêts (tous en cours : pas d'ambiguïté entre « mes prêts » et « mes prêts en cours »).
-- B : 4 objets, 3 prêts (dont un rendu) ; chaque texte libre porte un marqueur unique.
-- Le déclencheur loans_bump_times_lent fixe times_lent ; la graine ne l'écrit pas.
\set ON_ERROR_STOP on
begin;

insert into public.items (name, category, owner_id) values
  ('Perceuse sans fil', 'outil', :'a'::uuid),
  ('Scie sauteuse', 'outil', :'a'::uuid),
  ('Échelle pliante', 'outil', :'a'::uuid),
  ('Le Comte de Monte-Cristo', 'livre', :'a'::uuid),
  ('Dune', 'livre', :'a'::uuid),
  ('Sapiens', 'livre', :'a'::uuid),
  ('Catan', 'jeu', :'a'::uuid),
  ('Dixit', 'jeu', :'a'::uuid),
  ('Tente deux places', 'autre', :'a'::uuid),
  ('Projecteur vidéo', 'autre', :'a'::uuid),
  ('Objet MARQUEUR-B-80FC92D2', 'outil', :'b'::uuid),
  ('Objet MARQUEUR-B-30B936C2', 'livre', :'b'::uuid),
  ('Objet MARQUEUR-B-827CDC63', 'jeu', :'b'::uuid),
  ('Objet MARQUEUR-B-30B1EDF1', 'autre', :'b'::uuid);

insert into public.loans (owner_id, item_id, borrower, lent_on, due_on, returned_on, condition_note)
select i.owner_id, i.id, v.borrower, v.lent_on::date, v.due_on::date, v.returned_on::date, v.note
from (values
  ('Perceuse sans fil', 'Camille', '2026-08-01', '2026-08-15', null, null, :'a'::uuid),
  ('Scie sauteuse', 'Julien', '2026-08-20', '2026-09-03', null, null, :'a'::uuid),
  ('Échelle pliante', 'Sophie', '2026-09-10', '2026-09-24', null, null, :'a'::uuid),
  ('Le Comte de Monte-Cristo', 'Marc', '2026-09-15', '2026-10-15', null, null, :'a'::uuid),
  ('Dune', 'Léa', '2026-09-28', '2026-10-26', null, null, :'a'::uuid),
  ('Catan', 'Thomas', '2026-10-01', '2026-10-15', null, null, :'a'::uuid),
  ('Tente deux places', 'Nadia', '2026-10-05', '2026-11-02', null, null, :'a'::uuid),
  ('Projecteur vidéo', 'Hugo', '2026-10-08', '2026-10-22', null, null, :'a'::uuid),
  ('Objet MARQUEUR-B-80FC92D2', 'Emprunteur MARQUEUR-B-FCC4709B', '2026-08-03', '2026-08-17', null, 'Remarque MARQUEUR-B-A0CF573D', :'b'::uuid),
  ('Objet MARQUEUR-B-30B936C2', 'Emprunteur MARQUEUR-B-8ECC5EA9', '2026-08-10', '2026-08-24', '2026-08-22', 'Remarque MARQUEUR-B-4B573024', :'b'::uuid),
  ('Objet MARQUEUR-B-827CDC63', 'Emprunteur MARQUEUR-B-B10E651F', '2026-09-01', '2026-09-15', null, 'Remarque MARQUEUR-B-D7E78985', :'b'::uuid)
) as v(item, borrower, lent_on, due_on, returned_on, note, owner)
join public.items i on i.name = v.item and i.owner_id = v.owner;

commit;
