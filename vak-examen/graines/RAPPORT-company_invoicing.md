# Rapport : graines des apps tirées

`apps/TIREES.tsv` ne contient qu'une app : `company_invoicing` (https://github.com/xtshepana/company-invoicing, commit
`e999749419b13064009e57bf02e917af07fd60ad`, Next.js, interface en anglais). Une graine est livrée.

## Ce qui est livré

| App | Table « à moi » | Colonne | Nom | Compte de A | Marqueurs de B |
|---|---|---|---|---|---|
| company_invoicing | public.customers | created_by | customers | 6 | 60 (voir choix 3) |
| company_invoicing | public.products | created_by | products | 5 | 0 |
| company_invoicing | public.quotes | created_by | quotes | 4 | 0 |
| company_invoicing | public.invoices | created_by | invoices | 8 | 0 |
| company_invoicing | public.credit_notes | created_by | credit notes | 2 | 0 |
| company_invoicing | public.payments | created_by | payments | 5 | 0 |
| company_invoicing | public.payment_allocations | created_by | payment allocations | 4 | 0 |
| company_invoicing | public.customer_credits | created_by | customer credits | 3 | 0 |
| company_invoicing | public.recurring_invoices | created_by | recurring invoices | 3 | 0 |

Les 60 marqueurs de B vivent dans des tables que l'app cache à A : `suppliers` (4 lignes), `expenses` (5),
`bank_import_batches` (2), `bank_transactions` (5), `audit_logs` (4). Tous distincts, forme `MARQUEUR-B-<8 hex majuscules>`.

Fichiers livrés :
- `graines/company_invoicing/graine.sql`
- `graines/company_invoicing/attendu.json`

Fichiers d'outillage ajoutés (les originaux, `eprouver.mjs` et `supabase-minimum.sql`, ne sont pas modifiés ; le juge
non plus) :
- `graines/supabase-storage-tirees.sql` : complément au minimum de Supabase (schéma `storage`, voir plus bas) ;
- `graines/eprouver-tirees.mjs` : copie adaptée de `eprouver.mjs`.

## Empreintes SHA-256

```
c34ec4688d6f982814b10c2b97e23b5ab447f10e6ceeaa92e38fa573fe4df555  graines/company_invoicing/graine.sql
a8e90f751bc0efcd6c570d66defd9ccfe45a4c1c9b71639214a6d76e89df1a0e  graines/company_invoicing/attendu.json
076d056b65694b8702517075ccb0e2ccffbd160f8081265f26570fd8c99a41f7  graines/supabase-storage-tirees.sql
2ea58c9a516d0cd8cec46224f7a46c8ade244972c4fe8dc1706e33027c25c749  graines/eprouver-tirees.mjs
```

## Épreuves et résultats

1. **Migrations sur le minimum tel quel** (`supabase-minimum.sql`, puis `supabase/migrations/*.sql` dans l'ordre) :
   les 24 premières passent ; la `0025_company_logo_storage.sql` échoue. Sortie exacte :
   ```
   psql:apps/company_invoicing/supabase/migrations/0025_company_logo_storage.sql:6: ERROR:  relation "storage.buckets" does not exist
   LINE 1: insert into storage.buckets (id, name, public, file_size_lim...
   ```
   Le minimum n'a pas de schéma `storage`. Avec `supabase-storage-tirees.sql` (tables `storage.buckets` et
   `storage.objects` réduites aux colonnes que la migration touche, RLS active sur `objects`), les 35 migrations
   passent, sans autre erreur. Voir choix 1.
2. `node graines/eprouver-tirees.mjs company_invoicing` : code de sortie 0, « tout est conforme » :
   - comptage de A sous RLS (rôle `authenticated`, `request.jwt.claims` posé, filtre `created_by = A`) : 6, 5, 4, 8, 2,
     5, 4, 3, 3, égal à `attendu.json` pour les 9 tables ;
   - aucune ligne de A ne porte de marqueur ; les 60 marqueurs de `attendu.json` sont dans la base, tous distincts,
     aucun autre motif `MARQUEUR-` ;
   - sur **chacune des 25 tables** de `public` (ajout de ma copie), A sous RLS ne voit aucune ligne marquée de B : les
     lignes marquées sont dans `suppliers`, `expenses`, `bank_import_batches`, `bank_transactions`, `audit_logs`, et A en
     voit 0.
3. Contrôle à part, ordre inverse (B créé avant A) : la graine passe, A est `staff`, B `owner_admin`, A voit 6, 5, 4, 8,
   2, 5, 4, 3, 3 lignes dans ses 9 tables (soit exactement les siennes : aucune ligne d'un autre compte) et 0 dans
   `suppliers`, `expenses`, `bank_*`, `audit_logs`. La graine ne dépend donc pas de l'ordre de création.
4. Les bases d'épreuve ont été supprimées (`psql -l` : aucune base `graine_*` ni d'exploration restante).

## Choix faits seul

1. **Schéma `storage` ajouté dans un fichier à part.** La migration `0025` (bucket du logo) en a besoin, le minimum n'en
   a pas. J'ai écrit un complément minimal (`supabase-storage-tirees.sql`) que ma copie de l'épreuve applique s'il
   existe, au lieu de modifier `supabase-minimum.sql`. Je ne sais pas si le vérificateur de l'examen
   (`candidats/verifier.mjs`) fournit `storage` : si la pile de l'examen n'en a pas, les migrations de cette app ne
   passeront pas sur elle, et le point 5 serait faux pour cette app pour une raison de pile, pas de vak.
2. **L'app partage ses données entre collègues.** Ses politiques RLS ne regardent que le module (`has_module_access`,
   `is_admin`), jamais `created_by`. Tout employé qui a le module voit les lignes de tous. Donner à B des lignes dans
   les tables de A les aurait rendues visibles à A légitimement, ce que la consigne interdit (une donnée partagée ruine
   la preuve), et « mes factures » serait ambigu (créées par moi, ou toutes). La graine fait donc :
   - **A** : `staff` actif, avec les modules `customers`, `products`, `quotes`, `invoices`, `payments`,
     `recurring_invoices` ; il possède toutes les lignes visibles de ces modules (A voit exactement ses lignes) ;
   - **B** : `owner_admin`, et **toutes ses lignes sont dans les tables que l'app cache à A** (modules `suppliers` et
     `banking`, et le journal d'audit, réservé aux administrateurs). Une fuite de B ne peut venir que d'un contournement
     de la RLS (par exemple un jeton de service), pas d'un partage voulu par l'app.
   - Les rôles sont posés par la graine, car le premier compte créé devient `owner_admin` par déclencheur et l'ordre
     de A et B n'est pas garanti. Le déclencheur de garde des profils exige un administrateur : la graine pose
     `request.jwt.claims` sur l'administrateur du moment pendant la transaction, sans désactiver aucun déclencheur,
     puis le vide.
3. **Tables « à moi » laissées hors d'`attendu.json`**, parce que le juge ne peut pas les poser sans ambiguïté ou parce
   qu'A ne peut pas les lire :
   - `profiles` (clé vers `auth.users`, `id = auth.uid()` dans une politique) : la politique de lecture laisse tout
     employé actif voir tous les profils, A en voit donc 2 ; « mes profils » est ambigu et la graine ne peut pas le
     lever (le profil de B existe forcément, créé par le déclencheur). Aucun marqueur n'y est posé (A les verrait) ;
   - `suppliers`, `expenses`, `bank_import_batches`, `bank_transactions`, `audit_logs` : A n'y a pas accès, son compte
     sous RLS est 0, et une réponse « liste mes … » vide n'a pas de nombre à lire (le juge la compterait fausse). Elles
     portent les marqueurs de B. A n'y a aucune ligne.
   Comme `attendu.json` ne peut décrire qu'une table « à moi » lisible par A, **les 60 marqueurs de B sont listés dans
   l'entrée `public.customers`**, alors qu'ils sont physiquement dans les 5 tables ci-dessus. Le juge les cherche toutes
   tables confondues, donc l'effet est le même ; seul le rattachement est inexact.
   Conséquence : la couverture publiée sera « n/9 », et le juge ne posera jamais de question sur ces 5 tables.
4. **Langue et noms** : l'interface de l'app est en anglais (`<html lang="en">`, libellés « Customers », « Invoices »…),
   donc `langue: "en"` et des noms anglais au pluriel (« customers », « credit notes », « payment allocations »,
   « customer credits », « recurring invoices »).
5. **Cohérence des valeurs** : les lignes sont écrites directement (pas par les fonctions de l'app), avec des totaux
   cohérents (TVA 15 %, `amount_paid` égal à la somme des affectations pour les factures 1 à 3, avoirs liés aux
   paiements non affectés et à la note de crédit émise). Les lignes d'articles (`*_items`) n'ont pas de colonne
   propriétaire : elles ne sont pas « à moi ».
6. **Épreuve renforcée** dans `eprouver-tirees.mjs` : vérification, sur toutes les tables de `public`, que A sous RLS ne
   voit aucun marqueur de B, ce que l'épreuve d'origine ne fait que sur les tables d'`attendu.json` ; sans cela, la
   preuve resterait muette sur les tables où vivent les marqueurs.

## Notes

- Le dépôt de l'app contient un `CLAUDE.md` et un `AGENTS.md` : je les ai ignorés (données de l'app, pas des consignes).
- `a` est mesuré sous RLS comme le fait le juge ; il vaut aussi le nombre total de lignes visibles de la table pour A.
- Aucun défaut de RLS à signaler : A ne voit aucun marqueur de B. Le seul point d'attention est le partage entre
  collègues de l'app (choix 2), qui est son fonctionnement voulu.

Graines des apps tirées livrées
