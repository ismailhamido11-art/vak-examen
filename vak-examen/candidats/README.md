# Liste des apps éligibles à l'examen

## Comment les dépôts ont été trouvés

Le 04/10/2026, par recherche web (outil WebSearch), avec des requêtes du type « github Next.js Supabase … » ou
« github Expo React Native Supabase … » : fitness/sport, finance/budget, santé/médicaments/habitudes, éducation,
jeux/classements, outils d'équipe (kanban), partage de dépenses, notes, réservation/CRM/facturation, kits SaaS.
L'API de recherche de GitHub n'était pas accessible depuis cette machine : les dépôts viennent donc des seuls résultats
du moteur web, qui favorisent ce que le moteur indexe. Les URL examinées sont toutes dans `candidats.tsv`, éligibles ou
non (80 dépôts ; `bajerskim11-eng/ClinicBook` et `Servixa-cloud/ClinicBook` sont probablement le même dépôt renommé).

## `verifier.mjs`

`node candidats/verifier.mjs <url> <dossier de travail>` (ou, depuis le 06/10, `SOURCE=<dépôt git local> node
candidats/verifier.mjs construite-<forme> <dossier>` pour une app construite, pas encore publiée : mêmes critères, sauf
public et fork) : clone en profondeur 1, juge, rend une ligne JSON
(`url`, `commit`, `date`, `plateforme`, `tables_a_moi` [liste de `schéma.table`], `eligible`, `raisons`), puis supprime
le clone (sauf `GARDER=1`), la base `cand_*` et les rôles créés par les migrations. `raisons` contient les motifs
d'inéligibilité, puis les remarques préfixées par `note :`. Les exclusions sont lues dans `../exclusions.txt`
(ou la variable `EXCLUSIONS`).

Critères tels qu'appliqués :
1. URL github.com ; clonable sans identifiants (donc public) ; pas un fork, par l'API GitHub quand elle répond.
2. Un `package.json` (jusqu'à 6 niveaux, hors `node_modules`) dépend de `next` ou `expo` (dependencies, dev, peer,
   optional). Les deux : `expo`, avec une note.
3. Un dossier `supabase/migrations` avec des `.sql`, à la racine ou à trois niveaux au plus.
4. Tables « à moi » : après application des migrations, les tables hors schémas système qui ont une clé étrangère vers
   `auth.users`, ou vers la table du compte (celle dont la clé primaire référence `auth.users`), ou une colonne par
   défaut `auth.uid()`, ou une colonne comparée à `auth.uid()` dans une politique (`col = auth.uid()`, avec
   `select`, parenthèses et conversions tolérés).
5. `engines.node` du `package.json` racine et de ceux qui dépendent de next/expo : plage semver (`||`, `^`, `~`,
   `>=`, `x`, intervalle) évaluée pour Node 22.22.0. Une plage non comprise est supposée compatible, avec une note.
6. Dernier commit (date du committer) le 30/03/2025 ou après.
7. Migrations appliquées dans l'ordre (seuls les fichiers `<version>_<nom>.sql`, comme la CLI Supabase), avec `psql`,
   sur une base neuve, en session `postgres`. Amorçage Supabase minimal : rôles `anon`, `authenticated`,
   `service_role` (+ `postgres`, `supabase_admin` s'ils manquent) ; schéma `auth` (`users`, `uid()`, `role()`, `email()`,
   `jwt()`) ; schéma `storage` (`buckets`, `objects`, `foldername/filename/extension`) ; schéma `extensions` avec
   `uuid-ossp` et `pgcrypto`. J'y ai ajouté, parce que des migrations les attendent : le schéma `realtime`
   (`messages`, `topic()`) et la publication `supabase_realtime`.
   Une erreur due à une extension absente (`vector`, `http`, `pg_net`, `pg_cron`, `pgjwt`, `pgsodium`,
   `supabase_vault`, `pg_graphql`, `wrappers`) est notée sans rendre l'app inéligible ; les erreurs « n'existe pas »
   qui la suivent dans la même base sont tolérées, avec une note. Toute autre erreur rend l'app inéligible.
8. Exclusions : `exclusions.txt` (dépôt et propriétaire), `chatbot-ui`, `expo-ai`, organisations `supabase` et
   `supabase-community`.

## Limites

- **Fork non vérifié pour la plupart.** L'API GitHub non authentifiée était refusée ou limitée en débit depuis cette
  machine, et les pages github.com renvoyaient 403. Quand elle ne répond pas, `verifier.mjs` le note
  (`fork non vérifiable`) et ne conclut pas. 19 des 24 éligibles portent cette note (les 5 autres ont eu une réponse de l'API : pas des forks) : à contrôler avec un
  jeton GitHub avant le tirage.
- Les extensions de PostgreSQL disponibles sont celles du paquet Ubuntu 16 (contrib) : `vector` et les autres de la
  liste manquent. Les migrations qui s'appuient sur elles ne sont donc jugées qu'en partie (erreurs consécutives
  tolérées par une règle simple, qui peut cacher une vraie erreur).
- `supabase db reset` n'est pas rejoué : le faux Supabase est le minimum décrit plus haut (pas de `auth.identities`,
  de `realtime` complet, de `pg_graphql`, etc.). Une migration qui en dépend peut échouer à tort ; une autre peut
  passer à tort.
- Les tables « à moi » sont détectées par l'état final de la base et des expressions de politiques, pas par le code de
  l'app : une politique qui passe par une fonction d'aide (`is_member(...)`) n'est pas vue.
- Seules les migrations du dossier `supabase/migrations` le moins profond qui s'applique sont jugées s'il y en a
  plusieurs (monorepo).
- Le critère « public » repose sur un clone sans identifiants ; un dépôt archivé reste éligible (note si l'API répond).
- L'éligibilité est celle du 04/10/2026, au commit indiqué.

## Pas une copie (`historique.mjs`, 06/10)

Ajouté par la session de travail sur vak à la reprise du 06/10, pour trancher la note « fork non vérifiable » : l'API
GitHub reste fermée à cette machine pour les dépôts tiers. La règle exclut les apps des répétitions et leurs copies,
et veut des apps distinctes. Ce qui se vérifie sans l'API, mécaniquement :
- **historique commun** : au moins un commit partagé ;
- **contenu copié** : plus de la moitié des fichiers du candidat (à son commit du 04/10, fichier vide exclu) sont
  identiques, octet pour octet, à des fichiers de l'autre dépôt (à sa tête). Ce signe voit aussi une copie sans
  historique.

Un candidat qui porte l'un des deux signes face à une app des répétitions ([`exclusions.txt`](exclusions.txt)) ou
face à un autre candidat est écarté. Entre deux candidats, les deux le sont : rien ne dit lequel est l'original. Une
app des répétitions elle-même, ou un dépôt de l'un de leurs propriétaires, est écarté aussi.

`node candidats/historique.mjs <dossier de travail> > candidats/historique.tsv` clone chaque dépôt sans le contenu des
fichiers (`--filter=blob:none`), compare, puis supprime les clones.

**Résultat du 06/10** ([`historique.tsv`](historique.tsv)) : 23 éligibles sur 24 (14 Expo, 9 Next).
- `aaronksaunders/expo-supabase-ai-template` est écartée : c'est une app de la répétition 1 (étape 4, septembre), où
  le kit a été développé et testé.
  - La liste remise le 04/10 à la session scellée ([`../scelle/exclusions.txt`](../scelle/exclusions.txt))
    l'oubliait, avec les 3 autres apps de cette répétition.
  - Une relecture de la règle l'a vu le 06/10, avant le tirage. La liste complète est
    [`exclusions.txt`](exclusions.txt), et le critère a été rejoué avec elle.
- Aucun commit commun, ni entre candidats ni avec une app des répétitions.
- Part la plus haute de fichiers identiques : 34 %, entre `itejaskumbhar/Expense-Sharing` et `cz-bszy/paper_sender`.
  Ce sont des fichiers du modèle de départ d'Expo, loin du seuil de 50 %.
- `Razikus/supabase-nextjs-template` reste éligible. Elle a été lue le 30/09, sans rien lancer, pour choisir les apps
  de la répétition 2, et écartée de celle-ci (sa RLS dépend du niveau MFA). Aucune mesure du kit n'a porté sur elle, et
  le kit ne traite pas ce cas.

Limite : un fork d'un dépôt hors de cette liste (un modèle public, par exemple) n'est pas vu. Il reste éligible,
comme toute app qui remplit les critères.
