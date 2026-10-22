# Rapport — spectacles d'une troupe de théâtre amateur

## Construit
App Next.js 16 (App Router, TypeScript) dans `app/`, branche `main`, avec Supabase (`@supabase/supabase-js`, variables `NEXT_PUBLIC_SUPABASE_URL` et `NEXT_PUBLIC_SUPABASE_ANON_KEY` lues dans `.env`, décrites dans `.env.example`).

- Écrans : connexion/inscription (`/login`), mes troupes (`/`), une troupe avec ses spectacles, ses membres et l'invitation par e-mail (`/troupes/[id]`), un spectacle et ses personnages avec titulaire, doublure et statut (`/spectacles/[id]`), mes personnages à apprendre (`/mes-personnages`).
- Migrations (`supabase/migrations/`) : `schema` (4 tables et contraintes : répliques 1–2000, statuts, titulaire ≠ doublure), `helpers_triggers`, `rls`, `fonctions`.
- RLS par appartenance à la troupe. Un `viewer` lit seulement. Titulaire et doublure doivent être `owner` ou `actor` de la troupe du spectacle (déclencheur). Aucun droit pour `anon`.
- Fonctions RPC : `create_troupe`, `invite_member`, `remove_member`, `set_member_role`, `troupe_member_list`, `mes_personnages`.

## Choix faits seul
- L'invitation par e-mail ajoute directement un utilisateur qui a déjà un compte, avec le rôle `actor` ou `viewer`. Sans compte, elle échoue avec un message. Il n'y a pas de table d'invitations en attente, ni d'envoi d'e-mail.
- Les écritures sur `troupe_members` passent uniquement par des fonctions `security definer` réservées au propriétaire. Le propriétaire ne peut pas être retiré.
- Retirer un membre, ou le passer `viewer`, libère ses places de titulaire et de doublure dans la troupe.
- Les troupes se créent par `create_troupe`, qui ajoute le créateur comme `owner`. Le propriétaire peut modifier nom et ville, mais l'écran ne le propose pas. Il n'y a pas de suppression de troupe.
- `owner` et `actor` créent, modifient et suppriment spectacles et personnages. Troupe et créateur d'un spectacle ou d'un personnage sont immuables.
- `created_by` a pour défaut `auth.uid()` ; les politiques d'insertion exigent qu'il vaille l'appelant. `troupes.created_by` existe en plus de ce que dit la fiche.
- La session est gérée côté navigateur par `supabase-js`, sans `@supabase/ssr` : les pages sont des composants client qui redirigent vers `/login`. Sous Next 16, les pages `[id]` passent par `<Suspense>` pour que le build passe.
- `AGENTS.md` et `README.md`, générés par `create-next-app`, sont supprimés (la fiche interdit la mention d'un kit d'assistant). Je n'ai pas lancé `next dev`, qui recrée `AGENTS.md`.
- La police Google du gabarit est remplacée par une police système, pour que le build ne dépende pas du réseau.

## Vérifications
- `npx tsc --noEmit` : passe, sans erreur.
- `npm run lint` : passe, sans avertissement.
- `npm run build` : passe, 8 pages générées.
- Migrations sur une base PostgreSQL 16 jetable (rôles `anon`/`authenticated`/`service_role` et schéma `auth` minimal avec `users`, `uid()`, `role()`, `jwt()`) : les 4 migrations s'appliquent dans l'ordre sans erreur. La base est supprimée ensuite.
- RLS et fonctions, avec des utilisateurs A, B, C, D (rôle `authenticated`, `request.jwt.claims` posé) :
  - Un utilisateur sans troupe (D) voit 0 troupe, 0 membre, 0 spectacle, 0 personnage. Ses `update` et `delete` n'atteignent aucune ligne, et `troupe_member_list` est refusé.
  - B (`viewer` chez A, `owner` de sa propre troupe) ne modifie ni ne supprime rien chez A (0 ligne), ne peut pas y insérer de spectacle (RLS), n'y invite ni n'y retire personne, et ne peut pas écrire directement dans `troupe_members`.
  - A, simple `viewer` dans la troupe de B, ne peut pas y créer de personnage.
  - Un `viewer` ne peut être ni titulaire ni doublure (déclencheur) ; un titulaire égal à la doublure et des répliques de 0 ou 2001 sont refusés.
  - `anon` : permission refusée sur les tables.
  - Chaque fonction a été appelée au moins une fois, en cas nominal ou en cas refusé : `create_troupe`, `invite_member`, `remove_member`, `set_member_role`, `troupe_member_list`, `mes_personnages` (renvoie le personnage dont l'appelant est titulaire).
  - `set_member_role` vers `viewer` a libéré la doublure de C.
- Pas testé : l'app face à un vrai Supabase (interdit) ; les écrans ont été vérifiés par typage et build seulement. Pas de test de la confirmation d'e-mail à l'inscription.

## Ce qui manque
- Invitations pour les personnes sans compte, et envoi d'e-mail.
- Modifier ou supprimer une troupe, et modifier un spectacle (statut, titre), depuis l'interface. La base l'autorise.
- Les écrans n'ont pas été essayés dans un navigateur.
