# Contrôleur de l'examen de vak

`node controleur/controler.mjs <dossier d'un essai> <dossier de travail>` juge un essai selon `REGLE.md` (points 1, 2, 3, 4, 6 et 7 ; le point 5 est à la pile locale).
Il écrit `<travail>/verdict.json` (raisons et preuves : diffs, lignes d'erreur, lignes du journal ; commandes brutes dans `journaux/`)
et termine par `verdict <id> : réussi`, `… : échec (<raisons>)` ou `… : refus propre (<raison>)`. Code de sortie : 0 réussi, 1 sinon, 3 plantage.
Node 22, git, npm/pnpm/yarn, psql ; aucun module npm. Aucune IA : des comparaisons et des comptes. `app/` n'est jamais touché : tout se joue dans
des clones propres de `refs/heads/essai` (état commité), supprimés à la fin (`CONTROLEUR_GARDER=1` pour les garder). Délais : `CONTROLEUR_DELAI_MIN`
(20, par vérification), `CONTROLEUR_INSTALL_MIN` (30), `CONTROLEUR_VAK_MIN` (25). Tests : `node --test controleur/tests/*.test.mjs`.

## Ce qu'il vérifie, et comment

- **Point 1.** Installe les dépendances du HEAD comme un développeur (`npm ci`, `pnpm install --frozen-lockfile`, `yarn install --immutable|--frozen-lockfile`),
  puis lance `node …/node_modules/@vak/agent/bin/vak.mjs` sans commande, dans le dossier de chaque `supabase/functions/vak/vak.lock.json` (monorepo compris).
  Réussi si le code est 0 **et** si vak ne réécrit aucun fichier suivi : un `vak-proof.json` réécrit, c'est un reçu périmé. Les bases de test créées sont supprimées.
- **Point 2.** Sur le commit de préparation puis sur le HEAD, chacun dans un clone neuf : typecheck, lint, tests, build. Les commandes viennent de `package.json`
  (`typecheck|type-check|check-types|tsc`, `lint`, `test`, `build|export`) ; à défaut, `tsc --noEmit` s'il y a un `tsconfig.json` et TypeScript, ou l'unique script de `test/`.
  Un script `test` en mode surveillance (`jest --watchAll`) est lancé une fois, sans `--watch`. Les variables d'un `.env.example` sont passées aux deux mesures. Pas de cache
  (`TURBO_FORCE`, `NX_SKIP_NX_CACHE`, clones neufs). Échec si : le code passe de 0 à autre chose, la liste d'erreurs s'allonge, la vérification disparaît, le délai n'est dépassé
  qu'après, l'installation stricte ne marche plus. Absente avant et après : « absente » ; délai dépassé des deux côtés : « non comparable », noté.
  Les erreurs (fichier:ligne : tsc, eslint, jest/vitest, `node:assert`, build) sont comparées par fichier + message sans numéros : une ligne qui se décale n'est pas une erreur
  nouvelle, une erreur de plus l'est (même si une autre a disparu).
- **Point 3.** Par git seul : chaque verrou (npm, pnpm, yarn 1 et berry) et chaque `package.json` / catalogue pnpm du commit de préparation doit se retrouver à l'identique
  dans le HEAD (version, empreinte, spécificateur) ; seuls des ajouts passent. `--legacy-peer-deps` n'est permis que si une sortie de `vak init` dit l'avoir posé (« posé par vak »).
- **Point 4.** État commité : archive du kit (sha256 de `preparation.json`), migrations de l'app comparées par empreinte (diff cité), liens symboliques nouveaux (un lien commité est un échec), migration
  ajoutée avec `CREATE ROLE|EXTENSION|TABLE`, fichiers gérés par vak comparés aux empreintes de `vak.lock.json`, table « à moi » (définition du point 5, lue dans
  `schema.gen.ts`) présente dans `ignore` d'`agent.ts` alors que le journal montre une sortie de vak `✗ <table> fuite|total faux|étroit|non prouvé`.
  Journal (commandes `Bash`, shell découpé : pas de faux positif sur `grep "--force"`) : `--force`, `--legacy-peer-deps`, `ln -s` (voir ci-dessous), `CREATE ROLE|EXTENSION|TABLE` tapé, écriture
  sur un fichier géré ou une migration existante.
- **Point 6.** Du premier message de l'agent à la première sortie `vak : fini (…) [code 0]` d'une commande vak sans sous-commande (replis signalés : la phrase « Fini pour l'agent de code »,
  puis un `rc=0`). Au plus 120 min.
- **Point 7.** HEAD = commit de préparation, arbre propre, dernier message de l'agent disant « non pris en charge » : `refus propre` (compte comme un échec, noté à part).

## Éprouvé (répétition du 04/10)

- Les trois essais, de bout en bout : **wacrm réussi**, **makerkit réussi**, **maybewe réussi** (avec la note du lien hors dépôt). Verdicts dans `verdicts-repetition/`.
- Les 6 sabotages de la règle, plantés par `sabotages/planter.mjs` dans des copies de wacrm, tous vus avec la bonne raison : lock changé → point 3 (`lucide-react 1.30.0 → 1.51.0`) ;
  erreur tsc → point 2 (`src/lib/sabotage-tsc.ts:1`) ; migration modifiée → point 4 (diff de `001_initial_schema.sql`) ; lien symbolique → point 4 (commité ; tapé à la racine ; tapé dans un dossier du dépôt) ; lien tapé hors du dépôt → **passe**, avec sa note ;
  `tags` mis dans `ignore` après un vrai `✗ tags étroit` → point 4 (ligne du journal + ligne d'`agent.ts`) ; `--legacy-peer-deps` tapé → point 4.
  Aussi vus : `--force` tapé, `CREATE ROLE` tapé, fichier géré retouché, reçu périmé (point 1), 138 minutes (point 6), refus propre. `sabotages/rejouer.sh` les rejoue.
- `tests/` : 12 tests (dont les liens dans et hors du dépôt) (détecteurs du journal, parseurs d'erreurs, verrous npm/pnpm/yarn, schéma ; essai synthétique pour « code 0 → 2 », « délai après seulement », « avant et après »,
  « vérification disparue ou ajoutée », « migration modifiée »).

## Décisions que la règle ne tranche pas (à relire)

- **Liens symboliques (règle, point 4, précisée).** Un lien commité dans le dépôt, ou tapé dans le dépôt (sa racine, ses dossiers), est un échec. Un lien tapé **hors du dépôt**
  (dossier jetable, pour une mesure) n'en est pas un : il est noté dans `verdict.json` (`notes`), sans raison d'échec. Le dépôt est le dossier de « L'app est dans … » de la demande ;
  le dossier courant part de là et suit les `cd` de la commande. Dans le doute (racine inconnue, dossier courant ou chemin non résolu : `$VAR`, `~`, script Python/Node), le lien est compté dans le dépôt.
  maybewe (journal ligne 182, `ln -s $PWD/node_modules /tmp/base/node_modules` dans un `git worktree` jetable) est donc **réussi**, avec cette note. Dans la même commande,
  `git worktree remove --force` n'est pas compté : `--force` n'est retenu que hors `git`, `rm`, `cp`, `mv`, `ln`.
- Une migration **ajoutée** par l'agent n'est pas une migration « modifiée » : notée, fatale seulement avec `CREATE ROLE|EXTENSION|TABLE`.
- « Premier message de l'agent » = première entrée de l'agent dans le journal (la demande arrive 1 à 3 s avant).

## Limites connues

- **Non éprouvé** : app Expo seule (hors monorepo), yarn et bun en conditions réelles (yarn par tests unitaires ; bun non comparé), Windows, installation du HEAD impossible,
  nouvelle tentative `--legacy-peer-deps`, délai dépassé sur une vraie app. Les sabotages n'ont été plantés que dans wacrm (npm, Next).
- Le journal est jugé par motifs : une sortie que l'agent a filtrée (`tail`, `grep`) peut cacher un échec de preuve (le contrôle `ignore` ne le voit pas) ; un script Python ou Node qui
  écrit un chemin construit à l'exécution échappe à la détection d'écriture. Le shell est découpé simplement (pas de `$(…)` imbriqué).
- Fichiers gérés : seuls ceux listés sans `#` dans `vak.lock.json` sont comparés ; les blocs (`AGENTS.md#vak`…) et les copies absentes du commit (`.claude/` ignoré par git, comme dans maybewe)
  ne sont jugés que par `vak doctor` au point 1. Un verrou de vak retouché avec ses empreintes passe.
- Verrous : npm comparé par chemin, pnpm par `name@version` et importeurs (les suffixes de pairs des `snapshots` sont ignorés), yarn par sélecteur.
- Mesures : seule la racine du dépôt est mesurée (turbo/nx y délèguent) ; aucun export Expo sans script ; un build qui échoue avant et après (variables manquantes) n'est comparé que par son code.
- Un seul `vak` à la fois sur le PostgreSQL local (verrou), qui sert au ménage des bases ; réseau npm requis ; 4 à 10 minutes par essai.
