-- Graine « supabase_nextjs_template » (liste de tâches). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 6 tâches. B : 4 tâches, chaque texte libre (titre, description) porte un marqueur unique.
\set ON_ERROR_STOP on
begin;

insert into public.todo_list (title, urgent, description, done, done_at, created_at, owner) values
  ('Préparer la déclaration de TVA', true, 'Rassembler les factures du trimestre', false, null, '2026-03-02 09:00+00', :'a'::uuid),
  ('Réserver le train pour Lyon', false, 'Départ vendredi matin', true, '2026-03-04 10:30+00', '2026-03-03 08:15+00', :'a'::uuid),
  ('Appeler le plombier', true, 'Fuite sous l''évier', false, null, '2026-03-05 18:00+00', :'a'::uuid),
  ('Relire le rapport trimestriel', false, null, true, '2026-03-09 16:45+00', '2026-03-06 11:20+00', :'a'::uuid),
  ('Acheter un cadeau d''anniversaire', false, 'Pour samedi', false, null, '2026-03-10 12:00+00', :'a'::uuid),
  ('Renouveler le passeport', true, 'Rendez-vous en mairie à prendre', false, null, '2026-03-12 14:10+00', :'a'::uuid),
  ('Tâche MARQUEUR-B-40B4AEB4', true, 'Description MARQUEUR-B-8945C646', false, null, '2026-03-02 09:30+00', :'b'::uuid),
  ('Tâche MARQUEUR-B-E1640823', false, 'Description MARQUEUR-B-2477EA2B', true, '2026-03-04 11:00+00', '2026-03-03 09:00+00', :'b'::uuid),
  ('Tâche MARQUEUR-B-5CB2FBFD', false, 'Description MARQUEUR-B-D338521A', false, null, '2026-03-05 17:00+00', :'b'::uuid),
  ('Tâche MARQUEUR-B-5056709A', true, 'Description MARQUEUR-B-BF4C18BD', false, null, '2026-03-06 10:00+00', :'b'::uuid);

commit;
