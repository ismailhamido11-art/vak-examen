-- Graine « streakmates » (suivi d'habitudes). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- Suppose les migrations passées et A, B dans auth.users (le déclencheur on_auth_user_created a créé leurs profils).
-- A : 1 profil, 2 groupes (seul membre de chacun), 6 habitudes, 15 check-ins, 4 réactions, 3 rappels envoyés, 5 tâches,
--     3 complétions, 4 séances de focus, 6 positions d'habitudes. A et B ne partagent aucun groupe.
-- B : lignes différentes (nombres distincts), chaque texte libre porte un marqueur unique.
\set ON_ERROR_STOP on
begin;

-- Profils (créés par le déclencheur à l'insertion dans auth.users)
update public.profiles set display_name = 'Alice', username = 'alice_streaks', timezone = 'Europe/Paris'
  where id = :'a'::uuid;
update public.profiles set display_name = 'Profil MARQUEUR-B-A73A0C9C', timezone = 'UTC'
  where id = :'b'::uuid;

-- Groupes : A est créatrice et seule membre ; B a le sien
insert into public.groups (name, emoji, invite_code, created_by) values
  ('Run Club', '🏃', 'K7M2QX', :'a'::uuid),
  ('Book Club', '📚', 'W4P9TD', :'a'::uuid),
  ('Groupe MARQUEUR-B-FD728C68', '🔥', 'H8R3VZ', :'b'::uuid);

insert into public.group_members (group_id, user_id, role)
select g.id, g.created_by, 'owner' from public.groups g where g.created_by in (:'a'::uuid, :'b'::uuid);

-- Habitudes
insert into public.habits (owner_id, group_id, title, emoji, color, cadence, target_days, target_per_week, sort_order)
select v.owner, g.id, v.title, v.emoji, v.color, v.cadence, v.days::smallint[], v.per_week, v.ord
from (values
  (:'a'::uuid, null,         'Morning run',      '🏃', 'green',  'daily',  '{}',      1, 0),
  (:'a'::uuid, null,         'Read 20 pages',    '📖', 'blue',   'daily',  '{}',      1, 1),
  (:'a'::uuid, null,         'Meditate',         '🧘', 'purple', 'days',   '{1,3,5}', 1, 2),
  (:'a'::uuid, null,         'Water the plants', '🌱', 'teal',   'weekly', '{}',      2, 3),
  (:'a'::uuid, 'Run Club',   'Team stretch',     '🤸', 'amber',  'daily',  '{}',      1, 4),
  (:'a'::uuid, 'Book Club',  'Weekly review',    '📝', 'coral',  'weekly', '{}',      1, 5),
  (:'b'::uuid, null,         'Habitude MARQUEUR-B-49DFAB62', '💧', 'blue',   'daily',  '{}',      1, 0),
  (:'b'::uuid, null,         'Habitude MARQUEUR-B-8D323832', '🚴', 'green',  'days',   '{2,4}',   1, 1),
  (:'b'::uuid, null,         'Habitude MARQUEUR-B-F698D0A0', '🎸', 'coral',  'weekly', '{}',      3, 2),
  (:'b'::uuid, 'Groupe MARQUEUR-B-FD728C68', 'Habitude MARQUEUR-B-7B0B7ABC', '🔥', 'amber', 'daily', '{}', 1, 3)
) as v(owner, grp, title, emoji, color, cadence, days, per_week, ord)
left join public.groups g on g.name = v.grp and g.created_by = v.owner;

-- Ordre personnel : une position par habitude pour A (6) ; B n'en a que 3
insert into public.habit_order (user_id, habit_id, position)
select h.owner_id, h.id, h.sort_order from public.habits h
where h.owner_id = :'a'::uuid or (h.owner_id = :'b'::uuid and h.sort_order < 3);

-- Check-ins de A : 6 + 4 + 3 + 2 = 15
insert into public.check_ins (habit_id, user_id, local_date, note)
select h.id, h.owner_id, current_date - d, null
from public.habits h
join (values
  ('Morning run', 0), ('Morning run', 1), ('Morning run', 2), ('Morning run', 3), ('Morning run', 4), ('Morning run', 5),
  ('Read 20 pages', 0), ('Read 20 pages', 1), ('Read 20 pages', 2), ('Read 20 pages', 3),
  ('Meditate', 0), ('Meditate', 2), ('Meditate', 4),
  ('Water the plants', 1), ('Water the plants', 3)
) as v(title, d) on v.title = h.title
where h.owner_id = :'a'::uuid;
update public.check_ins set note = 'Easy pace, felt good'
  where user_id = :'a'::uuid and local_date = current_date
    and habit_id = (select id from public.habits where owner_id = :'a'::uuid and title = 'Morning run');

-- Check-ins de B : 5, chaque note porte un marqueur
insert into public.check_ins (habit_id, user_id, local_date, note)
select h.id, h.owner_id, current_date - v.d, v.note
from public.habits h
join (values
  ('Habitude MARQUEUR-B-49DFAB62', 0, 'Note MARQUEUR-B-E6E67E80'),
  ('Habitude MARQUEUR-B-49DFAB62', 1, 'Note MARQUEUR-B-6A307099'),
  ('Habitude MARQUEUR-B-8D323832', 0, 'Note MARQUEUR-B-7498979E'),
  ('Habitude MARQUEUR-B-F698D0A0', 2, 'Note MARQUEUR-B-F23446F3'),
  ('Habitude MARQUEUR-B-7B0B7ABC', 1, 'Note MARQUEUR-B-D5DFFF47')
) as v(title, d, note) on v.title = h.title
where h.owner_id = :'b'::uuid;

-- Réactions : 4 de A (sur ses propres check-ins), 2 de B (sur les siens)
insert into public.reactions (check_in_id, user_id, emoji)
select c.id, c.user_id, v.emoji
from public.check_ins c
join public.habits h on h.id = c.habit_id
join (values
  ('Morning run', 0, '🔥'), ('Morning run', 1, '💪'), ('Read 20 pages', 0, '👏'), ('Meditate', 0, '🙌')
) as v(title, d, emoji) on v.title = h.title and c.local_date = current_date - v.d
where c.user_id = :'a'::uuid;
insert into public.reactions (check_in_id, user_id, emoji)
select c.id, c.user_id, '😂' from public.check_ins c
where c.user_id = :'b'::uuid and c.note in ('Note MARQUEUR-B-E6E67E80', 'Note MARQUEUR-B-7498979E');

-- Rappels envoyés par A à B (3). B n'en envoie aucun : il faudrait les adresser à A, qui les verrait.
insert into public.nudges (habit_id, from_user, to_user, nudge_day)
select h.id, :'a'::uuid, :'b'::uuid, current_date - v.d
from public.habits h
join (values ('Morning run', 0), ('Morning run', 1), ('Read 20 pages', 0)) as v(title, d) on v.title = h.title
where h.owner_id = :'a'::uuid;

-- Tâches : A 5 (dont une dans chacun de ses groupes), B 3
insert into public.tasks (user_id, group_id, title, position, completion)
select v.owner, g.id, v.title, v.pos, v.completion
from (values
  (:'a'::uuid, null,        'Email the landlord',     0, 'once'),
  (:'a'::uuid, null,        'Renew passport',         1, 'once'),
  (:'a'::uuid, null,        'Book dentist',           2, 'once'),
  (:'a'::uuid, 'Run Club',  'Register for the 10k',   3, 'once'),
  (:'a'::uuid, 'Book Club', 'Pick next book',         4, 'everyone'),
  (:'b'::uuid, null,        'Tâche MARQUEUR-B-8F2C8443', 0, 'once'),
  (:'b'::uuid, null,        'Tâche MARQUEUR-B-185BAC35', 1, 'once'),
  (:'b'::uuid, 'Groupe MARQUEUR-B-FD728C68', 'Tâche MARQUEUR-B-2891C76F', 2, 'everyone')
) as v(owner, grp, title, pos, completion)
left join public.groups g on g.name = v.grp and g.created_by = v.owner;

-- Complétions : A 3 (tâches faites), B 2
insert into public.task_completions (task_id, user_id, done_at)
select t.id, t.user_id, now() - interval '1 day'
from public.tasks t
where (t.user_id = :'a'::uuid and t.title in ('Email the landlord', 'Book dentist', 'Pick next book'))
   or (t.user_id = :'b'::uuid and t.title in ('Tâche MARQUEUR-B-8F2C8443', 'Tâche MARQUEUR-B-2891C76F'));
update public.tasks t set done_at = c.done_at
  from public.task_completions c where c.task_id = t.id and c.user_id = t.user_id;

-- Séances de focus : A 4, B 3
insert into public.focus_sessions (user_id, task_id, started_at, minutes)
select :'a'::uuid, t.id, now() - v.ago, v.minutes
from (values
  ('Email the landlord', interval '2 hours', 25), ('Renew passport', interval '5 hours', 50),
  ('Renew passport', interval '8 hours', 25), (null, interval '10 hours', 45)
) as v(title, ago, minutes)
left join public.tasks t on t.title = v.title and t.user_id = :'a'::uuid;
insert into public.focus_sessions (user_id, task_id, started_at, minutes)
select :'b'::uuid, t.id, now() - v.ago, v.minutes
from (values
  ('Tâche MARQUEUR-B-8F2C8443', interval '3 hours', 30), ('Tâche MARQUEUR-B-185BAC35', interval '6 hours', 15),
  (null, interval '9 hours', 60)
) as v(title, ago, minutes)
left join public.tasks t on t.title = v.title and t.user_id = :'b'::uuid;

commit;
