# Rapport : graines des apps tirées

## Livré

Une seule app dans `apps/TIREES.tsv` : `medication_tracker` (PanagiotisKaraliolios/medication-tracker, commit cfad8417…).
Ses migrations (un seul fichier, `supabase/migrations/00000000000000_initial.sql`) passent sans erreur sur le minimum de
Supabase, sans adaptation d'`eprouver.mjs`. Fichiers : `graines/medication_tracker/graine.sql` et `attendu.json`.

| App | Table « à moi » | Colonne | Nom | Compte de A | Marqueurs de B |
|---|---|---|---|---|---|
| medication_tracker | public.profiles | id | profiles | 1 | 1 |
| medication_tracker | public.medications | user_id | medications | 5 | 12 |
| medication_tracker | public.schedules | user_id | schedules | 6 | 4 |
| medication_tracker | public.dose_logs | user_id | dose logs | 10 | 5 |
| medication_tracker | public.symptoms | user_id | symptoms | 4 | 6 |
| medication_tracker | public.inventory | user_id | inventory records | 3 | 0 |
| medication_tracker | public.adherence_logs | user_id | adherence logs | 5 | 0 |

## Empreintes SHA-256

```
12b32a87111b03126a1347128508f17ffd7210c3aa2b64a8f39281f43bcf7e17  medication_tracker/attendu.json
7a2a841002aab1aaa5a4e6f889654065086aa5c6d0692c12283b1b751f382732  medication_tracker/graine.sql
```

## Épreuve

Commande : `node graines/eprouver.mjs medication_tracker` (base neuve `graine_medication_tracker_<hex>`, supprimée ensuite ;
vérifié : aucune base `graine_%` ne reste). Résultat : « tout est conforme », 0 échec. En particulier :
- comptes de A sous RLS (rôle `authenticated`, `request.jwt.claims` posé) égaux à `a` pour les 7 tables ;
- aucune ligne de A ne porte de marqueur ; A ne voit aucun marqueur de B sous la RLS de l'app (RLS active sur les 7 tables) ;
- 28 marqueurs de B distincts, tous présents en base, aucun autre motif `MARQUEUR-`.

## Choix faits seul

- **Langue `en`** : l'interface de l'app est en anglais (titres « No medications yet », « No symptoms logged »…), sans i18n.
- **Les 7 tables sont « à moi »**, y compris `inventory` et `adherence_logs` (marquées « legacy, inutilisées » dans la
  migration) : elles ont une clé vers `auth.users` et une RLS sur `auth.uid() = user_id`. `profiles` l'est par `id`
  (clé vers `auth.users`, politique `auth.uid() = id`) : A en a 1, ce qui rend « how many of my profiles » peu naturel,
  mais la règle du point 5 l'inclut ; le nom est laissé « profiles ».
- **`inventory` et `adherence_logs` n'ont aucune colonne de texte libre** : pas de marqueur possible dans leurs lignes,
  donc `marqueurs_b` est vide pour elles. Les lignes de B s'y rattachent à des médicaments marqués de B (2 stocks, 3 journaux).
- **Ambiguïtés levées** : tous les médicaments et horaires sont actifs (`is_active = true`), pour que « mes médicaments »
  et « mes horaires » n'aient qu'un sens ; A a 1 médicament « à la demande » (`is_prn`, Ibuprofen), compté dans les 5.
  Les prises (`dose_logs`) comptent prises et sautées (`taken`/`skipped`) ; les journaux d'observance couvrent quatre états.
- Les données de A sont en anglais, sans marqueur ; celles de B sont préfixées en français (« Médicament », « Consigne »…)
  suivies d'un marqueur, dans chaque colonne de texte libre (nom, dosage, nom générique, consigne, raison, symptôme, notes, nom du profil).
- Les prises de B sont rattachées à des horaires de B via leur consigne (unique), car l'index unique `dose_logs_unique_slot` exige
  (horaire, date, créneau) distincts : respecté.
- Aucune donnée partagée dans l'app : aucune table publique, donc aucun marqueur que A pourrait voir légitimement.

Graines des apps tirées livrées
