# Fiche de forme 3 : une app « tout par fonctions » (Expo), cinquième examen

Cette fiche décrit une app à construire, sans la nommer, par une session qui n'a jamais vu vak. Son empreinte SHA-256
est publiée avant la construction ; la fiche l'est avec la règle, avant le tirage.

## L'app

Les **cartes de révision** d'une personne (langues, examens, culture…) : ses paquets de cartes, chaque carte, ses
révisions, et les cartes à revoir aujourd'hui.

- **Plateforme** : Expo (SDK courant, Expo Router, TypeScript), avec Supabase pour les comptes et les données.
- **Écrans** : connexion ; mes paquets ; les cartes d'un paquet, avec leurs révisions ; une nouvelle carte ; les
  cartes à revoir aujourd'hui. Dans l'app, une « révision » est toujours une ligne de `reviews`.

## Les données

Des migrations SQL dans `supabase/migrations/` :
- `decks` (nom, matière `langue`, `examen`, `culture` ou `autre`, le nombre de révisions faites dans le paquet,
  propriétaire), `cards` (le paquet, le recto, le verso, l'intervalle en jours avant la prochaine révision, un entier
  de 0 à 60, 0 pour une carte neuve, la date de la prochaine révision, le nombre de révisions réussies d'affilée,
  propriétaire) et `reviews` (la carte, la date de la révision, la réponse `ratee`, `difficile` ou `facile`, un mot
  facultatif, propriétaire). Un déclencheur sur `reviews` ajoute 1 au nombre de révisions du paquet de la carte à
  chaque nouvelle révision ; aucune fonction ne l'écrit autrement.
- **Toute écriture passe par des fonctions SQL** appelées en RPC, jamais par une écriture directe sur les tables.
  Leurs noms sont imposés ; leurs arguments sont à ton choix, sauf les deux objets `jsonb` indiqués :
  - `create_deck` : un nouveau paquet (son nom, sa matière : `autre` si elle n'est pas donnée) ;
  - `add_card` : une nouvelle carte dans un de mes paquets (recto, verso, la date du jour), à revoir ce jour-là ; elle
    refuse un recto déjà présent dans ce paquet ;
  - `edit_card(id uuid, changes jsonb)` (le recto, le verso), qui refuse un recto déjà porté par une autre carte du
    paquet ;
  - `review_card(id uuid, result jsonb)` (la réponse, la date de la révision, un mot facultatif) : elle écrit la
    révision dans `reviews` et met la carte à jour. Réussie (`difficile` ou `facile`), l'intervalle double (1 jour au
    moins, 60 au plus) et le compte d'affilée augmente de 1 ; ratée (`ratee`), l'intervalle revient à 1 et le compte
    à 0 ; la prochaine révision est à la date de la révision plus l'intervalle. Elle refuse une carte dont la
    prochaine révision est après la date de la révision ;
  - `delete_deck` : efface un paquet (avec la date du jour), ses cartes et leurs révisions, et refuse un paquet qui
    a encore une carte dont la prochaine révision est au plus tard cette date.

  Elles vérifient `auth.uid()` et rendent la ligne écrite en JSON (`review_card` : la carte mise à jour) ;
  `delete_deck` rend un entier : le nombre de lignes effacées, le paquet, ses cartes et leurs révisions compris.
- `cards_due(as_of date)` rend, pour chacune de mes cartes dont la prochaine révision est au plus tard `as_of`,
  l'identifiant de la carte, le nom du paquet, le recto, le verso et le nombre de jours de retard, sous forme de
  lignes. L'écran des cartes à revoir l'appelle avec la date du jour, puis appelle `review_card` pour chaque carte
  revue.

La RLS permet seulement la lecture de ses propres lignes ; elle n'accorde aucune écriture directe.

## Ce qui est attendu de la construction

- `npx tsc --noEmit` passe ; `npx expo export` passe pour le web.
- Un `package-lock.json` est commité ; aucun secret n'est commité, et un `.env.example` donne les noms des variables.
- Aucun assistant IA, aucune mention d'un kit d'assistant.
