# Fiche de forme 1 : une app qui démarre (Expo), troisième examen

Cette fiche décrit une app à construire, sans la nommer, par une session qui n'a jamais vu vak. Elle est publiée avec
son empreinte SHA-256 avant la construction.

## L'app

Le **carnet de cuisine** d'une personne : ses recettes, et chaque fois qu'elle en a cuisiné une.

- **Plateforme** : Expo (SDK courant, Expo Router, TypeScript), avec Supabase pour les comptes et les données.
- **Écrans** : connexion par e-mail et mot de passe ; la liste de mes recettes, les favorites d'abord ; la fiche d'une
  recette, avec les fois où je l'ai cuisinée ; l'ajout d'une recette ; l'ajout d'une fois cuisinée, avec sa note.
- **Taille** : celle d'une app qui démarre, autour de 10 fichiers d'écrans et de logique.

## Les données

Une migration SQL dans `supabase/migrations/` :
- `recipes` : titre, catégorie (`entree`, `plat`, `dessert` ou `boisson`), temps de préparation en minutes (de 1 à
  600), nombre de portions (de 1 à 20), favorite ou non, des mots-clés libres (une liste de textes), propriétaire
  (`auth.users`) ;
- `cookings` : la recette, la date, la note de 1 à 5, un commentaire libre, le propriétaire.

Chaque table a la RLS : un utilisateur ne voit et ne modifie que ses lignes.

## Ce qui est attendu de la construction

- `npx tsc --noEmit` passe ; `npx expo export` passe pour le web.
- Un `package-lock.json` est commité ; aucun secret n'est commité, et un `.env.example` donne les noms des variables.
- Aucun assistant IA, aucune mention d'un kit d'assistant.
