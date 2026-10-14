# Rapport : graines des apps tirées (deuxième examen)

## Ce qui est livré

La consigne parle de 3 apps, mais `apps/TIREES.tsv` n'en liste qu'**une** (`agence`, `vak-examen/apps/agence.bundle`, commit
`fed608276a1fd66abfd4e6f24b84d08e8f5a9876`) et `apps/` ne contient que celle-là. Je n'ai rien inventé pour les deux autres.

Livré : `graines/agence/graine.sql` et `graines/agence/attendu.json`. Les deux migrations de l'app passent telles quelles sur
`supabase-minimum.sql`, sans adaptation de `eprouver.mjs`.

| app | table « à moi » | colonne | nom | compte de A | marqueurs de B |
|---|---|---|---|---|---|
| agence | public.agencies | created_by | agences | 3 | 2 |
| agence | public.agency_members | user_id | adhésions à une agence | 3 | 0 |
| agence | public.trips | created_by | dossiers de voyage | 6 | 8 |
| agence | public.bookings | created_by | réservations | 9 | 5 |
| agence | public.agency_invitations | invited_by | invitations en attente | 4 | 3 |

## Empreintes SHA-256

```
a09c042af8d904f2dc5f0e04d5311128e1f33bb20435ea5a29cee917b819c4b6  graines/agence/graine.sql
c98fa64d0476fb39dc379a420cfa50f6f2ea60506d80644c79d8ee83b86cf286  graines/agence/attendu.json
```

## Épreuve

Commande : `node graines/eprouver.mjs agence` (base neuve, minimum de Supabase, 2 migrations, deux comptes, graine, comptes
de A sous le rôle `authenticated` avec `request.jwt.claims`, base supprimée ensuite ; vérifié : aucune base `graine_agence%` ne reste).

Résultat : « tout est conforme », 0 échec. Compte de A égal à `a` pour les 5 tables ; aucune ligne de A ne porte de marqueur ;
A ne voit aucun marqueur de B (RLS active sur les 5 tables) ; 18 marqueurs distincts, tous présents, aucun autre motif `MARQUEUR-`.
Aucun défaut de RLS à signaler.

## Choix faits seul

- **Toutes les colonnes d'utilisateur sont des tables « à moi »** (règle, point 5) : `created_by` (agencies, trips, bookings),
  `user_id` (agency_members), `invited_by` (agency_invitations). `bookings.assigned_to` est aussi une colonne d'utilisateur ; j'ai
  retenu `created_by` comme filtre, et rendu les deux lectures identiques (voir plus bas).
- **Levée des ambiguïtés** : A est le seul membre, et propriétaire, de ses 3 agences, qui n'ont pas d'autre membre : « mes agences »
  = créées = rejointes. Toutes les réservations de A sont créées par A **et** confiées à A (pas de réservation de A confiée à
  quelqu'un d'autre, ni l'inverse), donc « mes réservations » a un seul compte. Les agences de B sont distinctes : A n'en est pas
  membre, donc aucune donnée de B n'est légitimement visible par A.
- **`agency_members` n'a aucun texte libre** (seul `role`, contraint à 3 valeurs) : aucun marqueur n'y est possible, `marqueurs_b`
  est vide. B y a 2 lignes, sans marqueur ; la fuite éventuelle de B se verrait dans les autres tables. Le nom « adhésions à une
  agence » est un choix : l'app n'a pas de mot courant pour cette table. Son compte (3) égale celui des agences, par construction.
- **Marqueurs de B** : dans les noms d'agence, `client` et `destination` des dossiers (deux marqueurs par dossier), `supplier` des
  réservations, et e-mails des invitations (écrits en minuscules, car `agency_invitations.email` doit être en minuscules ; le juge
  ignore la casse, `attendu.json` les donne en majuscules).
- **Insertions directes** en super-utilisateur, sans passer par `create_agency()` (qui exige `auth.uid()`), avec des uuid fixes de
  graine pour agences et dossiers. Contraintes respectées : dates cohérentes, budgets/prix ≥ 0, responsables membres de l'agence
  (le déclencheur `bookings_guard` passe), e-mails d'invitation de A sans lien avec des comptes existants.
- `a` n'est pas redondant avec les agences seulement par accident : 3 (agences et adhésions), 6, 9, 4 sont distincts entre
  tables différentes de nature, ce qui évite qu'un assistant se trompe de table sans que le nombre le révèle.

Graines des apps tirées livrées
