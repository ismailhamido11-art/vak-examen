# Rapport : budget du foyer (Expo + Supabase)

## Construit
App dans `app/` (dépôt git, branche `main`, Expo SDK 57, Expo Router, TypeScript).
- Écrans : connexion (`login`), dépenses du mois (`(tabs)/index`, navigation mois par mois, total), ajout/modification/suppression d'une dépense (`expense`, modal), catégories (`(tabs)/categories`, création et édition avec plafond), total par catégorie (`(tabs)/summary`, dépassement de plafond en rouge).
- Migrations `supabase/migrations/` :
  - `20261006000100_budget_tables.sql` : `categories`, `expenses`, RLS en lecture seule (select sur ses propres lignes), droits d'écriture retirés.
  - `20261006000200_budget_functions.sql` : `add_expense`, `update_expense`, `delete_expense`, `upsert_category`, `month_summary` (SECURITY DEFINER, `auth.uid()` vérifié, ligne écrite rendue en JSON).
- Client Supabase configuré par `EXPO_PUBLIC_SUPABASE_URL` / `EXPO_PUBLIC_SUPABASE_ANON_KEY` (`.env` ignoré, `.env.example` commité). `package-lock.json` commité.

## Choix faits seul
- « Foyer » = un compte par propriétaire ; pas de partage entre membres (la fiche ne parle que de « propriétaire »).
- Inscription par e-mail + mot de passe depuis l'écran de connexion.
- Sortie web en `single` (et non `static`) : la session est lue dans AsyncStorage, inutilisable au rendu statique côté serveur.
- Une dépense doit avoir une catégorie ; clé étrangère composite `(category_id, owner_id)` : impossible d'utiliser la catégorie d'autrui. Suppression d'une catégorie non prévue (`on delete restrict`).
- `delete_expense` rend la ligne supprimée ; `month_summary(month)` prend n'importe quel jour du mois et inclut les catégories à 0.
- Montants `numeric(12,2)`, saisie de la date en texte `AAAA-MM-JJ` (pas de sélecteur de date).
- Gabarit Expo : retirés `AGENTS.md`, `.claude/`, `README.md` et les composants d'exemple (la fiche exclut toute mention d'un kit d'assistant). Aucun README écrit.
- Aucun test automatisé de l'UI ; l'app n'a pas été lancée contre un vrai Supabase (interdit).

## Vérifications
- `npx tsc --noEmit` : succès (code 0).
- `npx expo lint` : succès (code 0, aucun avertissement).
- `npx expo export --platform web` : succès, `dist/` généré (ignoré par git).
- Migrations sur base jetable PostgreSQL 16.13 (`budget_test`) : rôles `anon`, `authenticated`, `service_role` et schéma `auth` (`users`, `uid()`, `role()`, `jwt()`) créés au préalable ; les deux migrations s'appliquent dans l'ordre, sans erreur (`ON_ERROR_STOP`). Base supprimée ensuite (vérifié).
- RLS / fonctions, deux utilisateurs A et B (rôle `authenticated`, `request.jwt.claims` posé) :
  - B voit 0 catégorie et 0 dépense de A ; son `month_summary` est vide.
  - B ne peut ni modifier (`update_expense`), ni supprimer (`delete_expense`) la dépense de A, ni éditer sa catégorie, ni y ajouter une dépense : erreurs `not found`.
  - Écritures directes (insert/update/delete) refusées pour A comme pour B : `permission denied`.
  - A : ajout, mise à jour, suppression et `month_summary` corrects (total 42,50 → 15,00).
  - `anon` : refusé en lecture et en RPC ; sans `sub` : `not authenticated`.

## Manque
- Rien d'imposé par la fiche. Non fait : partage entre membres d'un foyer, suppression de catégorie, sélecteur de date, test sur un vrai projet Supabase.
