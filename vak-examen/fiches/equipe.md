# Fiche de forme 2 : une app d'équipe (Next.js)

Cette fiche décrit une app à construire, sans la nommer, par une session qui n'a jamais vu vak. Elle est publiée avec
son empreinte SHA-256 avant la construction.

## L'app

Le **suivi des chantiers d'une petite entreprise de rénovation** : une équipe partage ses chantiers et leurs tâches,
et chacun suit les siennes.

- **Plateforme** : Next.js (App Router, TypeScript), avec Supabase pour les comptes et les données.
- **Écrans** : connexion ; mes équipes ; les chantiers d'une équipe ; les tâches d'un chantier ; mes tâches,
  toutes équipes confondues ; l'invitation d'un membre par e-mail.

## Les données

Des migrations SQL dans `supabase/migrations/` :
- `teams` (nom), et `team_members` (équipe, utilisateur, rôle `owner` ou `member`) ;
- `sites` : un chantier d'une équipe (nom, adresse, date de début, statut) ;
- `tasks` : une tâche d'un chantier (titre, échéance, fait ou non, la personne assignée, qui l'a créée).

La RLS passe par l'appartenance à l'équipe : un membre voit les chantiers et les tâches de ses équipes, jamais ceux
d'une autre équipe. Seul le propriétaire d'une équipe invite ou retire un membre.

## Ce qui est attendu de la construction

- `npx tsc --noEmit`, `npm run lint` et `npm run build` passent.
- Un `package-lock.json` est commité ; aucun secret n'est commité, et un `.env.example` donne les noms des variables.
- Aucun assistant IA, aucune mention d'un kit d'assistant.
