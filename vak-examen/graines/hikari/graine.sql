-- Graine « hikari » (SaaS Next.js : profils, articles, abonnements). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 1 profil, 4 articles, 3 abonnements. B : 1 profil, 3 articles, 2 abonnements, chaque texte libre porte un marqueur unique.
-- Le déclencheur on_auth_user_created a déjà créé public.users pour A et B : on complète ces lignes.
-- public.customers (clé vers auth.users, aucune politique : table privée, illisible par l'utilisateur) n'est pas semée.
\set ON_ERROR_STOP on
begin;

update public.users set full_name = 'Alice Martin', avatar_url = 'https://example.test/avatars/alice.png',
  billing_address = '{"city": "Lyon", "country": "FR"}'::jsonb where id = :'a'::uuid;
update public.users set full_name = 'Nom MARQUEUR-B-3F9A1C07', avatar_url = 'https://example.test/avatars/MARQUEUR-B-B2D84E61.png',
  billing_address = '{"city": "Ville MARQUEUR-B-7C05A9DE", "country": "FR"}'::jsonb where id = :'b'::uuid;

insert into public.posts (user_id, title, content, created_at, updated_at) values
  (:'a'::uuid, 'Premiers pas avec Hikari', 'Notes de prise en main.', '2026-01-05 09:00+00', '2026-01-05 09:00+00'),
  (:'a'::uuid, 'Plan de la semaine', 'Trois tâches à finir avant vendredi.', '2026-02-02 10:30+00', '2026-02-02 10:30+00'),
  (:'a'::uuid, 'Idées de projets', 'Une liste courte pour le trimestre.', '2026-03-09 14:15+00', '2026-03-09 14:15+00'),
  (:'a'::uuid, 'Bilan du mois', 'Ce qui a marché et ce qui a coincé.', '2026-04-01 18:45+00', '2026-04-01 18:45+00'),
  (:'b'::uuid, 'Titre MARQUEUR-B-91E3B4F8', 'Contenu MARQUEUR-B-A60D2C75', '2026-01-10 08:00+00', '2026-01-10 08:00+00'),
  (:'b'::uuid, 'Titre MARQUEUR-B-4E8F17B3', 'Contenu MARQUEUR-B-D15C93A0', '2026-02-10 08:00+00', '2026-02-10 08:00+00'),
  (:'b'::uuid, 'Titre MARQUEUR-B-28B7E6F4', 'Contenu MARQUEUR-B-C3A04D19', '2026-03-10 08:00+00', '2026-03-10 08:00+00');

insert into public.products (id, active, name, description) values
  ('prod_graine_basic', true, 'Basic', 'Offre de base'),
  ('prod_graine_pro', true, 'Pro', 'Offre professionnelle');
insert into public.prices (id, product_id, active, description, unit_amount, currency, type, interval, interval_count) values
  ('price_graine_basic', 'prod_graine_basic', true, 'Basic mensuel', 900, 'eur', 'recurring', 'month', 1),
  ('price_graine_pro', 'prod_graine_pro', true, 'Pro mensuel', 2900, 'eur', 'recurring', 'month', 1);

insert into public.subscriptions (id, user_id, status, metadata, price_id, quantity, cancel_at_period_end,
    created, current_period_start, current_period_end, ended_at, cancel_at, canceled_at, trial_start, trial_end) values
  ('sub_graine_a1', :'a'::uuid, 'active', '{"note": "abonnement principal"}', 'price_graine_pro', 1, false,
    '2026-01-05 09:00+00', '2026-04-05 09:00+00', '2026-05-05 09:00+00', null, null, null, null, null),
  ('sub_graine_a2', :'a'::uuid, 'canceled', '{"note": "ancien abonnement"}', 'price_graine_basic', 1, false,
    '2025-06-01 09:00+00', '2025-11-01 09:00+00', '2025-12-01 09:00+00', '2025-12-01 09:00+00', null, '2025-11-20 09:00+00', null, null),
  ('sub_graine_a3', :'a'::uuid, 'trialing', '{"note": "essai"}', 'price_graine_basic', 2, false,
    '2026-03-20 09:00+00', '2026-03-20 09:00+00', '2026-04-20 09:00+00', null, null, null, '2026-03-20 09:00+00', '2026-04-03 09:00+00'),
  ('sub_graine_b_MARQUEUR-B-5F61E8B2', :'b'::uuid, 'active', '{"note": "Note MARQUEUR-B-E94B7A30"}', 'price_graine_pro', 1, false,
    '2026-01-12 09:00+00', '2026-04-12 09:00+00', '2026-05-12 09:00+00', null, null, null, null, null),
  ('sub_graine_b_MARQUEUR-B-0D7C25F6', :'b'::uuid, 'past_due', '{"note": "Note MARQUEUR-B-8A3E91C4"}', 'price_graine_basic', 1, false,
    '2026-02-12 09:00+00', '2026-04-12 09:00+00', '2026-05-12 09:00+00', null, null, null, null, null);

commit;
