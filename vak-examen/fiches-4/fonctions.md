# Fiche de forme 3 : une app « tout par fonctions » (Expo), quatrième examen

Cette fiche décrit une app à construire, sans la nommer, par une session qui n'a jamais vu vak. Son empreinte SHA-256
est publiée avant la construction ; la fiche l'est avec la règle, avant le tirage.

## L'app

Les **prêts d'objets** d'une personne à ses proches (livres, outils, jeux…) : ses objets, chaque prêt, et les prêts
en retard.

- **Plateforme** : Expo (SDK courant, Expo Router, TypeScript), avec Supabase pour les comptes et les données.
- **Écrans** : connexion ; mes objets ; les prêts d'un objet ; un nouveau prêt ; les prêts en retard.

## Les données

Des migrations SQL dans `supabase/migrations/` :
- `items` (nom, catégorie `livre`, `outil`, `jeu` ou `autre`, le nombre de fois prêté, propriétaire) et `loans`
  (l'objet, le nom de l'emprunteur, la date du prêt, la date de retour prévue, la date de retour réelle, un mot sur
  l'état rendu, propriétaire). Un déclencheur sur `loans` ajoute 1 au nombre de fois prêté de l'objet à chaque
  nouveau prêt ; aucune fonction ne l'écrit autrement.
- **Toute écriture passe par des fonctions SQL** appelées en RPC, jamais par une écriture directe sur les tables.
  Leurs noms sont imposés ; leurs arguments sont à ton choix, sauf les deux objets `jsonb` indiqués :
  - `add_item` : un nouvel objet (son nom, sa catégorie) ;
  - `rename_item(id uuid, changes jsonb)` (le nom, la catégorie) ;
  - `lend_item` : prête un objet à un emprunteur pour une durée en jours (14 si elle n'est pas donnée), et refuse un
    objet déjà prêté ;
  - `return_loan(id uuid, details jsonb)` (la date de retour réelle, un mot sur l'état rendu), qui refuse un prêt
    déjà rendu ;
  - `forget_item` : efface l'objet et ses prêts rendus, et refuse un objet encore prêté.

  Elles vérifient `auth.uid()` et rendent la ligne écrite en JSON ; `forget_item` rend un entier : le nombre de
  lignes effacées, l'objet et ses prêts compris.
- `overdue_loans(as_of date)` rend, pour chacun de mes prêts non rendus dont la date de retour prévue est avant
  `as_of`, le nom de l'objet, l'emprunteur et le nombre de jours de retard, sous forme de lignes. L'écran des prêts en
  retard l'appelle avec la date du jour.

La RLS permet seulement la lecture de ses propres lignes ; elle n'accorde aucune écriture directe.

## Ce qui est attendu de la construction

- `npx tsc --noEmit` passe ; `npx expo export` passe pour le web.
- Un `package-lock.json` est commité ; aucun secret n'est commité, et un `.env.example` donne les noms des variables.
- Aucun assistant IA, aucune mention d'un kit d'assistant.
