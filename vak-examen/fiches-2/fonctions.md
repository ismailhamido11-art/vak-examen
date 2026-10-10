# Fiche de forme 3 : une app « tout par fonctions » (Expo), deuxième examen

Cette fiche décrit une app à construire, sans la nommer, par une session qui n'a jamais vu vak. Elle est publiée avec
son empreinte SHA-256 avant la construction.

## L'app

Les **relevés de compteurs d'un logement** : on note ses relevés d'eau, d'électricité et de gaz, et on suit la
consommation du mois.

- **Plateforme** : Expo (SDK courant, Expo Router, TypeScript), avec Supabase pour les comptes et les données.
- **Écrans** : connexion ; mes compteurs ; les relevés d'un compteur ; l'ajout d'un relevé ; la consommation du mois
  par compteur.

## Les données

Des migrations SQL dans `supabase/migrations/` :
- `meters` (nom, type `eau`, `electricite` ou `gaz`, unité, propriétaire) et `readings` (compteur, date, valeur,
  propriétaire).
- **Toute écriture passe par des fonctions SQL** appelées en RPC, jamais par une écriture directe sur les tables :
  - `add_reading(payload jsonb)` ;
  - `update_reading(id uuid, payload jsonb)` ;
  - `delete_reading(id uuid)` ;
  - `upsert_meter(payload jsonb)`.

  Elles vérifient `auth.uid()`, refusent un relevé plus petit que le précédent du même compteur, et rendent la ligne
  écrite en JSON.
- `month_consumption(month date)` rend la consommation du mois par compteur, en JSON.

La RLS permet seulement la lecture de ses propres lignes ; elle n'accorde aucune écriture directe.

## Ce qui est attendu de la construction

- `npx tsc --noEmit` passe ; `npx expo export` passe pour le web.
- Un `package-lock.json` est commité ; aucun secret n'est commité, et un `.env.example` donne les noms des variables.
- Aucun assistant IA, aucune mention d'un kit d'assistant.
