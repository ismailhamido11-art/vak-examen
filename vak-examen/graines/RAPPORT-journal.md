# Rapport : graines des apps tirées (quatrième examen)

## Livré

`apps/TIREES.tsv` ne contient qu'**une** app : `journal` (Next.js, « Rédaction de quartier », commit
`af3d891a02374dbc938f61018bbd6f690573d729`). Les consignes parlent de 3 apps construites ; seule celle-ci est présente
dans `apps/`, et je n'ai rien inventé pour les deux autres. Livré : `graines/journal/graine.sql` et
`graines/journal/attendu.json`.

| app | table « à moi » | colonne | nom | compte de A | marqueurs de B |
|---|---|---|---|---|---|
| journal | public.profiles | id | profils | 1 | 1 |
| journal | public.newspapers | created_by | journaux | 2 | 4 |
| journal | public.newspaper_members | user_id | adhésions à un journal | 2 | 0 |
| journal | public.newspaper_invitations | invited_by | invitations envoyées | 3 | 2 |
| journal | public.articles | created_by | articles | 7 | 8 |
| journal | public.article_photos | added_by | photos | 5 | 6 |

Total : 21 marqueurs de B, tous distincts, tous présents dans la base.

## Empreintes SHA-256

```
409a0ced225e65161dea185e8593a8ae7ce643719f22820fe045ffdcb8eb55bc  graines/journal/graine.sql
566f1a5379f6056d203b795b30666baf203b3eca79aa7c61488f8b440c5b62aa  graines/journal/attendu.json
```

## Épreuve

Commande : `node graines/eprouver.mjs journal` (outil inchangé : les migrations sont dans `supabase/migrations`, le nom
d'app n'a pas de tiret). Base neuve `graine_journal_<hex>`, minimum de Supabase, 5 migrations dans l'ordre (toutes
passées sans erreur), deux comptes, graine, vérifications en tant que A (rôle `authenticated`, `request.jwt.claims`),
base supprimée (aucune base `graine_%` ne reste).

Résultat : « tout est conforme », 0 échec. Pour chaque table : compte de A égal à `a` ; aucune ligne de A ne porte de
marqueur ; A ne voit aucun marqueur de B sous la RLS de l'app (RLS active sur les 6 tables) ; marqueurs présents ;
aucun autre motif `MARQUEUR-` dans la base. Aucun défaut de l'app relevé.

## Choix faits seul

- **Toutes les tables avec une colonne d'utilisateur sont « à moi »** (clé vers `auth.users` ou défaut `auth.uid()`) :
  les six ci-dessus, y compris `profiles` et `newspaper_members`.
- **Aucun journal, aucun membre en commun entre A et B.** A est le seul membre de ses 2 journaux, dont il est
  propriétaire : la RLS n'a rien de partagé à montrer, donc tout marqueur de B vu par A serait une vraie fuite.
- **Ambiguïtés levées par la graine** : `articles` a deux colonnes d'utilisateur (`created_by`, `assignee_id`) : tous les
  articles de A sont créés par A et confiés à A, donc « mes articles » vaut 7 dans les deux sens (filtre : `created_by`).
  Idem pour les photos (toutes ajoutées par A). « Mes journaux » (créés par A ou dont A est membre) vaut 2 dans les deux
  sens. Les invitations de A sont toutes **envoyées** par A, aucune n'est adressée à l'e-mail de A ; le nom
  « invitations envoyées » lève l'autre lecture (invitations reçues).
- **`newspaper_members`** : son nom est « adhésions à un journal » (« rôles » ou « journaux » prêtaient à confusion) ; elle
  n'a aucun texte libre, donc `marqueurs_b` y est vide. Son compte (2) égale celui des journaux, faute de pouvoir les
  distinguer sans donner à A un journal que A ne voit pas ou un journal partagé avec B.
- **`profiles`** : A en a 1 (la RLS ne montre que son profil ou ceux d'un journal partagé). Les profils sont créés par le
  déclencheur à l'insertion des comptes ; la graine ne fait que les nommer (`on conflict do update`). Le marqueur de B
  est dans son `display_name`. L'e-mail du profil de B ne porte pas de marqueur (compte créé par la pile).
- **Invitations de B** : le marqueur est dans la partie locale de l'e-mail (en minuscules, la contrainte l'exige ; la
  recherche du juge ignore la casse).
- Les marqueurs ont été tirés au hasard (`openssl rand -hex 4`, majuscules).

Graines des apps tirées livrées
