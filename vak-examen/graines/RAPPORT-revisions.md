# Rapport : graines des apps tirées (cinquième examen)

## Livré

`apps/TIREES.tsv` ne contient qu'une app (`revisions`, commit `fd44d3346a948512168a8c16e4496fee43bf1ce3`), alors que la
consigne parle de 3 apps. Je n'ai donc livré qu'une graine, sans rien inventer pour les deux autres.
Les migrations passent sans erreur sur le minimum de Supabase.

| App | Table « à moi » | Colonne | Nom | Compte de A | Marqueurs de B |
|---|---|---|---|---|---|
| revisions | public.decks | owner_id | paquets | 3 | 3 |
| revisions | public.cards | owner_id | cartes | 9 | 10 |
| revisions | public.reviews | owner_id | révisions | 12 | 4 |

## Empreintes SHA-256

- `graines/revisions/graine.sql` : `3ca0832b5cabdeb46667d6e45d74642e7951f2b58525405539d931cc61c1ce32`
- `graines/revisions/attendu.json` : `89deeff9f9121b018db70eaec41f6e19e3564c2d43e3de65c22648810cae99cb`
- `graines/eprouver.mjs` (non modifié) : `c6c0e03637c6d062af1c251b022787ee9407ff05cec1d07983eec2e48d9bf1d4`

## Épreuve

Commande : `node graines/eprouver.mjs revisions`. Elle crée une base neuve, applique le minimum de Supabase, les 2
migrations dans l'ordre et deux comptes, puis la graine. Elle compte les lignes de A en rôle `authenticated` avec
`request.jwt.claims`, et supprime la base.
Résultat : « tout est conforme ».
- Comptes de A : 3, 9 et 12, conformes à `attendu.json`.
- Aucune ligne de A ne porte de marqueur.
- Les 17 marqueurs de B sont présents, distincts, et aucun autre motif `MARQUEUR-` n'existe.
- La RLS est active sur les 3 tables : A ne voit aucun marqueur de B.
- Aucune base `graine_*` ne reste.

Un premier passage avait échoué (11 révisions au lieu de 12) à cause d'une faute de frappe de ma part dans la graine
(« toget along with »). Je l'ai corrigée avant la version livrée.

## Choix faits seul

- Les 3 tables de l'app ont une colonne `owner_id` (clé vers `auth.users`) : toutes sont « à moi ».
- Langue `fr` : l'interface est en français. Les noms sont « paquets », « cartes » et « révisions », comme dans l'app.
- Les trois comptes de A sont distincts (3, 9, 12), pour qu'une confusion entre tables se voie.
- Les révisions passent par le déclencheur de l'app : `decks.reviews_count` reste cohérent avec le nombre de révisions
  (il n'y a pas d'ambiguïté sur « mes révisions »).
- Les marqueurs de B sont dans `decks.name`, `cards.front`, `cards.back` et `reviews.note`. La graine insère en
  super-utilisateur ; les clés étrangères, les contraintes (`interval_days`, `unique(deck_id, front)`) et le
  déclencheur sont respectés.
- Aucune donnée partagée : tout est filtré par `owner_id`.

Graines des apps tirées livrées
