# Rapport : collection de disques vinyles (Expo + Supabase)

## Construit
Dépôt `app/` (branche `main`, `git status` propre, `package-lock.json` commité).
- Expo SDK 57, Expo Router, TypeScript strict, `@supabase/supabase-js` + AsyncStorage.
- Écrans (`src/app/`) : `login` (connexion / création de compte e-mail + mot de passe), `index` (disques groupés par artiste, `SectionList`), `vinyl/[id]` (fiche + écoutes, suppression), `vinyl/new`, `listening/new`. Routes protégées par `Stack.Protected` selon la session.
- Logique : `src/lib/{supabase,auth,types}`, composants communs dans `src/components.tsx`.
- Migration `supabase/migrations/20260101000000_collection_vinyles.sql` : enum `etat_disque`, tables `vinyls` et `listenings`, contraintes (année 1900–2100, prix ≥ 0 ou nul, face A/B/AB, note 1–5), RLS « propriétaire seulement » avec `to authenticated`.
- `.env.example` (`EXPO_PUBLIC_SUPABASE_URL`, `EXPO_PUBLIC_SUPABASE_ANON_KEY`) ; `.env` ignoré.

## Choix faits seul
- Colonnes en français (`titre`, `artiste`, `annee`, `etat`, `genres`, `prix_achat`, `ecoute_le`, `face`, `note`, `commentaire`, `user_id`).
- `user_id` a pour défaut `auth.uid()`. Clé étrangère composite `listenings(vinyl_id, user_id) → vinyls(id, user_id)` : une écoute ne peut pas viser le disque d'un autre, même en forgeant la requête.
- Droits donnés au seul rôle `authenticated` ; `anon` n'a aucun accès.
- Commentaire : texte non nul, vide par défaut. Genres saisis séparés par des virgules. Date d'écoute saisie en `AAAA-MM-JJ HH:MM` (pré-remplie à maintenant) faute de sélecteur natif multiplateforme sans dépendance.
- Création de compte ajoutée sur l'écran de connexion (la fiche ne parle que de connexion, mais sans elle on ne peut pas démarrer). Si la confirmation d'e-mail est active, l'écran le signale.
- Suppression d'un disque ajoutée (supprime ses écoutes en cascade).
- Le modèle Expo contenait `.claude/`, `AGENTS.md` et des écrans de démo : supprimés (consigne : pas de kit d'assistant). Le dépôt initial du modèle (branche `master`) a été renommé `main`; il garde donc un commit « Initial commit » du modèle avant le mien.
- Rendu statique web : sans `window`, le client Supabase n'utilise ni stockage ni persistance (sinon l'export plantait).
- Sans `.env`, le client prend des valeurs factices pour que l'export passe ; aucun secret.
- La fiche ne définit aucune fonction SQL : il n'y en a donc aucune à appeler.

## Vérifications
- `npx tsc --noEmit` : code 0.
- `npx expo lint` : code 0, aucun avertissement (eslint et eslint-config-expo installés par la commande).
- `npx expo export --platform web` : code 0 (7 routes statiques, dossier `dist/` ignoré par git).
- Migrations sur PostgreSQL 16, base jetable (rôles `anon`/`authenticated`/`service_role`, schéma `auth` avec `users`, `uid()`, `role()`, `jwt()` écrits au préalable) : appliquées sans erreur, base supprimée ensuite.
- RLS, avec deux utilisateurs A et B (`request.jwt.claims` posé, rôle `authenticated`) :
  - A voit son disque et son écoute ; B en voit 0 ;
  - `update`/`delete` de B sur `vinyls` et `listenings` : 0 ligne touchée ;
  - B ne peut ni écouter le disque de A (violation de clé étrangère) ni insérer avec `user_id` de A (violation de RLS) ;
  - les contraintes refusent année 1899/2101, état inconnu, prix négatif, face `C`, notes 0 et 6 ; B insère normalement ses propres lignes ;
  - les données de A sont intactes à la fin ; `anon` : permission refusée.

## Ce qui manque
- Les écrans n'ont pas été lancés contre un vrai Supabase (interdit) ni sur appareil : vérifiés par typage, lint et export seulement.
- Pas de tests automatisés dans le dépôt (le script SQL de vérification était jetable).
- Pas de modification ni de suppression d'une écoute, ni de modification d'un disque (hors fiche).
- `npm audit` signale des vulnérabilités dans des dépendances transitives d'Expo ; non traitées.
