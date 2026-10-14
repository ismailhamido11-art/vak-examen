-- Graine « workout_app ». Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 8 séances (workouts), 2 recoveries, 1 ligne user_settings. B : 4 workouts, 2 recoveries, 1 user_settings,
-- chaque texte libre de B (et de ses lignes filles) porte un marqueur unique. La bibliothèque partagée (exercises,
-- templates, programs) ne contient aucun marqueur.
\set ON_ERROR_STOP on
begin;

insert into public.muscle_groups (id, name, display_order) values
  ('00000000-0000-4000-8000-000000000001', 'Chest', 1),
  ('00000000-0000-4000-8000-000000000002', 'Legs', 2);
insert into public.exercises (id, name, muscle_group_id, equipment_type) values
  ('00000000-0000-4000-8000-000000000011', 'Bench Press', '00000000-0000-4000-8000-000000000001', 'barbell'),
  ('00000000-0000-4000-8000-000000000012', 'Back Squat', '00000000-0000-4000-8000-000000000002', 'barbell');
insert into public.templates (id, name, category) values
  ('00000000-0000-4000-8000-000000000021', 'Push Day', 'push'),
  ('00000000-0000-4000-8000-000000000022', 'Leg Day', 'legs');
insert into public.programs (id, name, kind, description) values
  ('00000000-0000-4000-8000-000000000031', 'Achilles recovery', 'recovery', 'Shared recovery programme');

-- A : 8 workouts, tous terminés
insert into public.workouts (user_id, template_id, scheduled_for, started_at, completed_at, perceived_effort, notes) values
  (:'a'::uuid, '00000000-0000-4000-8000-000000000021', '2026-08-03', '2026-08-03 18:00+00', '2026-08-03 19:00+00', 7, 'Heavy bench day'),
  (:'a'::uuid, '00000000-0000-4000-8000-000000000022', '2026-08-05', '2026-08-05 18:00+00', '2026-08-05 19:10+00', 8, 'Squats felt strong'),
  (:'a'::uuid, '00000000-0000-4000-8000-000000000021', '2026-08-10', '2026-08-10 18:00+00', '2026-08-10 18:55+00', 6, 'Light push session'),
  (:'a'::uuid, '00000000-0000-4000-8000-000000000022', '2026-08-12', '2026-08-12 18:00+00', '2026-08-12 19:05+00', 7, 'Leg day with tempo work'),
  (:'a'::uuid, '00000000-0000-4000-8000-000000000021', '2026-08-17', '2026-08-17 18:00+00', '2026-08-17 19:00+00', 8, 'New bench PR attempt'),
  (:'a'::uuid, '00000000-0000-4000-8000-000000000022', '2026-08-19', '2026-08-19 18:00+00', '2026-08-19 19:15+00', 9, 'Hard squats'),
  (:'a'::uuid, '00000000-0000-4000-8000-000000000021', '2026-08-24', '2026-08-24 18:00+00', '2026-08-24 18:50+00', 6, 'Deload push'),
  (:'a'::uuid, '00000000-0000-4000-8000-000000000022', '2026-08-26', '2026-08-26 18:00+00', '2026-08-26 19:00+00', 7, 'Deload legs');

-- B : 4 workouts, tous terminés
insert into public.workouts (user_id, template_id, scheduled_for, started_at, completed_at, perceived_effort, notes) values
  (:'b'::uuid, '00000000-0000-4000-8000-000000000021', '2026-08-04', '2026-08-04 07:00+00', '2026-08-04 08:00+00', 7, 'Note MARQUEUR-B-5E7681B8'),
  (:'b'::uuid, '00000000-0000-4000-8000-000000000022', '2026-08-06', '2026-08-06 07:00+00', '2026-08-06 08:00+00', 8, 'Note MARQUEUR-B-FE124381'),
  (:'b'::uuid, '00000000-0000-4000-8000-000000000021', '2026-08-11', '2026-08-11 07:00+00', '2026-08-11 08:00+00', 6, 'Note MARQUEUR-B-BE3C6486'),
  (:'b'::uuid, '00000000-0000-4000-8000-000000000022', '2026-08-13', '2026-08-13 07:00+00', '2026-08-13 08:00+00', 7, 'Note MARQUEUR-B-D1A52B0C');

-- Lignes filles (workout_exercises, sets) pour la première séance de A et de B
insert into public.workout_exercises (id, workout_id, exercise_id, position, notes)
select v.id::uuid, w.id, '00000000-0000-4000-8000-000000000011', 1, v.note
from (values
  ('00000000-0000-4000-8000-0000000000a1', :'a'::uuid, '2026-08-03'::date, 'Warm-up then work sets'),
  ('00000000-0000-4000-8000-0000000000b1', :'b'::uuid, '2026-08-04'::date, 'Note MARQUEUR-B-46E0D996'),
  ('00000000-0000-4000-8000-0000000000b2', :'b'::uuid, '2026-08-06'::date, 'Note MARQUEUR-B-E91CC516')
) as v(id, owner, day, note)
join public.workouts w on w.user_id = v.owner and w.scheduled_for = v.day;

insert into public.sets (workout_exercise_id, set_number, weight, reps, notes) values
  ('00000000-0000-4000-8000-0000000000a1', 1, 100, 5, 'Easy'),
  ('00000000-0000-4000-8000-0000000000a1', 2, 110, 5, 'Solid'),
  ('00000000-0000-4000-8000-0000000000b1', 1, 60, 8, 'Note MARQUEUR-B-625C7B9E'),
  ('00000000-0000-4000-8000-0000000000b2', 1, 80, 6, 'Note MARQUEUR-B-F97AA665');

insert into public.user_settings (user_id, weight_unit, default_rest_seconds) values
  (:'a'::uuid, 'kg', 120),
  (:'b'::uuid, 'lbs', 90);

-- recoveries : A 2, B 2
insert into public.recoveries (id, user_id, program_id, label, side, injury_date, notes) values
  ('00000000-0000-4000-8000-0000000000c1', :'a'::uuid, '00000000-0000-4000-8000-000000000031', 'Left Achilles repair', 'left', '2026-05-04', 'Surgery went well'),
  ('00000000-0000-4000-8000-0000000000c2', :'a'::uuid, '00000000-0000-4000-8000-000000000031', 'Right ankle sprain', 'right', '2026-07-01', 'Mild sprain'),
  ('00000000-0000-4000-8000-0000000000d1', :'b'::uuid, '00000000-0000-4000-8000-000000000031', 'Plan MARQUEUR-B-2D8C1DFC', 'left', '2026-04-10', 'Note MARQUEUR-B-4A8892E2'),
  ('00000000-0000-4000-8000-0000000000d2', :'b'::uuid, '00000000-0000-4000-8000-000000000031', 'Plan MARQUEUR-B-0428DB04', 'right', '2026-06-10', 'Note MARQUEUR-B-BA7983EF');

insert into public.clearances (recovery_id, effective_from, kind, value_pct, source, note) values
  ('00000000-0000-4000-8000-0000000000c1', '2026-06-15', 'weight_bearing', 50, 'clinic', 'Cleared by surgeon'),
  ('00000000-0000-4000-8000-0000000000d1', '2026-06-01', 'weight_bearing', 25, 'clinic', 'Note MARQUEUR-B-5D712D09');
insert into public.events (recovery_id, date, kind, label, note) values
  ('00000000-0000-4000-8000-0000000000c1', '2026-09-01', 'appointment', 'Clinic follow-up', 'Bring the boot'),
  ('00000000-0000-4000-8000-0000000000d1', '2026-09-02', 'appointment', 'Visit MARQUEUR-B-18A4F919', 'Note MARQUEUR-B-CCE6B80F');
insert into public.rules (recovery_id, position, kind, title, detail) values
  ('00000000-0000-4000-8000-0000000000c1', 1, 'rule', 'Keep the boot on', 'Except in bed'),
  ('00000000-0000-4000-8000-0000000000d1', 1, 'rule', 'Rule MARQUEUR-B-F3F033C2', 'Detail of the rule');
insert into public.daily_checks (recovery_id, date, pain_0_10, note) values
  ('00000000-0000-4000-8000-0000000000c1', '2026-09-01', 2, 'Slept well'),
  ('00000000-0000-4000-8000-0000000000d1', '2026-09-01', 3, 'Note MARQUEUR-B-DDB5073D');

commit;
