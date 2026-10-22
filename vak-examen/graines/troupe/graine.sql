-- Graine « troupe » (troupes de théâtre). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 3 troupes (seul membre, propriétaire), 3 adhésions, 5 spectacles, 9 personnages (A titulaire de tous, statuts
-- a_apprendre/en_cours, sans doublure). B : 2 troupes, 2 adhésions, 3 spectacles, 5 personnages ; chaque texte libre de B
-- porte un marqueur unique. Aucune troupe n'est partagée : A ne voit rien de B.
\set ON_ERROR_STOP on
begin;

insert into public.troupes (nom, ville, created_by) values
  ('Les Tréteaux du Midi', 'Toulouse', :'a'::uuid),
  ('Compagnie des Quatre Vents', 'Nantes', :'a'::uuid),
  ('Théâtre de la Lanterne', 'Lyon', :'a'::uuid),
  ('Troupe MARQUEUR-B-9F4044E8', 'Ville MARQUEUR-B-5519AEEC', :'b'::uuid),
  ('Troupe MARQUEUR-B-54861542', 'Ville MARQUEUR-B-250B90DC', :'b'::uuid);

insert into public.troupe_members (troupe_id, user_id, role)
select id, created_by, 'owner' from public.troupes;

insert into public.shows (troupe_id, titre, auteur, premiere, statut, created_by)
select t.id, v.titre, v.auteur, v.premiere::date, v.statut, t.created_by
from (values
  ('Les Tréteaux du Midi', 'Le Malade imaginaire', 'Molière', '2026-03-14', 'a_l_affiche'),
  ('Les Tréteaux du Midi', 'Cyrano de Bergerac', 'Edmond Rostand', '2026-06-20', 'en_preparation'),
  ('Compagnie des Quatre Vents', 'Le Jeu de l''amour et du hasard', 'Marivaux', '2025-11-08', 'termine'),
  ('Compagnie des Quatre Vents', 'Antigone', 'Jean Anouilh', '2026-09-12', 'en_preparation'),
  ('Théâtre de la Lanterne', 'En attendant Godot', 'Samuel Beckett', '2026-05-02', 'a_l_affiche'),
  ('Troupe MARQUEUR-B-9F4044E8', 'Titre MARQUEUR-B-5E950C2E', 'Auteur MARQUEUR-B-CF43A180', '2026-02-01', 'a_l_affiche'),
  ('Troupe MARQUEUR-B-9F4044E8', 'Titre MARQUEUR-B-CE45BD0F', 'Auteur MARQUEUR-B-C4FA87C7', '2026-04-01', 'en_preparation'),
  ('Troupe MARQUEUR-B-54861542', 'Titre MARQUEUR-B-A1D2CAED', 'Auteur MARQUEUR-B-10D801B1', '2026-07-01', 'termine')
) as v(troupe, titre, auteur, premiere, statut)
join public.troupes t on t.nom = v.troupe;

insert into public.characters (show_id, nom, repliques, statut, titulaire_id, created_by)
select s.id, v.nom, v.repliques, v.statut, s.created_by, s.created_by
from (values
  ('Le Malade imaginaire', 'Argan', 210, 'en_cours'),
  ('Le Malade imaginaire', 'Toinette', 160, 'a_apprendre'),
  ('Le Malade imaginaire', 'Béralde', 75, 'a_apprendre'),
  ('Cyrano de Bergerac', 'Cyrano', 480, 'en_cours'),
  ('Cyrano de Bergerac', 'Roxane', 190, 'a_apprendre'),
  ('Le Jeu de l''amour et du hasard', 'Silvia', 150, 'en_cours'),
  ('Antigone', 'Antigone', 220, 'a_apprendre'),
  ('Antigone', 'Créon', 175, 'en_cours'),
  ('En attendant Godot', 'Vladimir', 260, 'a_apprendre'),
  ('Titre MARQUEUR-B-5E950C2E', 'Rôle MARQUEUR-B-BA9F384D', 120, 'en_cours'),
  ('Titre MARQUEUR-B-5E950C2E', 'Rôle MARQUEUR-B-B46886BC', 60, 'a_apprendre'),
  ('Titre MARQUEUR-B-CE45BD0F', 'Rôle MARQUEUR-B-C2EFC804', 90, 'su'),
  ('Titre MARQUEUR-B-CE45BD0F', 'Rôle MARQUEUR-B-C45B8158', 45, 'a_apprendre'),
  ('Titre MARQUEUR-B-A1D2CAED', 'Rôle MARQUEUR-B-2BCE609B', 300, 'en_cours')
) as v(show, nom, repliques, statut)
join public.shows s on s.titre = v.show;

commit;
