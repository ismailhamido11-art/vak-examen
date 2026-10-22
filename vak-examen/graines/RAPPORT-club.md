# Rapport : graines des apps tirées (troisième examen)

`apps/TIREES.tsv` ne contient qu'une app : `club` (commit 1b05281d…, Next.js + Supabase, une seule migration
`20261010100000_schema.sql`). Les deux autres apps annoncées par la règle ne sont pas dans ce dossier : je n'ai rien
inventé pour elles.

## Livré

| app | table « à moi » | colonne | nom | A | marqueurs de B |
|---|---|---|---|---|---|
| club | public.clubs | created_by | clubs | 3 | 4 |
| club | public.club_members | user_id | adhésions | 3 | 2 |
| club | public.club_invitations | invited_by | invitations envoyées | 2 | 2 |
| club | public.trainings | coach_id | entraînements | 6 | 6 |
| club | public.attendances | noted_by | présences notées | 10 | 4 |

Total : 18 marqueurs de B, tous distincts.

## Empreintes SHA-256

```
fa269ce132dbf1294156d5cb49a8ce6510cd722754b983cc0c545b6bdd17b271  graines/club/graine.sql
3b5da227d08dfb62a85531d552cac63a7f0e957adaeeead37a924854ebe6e85c  graines/club/attendu.json
```

## Épreuve

Commande : `node graines/eprouver.mjs club` (outil inchangé : la migration de l'app est dans `supabase/migrations` et le
nom d'app ne demande aucune adaptation). Résultat : toutes les vérifications `ok`, « tout est conforme », code 0 :
- la migration passe sur le minimum de Supabase ;
- comptes de A sous RLS (rôle `authenticated`, `request.jwt.claims` posé) : 3, 3, 2, 6, 10, égaux à `attendu.json` ;
- aucune ligne de A ne porte de marqueur ;
- A ne voit aucun marqueur de B sous la RLS de l'app (RLS active sur les cinq tables) ;
- les 18 marqueurs sont dans la base ; aucun autre motif `MARQUEUR-`.
La base d'épreuve est supprimée (aucune base `graine_%` ne reste).

## Choix faits seul

- **Toutes les colonnes « à moi » sont couvertes** (cinq tables) : `clubs.created_by`, `club_members.user_id`,
  `club_invitations.invited_by`, `trainings.coach_id`, `attendances.noted_by`. `trainings.created_by` désigne aussi
  l'utilisateur ; j'ai retenu `coach_id`, le filtre de la page « mes-entrainements », et mis A à la fois créateur et
  encadrant de tous ses entraînements, de sorte que les deux colonnes donnent 6.
- **Ambiguïtés levées par la graine** : A est le seul membre (propriétaire) de ses 3 clubs et n'appartient à aucun club de
  B (aucune donnée partagée, donc aucun marqueur visible légitimement) ; « mes clubs » = « mes adhésions » = 3, sans
  rôle différent. Toutes les présences de A sont `present = true`, pour que « présences » ne se lise pas « présents
  seulement ». Le nom `présences notées` (et non `présences`) dit que la ligne est liée à qui l'a notée, pas au
  participant ; `invitations envoyées` de même.
- **Marqueurs de B** dans chaque texte libre : nom et sport des clubs, titre et lieu des entraînements, nom des
  participants, e-mail des invitations et des adhésions. Ces e-mails respectent la contrainte de la base (minuscules,
  `@`) : le marqueur y est en minuscules, le juge ignorant la casse. L'e-mail d'adhésion de B (rempli par le
  déclencheur à partir de `auth.users`) est remplacé par un e-mail à marqueur par `update`, accepté par le déclencheur.
- Les adhésions de A sont créées par le déclencheur `clubs_add_owner` (insertion des clubs avec `created_by` explicite,
  la graine tournant sans session).
- Les invitations de A visent des adresses sans compte (elles resteraient sinon converties en adhésions par la fonction).

Graines des apps tirées livrées
