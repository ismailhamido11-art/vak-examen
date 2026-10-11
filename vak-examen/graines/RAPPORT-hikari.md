# Rapport : graines des apps tirées

## Livré

`apps/TIREES.tsv` ne contient qu'une app : `hikari` (https://github.com/antoineross/Hikari, commit c1f16f54…).

| app | table « à moi » | colonne | nom | compte de A | marqueurs de B |
|---|---|---|---|---|---|
| hikari | public.users | id | profiles | 1 | 3 |
| hikari | public.posts | user_id | posts | 4 | 6 |
| hikari | public.subscriptions | user_id | subscriptions | 3 | 4 |

Langue : `en` (l'interface est en anglais : `<html lang="en">`). Total : 13 marqueurs de B, tous distincts.

## Empreintes SHA-256

```
922c1220452f25d9491de08f4d0370c94c7050b8d599178a024941f4d59a9617  graines/hikari/graine.sql
565f46e39c007f3843221ebe9679dc70a148d6441220b693c253d7545ddb42d4  graines/hikari/attendu.json
```

## Épreuve

Commande : `node graines/eprouver.mjs hikari` (outil utilisé tel quel, sans adaptation : les migrations sont dans
`supabase/migrations`, le nom `hikari` n'a pas de tiret). Les 2 migrations (`20230530034630_init.sql`,
`20240918141953_posts.sql`) passent sur le minimum de Supabase. Seule sortie hors vérifications : l'avertissement
`wal_level is insufficient to publish logical changes` (création de la publication `supabase_realtime`), sans effet.

Résultat : toutes les vérifications `ok`, « tout est conforme », code 0 :
- comptes de A sous RLS (rôle `authenticated`, `request.jwt.claims` posé) : users 1, posts 4, subscriptions 3, égaux à `attendu.json` ;
- aucune ligne de A ne porte de marqueur ; A ne voit aucun marqueur de B sous la RLS de l'app (RLS active sur les trois tables) ;
- les 13 marqueurs sont présents dans la base, distincts, de forme `MARQUEUR-B-XXXXXXXX` ; aucun autre motif `MARQUEUR-` ;
- la base d'épreuve est supprimée (aucune base `graine_%` ne reste).

## Choix faits seul

- **`public.customers` n'est pas dans `attendu.json`.** Sa colonne `id` référence `auth.users`, donc au sens de la règle c'est une table
  « à moi » ; mais la RLS est active sans aucune politique (table privée voulue par l'app) : A y compte 0 ligne sous RLS, et
  elle n'est pas lisible par l'utilisateur. Un `a` de 0 est contraire à « des nombres connus » (`eprouver.mjs` exige `a > 0`), et B n'y a pas de texte libre
  à marquer sans risque. Elle n'est pas semée. Écart à connaître : si le juge ou l'examen compte `customers` parmi les tables « à moi »
  de l'app, la couverture se lit sur 3 tables de `attendu.json`, pas 4.
- **`public.users` est incluse** (clé `id` vers `auth.users`, politique `auth.uid() = id`), sous le nom « profiles » : une ligne par compte. Le
  déclencheur `on_auth_user_created` crée déjà ces lignes à l'insertion des comptes ; la graine les complète par `update`
  (nom, avatar, adresse de facturation en JSON). Le marqueur de B est dans `full_name`, `avatar_url` et `billing_address`.
- **Noms** : « posts » et « subscriptions » (mots de l'interface en anglais), « profiles » pour `users`.
- **Abonnements** : A en a 3 (active, canceled, trialing), tous comptés, sans dépendre du statut ; B 2, avec le marqueur dans l'id et `metadata`.
  `products` et `prices` (publics, lisibles par tous, sans marqueur) sont semés avec deux lignes neutres pour satisfaire les clés étrangères.
- **Posts** : A en a 4 et B 3, sous la limite de 5 que la politique d'insertion impose (la graine passe en super-utilisateur, mais reste dans les valeurs que l'app accepte).
- **Marqueurs** : uniquement dans les colonnes de texte de B (titres, contenus, noms, notes, ids d'abonnement) ; A n'en a aucun.
- Une base `graine_%` figurait peut-être dans le cluster lors d'un contrôle intermédiaire (compte à 1), puis plus aucune au contrôle suivant ; la mienne était déjà supprimée par l'outil, je n'y ai pas touché.
