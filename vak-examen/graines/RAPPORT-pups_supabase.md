# Rapport : graines des apps tirées

## Livré

| App | Table « à moi » | Colonne | Nom | Compte de A | Marqueurs de B |
|---|---|---|---|---|---|
| pups_supabase | public.profiles | id | profiles | 1 | 2 |
| pups_supabase | public.orders | user_id | orders | 5 | 4 |

`apps/TIREES.tsv` ne contient qu'une app (pups_supabase, commit 405d4df). Fichiers : `graines/pups_supabase/graine.sql`, `graines/pups_supabase/attendu.json`.

## Empreintes SHA-256

```
e8bd85e7547d2548ea18ee856e95c579ead2b419458b3a2e67bbb16eb92630c9  graines/pups_supabase/graine.sql
8998398a59f6e839ba1c0321dfa41c0b91f91479098ffabaf473603bf710c620  graines/pups_supabase/attendu.json
```

## Épreuve

Commande : `node graines/eprouver.mjs pups_supabase` (outil inchangé : la migration unique `001_init.sql` passe telle quelle sur le minimum de Supabase).
Résultat : toutes les vérifications « ok », « tout est conforme ». A compte 1 profil et 5 commandes sous RLS (rôle `authenticated`, `request.jwt.claims` posé) ; aucune ligne de A ne porte de marqueur ; A ne voit aucun marqueur de B (RLS active sur les deux tables) ; 6 marqueurs distincts présents, aucun autre motif `MARQUEUR-`. La base d'épreuve est supprimée (aucune base `graine_*` restante).

## Choix faits seul

- `profiles` est « à moi » (clé `id` vers `auth.users`, politique `auth.uid() = id`) ; A n'a donc qu'une ligne : « combien de mes profiles » = 1. Le juge lit « one profile » comme 1.
- `orders` : colonne `user_id`. Aucune commande sans propriétaire (`user_id` nul, permis par l'insertion) pour éviter toute ambiguïté.
- `puppies` est un catalogue public (lisible par tous) : aucune ligne marquée, il n'est pas « à moi ».
- Langue `en` (interface de l'app en anglais) ; noms « profiles » et « orders ».
- Marqueurs de B : `profiles.email` et `profiles.name`, et `orders.stripe_payment_intent_id` (un par commande). `orders.status` reste « paid »/« pending » : c'est un état, pas un texte libre, et la valeur doit rester plausible pour l'app.
- Pas de déclencheur de création de profil dans les migrations : la graine insère les profils elle-même.
- Aucune adaptation d'`eprouver.mjs` ni de `supabase-minimum.sql`.

Graines des apps tirées livrées
