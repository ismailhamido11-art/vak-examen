# Rapport — carnet des plantes d'intérieur

## Construit
App Expo (SDK 57, Expo Router, TypeScript) dans `app/`, branche `main`, avec Supabase (`@supabase/supabase-js`, session dans AsyncStorage).
- Écrans (`src/app/`) : `login` (connexion e-mail/mot de passe, création de compte), `index` (liste de mes plantes avec prochain arrosage), `plant/[id]` (fiche, arrosages, prochain arrosage, suppression), `add-plant`, `add-watering`. Garde d'authentification dans `_layout.tsx`.
- Logique : `src/lib/` (client Supabase, session, calcul des dates, petits composants).
- Migration `supabase/migrations/20261010120000_plants_waterings.sql` : tables `plants` et `waterings`, contraintes (lumière, fréquence 1–60, quantité > 0), RLS « propriétaire = auth.uid() » pour select/insert/update/delete.
- `.env.example` (URL et clé anonyme publiques), `.env` ignoré, `package-lock.json` commité.

## Choix faits seul
- Prochain arrosage = dernier arrosage (sinon date d'achat) + fréquence ; sans l'un ni l'autre, « pas de date de départ ».
- `waterings` a une clé étrangère composite `(plant_id, owner_id)` vers `plants(id, owner_id)` : impossible d'arroser la plante d'autrui, même avec la RLS seule.
- `owner_id` a pour défaut `auth.uid()` ; le client ne l'envoie pas.
- Dates saisies en texte AAAA-MM-JJ (pas de sélecteur de date, pour rester léger) ; lumière choisie par trois boutons.
- Sortie web en `single` (SPA) au lieu de `static` : le rendu statique plantait (`window is not defined`, stockage de session côté Node).
- Création de compte proposée sur l'écran de connexion (la fiche ne dit pas comment un compte naît).
- Supprimer une plante supprime ses arrosages (cascade). Pas de modification d'une plante ni d'un arrosage.
- Retiré du gabarit Expo : fichiers d'assistant (`AGENTS.md`, `.claude/`), écrans et assets de démonstration, `.vscode/`.
- Lint : `expo lint` configuré (eslint, eslint-config-expo) ; `app.json` renommé (`carnet-plantes`).

## Vérifications
- `npx tsc --noEmit` : passe.
- `npm run lint` : passe (0 erreur, 0 avertissement ; 2 erreurs d'apostrophes corrigées avant).
- `npx expo export --platform web` : passe (export dans `dist/`, ignoré par git).
- Migration sur base jetable PostgreSQL 16 (rôles `anon`/`authenticated`/`service_role`, schéma `auth` avec `users`, `uid()`, `role()`, `jwt()`) : appliquée sans erreur ; base supprimée ensuite.
- RLS, deux utilisateurs (rôle `authenticated`, `request.jwt.claims` posé) : A voit sa plante et son arrosage ; B voit 0 plante et 0 arrosage ; les UPDATE/DELETE de B touchent 0 ligne ; B ne peut insérer ni une plante au nom de A, ni un arrosage sur la plante de A (RLS et clé composite refusent) ; données de A intactes ensuite ; `anon` : permission refusée. Contraintes vérifiées : fréquence 61, lumière invalide, quantité 0 refusées.
- Aucun secret ni mention d'assistant dans les fichiers commités (recherche textuelle).

## Manque
- Pas lancé sur un appareil/émulateur ni contre un vrai Supabase (interdit) : les écrans sont vérifiés par typage, lint et export seulement.
- `npm audit` signale des vulnérabilités dans les dépendances transitives d'Expo, non traitées.
- Pas de tests automatisés de l'interface.

App construite au commit bea4192
