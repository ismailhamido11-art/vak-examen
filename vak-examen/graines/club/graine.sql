-- Graine « club » (planning de clubs de sport). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 3 clubs (seul membre, propriétaire), 3 adhésions, 2 invitations envoyées, 6 entraînements (A créateur et encadrant),
--     10 présences notées (toutes « présent »).
-- B : 2 clubs, 2 adhésions, 2 invitations, 3 entraînements, 4 présences ; chaque texte libre porte un marqueur unique.
-- Aucune donnée partagée : A n'est membre d'aucun club de B et inversement.
\set ON_ERROR_STOP on
begin;

-- Le déclencheur clubs_add_owner crée l'adhésion « owner » du créateur.
insert into public.clubs (name, sport, created_by) values
  ('FC Rivière', 'football', :'a'::uuid),
  ('Judo Club des Lilas', 'judo', :'a'::uuid),
  ('Tennis de table Pasteur', 'tennis de table', :'a'::uuid),
  ('Club MARQUEUR-B-F8D67580', 'Sport MARQUEUR-B-E0082817', :'b'::uuid),
  ('Club MARQUEUR-B-C1B4CA86', 'Sport MARQUEUR-B-C403D422', :'b'::uuid);

-- Le champ e-mail de l'adhésion de B est un texte libre : on y met le marqueur (l'e-mail doit rester en minuscules).
update public.club_members set email = lower('MARQUEUR-B-0F97D66E') || '@example.test'
  where user_id = :'b'::uuid and club_id = (select id from public.clubs where name = 'Club MARQUEUR-B-F8D67580');
update public.club_members set email = lower('MARQUEUR-B-E452EAED') || '@example.test'
  where user_id = :'b'::uuid and club_id = (select id from public.clubs where name = 'Club MARQUEUR-B-C1B4CA86');

-- Invitations en attente vers des adresses sans compte.
insert into public.club_invitations (club_id, email, role, invited_by) values
  ((select id from public.clubs where name = 'FC Rivière'), 'claire.dupont@example.test', 'coach', :'a'::uuid),
  ((select id from public.clubs where name = 'Judo Club des Lilas'), 'omar.benali@example.test', 'viewer', :'a'::uuid),
  ((select id from public.clubs where name = 'Club MARQUEUR-B-F8D67580'), lower('MARQUEUR-B-D27D91B9') || '@example.test', 'coach', :'b'::uuid),
  ((select id from public.clubs where name = 'Club MARQUEUR-B-C1B4CA86'), lower('MARQUEUR-B-A84D2657') || '@example.test', 'viewer', :'b'::uuid);

-- Entraînements : A est créateur et encadrant de tous les siens (A est owner de ses clubs, le déclencheur l'accepte).
insert into public.trainings (club_id, title, starts_at, duration_minutes, location, capacity, status, coach_id, created_by) values
  ((select id from public.clubs where name = 'FC Rivière'), 'Entraînement du mardi', '2026-09-01 18:30+02', 90, 'Stade Rivière', 20, 'fait', :'a'::uuid, :'a'::uuid),
  ((select id from public.clubs where name = 'FC Rivière'), 'Match amical', '2026-09-12 15:00+02', 120, 'Stade Rivière', 22, 'fait', :'a'::uuid, :'a'::uuid),
  ((select id from public.clubs where name = 'FC Rivière'), 'Entraînement du jeudi', '2026-10-15 18:30+02', 90, 'Stade Rivière', 20, 'prevu', :'a'::uuid, :'a'::uuid),
  ((select id from public.clubs where name = 'Judo Club des Lilas'), 'Randori du mercredi', '2026-09-02 19:00+02', 60, 'Dojo des Lilas', 12, 'fait', :'a'::uuid, :'a'::uuid),
  ((select id from public.clubs where name = 'Judo Club des Lilas'), 'Passage de ceinture', '2026-10-24 10:00+02', 180, 'Dojo des Lilas', 15, 'prevu', :'a'::uuid, :'a'::uuid),
  ((select id from public.clubs where name = 'Tennis de table Pasteur'), 'Tournoi interne', '2026-09-20 14:00+02', 240, 'Gymnase Pasteur', 16, 'annule', :'a'::uuid, :'a'::uuid),
  ((select id from public.clubs where name = 'Club MARQUEUR-B-F8D67580'), 'Séance MARQUEUR-B-886719B2', '2026-09-03 18:00+02', 60, 'Salle MARQUEUR-B-7313A750', 10, 'fait', :'b'::uuid, :'b'::uuid),
  ((select id from public.clubs where name = 'Club MARQUEUR-B-F8D67580'), 'Séance MARQUEUR-B-A38B4C6A', '2026-09-10 18:00+02', 60, 'Salle MARQUEUR-B-78EE50C7', 10, 'fait', :'b'::uuid, :'b'::uuid),
  ((select id from public.clubs where name = 'Club MARQUEUR-B-C1B4CA86'), 'Séance MARQUEUR-B-E3668CB4', '2026-09-17 20:00+02', 75, 'Salle MARQUEUR-B-7FF45293', 8, 'prevu', :'b'::uuid, :'b'::uuid);

-- Présences (toutes « présent ») ; participant_name est un texte libre.
insert into public.attendances (training_id, participant_name, present, amount_paid, noted_by)
select t.id, v.participant, true, v.amount, v.noter
from (values
  ('Entraînement du mardi', 'Léa Martin', 5.00, :'a'::uuid),
  ('Entraînement du mardi', 'Hugo Petit', 5.00, :'a'::uuid),
  ('Entraînement du mardi', 'Inès Moreau', 0.00, :'a'::uuid),
  ('Match amical', 'Léa Martin', 0.00, :'a'::uuid),
  ('Match amical', 'Hugo Petit', 0.00, :'a'::uuid),
  ('Randori du mercredi', 'Yanis Roux', 8.00, :'a'::uuid),
  ('Randori du mercredi', 'Sofia Girard', 8.00, :'a'::uuid),
  ('Randori du mercredi', 'Paul Lambert', 8.00, :'a'::uuid),
  ('Tournoi interne', 'Chloé Fabre', 3.50, :'a'::uuid),
  ('Tournoi interne', 'Noé Blanc', 3.50, :'a'::uuid),
  ('Séance MARQUEUR-B-886719B2', 'Participant MARQUEUR-B-F46FA99F', 4.00, :'b'::uuid),
  ('Séance MARQUEUR-B-886719B2', 'Participant MARQUEUR-B-5E3FE3A3', 4.00, :'b'::uuid),
  ('Séance MARQUEUR-B-A38B4C6A', 'Participant MARQUEUR-B-037A3B95', 4.00, :'b'::uuid),
  ('Séance MARQUEUR-B-E3668CB4', 'Participant MARQUEUR-B-A7279D2B', 6.00, :'b'::uuid)
) as v(title, participant, amount, noter)
join public.trainings t on t.title = v.title and t.created_by = v.noter;

commit;
