# Rapport — cartes de révision (Expo + Supabase)

## Construit
- `app/` : dépôt git neuf, branche `main`, Expo SDK 58 + Expo Router (`src/app/`), TypeScript strict, `package-lock.json` commité.
- Écrans : connexion/inscription ; mes paquets (création, accès aux cartes à revoir) ; cartes d'un paquet avec leurs
  révisions (lignes de `reviews`), modification d'une carte, suppression du paquet ; nouvelle carte ; cartes à revoir
  aujourd'hui (verso, mot facultatif, ratée/difficile/facile).
- Migrations : `20261022130000_tables.sql` (tables, index, déclencheur de compteur, RLS lecture seule, révocation des
  écritures) et `20261022130100_functions.sql` (`create_deck`, `add_card`, `edit_card`, `review_card`, `delete_deck`, `cards_due`).
- `.env.example` (`EXPO_PUBLIC_SUPABASE_URL`, `EXPO_PUBLIC_SUPABASE_ANON_KEY`) ; `.env` ignoré.

## Choix faits seul
- Gabarit `blank-typescript` de create-expo-app, auquel j'ai ajouté Expo Router ; j'ai retiré du gabarit les fichiers
  d'assistant (AGENTS.md, .claude/), App.tsx, index.ts et LICENSE.
- Arguments des fonctions : `create_deck(p_name, p_subject default 'autre')`, `add_card(p_deck_id, p_front, p_back, p_today)`,
  `delete_deck(p_deck_id, p_today)`, `cards_due(as_of)`. `result` de `review_card` : `{answer, date, note?}` ; `changes` de
  `edit_card` : `{front?, back?}` (toute autre clé est refusée).
- Fonctions en `security definer` avec `search_path = ''`, `auth.uid()` vérifié, exécution réservée à `authenticated` ; `cards_due` en `security invoker` (RLS + filtre).
- Une carte d'un autre utilisateur ou un paquet inconnu donnent « introuvable » (pas de fuite d'existence).
- Recto/verso sont rognés (`btrim`) et non vides ; l'unicité du recto est par paquet (contrainte `unique` + test explicite).
- `review_card` : date obligatoire ; carte neuve (intervalle 0) réussie → 1 jour ; verrou de ligne `for update`.
- `delete_deck` rend 1 + cartes + révisions effacées ; il refuse si une carte a `due_date <= date du jour` (donc un paquet
  contenant une carte neuve du jour ne se supprime pas avant le lendemain, conformément à la fiche).
- Date du jour : date locale de l'appareil, passée explicitement aux fonctions.
- Inscription e-mail + mot de passe ; si la confirmation par e-mail est active, l'écran le signale.
- Garde de routes via `Stack.Protected`. Sans `.env`, l'écran de connexion affiche un message de configuration.
- Base de vérification : une base `jetable` et les rôles `anon`/`authenticated`/`service_role` existaient déjà sur le serveur
  (pas les miens) ; je n'ai pas touché à `jetable`, j'ai créé et supprimé ma propre base `cartes_verif_*`, et réutilisé les rôles existants.

## Vérifications
| Commande | Résultat |
|---|---|
| `npx tsc --noEmit` | passe (code 0) |
| `npx expo lint` | passe (code 0, après correction de 4 apostrophes JSX) |
| `npx expo export --platform web` | passe, `dist/` produit (non commité, ignoré) |
| Stub Supabase (rôles, `auth.users`, `uid/role/jwt`) puis les 2 migrations dans l'ordre sur base neuve | appliquées sans erreur |
| Scénario SQL (`verif/test.sql`, rôle `authenticated`, `request.jwt.claims` posé) | voir ci-dessous |
| Base jetable supprimée | oui |

Scénario SQL, résultats observés :
- `create_deck` (matière par défaut `autre`), `add_card`, `edit_card`, `review_card`, `cards_due`, `delete_deck` appelées au moins une fois.
- Doublon de recto refusé à `add_card` et `edit_card` ; clé inconnue refusée à `edit_card`.
- `review_card` : facile 0→1 j, puis 2 j ; ratée → 1 j, streak 0, échéance = date + intervalle ; carte non échue refusée.
- `reviews_count` du paquet = 3 après 3 révisions ; `cards_due` rend 2 cartes avec 2 jours de retard.
- Écritures directes (insert/update/delete sur les 3 tables, appel du déclencheur) : « permission denied ».
- Utilisateur B : voit 0 paquet, 0 carte, 0 révision, 0 carte due ; `add_card`, `edit_card`, `review_card`, `delete_deck`
  sur les objets de A → « introuvable » ; B crée son propre paquet sans problème.
- `delete_deck` : refusé tant qu'une carte est due ; accepté sinon, a rendu 7 (1 paquet + 2 cartes + 4 révisions) et
  laissé 0 ligne dans les trois tables.
- `anon` : « permission denied » sur les fonctions et les tables.

## Ce qui manque
- Pas d'essai contre un vrai Supabase (interdit) : la partie auth/réseau de l'app n'a été vérifiée que par typage, lint et export,
  pas exécutée de bout en bout. Pas de tests automatisés dans le dépôt (le script de vérification SQL est dans `verif/`, hors `app/`).

App construite au commit ab67170
