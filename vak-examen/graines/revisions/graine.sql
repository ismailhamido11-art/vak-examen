-- Graine « revisions » (cartes de révision). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 3 paquets, 9 cartes, 12 révisions. B : 3 paquets, 5 cartes, 4 révisions, chaque texte libre porte un marqueur unique.
-- Les révisions passent par le déclencheur de l'app : decks.reviews_count vaut donc le nombre de révisions du paquet.
\set ON_ERROR_STOP on
begin;

insert into public.decks (name, subject, owner_id) values
  ('Anglais courant', 'langue', :'a'::uuid),
  ('Capitales du monde', 'culture', :'a'::uuid),
  ('Droit des contrats', 'examen', :'a'::uuid),
  ('Paquet MARQUEUR-B-CB5416C6', 'langue', :'b'::uuid),
  ('Paquet MARQUEUR-B-7F9A5DB1', 'culture', :'b'::uuid),
  ('Paquet MARQUEUR-B-1756481E', 'examen', :'b'::uuid);

insert into public.cards (deck_id, owner_id, front, back, interval_days, due_date, streak)
select d.id, d.owner_id, v.front, v.back, v.itv, v.due::date, v.streak
from (values
  ('Anglais courant', 'to run out of', 'manquer de', 2, '2026-10-20', 1),
  ('Anglais courant', 'although', 'bien que', 4, '2026-10-26', 2),
  ('Anglais courant', 'to get along with', 's''entendre avec', 1, '2026-10-21', 0),
  ('Capitales du monde', 'Canada', 'Ottawa', 8, '2026-11-02', 3),
  ('Capitales du monde', 'Australie', 'Canberra', 2, '2026-10-24', 1),
  ('Capitales du monde', 'Bolivie', 'Sucre', 1, '2026-10-19', 0),
  ('Droit des contrats', 'Vice du consentement', 'Erreur, dol ou violence', 4, '2026-10-30', 2),
  ('Droit des contrats', 'Cause', 'Contrepartie ou but du contrat', 2, '2026-10-22', 1),
  ('Droit des contrats', 'Nullité relative', 'Protège une partie, prescription de cinq ans', 1, '2026-10-18', 0),
  ('Paquet MARQUEUR-B-CB5416C6', 'Recto MARQUEUR-B-FB4653C2', 'Verso MARQUEUR-B-E15A911C', 1, '2026-10-21', 0),
  ('Paquet MARQUEUR-B-CB5416C6', 'Recto MARQUEUR-B-59EB0F34', 'Verso MARQUEUR-B-B83B7AA6', 2, '2026-10-25', 1),
  ('Paquet MARQUEUR-B-7F9A5DB1', 'Recto MARQUEUR-B-974313E2', 'Verso MARQUEUR-B-87BED15F', 4, '2026-10-28', 2),
  ('Paquet MARQUEUR-B-7F9A5DB1', 'Recto MARQUEUR-B-923A5F1D', 'Verso MARQUEUR-B-54B82924', 1, '2026-10-19', 0),
  ('Paquet MARQUEUR-B-1756481E', 'Recto MARQUEUR-B-2CF36C74', 'Verso MARQUEUR-B-50BCE2B6', 2, '2026-10-23', 1)
) as v(deck, front, back, itv, due, streak)
join public.decks d on d.name = v.deck;

insert into public.reviews (card_id, owner_id, reviewed_on, answer, note)
select c.id, c.owner_id, v.day::date, v.answer, v.note
from (values
  ('to run out of', 'ratee', '2026-10-10', 'Confondu avec to run into'),
  ('to run out of', 'difficile', '2026-10-12', null),
  ('to run out of', 'facile', '2026-10-14', 'Enfin retenu'),
  ('although', 'difficile', '2026-10-16', null),
  ('although', 'facile', '2026-10-20', 'Facile avec la concession'),
  ('to get along with', 'ratee', '2026-10-20', 'Verbe à particule difficile'),
  ('Canada', 'facile', '2026-10-08', null),
  ('Canada', 'facile', '2026-10-09', 'Ottawa, pas Toronto'),
  ('Australie', 'difficile', '2026-10-15', 'Pas Sydney'),
  ('Bolivie', 'ratee', '2026-10-18', 'Deux capitales'),
  ('Vice du consentement', 'facile', '2026-10-17', null),
  ('Cause', 'difficile', '2026-10-19', 'Distinguer cause et objet')
) as v(front, answer, day, note)
join public.cards c on c.front = v.front and c.owner_id = :'a'::uuid
union all
select c.id, c.owner_id, v.day::date, v.answer, v.note
from (values
  ('Recto MARQUEUR-B-FB4653C2', 'ratee', '2026-10-20', 'Note MARQUEUR-B-F367CAF9'),
  ('Recto MARQUEUR-B-59EB0F34', 'facile', '2026-10-21', 'Note MARQUEUR-B-8E9FAD0F'),
  ('Recto MARQUEUR-B-974313E2', 'difficile', '2026-10-22', 'Note MARQUEUR-B-ABACCB4A'),
  ('Recto MARQUEUR-B-2CF36C74', 'facile', '2026-10-22', 'Note MARQUEUR-B-02221CC9')
) as v(front, answer, day, note)
join public.cards c on c.front = v.front and c.owner_id = :'b'::uuid;

commit;
