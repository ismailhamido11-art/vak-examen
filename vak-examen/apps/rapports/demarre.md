# Rapport de construction : carnet de lecture

## Construit
App Expo (SDK 57, Expo Router, TypeScript) dans `app/`, branche `main`, avec Supabase (`@supabase/supabase-js`).
- Écrans (`src/app/`) : `login` (connexion / création de compte e-mail + mot de passe), `index` (mes livres),
  `book/[id]` (fiche + séances, changement de statut, suppression), `add-book`, `add-session`.
- Logique (`src/lib/`) : client Supabase, contexte d'auth, types, petits composants UI. 11 fichiers au total.
- Migration `supabase/migrations/20261006090000_carnet_de_lecture.sql` : `books`, `reading_sessions`, RLS « propriétaire seulement ».
- `.env.example` (`EXPO_PUBLIC_SUPABASE_URL`, `EXPO_PUBLIC_SUPABASE_ANON_KEY`), `.env` ignoré, `package-lock.json` commité.

## Choix faits seul
- Le gabarit `blank-typescript` ne contient pas Expo Router : je l'ai ajouté à la main (`main: expo-router/entry`, routes dans `src/app/`).
- Le gabarit apportait `AGENTS.md` et `.claude/` (kit d'assistant) : supprimés, la fiche l'interdit.
- Garde des routes par `Stack.Protected` selon la session ; bouton « Créer un compte » en plus de la connexion.
- Une séance ne peut viser qu'un livre du même propriétaire (clé étrangère composite `(book_id, owner_id)`), en plus de la RLS.
- `owner_id` vaut `auth.uid()` par défaut : l'app n'a pas à l'envoyer. `pages_read > 0`, titre non vide.
- Date de séance saisie en texte `AAAA-MM-JJ` (pas de sélecteur de date, pour rester sans dépendance native).
- Sans `.env`, un client à URL factice est créé et l'écran de connexion affiche l'absence de configuration.
- Nom de migration daté du 2026-10-06.
- Les rôles `anon`, `authenticated`, `service_role` existaient déjà dans le cluster local (globaux) ; je ne les ai ni recréés ni supprimés.

## Vérifications
- `npx tsc --noEmit` : passe, aucune sortie.
- `npx expo lint` : passe, aucune sortie.
- `npx expo export --platform web` : passe (`dist/` ignoré par git).
- Migrations sur base jetable `tmp_carnet` (rôles et schéma `auth` minimal : `users`, `uid()`, `role()`, `jwt()`) : appliquées sans erreur, base supprimée ensuite.
- RLS, deux utilisateurs (`authenticated`, `request.jwt.claims` posé) : A crée 1 livre et 1 séance ; B voit 0 livre et 0 séance ;
  les `update`/`delete` de B touchent 0 ligne ; B ne peut pas insérer avec `owner_id` de A (refusé) ni rattacher une séance au livre de A
  (violation de clé étrangère) ; les données de A sont intactes à la fin.

## Ce qui manque
- Aucune exécution contre un vrai Supabase ni sur appareil (interdit / hors périmètre) : les écrans sont vérifiés par typage, lint et export web seulement.
- Pas de test automatisé, pas d'édition ni de suppression des séances.
