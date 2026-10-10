# Fiche de forme 2 : une app d'équipe (Next.js), deuxième examen

Cette fiche décrit une app à construire, sans la nommer, par une session qui n'a jamais vu vak. Elle est publiée avec
son empreinte SHA-256 avant la construction.

## L'app

Les **dossiers de voyage d'une petite agence** : l'équipe partage ses dossiers clients et leurs réservations, et chacun
suit celles qu'on lui a confiées.

- **Plateforme** : Next.js (App Router, TypeScript), avec Supabase pour les comptes et les données.
- **Écrans** : connexion ; mes agences ; les dossiers d'une agence ; les réservations d'un dossier ; mes réservations
  à confirmer, toutes agences confondues ; l'invitation d'un membre par e-mail.

## Les données

Des migrations SQL dans `supabase/migrations/` :
- `agencies` (nom), et `agency_members` (agence, utilisateur, rôle `owner`, `agent` ou `viewer`) ;
- `trips` : un dossier d'une agence (client, destination, dates de départ et de retour, budget, statut) ;
- `bookings` : une réservation d'un dossier (type `vol`, `hotel` ou `autre`, fournisseur, prix, confirmée ou non, le
  membre qui en est chargé, qui l'a créée).

La RLS passe par l'appartenance à l'agence : un membre voit les dossiers et les réservations de ses agences, jamais
ceux d'une autre agence. Un `viewer` voit sans rien modifier. Seul le propriétaire d'une agence invite ou retire un
membre.

## Ce qui est attendu de la construction

- `npx tsc --noEmit`, `npm run lint` et `npm run build` passent.
- Un `package-lock.json` est commité ; aucun secret n'est commité, et un `.env.example` donne les noms des variables.
- Aucun assistant IA, aucune mention d'un kit d'assistant.
