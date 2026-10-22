# Rapport : graines des apps tirées

## Ce qui est livré

`apps/TIREES.tsv` ne contient qu'une app : `budget_web_app` (Next.js + Supabase, commit `88061f2c…`). Livré :
`graines/budget_web_app/graine.sql` et `graines/budget_web_app/attendu.json`. Aucun outil du dossier (`eprouver.mjs`,
`supabase-minimum.sql`, juge, pile) n'a été modifié.

Les 17 migrations de l'app passent telles quelles sur le minimum de Supabase (seule sortie : un NOTICE sur
`drop trigger if exists on_auth_user_created`).

| app | table « à moi » | colonne | nom | compte de A | marqueurs de B |
|---|---|---|---|---|---|
| budget_web_app | `public.profiles` | `id` | profils | 1 | 1 |
| budget_web_app | `public.invitations` | `inviter_user_id` | invitations | 3 | 4 |
| budget_web_app | `public.accounts` | `user_id` | comptes | 3 | 6 |
| budget_web_app | `public.categories` | `user_id` | catégories | 22 | 4 |
| budget_web_app | `public.transactions` | `user_id` | transactions | 12 | 12 |
| budget_web_app | `public.budgets` | `user_id` | budgets | 4 | 0 |
| budget_web_app | `public.fixed_charges` | `user_id` | charges fixes | 3 | 4 |
| budget_web_app | `public.savings_goals` | `user_id` | objectifs d'épargne | 2 | 2 |
| budget_web_app | `public.csv_import_rules` | `user_id` | règles d'import | 3 | 2 |
| budget_web_app | `public.spaces` | `created_by` | espaces | 3 | 2 |
| budget_web_app | `public.space_members` | `user_id` | adhésions à un espace | 3 | 0 |
| budget_web_app | `public.shared_expenses` | `paid_by` | dépenses partagées | 3 | 2 |
| budget_web_app | `public.settlements` | `created_by` | remboursements | 2 | 0 |

B porte 39 marqueurs distincts. Les tables sans texte libre (`budgets`, `space_members`, `settlements`) n'ont pas de
marqueur propre : une fuite de B y serait visible par les marqueurs des autres tables, pas par elles-mêmes.

## Empreintes SHA-256

```
ae75ab631a236854baf850f86667d0c7fd7656bc25f65437eb37a37002bdccc2  graines/budget_web_app/graine.sql
b520c8b1bcbc6ba75e57c33c010cb7b7f232802f94540bcd8142cc1d25a69043  graines/budget_web_app/attendu.json
```

## Épreuves

- `node graines/eprouver.mjs budget_web_app` : base neuve, minimum de Supabase, 17 migrations, deux comptes, graine ;
  comptes de A sous RLS (rôle `authenticated`, `request.jwt.claims`), aucune ligne de A marquée, aucun marqueur de B
  visible par A, tous les marqueurs présents, tous distincts, aucun autre motif `MARQUEUR-`. Résultat : 107 `ok`,
  0 `ÉCHEC`, 0 note, « tout est conforme ». Base supprimée.
- Vérification complémentaire à la main (même procédure, base supprimée ensuite) : nombre de lignes **visibles** pour
  A et pour B, par table, sous RLS. A : 1, 3, 3, 22, 12, 4, 3, 2, 3, 3, 3, 3, 2 ; B : 1, 2, 3, 4, 7, 3, 2, 2, 2, 2, 2,
  2, 1 (même ordre que le tableau). Chacun ne voit donc que ses lignes : « mes … » n'a qu'une lecture possible.
  Aucune ligne supprimée (`deleted_at` nul partout).
- Aucun défaut de RLS constaté : A ne voit aucun marqueur de B.

## Choix faits seul

- **Toutes les tables « à moi » sont listées** (13), par la définition de la règle : colonne vers `auth.users`/`profiles`,
  `auth.uid()` en politique. Le plafond de 8 tables est l'affaire de vak, pas de la graine.
- **Données partagées écartées** : A et B ne partagent aucun espace. Des comptes de service `c` et `d` (créés dans la
  graine, hors A et B) sont co-membres des espaces partagés le temps de poser les remboursements (il faut deux
  parties) et les parts des dépenses, puis quittent ces espaces. Sans cela, A verrait le profil et les lignes de ses
  co-membres, et « combien de mes profils ? » aurait deux réponses.
- **Catégories** : celles de A gardent les 17 catégories par défaut (créées par le déclencheur d'inscription) + 5
  propres (22). Celles de B : les 17 par défaut sont supprimées, pour que tout texte libre de B porte un marqueur.
  Le profil et l'espace « Personnel » de B sont renommés avec un marqueur.
- **Colonnes** : `profiles.id` ; `spaces.created_by` ; `shared_expenses.paid_by` ; `settlements.created_by` (A est
  aussi partie de chacun de ses remboursements) ; `invitations.inviter_user_id` (aucune invitation acceptée par A ou B).
- **Noms** : « adhésions à un espace » pour `space_members`, « remboursements » pour `settlements`, « dépenses
  partagées » pour `shared_expenses`. Langue `fr` (`<html lang="fr">` par défaut).
- **Marqueur d'une description recopiée** : la description d'une dépense partagée est copiée de sa transaction source
  par un déclencheur ; ce marqueur n'est listé que sous `shared_expenses`, les marqueurs distincts des notes de ces
  transactions sous `transactions`. Chaque marqueur n'est listé qu'une fois.
- La graine est générée par un script jetable (hors du dossier livré) ; seuls ses deux fichiers sont livrés.

Graines des apps tirées livrées
