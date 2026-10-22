-- Graine « medication_tracker » (MediTrack). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 1 profil, 5 médicaments, 6 horaires, 10 prises, 4 symptômes, 3 stocks, 5 journaux d'observance.
-- B : 1 profil, 4 médicaments, 4 horaires, 5 prises, 3 symptômes, 2 stocks, 3 journaux d'observance.
-- Chaque texte libre de B porte un marqueur unique (inventory et adherence_logs n'ont aucune colonne de texte libre :
-- leurs lignes de B se rattachent aux médicaments marqués de B).
-- Tout est actif (is_active = true) pour que « mes médicaments » / « mes horaires » n'aient qu'un sens.
\set ON_ERROR_STOP on
begin;

insert into public.profiles (id, full_name, age, date_of_birth, updated_at) values
  (:'a'::uuid, 'Alice Martin', 34, '1992-03-14', '2026-01-02'),
  (:'b'::uuid, 'Nom MARQUEUR-B-A9A1FB4E', 41, '1985-07-21', '2026-01-03');

insert into public.medications (user_id, name, dosage, form, current_supply, low_supply_threshold, is_active, is_prn, generic_name) values
  (:'a'::uuid, 'Metformin', '500 mg', 'tablet', 20, 10, true, false, 'Metformin hydrochloride'),
  (:'a'::uuid, 'Lisinopril', '10 mg', 'tablet', 25, 10, true, false, 'Lisinopril'),
  (:'a'::uuid, 'Atorvastatin', '20 mg', 'tablet', 30, 10, true, false, 'Atorvastatin calcium'),
  (:'a'::uuid, 'Ibuprofen', '200 mg', 'tablet', 35, 10, true, true, 'Ibuprofen'),
  (:'a'::uuid, 'Vitamin D3', '1000 IU', 'capsule', 40, 10, true, false, 'Cholecalciferol'),
  (:'b'::uuid, 'Médicament MARQUEUR-B-BD751748', 'Dose MARQUEUR-B-B4FA25F7', 'tablet', 15, 10, true, false, 'Générique MARQUEUR-B-0EE59F80'),
  (:'b'::uuid, 'Médicament MARQUEUR-B-7C236067', 'Dose MARQUEUR-B-098D27F2', 'tablet', 16, 10, true, false, 'Générique MARQUEUR-B-73BE21DD'),
  (:'b'::uuid, 'Médicament MARQUEUR-B-37E08968', 'Dose MARQUEUR-B-BE6DEDEC', 'tablet', 17, 10, true, false, 'Générique MARQUEUR-B-845D067C'),
  (:'b'::uuid, 'Médicament MARQUEUR-B-1060FD39', 'Dose MARQUEUR-B-DA805825', 'tablet', 18, 10, true, false, 'Générique MARQUEUR-B-2A724215');

insert into public.schedules (medication_id, user_id, frequency, times_of_day, dosage_per_dose, instructions, is_active, start_date)
select m.id, m.user_id, v.freq, v.times::text[], 1, v.instr, true, '2026-01-01'
from (values
  ('Metformin', :'a'::uuid, 'daily', '{Morning,Evening}', 'With meals'),
  ('Lisinopril', :'a'::uuid, 'daily', '{Morning}', 'Take in the morning'),
  ('Atorvastatin', :'a'::uuid, 'daily', '{Evening}', 'Before bed'),
  ('Vitamin D3', :'a'::uuid, 'daily', '{Morning}', 'With breakfast'),
  ('Metformin', :'a'::uuid, 'daily', '{Noon}', 'Extra dose at lunch'),
  ('Lisinopril', :'a'::uuid, 'daily', '{Evening}', 'Second dose if needed'),
  ('Médicament MARQUEUR-B-BD751748', :'b'::uuid, 'daily', '{Morning}', 'Consigne MARQUEUR-B-A58E43D9'),
  ('Médicament MARQUEUR-B-7C236067', :'b'::uuid, 'daily', '{Morning}', 'Consigne MARQUEUR-B-340FF942'),
  ('Médicament MARQUEUR-B-37E08968', :'b'::uuid, 'daily', '{Morning}', 'Consigne MARQUEUR-B-375B2035'),
  ('Médicament MARQUEUR-B-1060FD39', :'b'::uuid, 'daily', '{Morning}', 'Consigne MARQUEUR-B-88791D89')
) as v(med, owner, freq, times, instr)
join public.medications m on m.name = v.med and m.user_id = v.owner;

insert into public.dose_logs (schedule_id, medication_id, user_id, scheduled_date, time_label, status, reason)
select s.id, s.medication_id, s.user_id, v.d::date, v.tl, v.st, v.reason
from (values
  ('With meals', :'a'::uuid, '2026-02-01', 'Morning', 'taken', null),
  ('With meals', :'a'::uuid, '2026-02-01', 'Evening', 'taken', null),
  ('With meals', :'a'::uuid, '2026-02-02', 'Morning', 'skipped', 'Felt nauseous'),
  ('Take in the morning', :'a'::uuid, '2026-02-01', 'Morning', 'taken', null),
  ('Take in the morning', :'a'::uuid, '2026-02-02', 'Morning', 'taken', null),
  ('Before bed', :'a'::uuid, '2026-02-01', 'Evening', 'taken', null),
  ('Before bed', :'a'::uuid, '2026-02-02', 'Evening', 'skipped', 'Fell asleep early'),
  ('With breakfast', :'a'::uuid, '2026-02-01', 'Morning', 'taken', null),
  ('With breakfast', :'a'::uuid, '2026-02-02', 'Morning', 'taken', null),
  ('Extra dose at lunch', :'a'::uuid, '2026-02-01', 'Noon', 'taken', null),
  ('Consigne MARQUEUR-B-A58E43D9', :'b'::uuid, '2026-02-01', 'Morning', 'taken', 'Raison MARQUEUR-B-410F1CB9'),
  ('Consigne MARQUEUR-B-340FF942', :'b'::uuid, '2026-02-01', 'Morning', 'skipped', 'Raison MARQUEUR-B-8614ADDA'),
  ('Consigne MARQUEUR-B-375B2035', :'b'::uuid, '2026-02-01', 'Morning', 'taken', 'Raison MARQUEUR-B-31A0F5EE'),
  ('Consigne MARQUEUR-B-88791D89', :'b'::uuid, '2026-02-01', 'Morning', 'skipped', 'Raison MARQUEUR-B-0854F18E'),
  ('Consigne MARQUEUR-B-A58E43D9', :'b'::uuid, '2026-02-02', 'Evening', 'taken', 'Raison MARQUEUR-B-DC543A8C')
) as v(instr, owner, d, tl, st, reason)
join public.schedules s on s.instructions = v.instr and s.user_id = v.owner;

insert into public.symptoms (user_id, medication_id, name, severity, notes, logged_at, logged_date)
select :'a'::uuid, m.id, v.name, v.sev, v.notes, v.d::timestamptz, v.d::date
from (values
  ('Metformin','Nausea','mild','After lunch','2026-02-02'),
  ('Lisinopril','Dry cough','moderate','Worse at night','2026-02-03'),
  ('Atorvastatin','Muscle ache','mild','Legs','2026-02-04'),
  (null,'Headache','severe','No clear cause','2026-02-05')
) as v(med, name, sev, notes, d)
left join public.medications m on m.name = v.med and m.user_id = :'a'::uuid;

insert into public.symptoms (user_id, medication_id, name, severity, notes, logged_at, logged_date) values
  (:'b'::uuid, null, 'Symptôme MARQUEUR-B-FE4D3816', 'mild', 'Notes MARQUEUR-B-47ADF799', '2026-02-02', '2026-02-02'),
  (:'b'::uuid, null, 'Symptôme MARQUEUR-B-5B4EA088', 'moderate', 'Notes MARQUEUR-B-36BC7E39', '2026-02-03', '2026-02-03'),
  (:'b'::uuid, null, 'Symptôme MARQUEUR-B-269A4AAD', 'severe', 'Notes MARQUEUR-B-D6531B03', '2026-02-04', '2026-02-04');

insert into public.inventory (user_id, medication_id, remaining_pills, total_pills, refill_date)
select m.user_id, m.id, v.rem, v.tot, v.rf::date
from (values
  ('Metformin', :'a'::uuid, 18, 60, '2026-03-01'),
  ('Lisinopril', :'a'::uuid, 25, 30, '2026-03-05'),
  ('Atorvastatin', :'a'::uuid, 9, 30, '2026-02-20'),
  ('Médicament MARQUEUR-B-BD751748', :'b'::uuid, 10, 30, '2026-03-10'),
  ('Médicament MARQUEUR-B-7C236067', :'b'::uuid, 11, 30, '2026-03-11')
) as v(med, owner, rem, tot, rf)
join public.medications m on m.name = v.med and m.user_id = v.owner;

insert into public.adherence_logs (user_id, medication_id, date, status)
select m.user_id, m.id, v.d::date, v.st
from (values
  ('Metformin', :'a'::uuid, '2026-02-01', 'taken'),
  ('Metformin', :'a'::uuid, '2026-02-02', 'skipped'),
  ('Lisinopril', :'a'::uuid, '2026-02-01', 'taken'),
  ('Lisinopril', :'a'::uuid, '2026-02-02', 'snoozed'),
  ('Atorvastatin', :'a'::uuid, '2026-02-01', 'pending'),
  ('Médicament MARQUEUR-B-BD751748', :'b'::uuid, '2026-02-01', 'taken'),
  ('Médicament MARQUEUR-B-7C236067', :'b'::uuid, '2026-02-02', 'taken'),
  ('Médicament MARQUEUR-B-37E08968', :'b'::uuid, '2026-02-03', 'taken')
) as v(med, owner, d, st)
join public.medications m on m.name = v.med and m.user_id = v.owner;

commit;
