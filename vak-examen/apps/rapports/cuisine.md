# Rapport : carnet de cuisine

## Construit
App Expo (SDK 57, Expo Router, TypeScript) dans `app/`, branche `main`, un seul commit.
- Écrans (`src/app/`) : `login` (connexion / création de compte e-mail + mot de passe), `index` (mes recettes, favorites d'abord puis ordre alphabétique), `recipe/[id]` (fiche, fois cuisinées, bascule favorite), `new` (ajout de recette), `recipe/cook` (ajout d'une fois cuisinée avec note 1–5, date, commentaire). `_layout` protège les routes selon la session.
- Logique (`src/lib/`) : client Supabase, contexte de session, types, composants UI.
- Migration `supabase/migrations/20261010120000_carnet_initial.sql` : `recipes`, `cookings`, contraintes (catégorie, 1–600 min, 1–20 portions, note 1–5), index, RLS « propriétaire seulement » sur les deux tables.
- `.env.example` (`EXPO_PUBLIC_SUPABASE_URL`, `EXPO_PUBLIC_SUPABASE_ANON_KEY`), `.env` ignoré, `package-lock.json` commité.

## Choix faits seul
- Modèle de départ `blank-typescript`, puis Expo Router ajouté à la main. Les fichiers d'assistant du modèle (`AGENTS.md`, `.claude/`) ont été supprimés (la fiche exclut toute mention d'un kit d'assistant).
- Un trigger `cookings_check_owner` refuse une « fois cuisinée » rattachée à la recette d'un autre utilisateur (la RLS seule ne l'empêchait pas, la clé étrangère ne vérifiant pas le propriétaire).
- `user_id` a pour défaut `auth.uid()` ; `on delete cascade` vers `auth.users` et de recette vers cuissons (cookings).
- Colonnes en anglais (`title`, `category`, `prep_minutes`, `servings`, `is_favorite`, `keywords`, `cooked_on`, `rating`, `comment`) ; libellés d'interface en français.
- Pas de rôle `anon` sur les tables : seul `authenticated` a les droits.
- Date saisie en texte AAAA-MM-JJ (pas de sélecteur natif, pour rester simple et identique sur le web) ; mots-clés saisis séparés par des virgules.
- Création de compte depuis l'écran de connexion ; si la confirmation d'e-mail est active, un message l'indique.
- Pas de modification ni suppression de recette / de cuisson dans l'UI (non demandées) ; la RLS les permet aux propriétaires.
- Si les variables Supabase manquent, l'écran de connexion affiche une erreur au lieu de planter.
- Pas de test UI automatisé ; l'app n'a pas été lancée contre un vrai Supabase (interdit).

## Vérifications
- `npx tsc --noEmit` : passe, sans erreur.
- `npx expo lint` : passe, sans avertissement.
- `npx expo export --platform web` : passe (bundle web généré dans `dist/`, ignoré par git). `npx expo export` seul passe aussi.
- Migrations sur base jetable `carnet_test` (PostgreSQL 16 local) : rôles `anon`/`authenticated`/`service_role` (déjà présents dans le cluster, donc créés seulement s'ils manquent), schéma `auth` avec `users`, `uid()`, `role()`, `jwt()` ; la migration s'applique sans erreur. Base supprimée ensuite.
- RLS, avec deux utilisateurs A et B (rôle `authenticated`, `request.jwt.claims` posé) :
  - B voit 0 recette et 0 cuisson de A ; ses UPDATE et DELETE touchent 0 ligne sur les deux tables ;
  - B ne peut pas insérer avec le `user_id` de A (violation de la RLS), ni cuisiner la recette de A (trigger) ;
  - A voit toujours sa recette et sa cuisson intactes ;
  - contraintes refusées : catégorie inconnue, 601 min, 21 portions, note 6 ;
  - `anon` : permission refusée sur `recipes`.
- `git status` : propre. Aucun secret ni `.env` commité ; aucune mention d'assistant dans les fichiers du dépôt (recherche faite).

## Ce qui manque
Rien d'exigé par la fiche. Non fait : modification/suppression dans l'UI, test sur un vrai projet Supabase, tests automatisés. `npm audit` signale des vulnérabilités dans des dépendances transitives de l'écosystème Expo, non traitées.

App construite au commit 791c04d
