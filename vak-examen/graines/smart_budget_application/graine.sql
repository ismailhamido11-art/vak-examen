-- Graine « smart_budget_application ». Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A (foyer « Carter », seul membre) et B (foyer « Okafor », seul membre) n'ont aucune donnée en commun.
-- Chaque texte libre de B porte un marqueur unique. Le déclencheur on_auth_user_created a déjà créé les user_profiles.
\set ON_ERROR_STOP on
begin;

insert into public.households (id, name, created_by) values
  ('45f0b4aa-0818-4ea6-8c9e-2a336754169c', 'The Carter household', :'a'::uuid),
  ('288710a9-86ce-4f13-953d-d879d7b085c0', 'Household MARQUEUR-B-2CBF10B1', :'b'::uuid);

insert into public.household_members (household_id, user_id, role, preset, contribution_percentage) values
  ('45f0b4aa-0818-4ea6-8c9e-2a336754169c', :'a'::uuid, 'admin', 'custom', 100),
  ('288710a9-86ce-4f13-953d-d879d7b085c0', :'b'::uuid, 'admin', 'custom', 100);

insert into public.household_invitations (household_id, email, status, invited_by, expires_at) values
  ('45f0b4aa-0818-4ea6-8c9e-2a336754169c', 'sam.carter@example.test', 'pending', :'a'::uuid, '2026-11-30T00:00:00Z'),
  ('45f0b4aa-0818-4ea6-8c9e-2a336754169c', 'lee.carter@example.test', 'revoked', :'a'::uuid, '2026-09-01T00:00:00Z'),
  ('45f0b4aa-0818-4ea6-8c9e-2a336754169c', 'pat.carter@example.test', 'pending', :'a'::uuid, '2026-12-15T00:00:00Z'),
  ('288710a9-86ce-4f13-953d-d879d7b085c0', 'MARQUEUR-B-C90360B4@example.test', 'pending', :'b'::uuid, '2026-11-30T00:00:00Z'),
  ('288710a9-86ce-4f13-953d-d879d7b085c0', 'MARQUEUR-B-031F7653@example.test', 'revoked', :'b'::uuid, '2026-09-05T00:00:00Z');

insert into public.personal_allowances (user_id, household_id, monthly_amount, currency) values
  (:'a'::uuid, '45f0b4aa-0818-4ea6-8c9e-2a336754169c', 150, 'EUR'),
  (:'b'::uuid, '288710a9-86ce-4f13-953d-d879d7b085c0', 90, 'EUR');

insert into public.user_profiles (id, display_name, profile_picture_url) values
  (:'a'::uuid, 'Alex Carter', 'https://example.test/avatars/alex-carter.png'),
  (:'b'::uuid, 'Bo MARQUEUR-B-6C2F0D8B', 'https://example.test/avatars/MARQUEUR-B-D4736E1C.png')
on conflict (id) do update set display_name = excluded.display_name, profile_picture_url = excluded.profile_picture_url;

insert into public.categories (id, user_id, name, color, type, is_predefined, household_id, visibility_level) values
  ('14ae718e-27e9-4416-a563-7e7f94cacd27', :'a'::uuid, 'Groceries', '#2F855A', 'expense', false, '45f0b4aa-0818-4ea6-8c9e-2a336754169c', 'shared'),
  ('333b84bb-de3a-415e-bf33-9c9d241ce6f2', :'a'::uuid, 'Rent', '#2B6CB0', 'expense', false, '45f0b4aa-0818-4ea6-8c9e-2a336754169c', 'shared'),
  ('340218f7-48fd-4522-b10e-e85666dd1529', :'a'::uuid, 'Transport', '#C05621', 'expense', false, null, 'shared'),
  ('2540f7de-a93f-49c0-8d00-b20ceb16262a', :'a'::uuid, 'Dining out', '#B83280', 'expense', false, null, 'shared'),
  ('283354c1-d8db-4c0b-9bd0-020e7fad955b', :'a'::uuid, 'Utilities', '#718096', 'expense', false, '45f0b4aa-0818-4ea6-8c9e-2a336754169c', 'shared'),
  ('452ac273-9f87-4696-a92f-8c121abaed43', :'a'::uuid, 'Salary', '#38A169', 'income', false, null, 'shared'),
  ('57fe84d0-0854-4bc8-a6a7-020df7206c16', :'a'::uuid, 'Freelance', '#319795', 'income', false, null, 'shared'),
  ('99f7e9dc-c316-4252-845c-a803d9f078bc', :'b'::uuid, 'Food MARQUEUR-B-A5DFC481', '#E53E3E', 'expense', false, '288710a9-86ce-4f13-953d-d879d7b085c0', 'shared'),
  ('748cb3b2-1d9f-4a03-b8c7-e8ed75fd52df', :'b'::uuid, 'Bills MARQUEUR-B-5E5BE901', '#DD6B20', 'expense', false, null, 'shared'),
  ('241449be-aaa2-45ae-b582-db91ecd0f056', :'b'::uuid, 'Fun MARQUEUR-B-7062B9C1', '#805AD5', 'expense', false, null, 'shared'),
  ('2e603a5d-5110-42cd-98dd-973af11a2a17', :'b'::uuid, 'Pay MARQUEUR-B-1A617344', '#38A169', 'income', false, null, 'shared');

insert into public.goals (id, user_id, name, target_amount, current_amount, deadline, household_id) values
  ('e67a4bd0-68a3-4f7b-a517-31bf8579f5aa', :'a'::uuid, 'Emergency fund', 5000, 1200, '2027-06-30', '45f0b4aa-0818-4ea6-8c9e-2a336754169c'),
  ('f0b04be3-ff48-4d49-b3ae-0290ac8c56d6', :'a'::uuid, 'Summer holiday in Portugal', 2400, 650, '2027-07-01', null),
  ('0b58df5e-354c-457e-9986-e9f3ee4118fd', :'a'::uuid, 'New laptop', 1500, 300, null, null),
  ('0004eb1e-b17f-4a9a-b260-34e1ce3b45f5', :'b'::uuid, 'Goal MARQUEUR-B-04CFDD9E', 3000, 400, '2027-03-31', '288710a9-86ce-4f13-953d-d879d7b085c0'),
  ('d87f8512-8f61-4edc-a9d7-1d6d22505fe4', :'b'::uuid, 'Goal MARQUEUR-B-570F9FD3', 800, 100, null, null);

insert into public.goal_contributions (id, goal_id, user_id, amount, note, created_at) values
  ('c07054da-87a5-4df6-aae2-3367862ded2e', 'e67a4bd0-68a3-4f7b-a517-31bf8579f5aa', :'a'::uuid, 400, 'First deposit', '2026-06-01T10:00:00Z'),
  ('6a3d0f4c-c1b3-49a2-83ba-077c0bda28f1', 'e67a4bd0-68a3-4f7b-a517-31bf8579f5aa', :'a'::uuid, 400, 'Bonus saved', '2026-07-01T10:00:00Z'),
  ('68de9c68-46a4-42de-b886-4bb37f6e96d6', 'e67a4bd0-68a3-4f7b-a517-31bf8579f5aa', :'a'::uuid, 400, 'Monthly top-up', '2026-08-01T10:00:00Z'),
  ('bb4176f5-9f7a-4f35-8a11-f741be4b74de', 'f0b04be3-ff48-4d49-b3ae-0290ac8c56d6', :'a'::uuid, 350, 'Flights fund', '2026-07-15T10:00:00Z'),
  ('71c3a8ce-7966-4b44-88e2-2d2360ec27f1', 'f0b04be3-ff48-4d49-b3ae-0290ac8c56d6', :'a'::uuid, 300, 'Hotel fund', '2026-09-15T10:00:00Z'),
  ('9973846f-055e-41d5-9e2e-c3b49f052a91', '0b58df5e-354c-457e-9986-e9f3ee4118fd', :'a'::uuid, 300, 'Birthday money', '2026-09-20T10:00:00Z'),
  ('c214dcda-8dd9-4e2b-bd15-04c9ad058f80', '0004eb1e-b17f-4a9a-b260-34e1ce3b45f5', :'b'::uuid, 250, 'Note MARQUEUR-B-C9FB0A55', '2026-06-02T10:00:00Z'),
  ('cd1967b4-614b-4bd0-83bb-a273e19215ea', '0004eb1e-b17f-4a9a-b260-34e1ce3b45f5', :'b'::uuid, 150, 'Note MARQUEUR-B-3DFDCD93', '2026-07-02T10:00:00Z'),
  ('9b7e9bd8-4994-43f9-b1bd-da7c2d175375', 'd87f8512-8f61-4edc-a9d7-1d6d22505fe4', :'b'::uuid, 100, 'Note MARQUEUR-B-405C574A', '2026-08-02T10:00:00Z');

insert into public.transactions (user_id, category_id, amount, type, date, notes, currency, household_id) values
  (:'a'::uuid, '14ae718e-27e9-4416-a563-7e7f94cacd27', 82.4, 'expense', '2026-09-02', 'Weekly shop', 'EUR', '45f0b4aa-0818-4ea6-8c9e-2a336754169c'),
  (:'a'::uuid, '14ae718e-27e9-4416-a563-7e7f94cacd27', 64.15, 'expense', '2026-09-09', 'Weekly shop', 'EUR', '45f0b4aa-0818-4ea6-8c9e-2a336754169c'),
  (:'a'::uuid, '14ae718e-27e9-4416-a563-7e7f94cacd27', 91.8, 'expense', '2026-09-16', 'Weekly shop', 'EUR', null),
  (:'a'::uuid, '333b84bb-de3a-415e-bf33-9c9d241ce6f2', 950, 'expense', '2026-09-01', 'September rent', 'EUR', '45f0b4aa-0818-4ea6-8c9e-2a336754169c'),
  (:'a'::uuid, '333b84bb-de3a-415e-bf33-9c9d241ce6f2', 950, 'expense', '2026-10-01', 'October rent', 'EUR', '45f0b4aa-0818-4ea6-8c9e-2a336754169c'),
  (:'a'::uuid, '340218f7-48fd-4522-b10e-e85666dd1529', 45, 'expense', '2026-09-05', 'Monthly pass', 'EUR', null),
  (:'a'::uuid, '340218f7-48fd-4522-b10e-e85666dd1529', 18.6, 'expense', '2026-09-21', 'Taxi home', 'EUR', null),
  (:'a'::uuid, '2540f7de-a93f-49c0-8d00-b20ceb16262a', 56.9, 'expense', '2026-09-12', 'Dinner with friends', 'EUR', null),
  (:'a'::uuid, '2540f7de-a93f-49c0-8d00-b20ceb16262a', 32, 'expense', '2026-10-03', 'Lunch', 'EUR', null),
  (:'a'::uuid, '283354c1-d8db-4c0b-9bd0-020e7fad955b', 120.35, 'expense', '2026-09-07', 'Electricity', 'EUR', '45f0b4aa-0818-4ea6-8c9e-2a336754169c'),
  (:'a'::uuid, '283354c1-d8db-4c0b-9bd0-020e7fad955b', 38.9, 'expense', '2026-09-08', 'Internet', 'EUR', '45f0b4aa-0818-4ea6-8c9e-2a336754169c'),
  (:'a'::uuid, '452ac273-9f87-4696-a92f-8c121abaed43', 2850, 'income', '2026-09-28', 'Salary September', 'EUR', null),
  (:'a'::uuid, '452ac273-9f87-4696-a92f-8c121abaed43', 2850, 'income', '2026-10-28', 'Salary October', 'EUR', null),
  (:'a'::uuid, '57fe84d0-0854-4bc8-a6a7-020df7206c16', 400, 'income', '2026-09-18', 'Logo design', 'EUR', null);

insert into public.transactions (user_id, category_id, amount, type, date, notes, currency, household_id) values
  (:'b'::uuid, '99f7e9dc-c316-4252-845c-a803d9f078bc', 40.2, 'expense', '2026-09-03', 'Note MARQUEUR-B-DA596497', 'EUR', null),
  (:'b'::uuid, '99f7e9dc-c316-4252-845c-a803d9f078bc', 55.5, 'expense', '2026-09-10', 'Note MARQUEUR-B-308539A3', 'EUR', '288710a9-86ce-4f13-953d-d879d7b085c0'),
  (:'b'::uuid, '748cb3b2-1d9f-4a03-b8c7-e8ed75fd52df', 70, 'expense', '2026-09-05', 'Note MARQUEUR-B-6F14A1E7', 'EUR', null),
  (:'b'::uuid, '241449be-aaa2-45ae-b582-db91ecd0f056', 25, 'expense', '2026-09-14', 'Note MARQUEUR-B-CB6976D7', 'EUR', '288710a9-86ce-4f13-953d-d879d7b085c0'),
  (:'b'::uuid, '241449be-aaa2-45ae-b582-db91ecd0f056', 19.99, 'expense', '2026-09-22', 'Note MARQUEUR-B-7466C1D4', 'EUR', null),
  (:'b'::uuid, '2e603a5d-5110-42cd-98dd-973af11a2a17', 1900, 'income', '2026-09-28', 'Note MARQUEUR-B-809FB187', 'EUR', '288710a9-86ce-4f13-953d-d879d7b085c0'),
  (:'b'::uuid, '748cb3b2-1d9f-4a03-b8c7-e8ed75fd52df', 66, 'expense', '2026-10-05', 'Note MARQUEUR-B-73E81896', 'EUR', null),
  (:'b'::uuid, '99f7e9dc-c316-4252-845c-a803d9f078bc', 31, 'expense', '2026-10-08', 'Note MARQUEUR-B-FBDC10CF', 'EUR', '288710a9-86ce-4f13-953d-d879d7b085c0');

insert into public.category_budgets (user_id, category_id, period, limit_amount) values
  (:'a'::uuid, '14ae718e-27e9-4416-a563-7e7f94cacd27', 'monthly', 400),
  (:'a'::uuid, '340218f7-48fd-4522-b10e-e85666dd1529', 'monthly', 80),
  (:'a'::uuid, '2540f7de-a93f-49c0-8d00-b20ceb16262a', 'monthly', 150),
  (:'b'::uuid, '99f7e9dc-c316-4252-845c-a803d9f078bc', 'monthly', 300),
  (:'b'::uuid, '241449be-aaa2-45ae-b582-db91ecd0f056', 'monthly', 60);

insert into public.user_values (id, user_id, name, priority) values
  ('c2a55d2d-a405-412d-89e2-5c9fe9734070', :'a'::uuid, 'Security', 1),
  ('61ca56bf-d73f-4222-b2cc-7ea3968f7322', :'a'::uuid, 'Travel', 2),
  ('831106c5-0a44-4770-b68c-9f9199e9a2ad', :'a'::uuid, 'Health', 3),
  ('8a9d2201-a254-485a-8344-5d1901b0f04b', :'a'::uuid, 'Family', 4),
  ('e49ebf51-800e-4815-94ba-59a426e87546', :'b'::uuid, 'MARQUEUR-B-DE6E7CD0', 1),
  ('0dc8bc47-b70a-4eb6-b8b8-f195afd21162', :'b'::uuid, 'MARQUEUR-B-DBBCDC2C', 2);

insert into public.value_categories (user_id, value_id, category_id) values
  (:'a'::uuid, 'c2a55d2d-a405-412d-89e2-5c9fe9734070', '333b84bb-de3a-415e-bf33-9c9d241ce6f2'),
  (:'a'::uuid, 'c2a55d2d-a405-412d-89e2-5c9fe9734070', '283354c1-d8db-4c0b-9bd0-020e7fad955b'),
  (:'a'::uuid, '61ca56bf-d73f-4222-b2cc-7ea3968f7322', '340218f7-48fd-4522-b10e-e85666dd1529'),
  (:'a'::uuid, '831106c5-0a44-4770-b68c-9f9199e9a2ad', '14ae718e-27e9-4416-a563-7e7f94cacd27'),
  (:'a'::uuid, '8a9d2201-a254-485a-8344-5d1901b0f04b', '2540f7de-a93f-49c0-8d00-b20ceb16262a'),
  (:'b'::uuid, 'e49ebf51-800e-4815-94ba-59a426e87546', '99f7e9dc-c316-4252-845c-a803d9f078bc'),
  (:'b'::uuid, '0dc8bc47-b70a-4eb6-b8b8-f195afd21162', '241449be-aaa2-45ae-b582-db91ecd0f056');

insert into public.wishlist_items (user_id, category_id, name, price, status) values
  (:'a'::uuid, null, 'Noise-cancelling headphones', 249.9, 'active'),
  (:'a'::uuid, '2540f7de-a93f-49c0-8d00-b20ceb16262a', 'Tasting menu', 120, 'active'),
  (:'a'::uuid, null, 'Running shoes', 130, 'purchased'),
  (:'a'::uuid, '340218f7-48fd-4522-b10e-e85666dd1529', 'Bike lights', 35, 'active'),
  (:'a'::uuid, null, 'Espresso machine', 399, 'removed'),
  (:'b'::uuid, null, 'Item MARQUEUR-B-EDBFAED0', 80, 'active'),
  (:'b'::uuid, null, 'Item MARQUEUR-B-27952724', 45, 'active');

insert into public.detected_subscriptions (user_id, merchant_pattern, estimated_amount, currency, frequency, last_seen_at, status) values
  (:'a'::uuid, 'NETFLIX.COM', 13.99, 'EUR', 'monthly', '2026-10-02T00:00:00Z', 'active'),
  (:'a'::uuid, 'SPOTIFY AB', 10.99, 'EUR', 'monthly', '2026-10-05T00:00:00Z', 'active'),
  (:'a'::uuid, 'GYM CLUB ANNUAL', 360, 'EUR', 'annual', '2026-03-01T00:00:00Z', 'unused'),
  (:'a'::uuid, 'CLOUD STORAGE', 2.99, 'EUR', 'monthly', '2026-10-01T00:00:00Z', 'kept'),
  (:'b'::uuid, 'SHOP MARQUEUR-B-5559027B', 9.99, 'EUR', 'monthly', '2026-10-02T00:00:00Z', 'active'),
  (:'b'::uuid, 'SHOP MARQUEUR-B-2E7729B1', 5, 'EUR', 'weekly', '2026-10-06T00:00:00Z', 'dismissed');

insert into public.insights (user_id, title, description, type, priority, is_dismissed, metadata, fingerprint) values
  (:'a'::uuid, 'Groceries up 12%', 'You spent 12% more on groceries than last month.', 'spending_increase', 2, false, '{"category":"Groceries","change_pct":12}'::jsonb, 'fp-a-1'),
  (:'a'::uuid, 'Budget suggestion for Transport', 'A monthly limit of 80 EUR fits your transport habits.', 'budget_recommendation', 3, false, '{"category":"Transport"}'::jsonb, 'fp-a-2'),
  (:'a'::uuid, 'Unusual expense detected', 'A 91.80 EUR grocery shop stands out.', 'unusual_expense', 1, false, '{"amount":91.8}'::jsonb, 'fp-a-3'),
  (:'a'::uuid, 'Great job on dining out', 'Dining out spending fell by 20%.', 'positive_reinforcement', 4, false, '{"change_pct":-20}'::jsonb, 'fp-a-4'),
  (:'a'::uuid, 'Utilities spike', 'Electricity cost more than usual.', 'spending_anomaly', 2, false, '{"category":"Utilities"}'::jsonb, 'fp-a-5'),
  (:'b'::uuid, 'Insight MARQUEUR-B-1D156BAB', 'Details MARQUEUR-B-C3FD8954', 'spending_increase', 3, false, '{"note":"MARQUEUR-B-1E0162F8"}'::jsonb, 'fp-MARQUEUR-B-783CA478'),
  (:'b'::uuid, 'Insight MARQUEUR-B-E7CABDD6', 'Details MARQUEUR-B-DFBE7BFB', 'spending_increase', 3, false, '{"note":"MARQUEUR-B-60224559"}'::jsonb, 'fp-MARQUEUR-B-D27F6CA5');

insert into public.analytics_events (user_id, event_name, event_properties, device_type, session_id) values
  (:'a'::uuid, 'page_view', '{"page":"/dashboard"}'::jsonb, 'desktop', '71988447-52cd-49ec-94a9-040fcc9dd37b'),
  (:'a'::uuid, 'page_view', '{"page":"/transactions"}'::jsonb, 'desktop', '887897a1-fa52-420e-b8db-dab3b8d86e19'),
  (:'a'::uuid, 'transaction_created', '{"amount":82.4}'::jsonb, 'mobile', '884f147b-a45d-422b-aa2d-c8bde991fc56'),
  (:'a'::uuid, 'page_view', '{"page":"/goals"}'::jsonb, 'mobile', '677e14cd-d8e4-4672-ad26-f3ae8245fd8b'),
  (:'a'::uuid, 'goal_created', '{"name":"New laptop"}'::jsonb, 'desktop', 'dfa9e69c-88db-44ce-8059-cf4fdbd1d6ae'),
  (:'a'::uuid, 'page_view', '{"page":"/insights"}'::jsonb, 'tablet', 'f34522d4-c660-4f5a-a6dd-17c89dce04bf'),
  (:'a'::uuid, 'budget_set', '{"category":"Transport"}'::jsonb, 'desktop', '1e269d44-ff62-451c-8244-4021512844f0'),
  (:'a'::uuid, 'page_view', '{"page":"/settings"}'::jsonb, 'desktop', 'fc5f4c2b-0e34-4f37-9e4b-8fd8aa118d5d'),
  (:'a'::uuid, 'export_clicked', '{"format":"csv"}'::jsonb, 'desktop', 'a66d1ef0-15f0-4a26-b839-fb388dc57dfb'),
  (:'b'::uuid, 'event_MARQUEUR-B-7928CF95', '{"note":"MARQUEUR-B-7B95F005"}'::jsonb, 'mobile', 'bca7fa0d-4c41-415d-bad4-3d3a489127bf'),
  (:'b'::uuid, 'event_MARQUEUR-B-0E76A9CD', '{"note":"MARQUEUR-B-3D5A4CDC"}'::jsonb, 'desktop', 'fccc0d3f-aa5c-4266-af11-fa52795e9780'),
  (:'b'::uuid, 'event_MARQUEUR-B-4CFA6590', '{"note":"MARQUEUR-B-E10C9D73"}'::jsonb, 'tablet', '0ffa5e3c-d60e-48e6-99aa-c2508176ae0c');

insert into public.comeback_challenges (user_id, started_at, expires_at, target_count, previous_streak, status, completed_at) values
  (:'a'::uuid, '2026-10-10T00:00:00Z', '2026-10-17T00:00:00Z', 3, 9, 'active', null),
  (:'a'::uuid, '2026-08-01T00:00:00Z', '2026-08-08T00:00:00Z', 3, 5, 'completed', '2026-08-05T00:00:00Z'),
  (:'b'::uuid, '2026-10-11T00:00:00Z', '2026-10-18T00:00:00Z', 3, 7, 'active', null);

insert into public.notification_deliveries (user_id, kind, period_key, sent_at) values
  (:'a'::uuid, 'weekly_digest', '2026-W38', '2026-09-21T08:00:00Z'),
  (:'a'::uuid, 'weekly_digest', '2026-W39', '2026-09-28T08:00:00Z'),
  (:'a'::uuid, 'streak_reminder', '2026-10-12', '2026-10-12T18:00:00Z'),
  (:'b'::uuid, 'kind-MARQUEUR-B-7A1FE390', 'key-MARQUEUR-B-8E4E25A8', '2026-09-21T08:00:00Z'),
  (:'b'::uuid, 'kind-MARQUEUR-B-0FD3727C', 'key-MARQUEUR-B-6FA6C84C', '2026-09-28T08:00:00Z');

insert into public.push_subscriptions (user_id, endpoint, p256dh, auth) values
  (:'a'::uuid, 'https://push.example.test/send/a-phone', 'BKey-a-phone', 'auth-a-phone'),
  (:'a'::uuid, 'https://push.example.test/send/a-laptop', 'BKey-a-laptop', 'auth-a-laptop'),
  (:'b'::uuid, 'https://push.example.test/send/MARQUEUR-B-7A16CA22', 'BKey-MARQUEUR-B-4EEE7637', 'auth-MARQUEUR-B-3833850C');

insert into public.recovery_plans (user_id, start_date, end_date, status, targets) values
  (:'a'::uuid, '2026-08-01', '2026-08-31', 'completed', '{"Groceries":300,"Dining":100}'::jsonb),
  (:'a'::uuid, '2026-10-01', '2026-10-31', 'active', '{"Groceries":350,"Transport":60}'::jsonb),
  (:'b'::uuid, '2026-10-01', '2026-10-31', 'active', '{"MARQUEUR-B-EBA45AEC":100}'::jsonb);

insert into public.streaks (user_id, current_streak, longest_streak, weekly_streak, last_log_date, last_log_week) values
  (:'a'::uuid, 4, 9, 3, '2026-10-13', '2026-W42'),
  (:'b'::uuid, 2, 6, 1, '2026-10-12', '2026-W42');

insert into public.user_achievements (user_id, achievement_key, unlocked_at) values
  (:'a'::uuid, 'first_transaction', '2026-06-01T09:00:00Z'),
  (:'a'::uuid, 'ten_transactions', '2026-07-01T09:00:00Z'),
  (:'a'::uuid, 'first_budget', '2026-07-05T09:00:00Z'),
  (:'a'::uuid, 'first_goal', '2026-06-02T09:00:00Z'),
  (:'b'::uuid, 'first_transaction', '2026-06-03T09:00:00Z'),
  (:'b'::uuid, 'first_goal', '2026-06-04T09:00:00Z'),
  (:'b'::uuid, 'week_streak', '2026-07-03T09:00:00Z');

insert into public.user_feature_state (user_id, transactions_count, days_active, features_unlocked, last_active_date) values
  (:'a'::uuid, 14, 21, '{budgets,goals}', '2026-10-13'),
  (:'b'::uuid, 8, 10, '{budgets}', '2026-10-12');

insert into public.user_sessions (user_id, session_token, device_name, device_type, browser, ip_address) values
  (:'a'::uuid, 'tok-a-1', 'Alex''s MacBook', 'desktop', 'Firefox 130', '203.0.113.10'),
  (:'a'::uuid, 'tok-a-2', 'Alex''s Pixel', 'mobile', 'Chrome 129', '203.0.113.11'),
  (:'a'::uuid, 'tok-a-3', 'Family iPad', 'tablet', 'Safari 18', '203.0.113.12'),
  (:'b'::uuid, 'tok-MARQUEUR-B-8AE3CC3D', 'Device MARQUEUR-B-58EECD9F', 'desktop', 'Browser MARQUEUR-B-36E8C056', '198.51.100.20'),
  (:'b'::uuid, 'tok-MARQUEUR-B-422EBD10', 'Device MARQUEUR-B-513AA334', 'mobile', 'Browser MARQUEUR-B-BF2ED38B', '198.51.100.21');

insert into public.weekly_digests (user_id, week_start, week_end, total_spending, previous_week_spending, spending_change_pct, top_categories, actionable_highlight, currency) values
  (:'a'::uuid, '2026-09-07', '2026-09-13', 220.4, 180, 22.4, '[{"name":"Groceries","amount":64.15}]'::jsonb, 'Groceries were your biggest expense.', 'EUR'),
  (:'a'::uuid, '2026-09-14', '2026-09-20', 140.7, 220.4, -36.2, '[{"name":"Groceries","amount":91.8}]'::jsonb, 'Spending fell this week.', 'EUR'),
  (:'a'::uuid, '2026-09-21', '2026-09-27', 18.6, 140.7, -86.8, '[{"name":"Transport","amount":18.6}]'::jsonb, 'A very quiet week.', 'EUR'),
  (:'a'::uuid, '2026-09-28', '2026-10-04', 75, 18.6, 303.2, '[{"name":"Dining out","amount":32}]'::jsonb, 'Dining out is picking up.', 'EUR'),
  (:'b'::uuid, '2026-09-07', '2026-09-13', 100, 90, 11.1, '[{"name":"MARQUEUR-B-A1D839A2","amount":55.5}]'::jsonb, 'Highlight MARQUEUR-B-A3ACB3A3', 'EUR'),
  (:'b'::uuid, '2026-09-14', '2026-09-20', 60, 100, -40, '[{"name":"MARQUEUR-B-5FD82987","amount":25}]'::jsonb, 'Highlight MARQUEUR-B-5F288B38', 'EUR');

commit;
