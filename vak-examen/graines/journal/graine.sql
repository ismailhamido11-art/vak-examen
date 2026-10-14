-- Graine « journal » (rédaction de quartier). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 1 profil, 2 journaux (seul membre de chacun, propriétaire), 2 adhésions, 3 invitations envoyées, 7 articles
-- (tous créés par A et confiés à A), 5 photos (toutes ajoutées par A).
-- B : mêmes tables, journaux distincts de ceux de A (aucun membre commun), chaque texte libre porte un marqueur unique.
\set ON_ERROR_STOP on
begin;

-- Profils : créés par le déclencheur à l'insertion des comptes ; on ne fait que les nommer.
insert into public.profiles (id, email, display_name) values
  (:'a'::uuid, 'a@example.test', 'Camille Dupuis'),
  (:'b'::uuid, 'b@example.test', 'Nom MARQUEUR-B-E4145DCB')
on conflict (id) do update set display_name = excluded.display_name;

insert into public.newspapers (name, district, created_by) values
  ('La Gazette des Lilas', 'Les Lilas', :'a'::uuid),
  ('Le Petit Faubourg', 'Faubourg Saint-Antoine', :'a'::uuid),
  ('Journal MARQUEUR-B-83CE2D4F', 'Quartier MARQUEUR-B-CC710E96', :'b'::uuid),
  ('Journal MARQUEUR-B-62811744', 'Quartier MARQUEUR-B-9B9F1673', :'b'::uuid);

insert into public.newspaper_members (newspaper_id, user_id, role)
select id, created_by, 'owner' from public.newspapers;

insert into public.newspaper_invitations (newspaper_id, email, role, invited_by)
select n.id, v.email, v.role, n.created_by
from (values
  ('La Gazette des Lilas', 'lea.martin@example.test', 'writer'),
  ('La Gazette des Lilas', 'hugo.bernard@example.test', 'viewer'),
  ('Le Petit Faubourg', 'sonia.petit@example.test', 'writer'),
  ('Journal MARQUEUR-B-83CE2D4F', 'marqueur-b-48bf182f@example.test', 'writer'),
  ('Journal MARQUEUR-B-62811744', 'marqueur-b-c0461521@example.test', 'viewer')
) as v(journal, email, role)
join public.newspapers n on n.name = v.journal;

insert into public.articles (newspaper_id, title, section, planned_chars, status, due_date, assignee_id, created_by)
select n.id, v.title, v.section, v.chars, v.status, v.due::date, n.created_by, n.created_by
from (values
  ('La Gazette des Lilas', 'Le marché du dimanche change de place', 'Vie locale', 3500, 'publie', '2026-09-20'),
  ('La Gazette des Lilas', 'Portrait de la boulangère de la rue Haute', 'Portraits', 4200, 'relu', '2026-10-05'),
  ('La Gazette des Lilas', 'Travaux sur la ligne de bus 76', 'Transports', 2800, 'en_redaction', '2026-10-18'),
  ('La Gazette des Lilas', 'Le conseil de quartier du 12 novembre', 'Vie locale', 3000, 'idee', '2026-11-12'),
  ('Le Petit Faubourg', 'La fête des voisins en images', 'Culture', 2500, 'publie', '2026-09-28'),
  ('Le Petit Faubourg', 'Un nouveau jardin partagé', 'Environnement', 3800, 'en_redaction', '2026-10-25'),
  ('Le Petit Faubourg', 'Les commerçants face au froid', 'Économie', 3200, 'idee', '2026-11-02'),
  ('Journal MARQUEUR-B-83CE2D4F', 'Titre MARQUEUR-B-959D7300', 'Rubrique MARQUEUR-B-1A334D80', 1500, 'publie', '2026-09-15'),
  ('Journal MARQUEUR-B-83CE2D4F', 'Titre MARQUEUR-B-6FAAB7C3', 'Rubrique MARQUEUR-B-9512DA4F', 2000, 'relu', '2026-10-01'),
  ('Journal MARQUEUR-B-62811744', 'Titre MARQUEUR-B-58DA93B8', 'Rubrique MARQUEUR-B-2086E6DF', 2600, 'en_redaction', '2026-10-30'),
  ('Journal MARQUEUR-B-62811744', 'Titre MARQUEUR-B-96190C10', 'Rubrique MARQUEUR-B-FE224E1C', 1800, 'idee', null)
) as v(journal, title, section, chars, status, due)
join public.newspapers n on n.name = v.journal;

insert into public.article_photos (article_id, caption, photographer, width_px, added_by)
select ar.id, v.caption, v.photographer, v.width, ar.created_by
from (values
  ('Le marché du dimanche change de place', 'Les étals devant la mairie', 'Camille Dupuis', 2400),
  ('Le marché du dimanche change de place', 'La nouvelle place du marché', 'Camille Dupuis', 3000),
  ('Portrait de la boulangère de la rue Haute', 'Fournée de six heures', 'Camille Dupuis', 1800),
  ('La fête des voisins en images', 'Tablée dans la cour', 'Camille Dupuis', 2000),
  ('Un nouveau jardin partagé', 'Les premiers bacs', 'Camille Dupuis', 1600),
  ('Titre MARQUEUR-B-959D7300', 'Légende MARQUEUR-B-66BC27DB', 'Photographe MARQUEUR-B-FB786333', 1200),
  ('Titre MARQUEUR-B-6FAAB7C3', 'Légende MARQUEUR-B-A0998811', 'Photographe MARQUEUR-B-6F7316B7', 1400),
  ('Titre MARQUEUR-B-58DA93B8', 'Légende MARQUEUR-B-2F8C37DB', 'Photographe MARQUEUR-B-ED1DE677', 1000)
) as v(title, caption, photographer, width)
join public.articles ar on ar.title = v.title;

commit;
