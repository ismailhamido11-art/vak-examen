# Rapport : suivi des abonnements (Expo + Supabase)

## Ce qui est construit

Dépôt git `app/`, branche `main`, créé avec `create-expo-app` (SDK 57, Expo Router, TypeScript), nettoyé de ses écrans d'exemple.

- **Écrans** : connexion / création de compte (`sign-in`) ; mes abonnements, avec ajout (`index`) ; paiements d'un abonnement, avec résiliation et suppression d'un paiement (`subscription/[id]`) ; ajout d'un paiement (`subscription/[id]/payment`) ; dépense du mois par abonnement, avec navigation de mois (`spending`). Les routes protégées passent par `Stack.Protected` selon la session.
- **Migrations** (`supabase/migrations/`) :
  - `20261010100000_create_tables.sql` : `subscriptions` et `payments`, contraintes (catégorie, moyen, jour 1–28, montant de paiement > 0), RLS en lecture de ses propres lignes seulement, `revoke all` puis `grant select` : aucune écriture directe.
  - `20261010100100_create_functions.sql` : `create_subscription`, `update_subscription`, `cancel_subscription`, `record_payment`, `delete_payment` (SECURITY DEFINER, `auth.uid()` vérifié, ligne rendue en JSON) et `month_spending` (SECURITY INVOKER, lignes `name, total`).
- **Client** : `@supabase/supabase-js`, configuré par `EXPO_PUBLIC_SUPABASE_URL` et `EXPO_PUBLIC_SUPABASE_ANON_KEY` (`.env` ignoré par git, `.env.example` commité). Lecture directe des tables, écriture uniquement par RPC.

## Choix faits seul

- Un appel non authentifié, ou sur une ligne d'un autre utilisateur donne `not authenticated` (28000) ou `... not found` (P0002), sans révéler l'existence de la ligne.
- `update_subscription` accepte seulement `name`, `category`, `monthly_amount`, `billing_day`. Les autres clés (dont `active` et `owner_id`) sont refusées. Un abonnement résilié ne se réactive donc pas. L'app n'a pas d'écran de modification, la fonction existe côté base.
- `record_payment` : `amount` obligatoire et > 0 ; `date` par défaut aujourd'hui ; `method` par défaut `carte`. Refus sur abonnement inactif.
- `month_spending(month)` prend le mois du jour donné, liste tous les abonnements de l'appelant (y compris à 0 € et résiliés) et renvoie exactement `name, total`.
- Montant mensuel ≥ 0 autorisé (abonnement gratuit) ; un paiement doit être > 0.
- Suppression d'un compte : cascade sur les abonnements et paiements.
- Saisie de la date au format texte AAAA-MM-JJ (pas de sélecteur natif). Résiliation en deux appuis (confirmation intégrée, car `Alert` ne gère pas les boutons sur le web).
- Création de compte par e-mail et mot de passe ; si le projet exige la confirmation, un message l'indique.
- Valeurs de repli pour l'URL et la clé quand `.env` est absent, afin que `export` fonctionne ; l'écran de connexion signale alors l'absence de configuration. La session n'est pas persistée pendant le rendu statique web.
- Retiré du modèle : `AGENTS.md`, `.claude/`, `README.md`, script `reset-project`, composants et thème d'exemple (la fiche exclut toute mention d'un kit d'assistant).
- Ma préparation de la base jetable : les rôles `anon`, `authenticated` et `service_role` existaient déjà dans le cluster (utilisés par d'autres bases). Je les ai réutilisés sans les modifier ; seuls le schéma `auth` et ses fonctions ont été créés dans la base jetable.

## Vérifications

| Commande | Résultat |
|---|---|
| `npx tsc --noEmit` | passe (aucune erreur) |
| `npx expo lint` | passe, code de sortie 0 |
| `npx expo export -p web` | passe, 7 routes statiques exportées dans `dist/` (ignoré par git) |
| Base jetable `verif_abo` : rôles manquants, schéma `auth` (`users`, `uid()`, `role()`, `jwt()`), puis les 2 migrations dans l'ordre | s'appliquent sans erreur ; base supprimée ensuite |
| Contrôles RPC (rôle `authenticated`, `request.jwt.claims` posé) | paiement valide accepté ; montant 0 et négatif refusés ; moyen, catégorie et jour hors liste refusés ; clé non modifiable refusée ; abonnement inactif refuse un paiement ; sans JWT : `not authenticated` ; rôle `anon` : permission refusée |
| RLS avec deux utilisateurs A et B | B voit 0 abonnement, 0 paiement, 0 ligne de `month_spending` ; ses `update_subscription`, `cancel_subscription`, `record_payment` et `delete_payment` sur les lignes de A échouent (`not found`) ; `update`, `insert` et `delete` directs refusés (`permission denied`) ; après ces tentatives, A voit toujours ses données intactes |
| `git status` dans `app/` | propre |

Les contrôles SQL ont été lancés à la main (script psql jetable, hors dépôt) ; ils ne sont pas commités comme tests.

## Ce qui manque

- L'app n'a pas été lancée contre un vrai Supabase (interdit) : les écrans sont vérifiés par typage, lint et export, pas par usage.
- Pas d'écran de modification d'un abonnement (la fonction `update_subscription` est prête).
- Pas de tests automatisés commités.
- `npm audit` signale des vulnérabilités dans des dépendances transitives de l'outillage Expo ; non traitées.

App construite au commit 9ee8a78
