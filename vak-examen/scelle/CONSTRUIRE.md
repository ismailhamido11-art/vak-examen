# Consigne : construire une app

Tu construis, seul, l'app décrite dans `FICHE.md`, dans ce dossier. Personne ne répondra pendant ton travail : ne pose
aucune question et n'attends personne. Ce que la fiche ne dit pas, tranche-le comme le ferait un développeur, et
note-le dans ton compte rendu.

## Où et comment

- L'app est un dépôt git neuf dans `app/`, sur la branche `main`. Commite au fil du travail, avec des messages clairs.
  À la fin, `git status` est propre.
- Suis la fiche : la plateforme, les écrans, les données, et tout ce qui est « attendu de la construction ».
- Outils : Node 22 et npm, avec le registre npm. Crée l'app avec l'outil officiel de sa plateforme
  (`npx create-expo-app@latest` ou `npx create-next-app@latest`), en TypeScript.
- Données : Supabase.
  - Le client est `@supabase/supabase-js`, configuré par les variables publiques de la plateforme : l'URL du projet
    et la clé anonyme.
  - Elles sont lues depuis `.env` (non commité) et décrites dans `.env.example`.
- Migrations : dans `supabase/migrations/`, nommées comme la CLI Supabase les crée (`<AAAAMMJJHHMMSS>_<nom>.sql`),
  jouées dans l'ordre.

## Vérifier avant de finir

1. Les commandes de la fiche passent : typage, lint, build ou export.
2. Les migrations s'appliquent dans l'ordre sur une base neuve. Un PostgreSQL 16 tourne en local : 127.0.0.1:5432,
   super-utilisateur `root`, mot de passe dans `~/.pgpass`.
   - Crée une base jetable.
   - Écris d'abord le minimum de Supabase que les migrations attendent : les rôles `anon`, `authenticated` et
     `service_role` ; le schéma `auth`, avec `users`, `uid()`, `role()` et `jwt()`.
   - Applique les migrations, puis supprime la base.
3. La RLS fait ce que dit la fiche. Sur cette base, avec deux utilisateurs (rôle `authenticated`,
   `request.jwt.claims` posé), vérifie qu'aucun ne voit ni ne modifie les lignes de l'autre. Pour une équipe :
   celles d'une autre équipe.

## Interdits

- Aucun secret commité : ni clé, ni mot de passe, ni `.env`.
- Aucun vrai projet Supabase, aucun déploiement, aucun compte créé où que ce soit.
- Aucun assistant IA dans l'app.

## À la fin

Écris `RAPPORT.md` dans ce dossier, hors de `app/` :
- ce qui est construit ;
- les choix faits seul ;
- chaque commande de vérification et son résultat ;
- ce qui manque, s'il manque quelque chose.

Termine par une seule ligne : « App construite au commit <sha> ».
