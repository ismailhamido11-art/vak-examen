# Fiche de forme 3 : une app « tout par fonctions » (Expo)

Cette fiche décrit une app à construire, sans la nommer, par une session qui n'a jamais vu vak. Elle est publiée avec
son empreinte SHA-256 avant la construction.

## L'app

Le **budget d'un foyer** : on note ses dépenses par catégorie, et on suit le total du mois.

- **Plateforme** : Expo (SDK courant, Expo Router, TypeScript), avec Supabase pour les comptes et les données.
- **Écrans** : connexion ; les dépenses du mois ; l'ajout d'une dépense ; les catégories ; le total par catégorie.

## Les données

Des migrations SQL dans `supabase/migrations/` :
- `categories` (nom, plafond mensuel, propriétaire) et `expenses` (montant, date, libellé, catégorie, propriétaire).
- **Toute écriture passe par des fonctions SQL** appelées en RPC, jamais par une écriture directe sur les tables :
  - `add_expense(payload jsonb)` ;
  - `update_expense(id uuid, payload jsonb)` ;
  - `delete_expense(id uuid)` ;
  - `upsert_category(payload jsonb)`.

  Elles vérifient `auth.uid()` et rendent la ligne écrite en JSON.
- `month_summary(month date)` rend le total par catégorie en JSON.

La RLS permet seulement la lecture de ses propres lignes ; elle n'accorde aucune écriture directe.

## Ce qui est attendu de la construction

- `npx tsc --noEmit` passe ; `npx expo export` passe pour le web.
- Un `package-lock.json` est commité ; aucun secret n'est commité, et un `.env.example` donne les noms des variables.
- Aucun assistant IA, aucune mention d'un kit d'assistant.
