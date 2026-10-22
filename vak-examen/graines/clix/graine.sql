-- Graine « clix » (site de lancement d'un service de lavage auto par abonnement).
-- Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- Seule table « à moi » : public.admin_profiles (user_id -> auth.users, unique : une ligne au plus par compte).
-- A : 1 profil administrateur. B : 1 profil administrateur.
-- admin_profiles n'a aucun texte libre : les marqueurs de B sont dans les formulaires publics de B (leads,
-- membership_inquiries, booking_requests), tables en insertion seule que ni A ni B ne peuvent lire.
-- Rien de marqué dans launch_leads : A, administrateur, la lit en entier, c'est une donnée partagée.
\set ON_ERROR_STOP on
begin;

insert into public.admin_profiles (user_id, role) values
  (:'a'::uuid, 'admin'),
  (:'b'::uuid, 'admin');

insert into public.leads (name, email, phone, source, message) values
  ('Nom 6B69F033', 'b-6B69F033@example.test', '5550100101', 'Website', 'Message MARQUEUR-B-6B69F033'),
  ('Nom E9FD8140', 'b-E9FD8140@example.test', '5550100102', 'Website', 'Message MARQUEUR-B-E9FD8140');

insert into public.membership_inquiries (name, email, phone, zip_code, vehicle, preferred_plan, message) values
  ('Nom 8C5A031D', 'b-8C5A031D@example.test', '5550100103', '75001', 'Voiture MARQUEUR-B-8270EE0B', 'Essential', 'Message MARQUEUR-B-8C5A031D'),
  ('Nom 46FD8101', 'b-46FD8101@example.test', '5550100104', '75002', 'Voiture MARQUEUR-B-828C0EC6', 'Elite', 'Message MARQUEUR-B-46FD8101');

insert into public.booking_requests (name, email, phone, zip_code, vehicle, service_type, preferred_date, preferred_time, notes) values
  ('Nom 99E3B27F', 'b-99E3B27F@example.test', '5550100105', '75003', 'Voiture MARQUEUR-B-8B5D2002', 'Lavage complet', '2026-07-01', 'Matin', 'Notes MARQUEUR-B-99E3B27F');

commit;
