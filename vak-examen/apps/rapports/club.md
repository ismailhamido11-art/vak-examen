# Rapport de construction

## Ce qui est construit
App Next.js 16 (App Router, TypeScript, sans Tailwind) + `@supabase/supabase-js`, dépôt git dans `app/` (branche `main`).

Écrans :
- `/login` : connexion et inscription par e-mail et mot de passe.
- `/` : mes clubs, avec mon rôle, et création d'un club.
- `/clubs/[id]` : entraînements du club. Création, changement de statut et suppression pour owner/coach. Lecture seule pour un viewer.
- `/clubs/[id]/trainings/[tid]` : présents. Ajout, présent/absent, montant payé, retrait. Compteur présents/places.
- `/mes-entrainements` : entraînements que j'anime, tous clubs confondus. Filtre « prévus » activé par défaut.
- `/clubs/[id]/membres` : liste des membres. Le propriétaire invite par e-mail, change un rôle, retire un membre ou annule une invitation.

Migration `supabase/migrations/20261010100000_schema.sql` :
- Tables `clubs`, `club_members`, `trainings`, `attendances`, plus `club_invitations`.
- RLS par appartenance au club, via les fonctions `club_role()` et `training_club()` (security definer, pas de récursion).
- Triggers :
  - le créateur d'un club en devient `owner` ;
  - l'encadrant d'un entraînement doit être owner ou coach du club ;
  - `club_id` et `training_id` sont immuables ;
  - les présents ne dépassent pas les places ;
  - un owner ne peut ni être retiré ni changer de rôle.
- Fonction `invite_member()` et trigger `claim_invitations` sur `auth.users`.

Test RLS rejouable : `supabase/tests/rls.sql`.

## Choix faits seul
- **Invitation par e-mail** :
  - Le client ne peut pas lire `auth.users`, donc l'invitation passe par la RPC `invite_member(club, email, rôle)`, réservée au owner.
  - Si le compte existe, la personne est ajoutée tout de suite.
  - Sinon l'invitation est mise en attente dans `club_invitations`. Elle est réclamée automatiquement par un trigger à la création du compte avec cet e-mail.
  - Aucun e-mail n'est envoyé : cela demanderait un service d'envoi ou un projet réel. La personne doit s'inscrire elle-même avec l'adresse invitée.
- Rôles invitables : `coach` ou `viewer`. Le rôle `owner` n'est donné qu'au créateur du club, et un owner est non retirable.
- `club_members.email` est copié à l'ajout pour afficher les membres, car `auth.users` n'est pas lisible depuis le client.
- Les coach peuvent créer, modifier et supprimer entraînements et présents. Les viewer ne font que lire.
- `trainings.coach_id` est l'encadrant qui anime. Il est facultatif et passe à NULL si son compte est supprimé.
- Un participant est un nom libre, pas un compte. Les présents ne peuvent pas dépasser le nombre de places.
- Montant : `numeric(8,2) >= 0`, en euros.
- Auth : client `supabase-js` côté navigateur uniquement (session en localStorage), sans `@supabase/ssr`. Le client est créé à la demande pour que le build n'ait pas besoin des variables. Toutes les pages sont des composants client protégés par `components/Shell.tsx`.
- `<Suspense>` dans le layout racine, exigé par ce Next.js pour les routes dynamiques.
- `AGENTS.md`, généré par `create-next-app`, est supprimé : la fiche interdit toute mention d'un kit d'assistant. Ne pas lancer `next dev`, qui pourrait le recréer (non vérifié).
- `.gitignore` : exception `!.env.example`, car `.env*` l'aurait ignoré.
- Police Google (Geist) retirée : elle demande le réseau au build.
- Les trois pages dynamiques lisent `params` avec `use()` : `useParams` faisait échouer le prérendu.

## Vérifications
Dans `app/` :
| Commande | Résultat |
|---|---|
| `npx tsc --noEmit` | passe, sans erreur |
| `npm run lint` | passe, sans erreur ni avertissement |
| `npm run build` | passe, 9 pages générées |

Migrations sur base neuve (PostgreSQL 16 local, base jetable `test_club`) :
- Stubs Supabase écrits d'abord : rôles `anon`, `authenticated`, `service_role` (déjà présents sur le serveur, donc créés seulement s'ils manquaient). Schéma `auth` avec `users`, `uid()`, `role()`, `jwt()`.
- La migration s'applique sans erreur (`psql -v ON_ERROR_STOP=1`).
- RLS : `psql -f supabase/tests/rls.sql` donne 35 « ok » et aucun échec. Deux utilisateurs A et B, rôle `authenticated`, `request.jwt.claims` posé.
- Vérifié :
  - B, non membre, ne voit ni ne modifie rien de A : clubs, entraînements, présents, membres. Il ne crée rien chez A, ne s'ajoute pas comme owner, n'invite pas.
  - B devenu viewer lit mais ne modifie ni ne crée rien.
  - Un coach écrit, mais n'invite ni ne retire personne.
  - Le owner retire un membre, et ce membre perd l'accès.
  - Les invitations en attente sont réclamées à l'inscription.
  - Les limites de places (1 à 100, présents ≤ places) tiennent.
  - Le owner ne peut pas être retiré.
  - La suppression d'un club se propage en cascade.
- Une seconde exécution du même script sur la même base échoue sur des identifiants déjà présents : c'est attendu, le test s'applique à une base neuve.
- La base jetable est supprimée (vérifié).

## Ce qui manque
- Aucun test de l'interface dans un navigateur, et aucun test contre un vrai Supabase : c'était interdit. L'interface est vérifiée par le typage, le lint et le build seulement.
- Pas d'e-mail d'invitation envoyé (voir plus haut).
- Pas de pagination, ni de modification d'un entraînement existant (hors statut), ni de renommage de club.

App construite au commit 1b05281
