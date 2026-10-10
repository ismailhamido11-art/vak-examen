# Rapport de construction : relevés de compteurs

Commit final : `5c12ec9` (branche `main`, `git status` propre).

## Ce qui est construit

App Expo SDK 57 (Expo Router, TypeScript strict, création par `npx create-expo-app@latest`) avec Supabase.

**Écrans** (`app/src/app/`)
- `login` : connexion et création de compte (e-mail et mot de passe).
- `(app)/index` : mes compteurs, avec création d'un compteur.
- `(app)/meter/[id]` : relevés d'un compteur, avec modification et suppression.
- `(app)/reading/edit` : ajout d'un relevé (`meterId`) ou modification (`readingId`).
- `(app)/consumption` : consommation du mois par compteur, avec navigation de mois en mois.
- Les routes `(app)` sont protégées par `Stack.Protected` : sans session, seul `login` est accessible.

**Données** (`app/supabase/migrations/`)
- `20261010150000_meters_readings.sql` : tables `meters` et `readings`, contraintes, index, RLS. Seules des policies `select` sont créées pour `authenticated`. Les droits d'écriture directe sont retirés (`revoke all` puis `grant select`).
- `20261010150100_rpc_functions.sql` : `add_reading(payload)`, `update_reading(id, payload)`, `delete_reading(id)`, `upsert_meter(payload)` et `month_consumption(month)`. Elles sont `security definer`, avec `search_path` vide, et vérifient `auth.uid()`. Elles rendent la ligne écrite en JSON. Exécution réservée à `authenticated` (retirée à `public` et `anon`).

**Client** (`app/src/lib/`) : `supabase.ts` (client paresseux configuré par les variables publiques), `api.ts` (lectures via `select`, écritures uniquement via `rpc`), `auth.tsx`, `format.ts`, `use-load.ts`, `types.ts`.

## Choix faits seul

- **Colonne de date** : `read_on`. Le payload utilise `meter_id`, `read_on` et `value`. `read_on` vaut la date du jour s'il est omis à l'ajout.
- **Règle « pas plus petit que le précédent »** : le « précédent » est le plus grand relevé du compteur à une date antérieure ou égale. En plus, un relevé ne peut pas dépasser le suivant (date postérieure). Le contrôle vaut aussi pour `update_reading`. L'égalité est acceptée. Le compteur est verrouillé (`for update`) pendant l'écriture pour éviter les courses.
- **Consommation du mois** : dernier relevé du mois moins le dernier relevé avant le mois. À défaut de relevé antérieur, c'est le premier relevé du mois. Un compteur sans relevé dans le mois donne `consumption: null`, et il reste listé. Le résultat est un tableau JSON : `meter_id`, `name`, `type`, `unit`, `readings_count`, `start_value`, `end_value`, `consumption`. N'importe quelle date du mois est acceptée (`date_trunc`).
- **Erreurs** : une ligne d'un autre utilisateur donne « introuvable » (`P0002`), pour ne pas révéler son existence. Pas d'auth : `28000`. Relevé non croissant : `23514`.
- **Mises à jour de compteur** : `upsert_meter` sans `id` crée le compteur. Avec `id`, il modifie un compteur du propriétaire. Le propriétaire est toujours `auth.uid()`, jamais lu dans le payload.
- **Sortie web en `single`** et non `static`. L'app est derrière une connexion, et le rendu statique casse avec le stockage de session. J'ai aussi remplacé `use-color-scheme.web.ts`, qui n'était utile qu'à l'hydratation statique, par le hook de base.
- **Client Supabase paresseux**. Sans variables d'environnement, l'export et le typage passent, et l'écran de connexion affiche un message de configuration.
- **Inscription par e-mail et mot de passe**, avec message si une confirmation par e-mail est demandée. Rien n'est créé en vrai : aucun projet Supabase n'est contacté.
- **Nettoyage du modèle Expo** : j'ai retiré le contenu de démonstration, `AGENTS.md` et `.claude/settings.json`. La fiche exclut toute mention d'un kit d'assistant. Le modèle les fournissait.
- **Interface** : composants simples maison (`src/components/ui.tsx`), thème clair ou sombre du modèle, textes en français.
- **Unité** : champ libre, préremplie selon le type (m³, kWh, m³).
- `.gitignore` : ajout de `.env`. Le modèle n'ignorait que `.env*.local`.

## Vérifications

| Commande | Résultat |
|---|---|
| `npx tsc --noEmit` | passe, sans erreur |
| `npx expo lint` | passe, sans erreur ni avertissement |
| `npx expo export --platform web` | passe (« Exported: dist »), `dist/` supprimé ensuite |
| Migrations sur base jetable `verif_tmp` (PostgreSQL 16, `psql -v ON_ERROR_STOP=1`) | les 2 migrations s'appliquent dans l'ordre. Prérequis écrits d'abord : rôles `anon`, `authenticated`, `service_role` ; schéma `auth` avec `users`, `uid()`, `role()` et `jwt()`. Base supprimée ensuite. |
| RLS et RPC avec deux utilisateurs (rôle `authenticated`, `request.jwt.claims` posé) | voir ci-dessous |

Détail du test RLS et RPC :
- A crée un compteur et 3 relevés. Un relevé inférieur au précédent est refusé (50 après 125). Une modification sous le précédent est refusée (90 < 110). Une modification valide passe (130).
- `month_consumption` d'octobre rend 30 (de 100 à 130, 2 relevés), comme attendu.
- A tente `insert`, `update` et `delete` directs sur `readings` : « permission denied ».
- B voit 0 compteur, 0 relevé et une consommation vide. B ne peut ni modifier, ni supprimer, ni ajouter de relevé, ni modifier le compteur de A (« introuvable »). Ses `update` et `delete` directs sont refusés.
- Sans claims : « authentification requise ». Rôle `anon` : accès refusé aux tables et aux fonctions.
- En superuser, l'état final est intact (le compteur de A et ses relevés). A peut supprimer son propre relevé.

Pas testé : le test se limite à PostgreSQL 16 avec un faux schéma `auth`. L'app n'a pas été lancée contre un vrai Supabase (interdit), et aucun test visuel n'a été fait sur navigateur ou appareil.

## Ce qui manque

- Rien de ce que demande la fiche. Pas de tests automatisés dans le dépôt : les vérifications SQL ont été faites à la main sur une base jetable, puis le script a été jeté.
- `npm install` signale des alertes `npm audit` dans des dépendances transitives d'Expo. Je ne les ai pas traitées (`audit fix --force` casserait les versions du SDK).
