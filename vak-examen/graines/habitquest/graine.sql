-- Graine « habitquest » (HabitQuest, suivi d'habitudes). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- Les comptes A et B existent déjà dans auth.users (le déclencheur de l'app a créé leurs profils).
-- A : 6 habitudes, 8 notifications, 4 messages au support. B : 4 habitudes, 5 notifications, 3 messages au support ;
-- chaque texte libre de B porte un marqueur unique (aussi dans 2 notes de complétions de B, table non « à moi »).
-- Les deux profils passent en français (langue de l'interface, et les notifications ne sont pas retraduites).
\set ON_ERROR_STOP on
begin;

update public.profiles set language = 'fr' where id in (:'a'::uuid, :'b'::uuid);

insert into public.habits (user_id, name, category, frequency, emoji, why, anchor, mini) values
  (:'a'::uuid, 'Boire un verre d''eau au réveil', 'custom', 'daily', '💧', 'Pour bien démarrer la journée', 'En me levant', 'Un demi-verre'),
  (:'a'::uuid, 'Méditer dix minutes', 'custom', 'daily', '🧘', 'Pour garder le calme', 'Après le café', 'Trois respirations'),
  (:'a'::uuid, 'Lire vingt pages', 'custom', 'daily', '📖', 'Pour finir mon livre du mois', 'Avant de dormir', 'Une page'),
  (:'a'::uuid, 'Courir', 'custom', '3x_week', '🏃', 'Pour le souffle', 'Au retour du travail', 'Dix minutes de marche'),
  (:'a'::uuid, 'Étirements', 'custom', '5x_week', '🤸', 'Pour le dos', 'Avant la douche', 'Un étirement'),
  (:'a'::uuid, 'Écrire dans mon journal', 'custom', '2x_week', '✍️', 'Pour garder une trace', 'Le dimanche soir', 'Une phrase');

insert into public.habits (user_id, name, category, frequency, emoji, why, anchor, mini) values
  (:'b'::uuid, 'Habitude MARQUEUR-B-8ACD24EB', 'custom', 'daily', '🔥', 'Raison MARQUEUR-B-3E9E381D', 'Ancre MARQUEUR-B-26DAA321', 'Mini MARQUEUR-B-795DCEE2'),
  (:'b'::uuid, 'Habitude MARQUEUR-B-C5BB6167', 'custom', 'daily', '🔥', 'Raison MARQUEUR-B-1283180C', 'Ancre MARQUEUR-B-F139BFFA', 'Mini MARQUEUR-B-8BB9C37C'),
  (:'b'::uuid, 'Habitude MARQUEUR-B-7EA33E90', 'custom', 'daily', '🔥', 'Raison MARQUEUR-B-0F4CD790', 'Ancre MARQUEUR-B-D63B2431', 'Mini MARQUEUR-B-B455ED7E'),
  (:'b'::uuid, 'Habitude MARQUEUR-B-A57E2C77', 'custom', 'daily', '🔥', 'Raison MARQUEUR-B-73EC6577', 'Ancre MARQUEUR-B-C0ED1605', 'Mini MARQUEUR-B-5DB0A8D2');

insert into public.completions (habit_id, completed_at, xp_earned, note)
select h.id, v.at::timestamptz, 10, v.note
from (values
  ('Boire un verre d''eau au réveil', '2026-10-01 07:30+00', 'Fait', :'a'::uuid),
  ('Boire un verre d''eau au réveil', '2026-10-02 07:35+00', 'Fait aussi', :'a'::uuid),
  ('Méditer dix minutes', '2026-10-01 08:00+00', 'Séance calme', :'a'::uuid),
  ('Lire vingt pages', '2026-10-02 22:00+00', 'Chapitre trois', :'a'::uuid),
  ('Habitude MARQUEUR-B-8ACD24EB', '2026-10-01 09:00+00', 'Note MARQUEUR-B-11190FAE', :'b'::uuid),
  ('Habitude MARQUEUR-B-C5BB6167', '2026-10-02 09:00+00', 'Note MARQUEUR-B-D795D60F', :'b'::uuid)
) as v(name, at, note, owner)
join public.habits h on h.name = v.name and h.user_id = v.owner;

insert into public.notifications (user_id, type, title, body, is_read) values
  (:'a'::uuid, 'info', 'Bienvenue dans HabitQuest', 'Ton aventure commence maintenant.', false),
  (:'a'::uuid, 'info', 'Série en cours', 'Tu enchaînes trois jours de suite.', false),
  (:'a'::uuid, 'info', 'Nouvel objet', 'Un objet du magasin t''attend.', false),
  (:'a'::uuid, 'info', 'Rappel du matin', 'N''oublie pas ton verre d''eau.', false),
  (:'a'::uuid, 'info', 'Rappel du soir', 'Il reste une habitude à cocher.', false),
  (:'a'::uuid, 'info', 'Bravo', 'Tu as terminé toutes tes habitudes hier.', false),
  (:'a'::uuid, 'info', 'Coffre du jour', 'Ton coffre est prêt à être ouvert.', false),
  (:'a'::uuid, 'info', 'Semaine réussie', 'Belle semaine, continue ainsi.', false);

insert into public.notifications (user_id, type, title, body, is_read) values
  (:'b'::uuid, 'info', 'Titre MARQUEUR-B-BC437800', 'Texte MARQUEUR-B-48083E4B', false),
  (:'b'::uuid, 'info', 'Titre MARQUEUR-B-E50E5517', 'Texte MARQUEUR-B-10341BF1', false),
  (:'b'::uuid, 'info', 'Titre MARQUEUR-B-8E7892AF', 'Texte MARQUEUR-B-CA992452', false),
  (:'b'::uuid, 'info', 'Titre MARQUEUR-B-059A0E09', 'Texte MARQUEUR-B-D191AF67', false),
  (:'b'::uuid, 'info', 'Titre MARQUEUR-B-F5AC4B7A', 'Texte MARQUEUR-B-7DAFB582', false);

insert into public.support_messages (user_id, category, message, platform, app_version, language) values
  (:'a'::uuid, 'bug', 'Le bouton de partage ne répond pas toujours.', 'ios', '1.0.0', 'fr'),
  (:'a'::uuid, 'idea', 'Ce serait bien d''avoir un mode sombre.', 'ios', '1.0.0', 'fr'),
  (:'a'::uuid, 'other', 'Merci pour l''application, elle m''aide beaucoup.', 'ios', '1.0.0', 'fr'),
  (:'a'::uuid, 'idea', 'Pouvoir réorganiser mes habitudes à la main.', 'ios', '1.0.0', 'fr'),
  (:'b'::uuid, 'other', 'Message MARQUEUR-B-90B2E8B6', 'android', '1.0.0', 'fr'),
  (:'b'::uuid, 'other', 'Message MARQUEUR-B-20FE8C84', 'android', '1.0.0', 'fr'),
  (:'b'::uuid, 'other', 'Message MARQUEUR-B-E8E8B313', 'android', '1.0.0', 'fr');

commit;
