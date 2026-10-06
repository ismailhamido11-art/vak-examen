# Fiche de forme 1 : une app qui démarre (Expo)

Cette fiche décrit une app à construire, sans la nommer, par une session qui n'a jamais vu vak. Elle est publiée avec
son empreinte SHA-256 avant la construction.

## L'app

Un **carnet de lecture** personnel : on y note les livres qu'on lit, et ses séances de lecture.

- **Plateforme** : Expo (SDK courant, Expo Router, TypeScript), avec Supabase pour les comptes et les données.
- **Écrans** : connexion par e-mail et mot de passe ; la liste de mes livres ; la fiche d'un livre, avec ses séances ;
  l'ajout d'un livre ; l'ajout d'une séance.
- **Taille** : celle d'une app qui démarre, autour de 10 fichiers d'écrans et de logique.

## Les données

Une migration SQL dans `supabase/migrations/` :
- `books` : titre, auteur, statut (`a_lire`, `en_cours`, `lu`), date d'ajout, propriétaire (`auth.users`) ;
- `reading_sessions` : le livre, la date, le nombre de pages lues, une note libre, le propriétaire.

Chaque table a la RLS : un utilisateur ne voit et ne modifie que ses lignes.

## Ce qui est attendu de la construction

- `npx tsc --noEmit` passe ; `npx expo export` passe pour le web.
- Un `package-lock.json` est commité ; aucun secret n'est commité, et un `.env.example` donne les noms des variables.
- Aucun assistant IA, aucune mention d'un kit d'assistant.
