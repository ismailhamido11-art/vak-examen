# Rapport : graines des apps tirées (cinquième examen)

## Ce qui est livré

`apps/TIREES.tsv` ne contient **qu'une app** (`troupe`), pas trois comme l'annonce la consigne. Je n'ai pas inventé les deux
autres : seule `troupe` a une graine.

| app | table « à moi » | colonne | nom | compte de A | marqueurs de B |
|---|---|---|---|---|---|
| troupe | public.troupes | created_by | troupes | 3 | 4 |
| troupe | public.troupe_members | user_id | adhésions à une troupe | 3 | 0 |
| troupe | public.shows | created_by | spectacles | 5 | 6 |
| troupe | public.characters | titulaire_id | personnages | 9 | 5 |

## Empreintes SHA-256

```
dde42955873bdcf82c4020a1690b1ed2acf49cda0e8dc65ed4095023fad0f72c  graines/troupe/graine.sql
baa117cb516d33c9dbffa4ccdbe324cb3271e8f94346962e1a4a1b7c5e3efbb3  graines/troupe/attendu.json
```

## Épreuve

`node graines/eprouver.mjs troupe` (outil non modifié) : minimum de Supabase, les 4 migrations de l'app sans erreur, deux
comptes, graine, comptes de A sous RLS (rôle `authenticated`, `request.jwt.claims` posé). Résultat : **tout est conforme**,
0 échec. Les comptes de A sont 3, 3, 5 et 9 ; aucune ligne de A ne porte de marqueur ; A ne voit aucun marqueur de B sous la
RLS (RLS active sur les 4 tables) ; 15 marqueurs distincts, tous présents dans la base, aucun autre motif `MARQUEUR-`. La
base d'épreuve est supprimée (aucune base `graine_%` ne reste).

## Choix faits seul

- **Tables « à moi »** : les 4 tables ont une colonne vers `auth.users` (`created_by`, `user_id`, `titulaire_id`).
- **Personnages** : filtre `titulaire_id` (c'est le sens de « mes personnages » dans la fonction `mes_personnages()` de
  l'app), et non `created_by` ni `doublure_id`. Pour lever l'ambiguïté, A est à la fois créateur et titulaire de ses 9
  personnages, sans doublure, tous en `a_apprendre` ou `en_cours` (`mes_personnages()` ne renvoie que ces statuts) : toutes
  les lectures possibles de « mes personnages » donnent 9.
- **Troupes, spectacles** : A est créateur de tout et seul membre, propriétaire, de ses 3 troupes ; « mes troupes » (créées
  ou dont je suis membre) donne donc 3 dans les deux sens. Pour la même raison, les adhésions de A valent 3 aussi.
- **Aucune troupe partagée** entre A et B (un membre B dans une troupe de A, ou l'inverse, ferait voir des marqueurs de B à
  A). Je n'ai pas créé de troisième compte.
- **`troupe_members`** n'a aucun texte libre (`role` est une énumération) : `marqueurs_b` y est vide. Le nom « adhésions à
  une troupe » est le seul qui rende la table lisible en français (« mes membres » serait faux).
- Les lignes sont insérées directement (pas par `create_troupe`, qui exige `auth.uid()`), avec `created_by` explicite ; les
  déclencheurs de l'app passent (titulaires propriétaires de la troupe).
- Langue `fr` : les textes de l'interface sont en français. Les marqueurs sont tirés au hasard (`openssl rand -hex 4`).
- Chez B, un personnage est au statut `su` : sans effet sur A.

Graines des apps tirées livrées
