-- Graine « equipe » (équipes, chantiers, tâches). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 3 équipes (dont il est propriétaire et seul membre), 3 adhésions, 2 invitations, 9 tâches qui lui sont assignées.
-- B : équipes séparées de celles de A ; chaque texte libre porte un marqueur unique. A ne partage aucune équipe avec B.
\set ON_ERROR_STOP on
begin;

insert into public.teams (name, created_by) values
  ('Équipe Menuiserie', :'a'::uuid),
  ('Équipe Peinture', :'a'::uuid),
  ('Équipe Toiture', :'a'::uuid),
  ('Équipe MARQUEUR-B-1CE63051', :'b'::uuid),
  ('Équipe MARQUEUR-B-858F1F53', :'b'::uuid);

insert into public.team_members (team_id, user_id, role)
select id, created_by, 'owner' from public.teams where created_by in (:'a'::uuid, :'b'::uuid);

insert into public.sites (team_id, name, address, start_date, status)
select t.id, v.name, v.address, v.start_date::date, v.status
from (values
  ('Équipe Menuiserie', 'Atelier Nord', '12 rue des Lilas', '2026-03-01', 'in_progress'),
  ('Équipe Menuiserie', 'Cuisine Dupont', '4 allée des Chênes', '2026-04-10', 'planned'),
  ('Équipe Peinture', 'Façade école', '1 place de la Mairie', '2026-02-15', 'done'),
  ('Équipe Peinture', 'Appartement Martin', '8 boulevard Voltaire', '2026-05-02', 'on_hold'),
  ('Équipe Toiture', 'Hangar des Prés', 'Route de la Gare', '2026-06-01', 'planned'),
  ('Équipe MARQUEUR-B-1CE63051', 'Chantier MARQUEUR-B-9A9C0EC8', 'Adresse MARQUEUR-B-405AA468', '2026-01-20', 'planned'),
  ('Équipe MARQUEUR-B-1CE63051', 'Chantier MARQUEUR-B-A7B337B5', 'Adresse MARQUEUR-B-9114181C', '2026-02-20', 'in_progress'),
  ('Équipe MARQUEUR-B-858F1F53', 'Chantier MARQUEUR-B-C2A3B084', 'Adresse MARQUEUR-B-AEB3B08C', '2026-03-20', 'done'),
  ('Équipe MARQUEUR-B-858F1F53', 'Chantier MARQUEUR-B-6757B8EA', 'Adresse MARQUEUR-B-FBC7C617', '2026-04-20', 'on_hold')
) as v(team, name, address, start_date, status)
join public.teams t on t.name = v.team;

insert into public.tasks (site_id, title, due_date, done, assignee_id, created_by)
select s.id, v.title, v.due_date::date, v.done, v.who, v.who
from (values
  ('Atelier Nord', 'Commander le bois', '2026-03-05', true, :'a'::uuid),
  ('Atelier Nord', 'Poser les étagères', '2026-03-12', false, :'a'::uuid),
  ('Cuisine Dupont', 'Relever les mesures', '2026-04-02', true, :'a'::uuid),
  ('Cuisine Dupont', 'Découper le plan de travail', '2026-04-15', false, :'a'::uuid),
  ('Façade école', 'Poser l''échafaudage', '2026-02-16', true, :'a'::uuid),
  ('Façade école', 'Appliquer la sous-couche', '2026-02-20', true, :'a'::uuid),
  ('Appartement Martin', 'Protéger les sols', null, false, :'a'::uuid),
  ('Hangar des Prés', 'Vérifier la charpente', '2026-06-03', false, :'a'::uuid),
  ('Hangar des Prés', 'Commander les tuiles', '2026-06-10', false, :'a'::uuid),
  ('Chantier MARQUEUR-B-9A9C0EC8', 'Tâche MARQUEUR-B-22F9DD65', '2026-07-01', true, :'b'::uuid),
  ('Chantier MARQUEUR-B-9A9C0EC8', 'Tâche MARQUEUR-B-59EC105A', '2026-07-02', false, :'b'::uuid),
  ('Chantier MARQUEUR-B-A7B337B5', 'Tâche MARQUEUR-B-021853CD', '2026-07-03', true, :'b'::uuid),
  ('Chantier MARQUEUR-B-C2A3B084', 'Tâche MARQUEUR-B-20267754', '2026-07-04', false, :'b'::uuid),
  ('Chantier MARQUEUR-B-6757B8EA', 'Tâche MARQUEUR-B-E8987FF0', '2026-07-05', true, :'b'::uuid)
) as v(site, title, due_date, done, who)
join public.sites s on s.name = v.site;

insert into public.team_invitations (team_id, email, invited_by)
select t.id, v.email, t.created_by
from (values
  ('Équipe Menuiserie', 'camille.durand@example.test'),
  ('Équipe Peinture', 'sam.leroy@example.test'),
  ('Équipe MARQUEUR-B-1CE63051', 'invite-MARQUEUR-B-11179104@example.test'),
  ('Équipe MARQUEUR-B-1CE63051', 'invite-MARQUEUR-B-D6B8B45D@example.test'),
  ('Équipe MARQUEUR-B-858F1F53', 'invite-MARQUEUR-B-E8869764@example.test')
) as v(team, email)
join public.teams t on t.name = v.team;

commit;
