# Fiche de forme 1 : une app qui démarre (Expo), cinquième examen

Cette fiche décrit une app à construire, sans la nommer, par une session qui n'a jamais vu vak. Son empreinte SHA-256
est publiée avant la construction ; la fiche l'est avec la règle, avant le tirage.

## L'app

Le **carnet de randonnée** d'une personne : ses itinéraires, et chaque fois qu'elle en a parcouru un.

- **Plateforme** : Expo (SDK courant, Expo Router, TypeScript), avec Supabase pour les comptes et les données.
- **Écrans** : connexion par e-mail et mot de passe ; la liste de mes itinéraires, par région ; la fiche d'un
  itinéraire, avec ses sorties ; l'ajout d'un itinéraire ; l'ajout d'une sortie.
- **Taille** : celle d'une app qui démarre, autour de 10 fichiers d'écrans et de logique.

## Les données

Une migration SQL dans `supabase/migrations/` :
- `trails` : nom, région, distance en kilomètres (un nombre décimal, strictement positif), dénivelé positif en mètres
  (un entier de 0 à 9 000), difficulté (un type énuméré PostgreSQL : `facile`, `moyenne`, `difficile` ou `experte`),
  boucle ou non (un booléen), propriétaire (`auth.users`) ;
- `outings` : l'itinéraire, la date et l'heure du départ, la durée en minutes (facultative, de 1 à 1 440), la météo
  (`soleil`, `nuages`, `pluie` ou `neige`), une note de 1 à 5, les prénoms des accompagnants (une liste de textes,
  vide si seule), un commentaire libre, le propriétaire.

Chaque table a la RLS : un utilisateur ne voit et ne modifie que ses lignes.

## Ce qui est attendu de la construction

- `npx tsc --noEmit` passe ; `npx expo export` passe pour le web.
- Un `package-lock.json` est commité ; aucun secret n'est commité, et un `.env.example` donne les noms des variables.
- Aucun assistant IA, aucune mention d'un kit d'assistant.
