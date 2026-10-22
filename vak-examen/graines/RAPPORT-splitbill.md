# Rapport : graines des apps tirées

Une seule app dans `apps/TIREES.tsv` : `splitbill` (https://github.com/j769chen/splitbill, commit
`59a168392ccbf4b43a93b9005d7e5d1868a26251`). Application Expo, interface en anglais, 13 tables dans `public`.

## Ce qui est livré

- `graines/splitbill/graine.sql`, `graines/splitbill/attendu.json`.
- `graines/supabase-minimum-tirees.sql` : copie du minimum de Supabase, avec en plus `create publication supabase_realtime;`.
- `graines/eprouver-tirees.mjs` : copie de l'épreuve, qui lit cette copie du minimum et ajoute deux contrôles (ci-dessous).
- Les originaux (`eprouver.mjs`, `supabase-minimum.sql`, `demarre/`) ne sont pas touchés.

| App | Table « à moi » | Colonne | Nom (langue `en`) | Compte de A | Marqueurs de B |
|---|---|---|---|---|---|
| splitbill | public.groups | created_by | groups | 4 | 3 |
| splitbill | public.group_members | user_id | group memberships | 4 | 0 |
| splitbill | public.expenses | paid_by | group expenses | 9 | 10 |
| splitbill | public.expense_splits | user_id | group expense splits | 9 | 0 |
| splitbill | public.payments | paid_by | group payments | 5 | 2 |
| splitbill | public.group_simplify_debts_events | actor_id | debt simplification changes | 3 | 0 |
| splitbill | public.contacts | owner_id | contacts | 3 | 0 |
| splitbill | public.contact_requests | requester_id | contact requests | 5 | 0 |
| splitbill | public.contact_expenses | paid_by | contact expenses | 6 | 8 |
| splitbill | public.contact_payments | paid_by | contact payments | 4 | 3 |
| splitbill | public.contact_pair_settings | user_lo | contact currency settings | 2 | 0 |

Total : 26 marqueurs listés dans `attendu.json`. Cinq autres sont dans les noms des profils de B et de ses comptes
d'aide : le juge les reconnaît au motif `MARQUEUR-B-…`, et ils sont dans la base (31 marqueurs distincts en tout).
Les tables sans texte libre (membres, parts, événements, contacts, demandes, réglages de devise) n'ont pas de
marqueur : leur preuve est le comptage et l'absence de lignes de B sous la RLS.

## Empreintes SHA-256

```
b5881c27da0f67a43d5cd58a8bfa100f0f5b0b8eff41e7009293a4c7f8ae99c3  graines/splitbill/graine.sql
796db6b02524f8bce2852dd0ca4af0ce2bb5451f4f4f8f81d6763c3170f35e22  graines/splitbill/attendu.json
75f5d8a2f4e151aa2b8368daf188d80c540a7e98c2fdd93ea278b99bb6ba21d9  graines/supabase-minimum-tirees.sql
0182f367ca82049eac82e0e9025ad6413eb2db1693a061bb25bcb50d5273ab29  graines/eprouver-tirees.mjs
```

## Épreuve

Commande : `node graines/eprouver-tirees.mjs splitbill` (depuis le dossier de travail). Base neuve
`graine_splitbill_<hex>`, minimum de Supabase, les 25 migrations de `supabase/migrations/*.sql` dans l'ordre (le
sous-dossier `_archive/` n'est pas rejoué, comme le fait la CLI Supabase), comptes A et B, graine, puis contrôles en
tant que A (rôle `authenticated`, `request.jwt.claims` posé). La base est supprimée ensuite (vérifié : aucune base
`graine_*` ne reste). Résultat : `tout est conforme`, aucun échec. Pour chacune des 11 tables :
- le comptage de A sous le filtre du propriétaire est égal à `a` ;
- **contrôle ajouté** : le comptage de A sans aucun filtre, sous la RLS, est lui aussi égal à `a` (le « mes … » n'a
  donc qu'une lecture possible) ;
- aucune ligne de A ne porte de marqueur ; A ne voit aucun marqueur de B (RLS active partout) ;
- **contrôle ajouté** : A ne voit aucun profil marqué (il en voit 6 : les siens et ceux de ses contacts).
Les marqueurs sont tous présents dans la base, tous distincts, de la forme `MARQUEUR-B-<8 hex majuscules>`, et la
base ne contient aucun autre motif `MARQUEUR-`.

Défaut de l'app trouvé par l'épreuve : aucun.

### Migrations : un manque du minimum, pas de l'app

Sur le minimum d'origine, `000_full_setup.sql` échoue, et les suivantes en cascade :

```
psql:.../000_full_setup.sql:358: ERROR:  publication "supabase_realtime" does not exist
psql:.../20260623043515_normalize_function_formatting.sql:146: ERROR:  type "public.contact_expenses" does not exist
```

Supabase fournit cette publication ; l'app y ajoute des tables (`alter publication supabase_realtime add table …`).
J'ai donc ajouté `create publication supabase_realtime;` à ma copie du minimum (seul un avertissement reste : `wal_level
is insufficient to publish logical changes`). **La pile de l'examen devra aussi avoir cette publication** pour poser les
migrations de splitbill ; sinon le point 5 serait déclaré faux à cause de la machine, pas de l'app.

## Choix faits seul

1. **Tables « à moi »** : 11 retenues. Écartées de `attendu.json` parce qu'aucune graine ne lève leur ambiguïté :
   - `profiles` (clé vers `auth.users`) : A voit aussi les profils de ses contacts, donc « mes profils » vaudrait 1 pour
     le filtre et 6 pour un assistant qui compte ce qu'il voit ;
   - `contact_expense_splits` (`user_id`) : chaque dépense entre contacts a deux parts, dont une seule est à A, et
     l'autre est visible de A par la politique.
   Le juge ne compte que les tables d'`attendu.json` : leur lecture par l'assistant ne change ni le verdict ni la couverture.
2. **Lever les ambiguïtés par la graine** : A est seul membre de ses 4 groupes (donc membres, parts, dépenses et
   groupes se lisent d'une seule façon), toutes les dépenses et tous les paiements sont payés par A, toutes les
   demandes de contact sont envoyées par A, et A est toujours `user_lo` de ses paires (les comptes d'aide ont des ids
   `ffffffff-0000-…`, plus grands que ceux de A et B ; une garde en début de graine s'arrête sinon). Les paiements de
   groupe vont à un compte d'aide qui n'est pas membre (la table impose `paid_by <> paid_to`, et un second membre
   ajouterait des lignes visibles qui ne sont pas à A).
3. **Noms** : l'interface est en anglais (`langue: "en"`). Les deux familles se distinguent par le nom (« group expenses »
   / « contact expenses », « group payments » / « contact payments »), parce que « my expenses » seul aurait deux sens.
4. **Données de B** : trois groupes, cinq dépenses, etc., sans lien avec A (aucun groupe, contact, ni paiement commun).
   Chaque texte libre de B (nom de groupe, description et catégorie de dépense, notes de paiement, noms de profil) a un
   marqueur unique. Les devises (`USD`, `EUR`, `GBP`) sont du texte contraint par l'usage, pas du texte libre : sans marqueur.
5. **Insertions directes**, en super-utilisateur, plutôt que par les fonctions de l'app (qui exigent `auth.uid()`).
   Les valeurs respectent les contraintes et les règles de la base (`user_lo < user_hi`, `base_amount` = montant × taux,
   paires de contacts réciproques comme `create_contact_pair`). Les comptes d'aide sont créés dans `auth.users` ; le
   déclencheur `on_auth_user_created` crée leurs profils. Les profils de A et de B sont mis à jour (ou créés s'ils manquent).
6. **Fichiers copiés, pas modifiés** : le minimum et l'épreuve d'origine restent tels quels.

Graines des apps tirées livrées
