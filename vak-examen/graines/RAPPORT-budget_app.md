# Rapport : graines des apps tirées

`apps/TIREES.tsv` ne contient qu'une app : `budget_app` (AndrerezaMedya/budget-app, commit f1f3ef1b…). Une graine livrée.

## Livré

- `graines/budget_app/graine.sql`, `graines/budget_app/attendu.json`.
- Outils d'épreuve adaptés (copies ; `eprouver.mjs` et `supabase-minimum.sql` sont intacts) :
  `graines/supabase-minimum-tirees.sql` et `graines/eprouver-tirees.mjs` (seule différence avec l'original : il charge `supabase-minimum-tirees.sql`).

| app | table « à moi » | colonne | nom | compte de A | marqueurs de B |
|---|---|---|---|---|---|
| budget_app | `public.profiles` | `id` | profiles | 1 | 1 |
| budget_app | `public.accounts` | `user_id` | accounts | 3 | 2 |
| budget_app | `public.categories` | `user_id` | categories | 5 | 3 |
| budget_app | `public.tags` | `user_id` | tags | 4 | 3 |
| budget_app | `public.payees` | `user_id` | payees | 6 | 4 |
| budget_app | `public.transactions` | `user_id` | transactions | 14 | 10 |
| budget_app | `public.budgets` | `user_id` | budgets | 6 | 0 |
| budget_app | `public.category_monthly_summaries` | `user_id` | category monthly summaries | 12 | 0 |
| budget_app | `public.account_daily_summaries` | `user_id` | account daily summaries | 5 | 0 |
| budget_app | `public.daily_cashflow_summaries` | `user_id` | daily cashflow summaries | 14 | 0 |
| budget_app | `public.receipt_ingestion_jobs` | `user_id` | receipt ingestion jobs | 3 | 5 |
| budget_app | `public.receipts` | `user_id` | receipts | 4 | 16 |

44 marqueurs de B distincts au total (tous présents dans la base, aucun autre motif `MARQUEUR-` dans la base).

## Empreintes SHA-256

```
c1c1cd3651a52dce7f0082452b868bfc2deb91c9c0bd7de745f1986f60e03680  graines/budget_app/graine.sql
fe7f0d075ccfb2c60c1edf398975401397c2dfe700c5b7c67b971a0368fb9d5d  graines/budget_app/attendu.json
0ce7d0790cfffe58e4a1b66e956188e8c3fd6a56ed64292a05d66691b0a94b07  graines/supabase-minimum-tirees.sql
0caea8e6133b23742f2ab94a7bec063660c86efd958a2d4fe311266393aa645e  graines/eprouver-tirees.mjs
```

## Épreuves

1. `node graines/eprouver.mjs budget_app` (minimum d'origine) : **échec**, les migrations ne passent pas. Sortie exacte :
   ```
   psql:.../migrations/202511060001_receipts.sql:6: ERROR:  relation "storage.buckets" does not exist
   LINE 1: insert into storage.buckets (id, name, public)
   ```
   Les migrations `202511060002` (table `receipt_ingestion_jobs` absente) et `202511120001` (`schema "storage" does not exist`)
   échouent ensuite par ricochet. Cause : le minimum de Supabase n'a pas de schéma `storage`.
2. `node graines/eprouver-tirees.mjs budget_app` : minimum + schéma `storage` (voir les choix), les 8 migrations passent, deux
   comptes, graine, puis comptes de A sous RLS (rôle `authenticated`, `request.jwt.claims` posé) : **107 vérifications ok, 0 échec,
   « tout est conforme »**. Notamment : les 12 comptes de A égaux à `attendu.json` ; aucune ligne de A ne porte de marqueur ;
   A ne voit aucun marqueur de B sous la RLS de l'app (RLS active sur les 12 tables). Seuls bruits : 3 NOTICE de
   `202511090001` (`drop ... if exists`) et un avertissement `pg_dump` sur la clé circulaire de `categories` (sans effet).
   Base supprimée à chaque fois (0 base `graine_%` restante).

Je n'ai pas lancé le juge ni la pile (`demander.mjs`) : hors de la consigne.

## Choix faits seul

- **Schéma `storage`.** Le minimum fourni ne le contient pas et les migrations de l'app l'exigent. Plutôt que de modifier le
  minimum partagé, j'ai ajouté dans une copie un schéma `storage` réduit (`buckets`, `objects` avec RLS activée, privilèges).
  C'est une approximation de Supabase, pas la vraie table. Si le vérificateur de l'examen (`candidats/verifier.mjs`, que je n'ai pas)
  n'a pas ce schéma, l'éligibilité de budget_app est à réexaminer : à la charge de l'examen, pas de ma graine.
- **Tables « à moi » : toutes celles qui ont une colonne utilisateur**, y compris `profiles` (colonne `id`, clé vers
  `auth.users`) et les 3 tables de synthèse. Exclues : `transaction_tags` et `receipt_line_items` (pas de colonne utilisateur,
  la RLS passe par une sous-requête sur le parent) ; leur ligne de B porte quand même un marqueur (`receipts` en recense un).
- **Langue `en`**, car l'interface est en anglais (locale par défaut `en`, `en`/`id` seulement). Les noms sont ceux de la
  navigation et des tables (`accounts`, `payees`…) ; pour les synthèses, des noms descriptifs.
- **Profils** : aucun déclencheur ne les crée, la graine insère un profil pour A et un pour B. « My profiles » vaut 1.
- **Synthèses** : `category_monthly_summaries` et `daily_cashflow_summaries` sont remplies par les déclencheurs de l'app
  (leurs comptes, 12 et 14, sont ceux que la base donne, vérifiés) ; `account_daily_summaries` n'est écrite par aucun déclencheur,
  la graine l'écrit à la main (5 lignes pour A). Ces 4 tables (avec `budgets`) n'ont pas de texte libre : `marqueurs_b` y est vide,
  B y a quand même des lignes, que la RLS cache à A.
- **Ambiguïtés écartées** : aucun compte archivé, aucune catégorie fille, aucun virement (une ligne = une transaction) ; A a des
  comptes de types variés mais tous actifs. Comptes de A tous distincts entre tables (sauf 14 = 14 pour `transactions` et
  `daily_cashflow_summaries`, qui comptent des choses différentes).
- **Marqueurs** : tirés au hasard (8 hexadécimaux majuscules), uniques ; ceux de B dans les noms de comptes, catégories, étiquettes,
  bénéficiaires, descriptions et notes, noms de fichiers et messages d'import, marchand, adresse, notes, OCR et JSON des reçus.
  Les noms de comptes/catégories/bénéficiaires de B sont repris dans ses transactions (ils servent de clés).
- Les valeurs de A sont lisibles (noms réalistes, en roupies `IDR`, comme les défauts de l'app) ; B est en `USD`.

Graines des apps tirées livrées
