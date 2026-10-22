# Rapport : graines des apps tirées

## Ce qui est livré

Une seule app dans `apps/TIREES.tsv` : `flow_finance` (Next.js, commit `642880178c93a8206834b1a1b5ca1de9bcd9c7a0`).
Fichiers : `graines/flow_finance/graine.sql` et `graines/flow_finance/attendu.json`.

Les 32 migrations de l'app passent, dans l'ordre, sur le minimum de Supabase (aucune sortie d'erreur ; seulement trois
NOTICE « déjà existant / inexistant, ignoré »). 18 tables « à moi » (toutes à `user_id`, sauf `profiles` à `id`).
La table `transactions` n'en est pas une : pas de colonne propriétaire, la politique passe par `accounts`.

| App | Table « à moi » | Colonne | Nom | A | Marqueurs de B |
|---|---|---|---|---|---|
| flow_finance | `public.spaces` | `user_id` | espaces | 2 | 3 |
| flow_finance | `public.bank_connections` | `user_id` | connexions bancaires | 2 | 6 |
| flow_finance | `public.accounts` | `user_id` | comptes bancaires | 3 | 6 |
| flow_finance | `public.categories` | `user_id` | catégories | 6 | 8 |
| flow_finance | `public.recurring_payments` | `user_id` | paiements récurrents | 5 | 6 |
| flow_finance | `public.recurring_suggestion_dismissals` | `user_id` | suggestions de paiements récurrents écartées | 4 | 6 |
| flow_finance | `public.savings_accounts` | `user_id` | livrets d'épargne | 3 | 5 |
| flow_finance | `public.savings_adjustments` | `user_id` | ajustements d'épargne | 5 | 6 |
| flow_finance | `public.savings_goals` | `user_id` | objectifs d'épargne | 2 | 8 |
| flow_finance | `public.savings_goal_allocations` | `user_id` | affectations aux objectifs d'épargne | 3 | 0 |
| flow_finance | `public.pea_holdings` | `user_id` | titres du PEA | 4 | 4 |
| flow_finance | `public.pea_investment_plans` | `user_id` | plans d'investissement du PEA | 2 | 6 |
| flow_finance | `public.pea_transactions` | `user_id` | opérations du PEA | 7 | 10 |
| flow_finance | `public.pea_settings` | `user_id` | réglages du PEA | 1 | 0 |
| flow_finance | `public.crypto_holdings` | `user_id` | cryptomonnaies | 3 | 3 |
| flow_finance | `public.crypto_transactions` | `user_id` | transactions crypto | 6 | 4 |
| flow_finance | `public.crypto_portfolio_settings` | `user_id` | réglages du portefeuille crypto | 1 | 0 |
| flow_finance | `public.profiles` | `id` | profils | 1 | 3 |

84 marqueurs listés dans `attendu.json`, plus 8 dans les transactions bancaires de B (table hors `attendu.json`) : 92
marqueurs distincts dans la base, tous reconnus par le motif `MARQUEUR-B-<8 hex>`.

## Empreintes SHA-256

```
24b748d95326d3f6bf0697a0ef6f9684ca3e2158559d791aac93c1c83c12c219  graines/flow_finance/graine.sql
b18f9ae5e1bacc469eeb620e433a7bfa6591265c9a73f7b63181be64c69e75e7  graines/flow_finance/attendu.json
```

## Épreuves

- `node graines/eprouver.mjs flow_finance` (outil non modifié : le nom `flow_finance` n'a pas de tiret, les migrations sont
  dans `supabase/migrations`). Résultat : 177 vérifications `ok`, 0 `ÉCHEC`, aucune `note`, « tout est conforme », code 0.
  Il crée une base neuve, applique le minimum, les migrations, deux comptes, la graine, vérifie `a` sous le rôle
  `authenticated` avec `request.jwt.claims`, qu'aucune ligne de A ne porte de marqueur et que A ne voit aucun marqueur de B
  (RLS active sur les 18 tables), puis supprime la base.
- Contrôle à la main sur une base neuve (supprimée ensuite) : la graine s'applique avec `ON_ERROR_STOP` ; A voit ses 8
  transactions bancaires, dont 0 marquée (les 3 de B sont invisibles sous la RLS).
- Aucun défaut de l'app relevé : la RLS isole A de B sur toutes les tables.

## Choix faits seul

- **Tables à moi.** Les 18 tables à colonne propriétaire. `transactions` est exclue (pas de colonne ; ses lignes sont
  tout de même semées, avec marqueurs pour B). `profiles` y est, avec `id` comme colonne.
- **Profils.** Le déclencheur `on_auth_user_created` crée déjà un profil par compte ; la graine fait `on conflict do nothing`
  puis ne donne de réglages marqués (JSON) qu'à B. A garde les réglages par défaut.
- **Tables sans texte libre** (`savings_goal_allocations`, `pea_settings`, `crypto_portfolio_settings`) : `marqueurs_b` est
  vide, faute de colonne où en mettre. B y a d'autres valeurs (ex. solde espèces 4242,42).
- **Tables à une ligne par compte** (`profiles`, `pea_settings`, `crypto_portfolio_settings`) : A = 1, gardées malgré le
  risque qu'une question « combien de mes profils ? » paraisse étrange.
- **Noms.** Choisis pour ne pas se confondre : « transactions crypto », « opérations du PEA », « ajustements d'épargne »,
  « livrets d'épargne », « comptes bancaires ». Tous les comptes de A sont de type `checking`, pour qu'un « compte
  d'épargne » ne se lise pas comme une ligne de `accounts`.
- **Ambiguïtés levées.** Aucun paiement récurrent fusionné (`merged_into_id`) ou terminé (`active_to`) chez A ; aucune donnée
  n'est partagée entre A et B (les « espaces » ne portent aucun droit d'accès).
- **Nombres de A** : variés d'une table à l'autre quand c'était possible, pour repérer une question mal aiguillée.
- **Marqueurs** tirés au hasard, une fois ; ils sont écrits dans la graine. Le générateur n'est pas livré.
- Le nom des « suggestions écartées » est long ; je l'ai gardé pour qu'il ne se confonde pas avec « paiements récurrents ».

Graines des apps tirées livrées
