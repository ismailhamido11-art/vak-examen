# Fiche de forme 1 : une app qui démarre (Expo), quatrième examen

Cette fiche décrit une app à construire, sans la nommer, par une session qui n'a jamais vu vak. Son empreinte SHA-256
est publiée avant la construction ; la fiche l'est avec la règle, avant le tirage.

## L'app

La **collection de disques vinyles** d'une personne : ses disques, et chaque fois qu'elle en a écouté un.

- **Plateforme** : Expo (SDK courant, Expo Router, TypeScript), avec Supabase pour les comptes et les données.
- **Écrans** : connexion par e-mail et mot de passe ; la liste de mes disques, par artiste ; la fiche d'un disque,
  avec ses écoutes ; l'ajout d'un disque ; l'ajout d'une écoute.
- **Taille** : celle d'une app qui démarre, autour de 10 fichiers d'écrans et de logique.

## Les données

Une migration SQL dans `supabase/migrations/` :
- `vinyls` : titre, artiste, année de sortie (de 1900 à 2100), état du disque (un type énuméré PostgreSQL : `neuf`,
  `tres_bon`, `bon` ou `abime`), des genres (une liste de textes), prix d'achat en euros (facultatif, positif ou
  nul), propriétaire (`auth.users`) ;
- `listenings` : le disque, la date et l'heure de l'écoute, la face écoutée (`A`, `B` ou `AB` pour les deux), une
  note de 1 à 5, un commentaire libre, le propriétaire.

Chaque table a la RLS : un utilisateur ne voit et ne modifie que ses lignes.

## Ce qui est attendu de la construction

- `npx tsc --noEmit` passe ; `npx expo export` passe pour le web.
- Un `package-lock.json` est commité ; aucun secret n'est commité, et un `.env.example` donne les noms des variables.
- Aucun assistant IA, aucune mention d'un kit d'assistant.
