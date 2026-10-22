# Rapport : graines des apps tirées

## Ce qui est livré

`apps/TIREES.tsv` ne contient qu'une app : `smart_budget_application` (Smart-Budget-Application, commit `d8173d6a…`, Next.js + Supabase).

- `graines/smart_budget_application/graine.sql` et `attendu.json` : 25 tables « à moi », langue `en` (interface en/bg, `en` par défaut ; `handle_new_user` écrit `language: en`).
- Outils annexes (copies adaptées, les originaux ne sont pas touchés) : `graines/supabase-minimum-tirees.sql` et `graines/eprouver-tirees.mjs`.

| App | Table « à moi » | Colonne | Nom | A | Marqueurs de B |
|---|---|---|---|---|---|
| smart_budget_application | `public.analytics_events` | `user_id` | analytics events | 9 | 6 |
| | `public.categories` | `user_id` | categories | 7 | 4 |
| | `public.category_budgets` | `user_id` | category budgets | 3 | 0 |
| | `public.comeback_challenges` | `user_id` | comeback challenges | 2 | 0 |
| | `public.detected_subscriptions` | `user_id` | detected subscriptions | 4 | 2 |
| | `public.goal_contributions` | `user_id` | goal contributions | 6 | 3 |
| | `public.goals` | `user_id` | savings goals | 3 | 2 |
| | `public.household_invitations` | `invited_by` | household invitations | 3 | 2 |
| | `public.household_members` | `user_id` | household memberships | 1 | 0 |
| | `public.households` | `created_by` | households | 1 | 1 |
| | `public.insights` | `user_id` | insights | 5 | 8 |
| | `public.notification_deliveries` | `user_id` | notification deliveries | 3 | 4 |
| | `public.personal_allowances` | `user_id` | personal allowances | 1 | 0 |
| | `public.push_subscriptions` | `user_id` | push subscriptions | 2 | 3 |
| | `public.recovery_plans` | `user_id` | recovery plans | 2 | 1 |
| | `public.streaks` | `user_id` | streaks | 1 | 0 |
| | `public.transactions` | `user_id` | transactions | 14 | 8 |
| | `public.user_achievements` | `user_id` | achievements | 4 | 0 |
| | `public.user_feature_state` | `user_id` | feature states | 1 | 0 |
| | `public.user_profiles` | `id` | profiles | 1 | 2 |
| | `public.user_sessions` | `user_id` | sessions | 3 | 6 |
| | `public.user_values` | `user_id` | values | 4 | 2 |
| | `public.value_categories` | `user_id` | value-category links | 5 | 0 |
| | `public.weekly_digests` | `user_id` | weekly digests | 4 | 4 |
| | `public.wishlist_items` | `user_id` | wishlist items | 5 | 2 |

60 marqueurs distincts au total, tous dans des tables « à moi ». `exchange_rates_cache` (cache de taux, sans colonne propriétaire) est exclue.

## Empreintes SHA-256

```
8c1ce085fc860f317fbf60588ab68bfbdea50ef919c18ea526ece305177ec829  graines/smart_budget_application/attendu.json
69f257b27ee5a30c539127c590bdeb9e187fe72dcc176b4c1284dfa1162ef2ce  graines/smart_budget_application/graine.sql
de5dd0d8c66fe1438d0141ebe9cf443178d240565a6458efbb11a9c0fcdc82f8  graines/supabase-minimum-tirees.sql
002e8017f9a1d827a4813281338e727f3a48b305e15c3cef2092f355df01dd73  graines/eprouver-tirees.mjs
```

## Épreuves

1. Avec le minimum d'origine (`supabase-minimum.sql`), deux migrations échouent (`ON_ERROR_STOP`) :
   - `006_user_sessions_table.sql:167: ERROR:  publication "supabase_realtime" does not exist`
   - `038_security_hardening.sql:153: ERROR:  schema "storage" does not exist` (la transaction de 038 est annulée en entier).
   Ce sont des manques du minimum, pas de l'app : Supabase fournit la publication et `storage`. `supabase-minimum-tirees.sql` ajoute `create publication supabase_realtime`, le schéma `storage` (`buckets`, `objects` avec RLS, `foldername()`). Avec lui, les 42 migrations passent sans erreur. (Remarque : la pile réelle doit fournir ces deux objets, sinon 006 et 038 échouent.)
2. `node graines/eprouver-tirees.mjs smart_budget_application` : base neuve, minimum, migrations dans l'ordre, deux comptes, graine, comptes de A sous `authenticated` + `request.jwt.claims`, marqueurs, puis suppression de la base. Résultat : **« tout est conforme », 0 échec**. Pour chacune des 25 tables : compte de A égal à `a` ; `a > 0` ; aucune ligne de A ne porte de marqueur ; A ne voit aucun marqueur de B (RLS active sur les 25 tables) ; chaque marqueur de B est présent dans la base ; marqueurs tous distincts ; aucun autre motif `MARQUEUR-`.
3. Aucun défaut de l'app relevé : pas de fuite de B vers A sous la RLS.

## Choix faits seul

- **Toutes les tables avec une colonne vers `auth.users`** sont « à moi » (règle du point 5), y compris les tables techniques (sessions, push, analytics…). Colonne de filtre : `created_by` pour `households`, `invited_by` pour `household_invitations` (l'autre colonne, `accepted_by`, reste nulle), `id` pour `user_profiles`.
- **Données partagées écartées** : A et B ont chacun leur foyer, dont ils sont l'unique membre (admin). Les catégories, objectifs et transactions de foyer ne sont donc visibles que de leur auteur : aucun marqueur de B n'est légitimement visible par A. Pas de catégories `is_predefined`, pour que « mes catégories » = celles de `user_id`.
- **`user_profiles`** : le déclencheur `on_auth_user_created` crée déjà les profils à l'insertion des comptes ; la graine fait donc un `insert … on conflict (id) do update`. A = 1 profil.
- **Tables sans texte libre** (`category_budgets`, `comeback_challenges`, `household_members`, `personal_allowances`, `streaks`, `user_achievements`, `user_feature_state`, `value_categories`) : `marqueurs_b` est vide ; leur fuite ne se verrait que par le comptage. Les valeurs sont contraintes (énumérations, `check`, noms de clés).
- **Langue `en`** et noms au pluriel en anglais. Certains noms sont forcés (« household memberships », « value-category links », « feature states ») : l'app n'a pas de nom courant pour ces lignes ; ils sont peu probables comme questions naturelles, mais le comptage reste exact.
- Comptes de A tous distincts quand c'est possible, pour repérer une table confondue avec une autre.
- Le générateur (`gen.mjs`, hors livraison) tire les marqueurs au hasard ; les fichiers livrés sont ceux de la dernière génération, éprouvés tels quels.
- La base `graine_flow_finance_8af783`, présente sur le serveur, n'est pas de moi : je n'y ai pas touché.

Graines des apps tirées livrées
