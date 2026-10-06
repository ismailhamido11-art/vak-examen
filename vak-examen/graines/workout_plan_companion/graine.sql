-- Graine « workout_plan_companion » (compagnon de plans d'entraînement). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 1 profil, 1 préférence, 3 versions de plan (la 3e active), 3 conversations / 6 messages, 2 propositions,
--     3 séances terminées, 1 copie d'historique, 1 consentement (version courante de l'app), 3 jours d'usage, 3 exercices créés par l'assistant.
-- B : mêmes tables, d'autres lignes ; chaque texte libre porte un marqueur unique.
\set ON_ERROR_STOP on
begin;

insert into public.profiles (user_id, first_name, availability, session_duration_minutes, limitations, units, training_preferences, primary_goal, training_experience, equipment_access, training_emphasis) values
  (:'a'::uuid, 'Marta', 'three-days', 60, 'Molestias leves en el hombro derecho', 'metric', 'Prefiero ejercicios con mancuernas', 'strength', 'some-experience', 'dumbbells-and-bench', 'compound-strength'),
  (:'b'::uuid, 'Nombre MARQUEUR-B-BC6C5E81', 'four-days', 45, 'Limitaciones MARQUEUR-B-6FFD9A2E', 'imperial', 'Preferencias MARQUEUR-B-C1823EDD', 'muscle', 'experienced', 'full-gym', 'balanced');

insert into public.user_preferences (user_id, theme_name) values (:'a'::uuid, 'verde-activo'), (:'b'::uuid, 'grafito-naranja');

insert into public.exercise_catalog (id, name, equipment, coaching_cue, source_attribution, owner_user_id, entry_source) values
  ('asistente-a-zancada-atras', 'Zancada hacia atrás', 'Mancuernas', 'Da el paso atrás con control.', 'Asistente IA', :'a'::uuid, 'assistant'),
  ('asistente-a-remo-unilateral', 'Remo unilateral con mancuerna', 'Mancuerna y banco', 'Mantén la espalda larga.', 'Asistente IA', :'a'::uuid, 'assistant'),
  ('asistente-a-puente-gluteo', 'Puente de glúteo', 'Esterilla', 'Empuja con los talones.', 'Asistente IA', :'a'::uuid, 'assistant'),
  ('asistente-b-1', 'Ejercicio MARQUEUR-B-59DC48FF', 'Barra', 'Indicación MARQUEUR-B-644CB4F6', 'Asistente IA', :'b'::uuid, 'assistant'),
  ('asistente-b-2', 'Ejercicio MARQUEUR-B-06694541', 'Polea', 'Indicación MARQUEUR-B-CFD8B2FF', 'Asistente IA', :'b'::uuid, 'assistant');

insert into public.plan_versions (user_id, version_number, name) values
  (:'a'::uuid, 1, 'Plan inicial de fuerza'),
  (:'a'::uuid, 2, 'Plan de fuerza ajustado'),
  (:'a'::uuid, 3, 'Plan equilibrado de otoño'),
  (:'b'::uuid, 1, 'Plan MARQUEUR-B-742E86F2'),
  (:'b'::uuid, 2, 'Plan MARQUEUR-B-298CF82D');

insert into public.plan_weeks (plan_version_id, week_number, goal)
select id, 1, 'Semana de adaptación' from public.plan_versions where user_id in (:'a'::uuid, :'b'::uuid);

insert into public.plan_sessions (plan_week_id, session_position, day_label, title, focus, estimated_minutes)
select w.id, s.pos, s.day, s.title, 'Cuerpo completo', 60
from public.plan_weeks w
join public.plan_versions v on v.id = w.plan_version_id
cross join (values (1, 'Lunes', 'Sesión A'), (2, 'Jueves', 'Sesión B')) as s(pos, day, title)
where v.user_id in (:'a'::uuid, :'b'::uuid);

insert into public.plan_session_exercises (plan_session_id, exercise_position, catalog_exercise_id, exercise_snapshot)
select s.id, 1, case when s.session_position = 1 then 'sentadilla-goblet' else 'remo-sentado' end, '{}'::jsonb
from public.plan_sessions s;

insert into public.active_plan_selection (user_id, plan_version_id)
select user_id, id from public.plan_versions where (user_id = :'a'::uuid and version_number = 3) or (user_id = :'b'::uuid and version_number = 2);

insert into public.assistant_conversations (user_id, source_plan_version_id, status)
select v.user_id, v.id, c.status
from public.plan_versions v
join (values (:'a'::uuid, 1, 'closed'), (:'a'::uuid, 2, 'closed'), (:'a'::uuid, 3, 'active'), (:'b'::uuid, 1, 'closed'), (:'b'::uuid, 2, 'active')) as c(uid, vn, status)
  on c.uid = v.user_id and c.vn = v.version_number;

-- A : 6 messages (2 par conversation), B : 4 messages (2 par conversation)
insert into public.assistant_messages (conversation_id, user_id, role, content)
select c.id, c.user_id, m.role, m.content
from (select c.*, row_number() over (partition by user_id order by created_at, id) as rn from public.assistant_conversations c) c
join (values
  (:'a'::uuid, 1, 'user', 'Quiero un plan más equilibrado'),
  (:'a'::uuid, 1, 'assistant', 'Te propongo repartir los días de fuerza'),
  (:'a'::uuid, 2, 'user', 'Cambia la sentadilla por otra opción'),
  (:'a'::uuid, 2, 'assistant', 'Puedes usar la zancada hacia atrás'),
  (:'a'::uuid, 3, 'user', 'Gracias, ¿y para el hombro?'),
  (:'a'::uuid, 3, 'assistant', 'Evita el press por encima de la cabeza'),
  (:'b'::uuid, 1, 'user', 'Mensaje MARQUEUR-B-3CED51C3'),
  (:'b'::uuid, 1, 'assistant', 'Mensaje MARQUEUR-B-6F770686'),
  (:'b'::uuid, 2, 'user', 'Mensaje MARQUEUR-B-54ED7509'),
  (:'b'::uuid, 2, 'assistant', 'Mensaje MARQUEUR-B-7FFA1661')
) as m(uid, rn, role, content) on m.uid = c.user_id and m.rn = c.rn;

insert into public.plan_proposals (user_id, source_plan_version_id, proposal_snapshot, changes, status)
select v.user_id, v.id, jsonb_build_object('summary', p.summary), '[]'::jsonb, p.status
from public.plan_versions v
join (values
  (:'a'::uuid, 3, 'Repartir mejor la fuerza y el trabajo de espalda', 'reviewable'),
  (:'a'::uuid, 2, 'Sustituir la sentadilla por zancadas', 'dismissed'),
  (:'b'::uuid, 2, 'Resumen MARQUEUR-B-BB54F1E5', 'reviewable'),
  (:'b'::uuid, 1, 'Resumen MARQUEUR-B-E2BCB6BE', 'dismissed')
) as p(uid, vn, summary, status) on p.uid = v.user_id and p.vn = v.version_number;

insert into public.workout_logs (user_id, plan_version_id, plan_session_id, session_title_snapshot, status, started_at, completed_at, units, note)
select v.user_id, v.id, s.id, l.title, 'completed', l.at, l.at + interval '55 minutes', l.units, l.note
from public.plan_versions v
join public.plan_weeks w on w.plan_version_id = v.id
join public.plan_sessions s on s.plan_week_id = w.id
join (values
  (:'a'::uuid, 3, 1, 'Sesión A', timestamptz '2026-09-01 18:00+00', 'metric', 'Buena sesión, subí peso en la sentadilla'),
  (:'a'::uuid, 3, 2, 'Sesión B', timestamptz '2026-09-04 18:00+00', 'metric', 'Un poco cansada'),
  (:'a'::uuid, 2, 1, 'Sesión A', timestamptz '2026-08-20 18:00+00', 'metric', 'Primera sesión del plan ajustado'),
  (:'b'::uuid, 2, 1, 'Sesión MARQUEUR-B-8A4E2C3C', timestamptz '2026-09-02 17:00+00', 'imperial', 'Nota MARQUEUR-B-F1F2DB25'),
  (:'b'::uuid, 1, 1, 'Sesión MARQUEUR-B-409BC9BD', timestamptz '2026-08-21 17:00+00', 'imperial', 'Nota MARQUEUR-B-8EECE796')
) as l(uid, vn, pos, title, at, units, note) on l.uid = v.user_id and l.vn = v.version_number and l.pos = s.session_position;

insert into public.training_history_backups (user_id, plan_count, completed_log_count) values (:'a'::uuid, 3, 3), (:'b'::uuid, 2, 2);

insert into public.assistant_consents (user_id, policy_version) values (:'a'::uuid, '2026-09-20.2'), (:'b'::uuid, 'MARQUEUR-B-7A448822');

insert into public.assistant_usage_daily (user_id, usage_date, turn_count) values
  (:'a'::uuid, '2026-09-01', 4), (:'a'::uuid, '2026-09-02', 2), (:'a'::uuid, '2026-09-03', 5),
  (:'b'::uuid, '2026-09-01', 3), (:'b'::uuid, '2026-09-02', 1);

commit;
