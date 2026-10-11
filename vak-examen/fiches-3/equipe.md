# Fiche de forme 2 : une app d'équipe (Next.js), troisième examen

Cette fiche décrit une app à construire, sans la nommer, par une session qui n'a jamais vu vak. Elle est publiée avec
son empreinte SHA-256 avant la construction.

## L'app

Le **planning d'un club de sport amateur** : les encadrants partagent les entraînements de leurs clubs et la liste des
présents, et chacun suit les entraînements qu'il anime.

- **Plateforme** : Next.js (App Router, TypeScript), avec Supabase pour les comptes et les données.
- **Écrans** : connexion ; mes clubs ; les entraînements d'un club ; les présents d'un entraînement ; mes
  entraînements à animer, tous clubs confondus ; l'invitation d'un membre par e-mail.

## Les données

Des migrations SQL dans `supabase/migrations/` :
- `clubs` (nom, sport), et `club_members` (club, utilisateur, rôle `owner`, `coach` ou `viewer`) ;
- `trainings` : un entraînement d'un club (titre, début, durée en minutes, lieu, nombre de places de 1 à 100, statut
  `prevu`, `fait` ou `annule`, l'encadrant qui l'anime, qui l'a créé) ;
- `attendances` : un participant à un entraînement (son nom, présent ou absent, le montant payé, qui l'a noté).

La RLS passe par l'appartenance au club : un membre voit les entraînements et les présents de ses clubs, jamais ceux
d'un autre club. Un `viewer` voit sans rien modifier. Seul le propriétaire d'un club invite ou retire un membre.

## Ce qui est attendu de la construction

- `npx tsc --noEmit`, `npm run lint` et `npm run build` passent.
- Un `package-lock.json` est commité ; aucun secret n'est commité, et un `.env.example` donne les noms des variables.
- Aucun assistant IA, aucune mention d'un kit d'assistant.
