# Rapport de construction

## Ce qui est construit

App Next.js 16 (App Router, TypeScript) + Supabase dans `app/` (git, branche `main`, 3 commits, arbre propre).

**Écrans** : connexion / création de compte (`/login`) ; mes journaux + création (`/`) ; articles d'un journal + nouvel
article (`/journaux/[id]`) ; un article, son édition et ses photos (`/journaux/[id]/articles/[articleId]`) ; mes articles à
rendre, statut `idee` ou `en_redaction`, tous journaux confondus, triés par date de remise (`/a-rendre`) ; membres et
invitation par e-mail (`/journaux/[id]/membres`).

**Migrations** (`supabase/migrations/`, 5 fichiers `20261014120000…120400`) :
- `newspapers`, `newspaper_members`, `articles`, `article_photos` avec les contraintes de la fiche (signes 500–20 000,
  largeur 100–6 000, statuts, rôles) ; en plus `profiles` et `newspaper_invitations` (voir choix) ;
- helpers `SECURITY DEFINER` dans un schéma `private` non exposé (pas de récursion RLS) ;
- triggers : profil créé avec le compte, dernier propriétaire protégé, articles libérés quand un membre part ou devient
  lecteur, rédacteur d'un article = propriétaire/rédacteur du journal, journal/créateur figés ;
- RLS sur toutes les tables ;
- fonctions RPC : `create_newspaper`, `invite_member`, `remove_member`, `claim_invitations`.

Client : `@supabase/supabase-js` seul, variables `NEXT_PUBLIC_SUPABASE_URL` / `NEXT_PUBLIC_SUPABASE_ANON_KEY` lues dans
`.env` (ignoré), décrites dans `.env.example` (commité). `package-lock.json` commité.

## Choix faits seul

- **Droits** : `owner` tout ; `writer` crée des articles, modifie ceux qu'il a créés ou qui lui sont confiés, supprime les
  siens, ajoute des photos à tout article du journal et retire les siennes ; `viewer` lit seulement. Seul le propriétaire
  invite, change un rôle ou retire un membre. Pas de départ volontaire d'un membre (la fiche ne le prévoit pas).
- **Création d'un journal** par `create_newspaper` (pas de politique d'INSERT directe), qui fait du créateur le propriétaire.
- **Invitation par e-mail** : sans service-role (interdit côté client), l'app ne peut pas envoyer de courrier. `invite_member`
  ajoute directement un compte existant, sinon garde une invitation en attente ; `claim_invitations` (appelée à chaque
  connexion, sur l'e-mail du JWT) la transforme en appartenance. L'invité doit donc créer un compte avec cette adresse.
- **`profiles`** (id, e-mail, nom) alimenté par trigger sur `auth.users`, visible de soi et des co-membres, pour afficher
  les membres et les rédacteurs sans exposer `auth.users`.
- **Photos** : la fiche ne décrit que des métadonnées (légende, photographe, largeur) ; pas de Storage, pas de fichier.
- **Authentification côté client** (session `supabase-js` dans le navigateur, pages `"use client"`), sans `@supabase/ssr` :
  la consigne fixe `supabase-js` comme client. La sécurité repose sur la RLS, pas sur les redirections.
- `AGENTS.md` généré par `create-next-app` supprimé (« aucune mention d'un kit d'assistant ») ; README réécrit.
- Pas de confirmation d'e-mail simulée ni de test navigateur : aucun projet Supabase réel n'est autorisé.

## Vérifications

| Commande | Résultat |
|---|---|
| `npx tsc --noEmit` | passe, sans sortie |
| `npm run lint` | passe, sans sortie |
| `npm run build` | passe (Next 16.4.0 ; 9 pages générées, sans `.env`) |
| Base jetable `jetable` (PG 16, rôles `anon`/`authenticated`/`service_role`, `auth.users`, `uid()`, `role()`, `jwt()` — `supabase/tests/supabase_stub.sql`), les 5 migrations dans l'ordre avec `ON_ERROR_STOP` | toutes appliquées sans erreur |
| `supabase/tests/rls.sql` sur cette base (5 utilisateurs, rôle `authenticated`, `request.jwt.claims` posé) | **76 contrôles, 76 réussis, 0 échec** |
| Suppression de la base jetable | faite (`jetable` absente de `pg_database`) |

Le test couvre : un utilisateur d'un autre journal ne voit ni ne modifie journaux, membres, invitations, articles, photos,
profils (lecture, UPDATE et DELETE à 0 ligne, INSERT refusé en 42501), ni par `invite_member` / `remove_member` ; le
`viewer` lit sans rien modifier ; le `writer` est limité à son périmètre et ne s'auto-promeut pas ; contraintes de la fiche
(signes, largeur, statut, rôle, usurpation de `created_by`, article confié à un lecteur) ; chaque fonction appelée au moins
une fois (`create_newspaper`, `invite_member` en `added`/`pending`/erreurs, `remove_member`, `claim_invitations` y compris
idempotence) ; dernier propriétaire protégé ; suppression en cascade ; `anon` sans accès.

Les rôles `anon`, `authenticated`, `service_role` existaient déjà dans le cluster local (rôles globaux) : le stub les crée
seulement s'ils manquent, et je ne les ai pas supprimés.

## Ce qui manque

- Pas d'envoi réel d'e-mail d'invitation (voir choix) ; pas de gestion de l'upload de fichiers photo.
- L'interface n'a pas été exercée contre un vrai Supabase (interdit) : elle est vérifiée par typage, lint et build, et le
  SQL par le test ci-dessus.
- `npm audit` signale des vulnérabilités dans l'arbre de dépendances de `create-next-app` ; non traitées.
