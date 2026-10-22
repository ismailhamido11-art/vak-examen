# Fiche de forme 2 : une app d'équipe (Next.js), cinquième examen

Cette fiche décrit une app à construire, sans la nommer, par une session qui n'a jamais vu vak. Son empreinte SHA-256
est publiée avant la construction ; la fiche l'est avec la règle, avant le tirage.

## L'app

Les **spectacles d'une troupe de théâtre amateur** : les membres partagent les spectacles de leurs troupes et leur
distribution ; un personnage a un titulaire et, s'il le faut, une doublure, et chacun suit les personnages dont il est
titulaire.

- **Plateforme** : Next.js (App Router, TypeScript), avec Supabase pour les comptes et les données.
- **Écrans** : connexion ; mes troupes ; les spectacles d'une troupe ; un spectacle et ses personnages, avec leur
  titulaire et leur doublure ; mes personnages à apprendre (ceux dont je suis titulaire, statut `a_apprendre` ou
  `en_cours`), toutes troupes confondues ; l'invitation d'un membre par e-mail.

## Les données

Des migrations SQL dans `supabase/migrations/` :
- `troupes` (nom, ville), et `troupe_members` (troupe, utilisateur, rôle `owner`, `actor` ou `viewer`) ;
- `shows` : un spectacle d'une troupe (titre, auteur de la pièce, date de la première, facultative, statut
  `en_preparation`, `a_l_affiche` ou `termine`, qui l'a créé) ;
- `characters` : un personnage d'un spectacle (son nom, le nombre de répliques de 1 à 2 000, statut `a_apprendre`,
  `en_cours` ou `su`, le titulaire et la doublure, deux membres de la troupe, des clés vers `auth.users`, facultatifs
  tant que le personnage n'est pas distribué, qui l'a créé).

La RLS passe par l'appartenance à la troupe : un membre voit les spectacles et les personnages de ses troupes, jamais
ceux d'une autre troupe. Un `viewer` voit sans rien modifier, et ne joue aucun personnage ; le propriétaire et les
`actor` peuvent jouer. Seul le propriétaire d'une troupe invite ou retire un membre.

## Ce qui est attendu de la construction

- `npx tsc --noEmit`, `npm run lint` et `npm run build` passent.
- Un `package-lock.json` est commité ; aucun secret n'est commité, et un `.env.example` donne les noms des variables.
- Aucun assistant IA, aucune mention d'un kit d'assistant.
