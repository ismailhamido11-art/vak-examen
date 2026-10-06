-- Graine « track_training_app » (carnet d'entraînement d'athlétisme). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 6 séances, 9 exercices de séance, 5 événements, 4 succès, 3 records, 2 équipes (dont A est le seul membre), 2 appartenances.
-- B : 4 séances, 5 exercices de séance, 3 événements, 3 succès, 2 records, 2 équipes privées, 2 appartenances ; chaque texte libre porte un marqueur unique.
-- Les 8 exercices du catalogue (public.exercises) viennent des migrations : partagés, ils ne portent aucun marqueur.
\set ON_ERROR_STOP on
begin;

insert into public.workouts (title, notes, workout_type, workout_date, user_id) values
  ('Easy run 5 km', 'Steady pace, felt good', 'running', '2026-03-02', :'a'::uuid),
  ('Hill repeats', '8 reps on the long hill', 'running', '2026-03-05', :'a'::uuid),
  ('Squat day', 'Heavy triples', 'lift', '2026-03-07', :'a'::uuid),
  ('Long jump session', 'Approach run drills', 'jumps', '2026-03-10', :'a'::uuid),
  ('Shot put technique', 'Glide drills', 'throws', '2026-03-14', :'a'::uuid),
  ('Tempo 400s', '6 x 400 m at tempo', 'running', '2026-03-18', :'a'::uuid),
  ('Séance MARQUEUR-B-730E027A', 'Notes MARQUEUR-B-54832922', 'running', '2026-03-03', :'b'::uuid),
  ('Séance MARQUEUR-B-1830F78A', 'Notes MARQUEUR-B-4E7886AB', 'lift', '2026-03-06', :'b'::uuid),
  ('Séance MARQUEUR-B-BA8A3B9C', 'Notes MARQUEUR-B-06BC0257', 'jumps', '2026-03-09', :'b'::uuid),
  ('Séance MARQUEUR-B-61658550', 'Notes MARQUEUR-B-33B01628', 'throws', '2026-03-12', :'b'::uuid);

insert into public.workout_entries (workout_id, user_id, label, notes, exercise, event_code, implement_weight_kg, exercise_id, sets, reps, distance_m)
select w.id, w.user_id, v.label, v.notes, v.exercise, v.event_code, v.implement, v.exercise_id, v.sets, v.reps, v.distance_m
from (values
  ('Easy run 5 km', 'a', 'Easy run', 'Conversational pace', '5 km easy', null, null, null, 1, null, 5000),
  ('Hill repeats', 'a', 'Hill reps', 'Jog down recovery', 'Hill repeats', null, null, null, 1, 8, null),
  ('Hill repeats', 'a', 'Cooldown', 'Easy jog', 'Cooldown jog', null, null, null, 1, null, 1600),
  ('Squat day', 'a', 'Back squat', '3 x 3 at 100 kg', 'Back squat', null, null, null, 3, 3, null),
  ('Squat day', 'a', 'Romanian deadlift', '3 x 8', 'Romanian deadlift', null, null, null, 3, 8, null),
  ('Long jump session', 'a', 'Long jump', 'Six full approaches', 'Long jump', 'long_jump', null, (select exercise_id from public.exercises where name = 'Long Jump'), 6, null, null),
  ('Shot put technique', 'a', 'Shot put', 'Standing throws', 'Shot put', 'shot_put', 7.26, (select exercise_id from public.exercises where name = 'Shot Put'), 5, null, null),
  ('Tempo 400s', 'a', 'Tempo 400', '6 reps, 90 s rest', '400 m tempo', null, null, null, 1, 6, 400),
  ('Tempo 400s', 'a', 'Warm-up', 'Dynamic drills', 'Warm-up', null, null, null, 1, null, null),
  ('Séance MARQUEUR-B-730E027A', 'b', 'Run MARQUEUR-B-659C557F', 'Notes MARQUEUR-B-DE0EB7F4', 'Exercice MARQUEUR-B-0FF949DF', null, null, null, 1, null, null),
  ('Séance MARQUEUR-B-1830F78A', 'b', 'Lift MARQUEUR-B-D40A275A', 'Notes MARQUEUR-B-F99EA23F', 'Exercice MARQUEUR-B-E2DCD2CA', null, null, null, 1, null, null),
  ('Séance MARQUEUR-B-BA8A3B9C', 'b', 'Jump MARQUEUR-B-C14B1793', 'Notes MARQUEUR-B-A050AB53', 'Exercice MARQUEUR-B-F1832CB4', 'triple_jump', null, (select exercise_id from public.exercises where name = 'Triple Jump'), 1, null, null),
  ('Séance MARQUEUR-B-61658550', 'b', 'Throw MARQUEUR-B-A2177D25', 'Notes MARQUEUR-B-8C8CDCB8', 'Exercice MARQUEUR-B-837A465C', 'discus', 1.75, (select exercise_id from public.exercises where name = 'Discus'), 1, null, null),
  ('Séance MARQUEUR-B-730E027A', 'b', 'Cooldown MARQUEUR-B-C87F85A5', 'Notes MARQUEUR-B-755BCBB0', 'Exercice MARQUEUR-B-61C96470', null, null, null, 1, null, null)
) as v(wtitle, own, label, notes, exercise, event_code, implement, exercise_id, sets, reps, distance_m)
join public.workouts w on w.title = v.wtitle and w.user_id = (case v.own when 'a' then :'a'::uuid else :'b'::uuid end);

insert into public.calendar_events (title, notes, starts_at, user_id) values
  ('Spring opener meet', 'Bring spikes', '2026-04-04 09:00+00', :'a'::uuid),
  ('Team practice', 'Track, 4 pm', '2026-04-07 16:00+00', :'a'::uuid),
  ('Physio appointment', 'Left hamstring', '2026-04-09 11:30+00', :'a'::uuid),
  ('Regional qualifier', 'Warm-up at 7 am', '2026-04-18 08:00+00', :'a'::uuid),
  ('Strength session', 'Weight room', '2026-04-21 17:00+00', :'a'::uuid),
  ('Événement MARQUEUR-B-78DBE3BD', 'Notes MARQUEUR-B-9F287CDC', '2026-04-05 10:00+00', :'b'::uuid),
  ('Événement MARQUEUR-B-4C405FF5', 'Notes MARQUEUR-B-D89B224C', '2026-04-12 15:00+00', :'b'::uuid),
  ('Événement MARQUEUR-B-BBD30E72', 'Notes MARQUEUR-B-B7729EBD', '2026-04-19 12:00+00', :'b'::uuid);

insert into public.achievements (type, value_text, user_id) values
  ('first_workout', 'First workout logged', :'a'::uuid),
  ('streak_7', 'Seven-day streak', :'a'::uuid),
  ('pr_long_jump', 'New long jump record', :'a'::uuid),
  ('workout_10', 'Ten workouts logged', :'a'::uuid),
  ('first_workout', 'Succès MARQUEUR-B-380C3F62', :'b'::uuid),
  ('streak_7', 'Succès MARQUEUR-B-BE595664', :'b'::uuid),
  ('pr_shot_put', 'Succès MARQUEUR-B-2FE2E810', :'b'::uuid);

insert into public.exercise_prs (user_id, exercise_id, best_time_text) values
  (:'a'::uuid, (select exercise_id from public.exercises where name = 'Long Jump'), '6.12 m'),
  (:'a'::uuid, (select exercise_id from public.exercises where name = 'Shot Put'), '11.80 m'),
  (:'a'::uuid, (select exercise_id from public.exercises where name = 'Javelin'), '38.40 m'),
  (:'b'::uuid, (select exercise_id from public.exercises where name = 'High Jump'), 'Record MARQUEUR-B-4B8C1557'),
  (:'b'::uuid, (select exercise_id from public.exercises where name = 'Discus'), 'Record MARQUEUR-B-D6BC5713');

insert into public.teams (name, slug, description, visibility, created_by) values
  ('Riverside Sprinters', 'riverside-sprinters', 'Local club team', 'private', :'a'::uuid),
  ('Hilltop Throwers', 'hilltop-throwers', 'Local club team', 'private', :'a'::uuid),
  ('Équipe MARQUEUR-B-422726C2', 'equipe-422726c2', 'Description MARQUEUR-B-E497EF25', 'private', :'b'::uuid),
  ('Équipe MARQUEUR-B-078706DC', 'equipe-078706dc', 'Description MARQUEUR-B-71E561F6', 'private', :'b'::uuid);

insert into public.team_memberships (team_id, user_id, role_title, member_type, management_role, status, joined_at)
select v.team_id, v.user_id, v.role_title, 'athlete', 'owner', 'active', '2026-01-15'
from (values
  ((select id from public.teams where name = 'Riverside Sprinters'), :'a'::uuid, 'Captain'),
  ((select id from public.teams where name = 'Hilltop Throwers'), :'a'::uuid, 'Coach and captain'),
  ((select id from public.teams where name = 'Équipe MARQUEUR-B-422726C2'), :'b'::uuid, 'Rôle MARQUEUR-B-C1EC6E72'),
  ((select id from public.teams where name = 'Équipe MARQUEUR-B-078706DC'), :'b'::uuid, 'Rôle MARQUEUR-B-782EBC59')
) as v(team_id, user_id, role_title);

commit;
