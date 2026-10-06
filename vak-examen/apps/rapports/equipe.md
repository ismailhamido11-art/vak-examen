# Rapport de construction : suivi des chantiers

## Ce qui est construit

App Next.js 16 (App Router, TypeScript) dans `app/`, dépôt git neuf sur `main`, Supabase pour comptes et données.

**Écrans**
- `/login` : connexion, et création de compte (e-mail + mot de passe).
- `/` : mes équipes, avec création d'une équipe.
- `/teams/[teamId]` : les chantiers d'une équipe, avec création.
- `/teams/[teamId]/members` : membres, invitation par e-mail, retrait, annulation d'une invitation.
- `/sites/[siteId]` : les tâches d'un chantier (créer, cocher, assigner, supprimer) et le statut du chantier.
- `/tasks` : mes tâches, toutes équipes confondues.

**Migrations** (`supabase/migrations/`)
1. `20261006100000_create_schema` : `teams`, `team_members`, `sites`, `tasks`, `team_invitations`.
2. `20261006100100_rls_helpers` : `is_team_member`, `is_team_owner`, `is_site_member`, `is_site_team_user`.
3. `20261006100200_rls_policies` : RLS sur toutes les tables, droits explicites pour `authenticated`, aucun pour `anon`.
4. `20261006100300_team_functions` : `create_team`, `invite_member`, et un trigger sur `auth.users` qui accepte les invitations en attente.
5. `20261006100400_team_roster` : `team_roster`, la liste des membres avec e-mail.

Le client est `@supabase/supabase-js`. Les variables sont `NEXT_PUBLIC_SUPABASE_URL` et `NEXT_PUBLIC_SUPABASE_ANON_KEY`, lues depuis `.env` (ignoré) et décrites dans `.env.example`.

## Choix faits seul

- **Pages en composants client**, avec la session de `supabase-js` dans le navigateur, sans `@supabase/ssr`. L'accès aux données est protégé par la RLS, pas par le rendu serveur. Le client Supabase est créé à la demande : le build n'a pas besoin des variables, et un message clair s'affiche si elles manquent.
- **Création d'équipe par RPC** `create_team` : elle crée l'équipe et le créateur comme `owner` en une fois. Il n'y a pas de policy d'insertion directe sur `teams` ni sur `team_members`.
- **Invitation par e-mail** : la fiche n'impose pas de mécanisme d'envoi, et aucun service de mail n'est utilisé.
  - Si le compte existe, la personne est ajoutée tout de suite.
  - Sinon, une ligne est écrite dans `team_invitations` (table ajoutée), et le trigger sur `auth.users` l'accepte à l'inscription.
  - Aucun e-mail n'est envoyé par l'app : le propriétaire prévient la personne. Pour envoyer un vrai message, il faudrait une fonction serveur ou l'invitation Supabase Auth, à brancher sur un vrai projet.
- **Droits**
  - Un membre crée et modifie les chantiers, et crée, modifie et supprime les tâches de son équipe.
  - Seul le propriétaire supprime un chantier, renomme ou supprime l'équipe, invite ou retire un membre.
  - Un propriétaire ne peut pas se retirer lui-même, pour qu'une équipe garde toujours un owner.
  - Pas de changement de rôle ni de transfert de propriété (hors fiche).
- **Tâches** : l'assigné doit être membre de l'équipe du chantier, et `created_by` doit être l'utilisateur courant (contrôlé par la RLS).
- **Annuaire** : `auth.users` n'est pas lisible par l'app, donc `team_roster(team)` renvoie les e-mails des membres, aux membres seulement.
- **Statuts de chantier** : `planned`, `in_progress`, `on_hold`, `done`, affichés en français.
- **Fichiers retirés** : `AGENTS.md` et `CLAUDE.md`, générés par `create-next-app`, supprimés car la fiche interdit toute mention d'un kit d'assistant. `next dev` peut les recréer : je ne l'ai pas lancé.
- `.gitignore` : `.env*` reste ignoré, sauf `.env.example`.
- Le test RLS est gardé dans `supabase/tests/` (`bootstrap.sql`, `rls.sql`, `run.sh`), hors de `migrations/`.

## Vérifications

| Commande | Résultat |
|---|---|
| `npx tsc --noEmit` | passe, sans erreur |
| `npm run lint` | passe, sans erreur ni avertissement |
| `npm run build` | passe : 6 routes générées (`/`, `/login`, `/tasks`, `/sites/[siteId]`, `/teams/[teamId]`, `/teams/[teamId]/members`) |
| `supabase/tests/run.sh` | passe : « RLS OK » |

`run.sh` crée une base jetable sur le PostgreSQL 16 local (127.0.0.1:5432, `root`). Les rôles `anon`, `authenticated` et `service_role` existaient déjà dans le cluster : le bootstrap ne les crée que s'ils manquent. Le script écrit le minimum de Supabase (schéma `auth`, `auth.users`, `uid()`, `role()`, `jwt()`), applique les 5 migrations dans l'ordre, joue `rls.sql`, puis supprime la base. Aucune base `chantiers_test_*` ne subsiste.

Le test de RLS (`rls.sql`) utilise trois utilisateurs en rôle `authenticated`, avec `request.jwt.claims` posé. Voici ce qu'il vérifie :
- carol, d'une autre équipe, ne voit ni équipe, ni membres, ni chantiers, ni tâches, ni invitations, ni annuaire de l'équipe A ;
- carol ne peut ni modifier ni supprimer chantiers, tâches, équipe ou membres de A ;
- carol ne peut pas non plus créer de chantier ni de tâche dans A, y inviter quelqu'un, ni s'y ajouter ;
- une tâche assignée à quelqu'un hors équipe est refusée ;
- bob, membre de A, voit A et rien de B, ne retire personne, n'invite pas et ne supprime pas de chantier, mais coche sa tâche ;
- alice, propriétaire de A, retire bob mais ne se retire pas elle-même ;
- l'invitation en attente de dave devient une adhésion à son inscription ;
- le rôle `anon` est refusé.

## Ce qui manque

- **Pas testé contre un vrai Supabase** : interdit par la consigne. L'interface n'a jamais tourné avec une vraie authentification. Seuls le typage, le lint et le build la valident. La RLS et les fonctions, elles, sont testées sur PostgreSQL.
- Pas d'envoi d'e-mail d'invitation (voir plus haut).
- Pas de modification du nom ou de l'adresse d'un chantier, ni du titre d'une tâche, après création. Le statut, la case « fait » et l'assignation se changent.
- Pas de tests automatisés côté interface.
