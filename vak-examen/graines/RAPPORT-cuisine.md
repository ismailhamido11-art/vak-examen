# Rapport : graines des apps construites (troisième examen)

## Livré

`apps/TIREES.tsv` ne contient qu'une app (`cuisine`), et `apps/` ne contient que celle-là, alors que la consigne en annonce 3.
Je n'ai donc livré qu'une graine. Je n'ai rien inventé pour les deux autres : leur code et leurs migrations ne sont pas ici.

| app | table « à moi » | colonne | nom | compte de A | marqueurs de B |
|---|---|---|---|---|---|
| cuisine | public.recipes | user_id | recettes | 7 | 8 |
| cuisine | public.cookings | user_id | cuissons | 12 | 6 |

## Empreintes SHA-256

```
124eb97e58667e3aab034f38e08303e07c7ac8a2c8c22848aa0f046851e44b7e  graines/cuisine/graine.sql
50cc7b8979ec2fedc470402895441403a5df4a2005642ff1006ceb8bd935f477  graines/cuisine/attendu.json
```

## Épreuves

`node graines/eprouver.mjs cuisine` (outil inchangé : la migration est dans `supabase/migrations`, le nom d'app n'a pas de tiret).
La migration `20261010120000_carnet_initial.sql` passe sur le minimum de Supabase, sans erreur.
Résultat : « tout est conforme ».
- 7 recettes et 12 cuissons de A sous RLS, en tant que A (`authenticated`, `request.jwt.claims` posé) : égal à `attendu.json`.
- Aucune ligne de A ne porte de marqueur.
- A ne voit aucun marqueur de B : la RLS est active sur les deux tables, sans défaut de l'app.
- Les 14 marqueurs de B sont présents dans la base, distincts, et il n'y a aucun autre motif `MARQUEUR-`.
- La base d'épreuve a été supprimée (vérifié : aucune base `graine_%` ne reste).

## Choix faits seul

- **Nom de `cookings`** : « cuissons » (l'interface dit « J'ai cuisiné cette recette », sans nom courant).
  « Mes recettes cuisinées » aurait prêté à confusion avec `recipes`.
  Les comptes sont différents (7 recettes, 12 cuissons) pour que la confusion se voie.
- **Langue** : `fr` (interface en français).
- **Marqueurs** : dans chaque texte libre de B : `title` et `keywords` des recettes, `comment` des cuissons.
- **Cohérence** : le déclencheur `cookings_check_owner` impose qu'une cuisson désigne une recette du même propriétaire.
  La graine insère donc les cuissons de chaque compte sur ses propres recettes.
- **Variété** : les 4 catégories, des favorites, des recettes cuisinées plusieurs fois ; chaque recette de A est cuisinée au moins une fois.

Graines des apps tirées livrées
