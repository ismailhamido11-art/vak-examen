# Rapport — app de prêts d'objets (Expo + Supabase)

## Construit
Dépôt `app/` (branche `main`, 2 commits, `git status` propre). Expo SDK 57, Expo Router (`src/app/`), TypeScript.
- Écrans : connexion/création de compte (`login`), mes objets (`index`, ajout + liste), prêts d'un objet (`item/[id]` :
  renommer, prêter, marquer rendu, oublier), nouveau prêt (`new-loan`), prêts en retard (`overdue`, appelle
  `overdue_loans` avec la date du jour).
- Migrations : `20260101000000_tables.sql` (tables, index, RLS lecture seule, déclencheur `times_lent`),
  `20260101000100_functions.sql` (`add_item`, `rename_item(id, changes jsonb)`, `lend_item`, `return_loan(id, details jsonb)`,
  `forget_item`, `overdue_loans(as_of)`).
- `.env.example` (`EXPO_PUBLIC_SUPABASE_URL`, `EXPO_PUBLIC_SUPABASE_ANON_KEY`), `.env` ignoré, `package-lock.json` commité.

## Choix faits seul
- Écritures : tables en `select` seul pour `authenticated`, tout retiré à `anon` ; les fonctions sont `security definer`
  (nécessaire puisqu'aucune écriture directe n'est accordée), `search_path` fixé, `auth.uid()` vérifié, `execute`
  réservé à `authenticated`. Le déclencheur est aussi `security definer`.
- Arguments : `add_item(p_name, p_category default 'autre')`, `lend_item(p_item_id, p_borrower, p_days default 14)`,
  `forget_item(p_item_id)`. Clés jsonb : `name`/`category` ; `returned_on`/`condition_note` (retour = aujourd'hui par défaut).
- Un seul prêt en cours par objet, garanti aussi par un index unique partiel. Durée négative refusée ; 0 jour accepté.
- `forget_item` rend objet + prêts effacés (ex. 1 objet + 1 prêt = 2). Les prêts d'autrui ne sont jamais visibles
  (objet inconnu ou d'un autre = « not found »).
- `overdue_loans` rend `loan_id, item_name, borrower, due_on, days_late`.
- Connexion par e-mail/mot de passe. Stockage de session : AsyncStorage, remplacé par un stockage mémoire pendant le rendu
  statique web (sinon `expo export` échoue).
- Le gabarit Expo apportait `AGENTS.md`, `.claude/` et des écrans de démo : supprimés, et dépôt git recréé pour que
  l'historique n'en contienne rien (Interdit : aucun assistant IA).
- Identité git locale par défaut si absente.

## Vérifications
- `npx tsc --noEmit` : OK.
- `npx expo lint` : OK (eslint-config-expo ajouté), aucune alerte.
- `npx expo export --platform web` : OK (échec au premier essai, corrigé comme ci-dessus).
- Migrations sur base jetable `tmp_test` (PostgreSQL 16 local), après schéma `auth` minimal (`users`, `uid()`, `role()`,
  `jwt()`) : appliquées dans l'ordre sans erreur ; base supprimée ensuite. Les rôles `anon`, `authenticated`,
  `service_role` existaient déjà dans le cluster (autre base) : réutilisés et laissés en place (non supprimables).
- Scénario avec deux utilisateurs A et B (rôle `authenticated`, `request.jwt.claims`) :
  - A : `add_item` ×2, `rename_item`, `lend_item` (`times_lent` passe à 1), nouveau prêt refusé (« already lent »),
    `forget_item` refusé tant que prêté, `overdue_loans(+20 j)` rend 1 ligne (6 j de retard), `overdue_loans(aujourd'hui)` 0 ligne,
    `return_loan` OK puis second refusé (« already returned »), `forget_item` rend 2, il ne reste aucun prêt.
  - B : voit 0 objet, 0 prêt, 0 retard ; `rename_item`, `lend_item`, `return_loan`, `forget_item` sur les lignes de A
    refusés (« not found ») ; `insert`/`update`/`delete` directs refusés (permission denied) ; `anon` ne peut appeler aucune fonction.

## Manque
- Non testé contre un vrai Supabase (interdit) ni sur appareil/émulateur : seul l'export web est vérifié.
  Les écrans n'ont pas de test automatisé. Pas de confirmation e-mail gérée dans l'écran de connexion
  (selon la config du projet, l'inscription peut exiger de confirmer l'adresse).
