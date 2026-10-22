-- Graine « agence » (dossiers de voyage). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 3 agences (seul membre, propriétaire de chacune), 3 adhésions, 6 dossiers, 9 réservations (toutes créées par A et
-- confiées à A), 4 invitations en attente. B : ses propres agences, où A n'est pas membre ; chaque texte libre porte un marqueur.
-- Les identifiants fixes sont des uuid de graine, sans lien avec les comptes.
\set ON_ERROR_STOP on
begin;

insert into public.agencies (id, name, created_by) values
  ('a0000000-0000-4000-8000-000000000001', 'Horizons Lointains', :'a'::uuid),
  ('a0000000-0000-4000-8000-000000000002', 'Évasion Méditerranée', :'a'::uuid),
  ('a0000000-0000-4000-8000-000000000003', 'Voyages du Nord', :'a'::uuid),
  ('b0000000-0000-4000-8000-000000000001', 'Agence MARQUEUR-B-81B8BF47', :'b'::uuid),
  ('b0000000-0000-4000-8000-000000000002', 'Agence MARQUEUR-B-77A82F12', :'b'::uuid);

insert into public.agency_members (agency_id, user_id, role) values
  ('a0000000-0000-4000-8000-000000000001', :'a'::uuid, 'owner'),
  ('a0000000-0000-4000-8000-000000000002', :'a'::uuid, 'owner'),
  ('a0000000-0000-4000-8000-000000000003', :'a'::uuid, 'owner'),
  ('b0000000-0000-4000-8000-000000000001', :'b'::uuid, 'owner'),
  ('b0000000-0000-4000-8000-000000000002', :'b'::uuid, 'owner');

insert into public.trips (id, agency_id, client, destination, departure_date, return_date, budget, status, created_by) values
  ('a1000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'Famille Martin', 'Lisbonne', '2026-11-05', '2026-11-12', 3200, 'confirmed', :'a'::uuid),
  ('a1000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001', 'Julie Lefèvre', 'Kyoto', '2027-03-20', '2027-04-03', 5400, 'draft', :'a'::uuid),
  ('a1000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000002', 'Entreprise Bernard SA', 'Marrakech', '2026-12-01', '2026-12-05', 8800, 'confirmed', :'a'::uuid),
  ('a1000000-0000-4000-8000-000000000004', 'a0000000-0000-4000-8000-000000000002', 'Paul et Sophie Durand', 'Rome', '2026-09-10', '2026-09-17', 2700, 'completed', :'a'::uuid),
  ('a1000000-0000-4000-8000-000000000005', 'a0000000-0000-4000-8000-000000000003', 'Classe de 3e B', 'Edimbourg', '2027-05-10', '2027-05-15', 9600, 'draft', :'a'::uuid),
  ('a1000000-0000-4000-8000-000000000006', 'a0000000-0000-4000-8000-000000000003', 'Marc Girard', 'Reykjavik', '2026-08-02', '2026-08-09', 4100, 'cancelled', :'a'::uuid),
  ('b1000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'Client MARQUEUR-B-96A4062C', 'Destination MARQUEUR-B-DFA0F221', '2026-10-10', '2026-10-20', 1000, 'draft', :'b'::uuid),
  ('b1000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000002', 'Client MARQUEUR-B-F578D00B', 'Destination MARQUEUR-B-59CFBD59', '2026-10-11', '2026-10-21', 1100, 'confirmed', :'b'::uuid),
  ('b1000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000001', 'Client MARQUEUR-B-FBC6D5F2', 'Destination MARQUEUR-B-34041E3E', '2026-10-12', '2026-10-22', 1200, 'completed', :'b'::uuid),
  ('b1000000-0000-4000-8000-000000000004', 'b0000000-0000-4000-8000-000000000002', 'Client MARQUEUR-B-893657A1', 'Destination MARQUEUR-B-FF62B213', '2026-10-13', '2026-10-23', 1300, 'cancelled', :'b'::uuid);

insert into public.bookings (trip_id, agency_id, type, supplier, price, confirmed, assigned_to, created_by) values
  ('a1000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'vol', 'TAP Air Portugal', 640, true, :'a'::uuid, :'a'::uuid),
  ('a1000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'hotel', 'Hôtel Alfama', 980, true, :'a'::uuid, :'a'::uuid),
  ('a1000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'autre', 'Location de voiture Sixt', 210, false, :'a'::uuid, :'a'::uuid),
  ('a1000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001', 'vol', 'Japan Airlines', 1850, false, :'a'::uuid, :'a'::uuid),
  ('a1000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001', 'hotel', 'Ryokan Kikunoi', 2100, false, :'a'::uuid, :'a'::uuid),
  ('a1000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000002', 'vol', 'Royal Air Maroc', 1200, true, :'a'::uuid, :'a'::uuid),
  ('a1000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000002', 'hotel', 'Riad Yasmine', 2400, true, :'a'::uuid, :'a'::uuid),
  ('a1000000-0000-4000-8000-000000000004', 'a0000000-0000-4000-8000-000000000002', 'hotel', 'Albergo del Sole', 1300, true, :'a'::uuid, :'a'::uuid),
  ('a1000000-0000-4000-8000-000000000005', 'a0000000-0000-4000-8000-000000000003', 'vol', 'easyJet', 3100, false, :'a'::uuid, :'a'::uuid),
  ('b1000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'vol', 'Fournisseur MARQUEUR-B-F3CA524F', 200, true, :'b'::uuid, :'b'::uuid),
  ('b1000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000002', 'hotel', 'Fournisseur MARQUEUR-B-32F5C80D', 250, false, :'b'::uuid, :'b'::uuid),
  ('b1000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000001', 'autre', 'Fournisseur MARQUEUR-B-2F450219', 300, true, :'b'::uuid, :'b'::uuid),
  ('b1000000-0000-4000-8000-000000000004', 'b0000000-0000-4000-8000-000000000002', 'vol', 'Fournisseur MARQUEUR-B-69EE4A9A', 350, false, :'b'::uuid, :'b'::uuid),
  ('b1000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'hotel', 'Fournisseur MARQUEUR-B-75AD5C85', 400, true, :'b'::uuid, :'b'::uuid);

insert into public.agency_invitations (agency_id, email, role, invited_by) values
  ('a0000000-0000-4000-8000-000000000001', 'claire.dupont@example.test', 'agent', :'a'::uuid),
  ('a0000000-0000-4000-8000-000000000002', 'thomas.leroy@example.test', 'viewer', :'a'::uuid),
  ('a0000000-0000-4000-8000-000000000003', 'nadia.benali@example.test', 'agent', :'a'::uuid),
  ('a0000000-0000-4000-8000-000000000001', 'hugo.petit@example.test', 'viewer', :'a'::uuid),
  ('b0000000-0000-4000-8000-000000000001', lower('MARQUEUR-B-C3A909A4') || '@example.test', 'agent', :'b'::uuid),
  ('b0000000-0000-4000-8000-000000000002', lower('MARQUEUR-B-D262A8A6') || '@example.test', 'agent', :'b'::uuid),
  ('b0000000-0000-4000-8000-000000000001', lower('MARQUEUR-B-40905CAB') || '@example.test', 'agent', :'b'::uuid);

commit;
