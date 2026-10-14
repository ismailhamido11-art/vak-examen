-- Graine « split_free_frontend » (SplitFree, dépenses partagées). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 4 groupes (dont il est le seul membre), 4 appartenances, 3 amis, 2 demandes d'ami envoyées, 5 invitations envoyées.
-- B : 2 groupes, 2 appartenances, 2 amis, 2 demandes, 2 invitations ; chaque texte libre de B porte un marqueur unique.
-- Cinq comptes d'amis (ami-1 à ami-5) sont ajoutés dans auth.users ; le déclencheur de l'app crée leurs profils.
-- Les profils sont lisibles par tous (politique « users can view all profiles ») : aucun marqueur n'y est mis.
\set ON_ERROR_STOP on
begin;

insert into auth.users (id, email) values
  ('00000000-0000-4000-8000-0000000000c1', 'ami-1@example.test'),
  ('00000000-0000-4000-8000-0000000000c2', 'ami-2@example.test'),
  ('00000000-0000-4000-8000-0000000000c3', 'ami-3@example.test'),
  ('00000000-0000-4000-8000-0000000000c4', 'ami-4@example.test'),
  ('00000000-0000-4000-8000-0000000000c5', 'ami-5@example.test');

-- Au cas où le déclencheur d'inscription n'aurait pas créé les profils.
insert into public.profiles (id, full_name, email)
select u.id, split_part(u.email, '@', 1), u.email
from auth.users u
where u.id in (:'a'::uuid, :'b'::uuid) or u.email like 'ami-_@example.test'
on conflict (id) do nothing;

insert into public.groups (title, description, owner, currency) values
  ('Weekend in Lisbon', 'Flights, hotel and dinners', :'a'::uuid, 'EUR'),
  ('Flatshare 2026', 'Rent, internet and groceries', :'a'::uuid, 'EUR'),
  ('Ski trip', 'Chalet and lift passes', :'a'::uuid, 'EUR'),
  ('Office lunches', 'Friday lunches with the team', :'a'::uuid, 'EUR'),
  ('Title MARQUEUR-B-D25A861E', 'Description MARQUEUR-B-1BF1E493', :'b'::uuid, 'EUR'),
  ('Title MARQUEUR-B-C9C10F78', 'Description MARQUEUR-B-F61A9AA3', :'b'::uuid, 'EUR');

insert into public.members (name, group_id, profile, role)
select 'Alex', g.id, g.owner, 'owner'
from public.groups g
where g.owner = :'a'::uuid;

insert into public.members (name, group_id, profile, role)
select 'Name MARQUEUR-B-' || v.marqueur, g.id, g.owner, 'owner'
from (values
  ('MARQUEUR-B-D25A861E', '8A9710EA'),
  ('MARQUEUR-B-C9C10F78', 'AC67D349')
) as v(mg, marqueur)
join public.groups g on g.title = 'Title ' || v.mg and g.owner = :'b'::uuid;

insert into public.friends (profile, friend) values
  (:'a'::uuid, '00000000-0000-4000-8000-0000000000c1'),
  (:'a'::uuid, '00000000-0000-4000-8000-0000000000c2'),
  (:'a'::uuid, '00000000-0000-4000-8000-0000000000c3'),
  (:'b'::uuid, '00000000-0000-4000-8000-0000000000c1'),
  (:'b'::uuid, '00000000-0000-4000-8000-0000000000c4');

insert into public.friend_requests (sender, receiver) values
  (:'a'::uuid, '00000000-0000-4000-8000-0000000000c4'),
  (:'a'::uuid, '00000000-0000-4000-8000-0000000000c5'),
  (:'b'::uuid, '00000000-0000-4000-8000-0000000000c2'),
  (:'b'::uuid, '00000000-0000-4000-8000-0000000000c5');

insert into public.group_invitations (sender, receiver, group_id, group_name)
select :'a'::uuid, v.receiver::uuid, g.id, g.title
from (values
  ('Weekend in Lisbon', '00000000-0000-4000-8000-0000000000c1'),
  ('Weekend in Lisbon', '00000000-0000-4000-8000-0000000000c2'),
  ('Flatshare 2026', '00000000-0000-4000-8000-0000000000c3'),
  ('Ski trip', '00000000-0000-4000-8000-0000000000c4'),
  ('Office lunches', '00000000-0000-4000-8000-0000000000c5')
) as v(title, receiver)
join public.groups g on g.title = v.title and g.owner = :'a'::uuid;

insert into public.group_invitations (sender, receiver, group_id, group_name)
select :'b'::uuid, v.receiver::uuid, g.id, 'Invitation MARQUEUR-B-' || v.marqueur
from (values
  ('MARQUEUR-B-D25A861E', '00000000-0000-4000-8000-0000000000c3', '390FC04D'),
  ('MARQUEUR-B-C9C10F78', '00000000-0000-4000-8000-0000000000c4', '1DEC0C99')
) as v(mg, receiver, marqueur)
join public.groups g on g.title = 'Title ' || v.mg and g.owner = :'b'::uuid;

commit;
