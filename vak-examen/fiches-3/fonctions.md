# Fiche de forme 3 : une app « tout par fonctions » (Expo), troisième examen

Cette fiche décrit une app à construire, sans la nommer, par une session qui n'a jamais vu vak. Elle est publiée avec
son empreinte SHA-256 avant la construction.

## L'app

Le **suivi des abonnements** d'une personne (musique, sport, téléphone…) : ses abonnements, chaque paiement, et la
dépense du mois.

- **Plateforme** : Expo (SDK courant, Expo Router, TypeScript), avec Supabase pour les comptes et les données.
- **Écrans** : connexion ; mes abonnements ; les paiements d'un abonnement ; l'ajout d'un paiement ; la dépense du
  mois par abonnement.

## Les données

Des migrations SQL dans `supabase/migrations/` :
- `subscriptions` (nom, catégorie `loisirs`, `maison`, `travail` ou `autre`, montant mensuel, jour du prélèvement
  de 1 à 28, actif ou non, propriétaire) et `payments` (abonnement, date, montant, moyen `carte`, `prelevement` ou
  `especes`, propriétaire).
- **Toute écriture passe par des fonctions SQL** appelées en RPC, jamais par une écriture directe sur les tables :
  - `create_subscription(name text, category text, monthly_amount numeric, billing_day int)` ;
  - `update_subscription(id uuid, changes jsonb)` ;
  - `cancel_subscription(id uuid)`, qui rend l'abonnement inactif sans rien effacer ;
  - `record_payment(subscription_id uuid, details jsonb)` (la date, le montant, le moyen) ;
  - `delete_payment(id uuid)`.

  Elles vérifient `auth.uid()`, refusent un paiement sur un abonnement inactif ou d'un montant nul ou négatif, et
  rendent la ligne écrite en JSON.
- `month_spending(month date)` rend, pour chaque abonnement, le total payé dans le mois, sous forme de lignes (nom,
  total).

La RLS permet seulement la lecture de ses propres lignes ; elle n'accorde aucune écriture directe.

## Ce qui est attendu de la construction

- `npx tsc --noEmit` passe ; `npx expo export` passe pour le web.
- Un `package-lock.json` est commité ; aucun secret n'est commité, et un `.env.example` donne les noms des variables.
- Aucun assistant IA, aucune mention d'un kit d'assistant.
