# Fiche de forme 1 : une app qui démarre (Expo), deuxième examen

Cette fiche décrit une app à construire, sans la nommer, par une session qui n'a jamais vu vak. Elle est publiée avec
son empreinte SHA-256 avant la construction.

## L'app

Le **carnet des plantes d'intérieur** d'une personne : ses plantes, et chaque arrosage.

- **Plateforme** : Expo (SDK courant, Expo Router, TypeScript), avec Supabase pour les comptes et les données.
- **Écrans** : connexion par e-mail et mot de passe ; la liste de mes plantes ; la fiche d'une plante, avec ses
  arrosages et la date du prochain ; l'ajout d'une plante ; l'ajout d'un arrosage.
- **Taille** : celle d'une app qui démarre, autour de 10 fichiers d'écrans et de logique.

## Les données

Une migration SQL dans `supabase/migrations/` :
- `plants` : nom, espèce, pièce, lumière (`faible`, `moyenne`, `forte`), fréquence d'arrosage en jours (de 1 à 60),
  date d'achat, propriétaire (`auth.users`) ;
- `waterings` : la plante, la date, la quantité en millilitres (positive), une note libre, le propriétaire.

Chaque table a la RLS : un utilisateur ne voit et ne modifie que ses lignes.

## Ce qui est attendu de la construction

- `npx tsc --noEmit` passe ; `npx expo export` passe pour le web.
- Un `package-lock.json` est commité ; aucun secret n'est commité, et un `.env.example` donne les noms des variables.
- Aucun assistant IA, aucune mention d'un kit d'assistant.
