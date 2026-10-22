# Rapport : graines des apps tirées

## Ce qui est livré

`apps/TIREES.tsv` ne contient qu'une app : `split_free_frontend` (SplitFree, dépenses partagées, commit `74b66125…`).
Une graine, donc : `graines/split_free_frontend/graine.sql` et `graines/split_free_frontend/attendu.json`.
J'ai aussi écrit `graines/eprouver-tirees.mjs`, copie adaptée de `eprouver.mjs` (l'original est intact).

| App | Table « à moi » | Colonne | Nom (langue `en`) | Compte de A | Marqueurs de B |
|---|---|---|---|---|---|
| split_free_frontend | public.groups | owner | groups | 4 | 4 (titre et description de 2 groupes) |
| split_free_frontend | public.members | profile | group memberships | 4 | 2 (nom des membres) |
| split_free_frontend | public.friends | profile | friends | 3 | 0 |
| split_free_frontend | public.friend_requests | sender | friend requests | 2 | 0 |
| split_free_frontend | public.group_invitations | sender | group invitations | 5 | 2 (`group_name`) |

Total : 8 marqueurs de B, tous distincts. Les tables `friends` et `friend_requests` n'ont aucun texte libre, donc aucun
marqueur n'y tient : une fuite de B y serait invisible pour le juge (il ne verrait que des UUID).

## Empreintes SHA-256

```
6599e97d924f6288a6b6c3070dd5db8b20a996d782825010b9980367382b8688  graines/split_free_frontend/attendu.json
94573b499bf377e65bb8a96b966a00ecde3b80c664f05e481af8a04c25b57959  graines/split_free_frontend/graine.sql
24d109e1442d23e7e9530325d92429eeace3fb569b0ea5f2ba6a05b26d3f8759  graines/eprouver-tirees.mjs
```

## Épreuves

**Les migrations ne passent pas telles quelles sur le minimum.** Avec `ON_ERROR_STOP=1`, la première migration
(`20250803101439_remote_schema.sql`) s'arrête sur :

```
ERROR:  extension "pg_net" is not available
DETAIL:  Could not open extension control file "/usr/share/postgresql/16/extension/pg_net.control": No such file or directory.
```

et toutes les suivantes échouent en cascade (`relation "public.profiles" does not exist`, `schema "trigger_functions" does not exist`…).
Sans arrêt sur erreur, les seules erreurs sont 6 extensions absentes de ce PostgreSQL 16 (`pg_net`, `pgsodium`, `pg_graphql`,
`pgjwt`, `supabase_vault`, `vector`) et 4 `publication "supabase_realtime" does not exist` (lignes 1860-1875). Aucun objet de l'app
n'utilise ces extensions (vérifié par recherche dans les migrations). Les 11 autres migrations passent sans erreur, les 13 tables
de `public` et leurs politiques existent. `eprouver-tirees.mjs` tolère exactement ces deux sortes d'erreurs et échoue sur toute autre.

Commande : `node graines/eprouver-tirees.mjs split_free_frontend` (base neuve, supprimée ensuite). Résultat : « tout est conforme » :
12 migrations ok (10 erreurs tolérées, 0 autre) ; pour chacune des 5 tables, le compte de A sous RLS (rôle `authenticated`,
`request.jwt.claims` posé) égale `a` (4, 4, 3, 2, 5) ; aucune ligne de A ne porte de marqueur ; A ne voit aucun marqueur de B
(RLS active sur les 5 tables) ; les 8 marqueurs sont présents dans la base, distincts, et il n'y a aucun autre motif `MARQUEUR-`.

Épreuve en plus, sur une autre base neuve : sous RLS, le nombre de lignes que A *voit* (sans filtre) est 4, 4, 3, 2, 5, soit
exactement `a` : aucune lecture alternative (« visible » au lieu de « possédé ») ne donne un autre nombre.

## Choix faits seul

- **Extensions absentes** : je n'ai pas modifié `supabase-minimum.sql` ; j'ai toléré les erreurs ci-dessus dans ma copie de l'épreuve.
  Je ne sais pas comment la vraie pile traite ces extensions : si ses migrations s'arrêtent à la première erreur, la graine ne s'applique pas et le point 5 serait faux pour une raison d'état commité (règle) ou de pile, à trancher par l'organisateur.
- **Tables « à moi » retenues** : `groups` (owner), `members` (profile), `friends` (profile), `friend_requests` (sender), `group_invitations` (sender) :
  colonnes qui sont des clés vers `profiles` (lui-même clé vers `auth.users`) et comparées à `auth.uid()` par les politiques.
- **`profiles` écartée** : elle est « à moi » (`id` vers `auth.users`) mais sa politique `users can view all profiles` (`using true`) la rend lisible par
  tous : un marqueur de B y serait légitimement visible par A, et « mes profils » est ambigu. Elle n'est donc pas dans `attendu.json`, et aucun marqueur n'est mis dans les profils.
  Conséquence : si l'assistant de l'app ne lisait que `profiles`, le juge dirait « aucune table lue » alors qu'elle serait lue.
- **Tables liées au groupe écartées** (`expenses`, `expense_payers`, `expense_participants`, `debts`, `debts_per_expense`, `transfers`, `invite_tokens`) :
  aucune colonne ne désigne l'utilisateur, les politiques passent par `utils.is_member_of(auth.uid(), group_id)` ou une sous-requête sur `members`,
  pas par une colonne comparée à `auth.uid()`. Je n'y ai mis aucune ligne (pas de dépenses ni de dettes inventées).
- **Ambiguïtés levées par la graine** : A est le seul membre de ses 4 groupes (un membre par groupe, lié à A, aucun membre sans profil), n'est ni membre
  ni invité d'aucun groupe de B, et n'est jamais destinataire : toutes ses demandes d'ami et invitations sont envoyées, tous ses amis sont en colonne
  `profile`. « Mes groupes » = possédés = visibles ; « mes amis », « mes demandes » : mêmes nombres dans les deux sens. Les comptes de A
  sont tous différents sauf groupes et appartenances (4 et 4), égaux par construction (un groupe, un membre).
- **Noms** (langue `en`, langue par défaut de l'app et de `profiles.language`) : « group memberships » pour `members` ; les autres sont les mots de l'interface.
- **Cinq comptes d'amis** (`ami-1` à `ami-5@example.test`, UUID fixes) sont insérés dans `auth.users` par la graine, avec les seules colonnes `id` et `email`
  (comme l'épreuve le fait pour A et B) : les tables d'amis et d'invitations visent `profiles`, donc des comptes. Le déclencheur `on_auth_user_created`
  de l'app crée leurs profils ; un `insert … on conflict do nothing` en garde-fou crée ceux de A, B et des amis s'il manquait. Si la pile
  impose d'autres colonnes non nulles à `auth.users`, cet insert échouerait.
- **Données B** : 2 groupes, 2 appartenances, 2 amis (dont un ami commun avec A, sans marqueur), 2 demandes, 2 invitations ; les profils des amis
  ne portent aucun marqueur (lisibles par tous).

Graines des apps tirées livrées
