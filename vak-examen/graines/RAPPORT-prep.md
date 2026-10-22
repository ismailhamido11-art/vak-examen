# Rapport : graines des apps tirées

`apps/TIREES.tsv` ne contient qu'une app : **prep** (Truella/prep, commit 341c8dc5…). Une graine livrée.

## Livré

| app | table « à moi » | colonne | nom | compte de A | marqueurs de B |
|---|---|---|---|---|---|
| prep | public.quizzes | created_by | quizzes | 6 | 35 (titres, descriptions, textes des questions) |
| prep | public.quiz_ratings | user_id | quiz ratings | 4 | 0 (aucun texte libre dans la table) |

Les autres tables (`questions`, `quiz_attempts`) n'ont pas de colonne désignant l'utilisateur : elles ne sont pas « à moi ».

## Empreintes SHA-256

```
c49fe97095335480814bb2e80ac757c7cc37dc095b380e547badb1f7b7ac35ff  prep/graine.sql
ca89bb7000ce075e76a33840204885484391fc44ed0dc03a3d82a72f78d88e28  prep/attendu.json
```

## Épreuve

`node graines/eprouver.mjs prep`, sans adaptation (migrations dans `supabase/migrations`, nom sans tiret). Les 8 migrations
passent sur le minimum de Supabase (seule sortie : une NOTICE « function … does not exist, skipping » du `drop function if exists`).
Résultat : tous les contrôles « ok », « tout est conforme » : A a 6 quizzes et 4 notes sous RLS ; aucune ligne de A ne porte de
marqueur ; A ne voit aucun marqueur de B ; les 35 marqueurs sont dans la base, distincts, sans autre motif `MARQUEUR-`. La base
d'épreuve est supprimée (aucune base `graine_*` ne reste).

## Choix faits seul

- **Langue `en`** : l'interface de prep est en anglais. Noms : « quizzes » et « quiz ratings ».
- **Lecture publique de la RLS** : la politique d'`quizzes` montre à tous les quiz publiés. Les 5 quiz de B sont donc en
  **brouillon** (`status = 'draft'`) : A ne les voit pas, et ses marqueurs ne sont jamais légitimement visibles. Leurs questions
  suivent (lisibles seulement si le quiz est publié ou à soi). Vérifié : A ne voit aucun marqueur.
- **Quizzes de A** : tous publiés avec un code (4 publics, 2 privés), pour qu'« mes quizzes » ne se lise pas « mes quiz publiés ».
  Ils comptent 6, les notes 4 : deux nombres distincts.
- **« Mes notes »** : ambiguïté entre notes données et notes reçues. Levée : A ne note que ses propres quiz, B ne note jamais les
  quiz de A ; donné = reçu = 4. B note ses propres quiz publics (sans texte libre, d'où 0 marqueur dans `quiz_ratings`).
- Aucun défaut de l'app trouvé : la RLS est active sur les deux tables et ne laisse rien fuir de B. Réserve : la politique
  `quiz_attempts` (insertion par tout utilisateur connecté) n'est pas concernée par le point 5 et n'a pas de graine.
- Pas de ligne `quiz_attempts` : la table n'est pas « à moi ».

Graines des apps tirées livrées
