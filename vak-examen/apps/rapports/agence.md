# Rapport

## Construit
App Next.js 16 (App Router, TypeScript) dans `app/`, Supabase pour comptes et données (`@supabase/supabase-js` + `@supabase/ssr`).
- Écrans : connexion/création de compte (`/login`) ; mes agences (`/`, création d'une agence) ; dossiers d'une agence
  (`/agencies/[id]`) ; réservations d'un dossier (`/agencies/[id]/trips/[tripId]`) ; mes réservations à confirmer, toutes
  agences confondues (`/bookings`) ; membres et invitation par e-mail (`/agencies/[id]/members`).
- Migrations (`supabase/migrations/`) : `20261010150000_schema.sql` (agencies, agency_members, trips, bookings,
  agency_invitations) et `20261010150100_rls_and_functions.sql` (RLS, déclencheurs, fonctions).
- `.env.example` (noms des variables), `package-lock.json` commité, aucun secret, aucun `.env` commité.

## Choix faits seul
- **Rôles** : `owner` et `agent` écrivent (dossiers, réservations) ; `viewer` lit seulement ; seul `owner` invite, retire ou change un membre, renomme/supprime l'agence. Une agence garde toujours au moins un propriétaire (déclencheur).
- **Création d'agence** via la fonction `create_agency` (agence + membre `owner` en une transaction) ; l'insertion directe dans `agencies` est refusée.
- **Invitation** : fonction `invite_member`. Compte existant → ajouté tout de suite. Sinon → ligne dans `agency_invitations`, rattachée par `accept_invitations()` (appelée après connexion/inscription/lien de confirmation) si l'e-mail du compte est confirmé. L'e-mail d'invitation Supabase n'est envoyé que si `SUPABASE_SERVICE_ROLE_KEY` est définie (variable serveur facultative, jamais publique) ; sinon l'invité s'inscrit lui-même avec cet e-mail.
- Une réservation porte aussi `agency_id` (clé étrangère composite avec le dossier : impossible de la rattacher à une autre agence) ; le responsable doit être membre de l'agence ; `created_by`, `agency_id`, `trip_id` ne sont pas modifiables.
- Statuts de dossier : `draft`, `confirmed`, `completed`, `cancelled` (affichés en français). Budget et prix en euros, `numeric(12,2)`.
- Un `agent` peut supprimer dossiers et réservations (la fiche ne le précise pas).
- Fonction `agency_member_emails` (security definer, limitée aux membres de l'agence) pour afficher les e-mails des membres.
- `proxy.ts` (nouveau nom de middleware dans Next 16) rafraîchit la session et redirige vers `/login`. `Suspense` dans le layout, exigé par `cacheComponents` activé par défaut dans ce gabarit.
- Le fichier `AGENTS.md` généré par `create-next-app` a été retiré (la fiche demande aucune mention d'un kit d'assistant).
- Polices système plutôt que Google Fonts (pas de réseau nécessaire au build).

## Vérifications
Dans `app/` :
- `npx tsc --noEmit` : passe, sans erreur.
- `npm run lint` : passe, sans avertissement.
- `npm run build` : passe (sans variables Supabase définies). 
- `next start` avec de fausses variables : `/bookings` redirige (307) vers `/login`, `/login` répond 200. Aucun test réel contre Supabase.
- `git status` : propre.

Migrations et RLS (script `verif/run.sh app`, hors de `app/`, avec `verif/stub.sql` et `verif/rls.sql`) : base jetable créée sur le
PostgreSQL local, rôles `anon`/`authenticated`/`service_role` et schéma `auth` minimal (`users`, `uid()`, `role()`, `jwt()`) écrits d'abord, les
2 migrations appliquées dans l'ordre sans erreur, puis 59 contrôles avec `request.jwt.claims` posé en rôle `authenticated` : **0 échec sur 59**.
Couvert : deux propriétaires d'agences distinctes (A, B) ne voient ni ne modifient/suppriment/créent rien chez l'autre (agences, membres, dossiers,
réservations, invitations, e-mails) ; `viewer` lit mais ne modifie rien ni n'invite ; `agent` écrit mais ne gère pas les membres ni son rôle ;
invitation (compte existant, en attente, e-mail non confirmé) ; dernier propriétaire protégé ; membre retiré ne voit plus rien ; `anon` sans accès.
La base jetable est supprimée (aucune base `verif_*` restante).

## Ce qui manque
- Aucun essai de bout en bout contre un vrai Supabase (interdit) : le parcours d'authentification, l'envoi d'e-mails et les liens de confirmation ne sont pas exercés.
- Pas de tests automatisés dans le dépôt (les contrôles RLS sont dans `verif/`, hors de `app/`).
- Pas de modification de dossier ni de réservation après création (hors confirmation et suppression), ni de changement de rôle d'un membre dans l'interface (possible en base pour le propriétaire).
