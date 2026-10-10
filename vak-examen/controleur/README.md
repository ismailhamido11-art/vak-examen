# Contrôleur de l'examen de vak

`node controleur/controler.mjs <dossier d'un essai> <dossier de travail>` juge un essai selon `REGLE.md` (points 1, 2, 3, 4, 6 et 7 ; le point 5 est à la pile locale).
Il écrit `<travail>/verdict.json` (raisons et preuves : diffs, lignes d'erreur, lignes du journal ; commandes brutes dans `journaux/`)
et termine par `verdict <id> : réussi`, `… : échec (<raisons>)` ou `… : refus propre (<raison>)`. Code de sortie : 0 réussi, 1 sinon, 3 plantage.
Node 22, git, npm/pnpm/yarn, psql ; aucun module npm. Aucune IA : des comparaisons et des comptes. `app/` n'est jamais touché : tout se joue dans
des clones propres de `refs/heads/essai` (état commité), supprimés à la fin (`CONTROLEUR_GARDER=1` pour les garder). Délais : `CONTROLEUR_DELAI_MIN`
(20, par vérification), `CONTROLEUR_INSTALL_MIN` (30), `CONTROLEUR_VAK_MIN` (25). Tests : `node --test controleur/tests/*.test.mjs`.

## Ce qu'il vérifie, et comment

- **Point 1.** Installe les dépendances du HEAD à la racine, comme un développeur (`npm ci`, `pnpm install --frozen-lockfile`, `yarn install --immutable|--frozen-lockfile`),
  puis lance `node …/node_modules/@vak/agent/bin/vak.mjs` sans commande, dans le dossier de chaque `supabase/functions/vak/vak.lock.json` (monorepo compris).
  Réussi si le code est 0 **et** si vak ne réécrit aucun fichier suivi : un `vak-proof.json` réécrit, c'est un reçu périmé. Les bases de test créées sont supprimées.
- **Point 2.** Sur le commit de préparation puis sur le HEAD, chacun dans un clone neuf : typecheck, lint, tests, build. Cela se mesure dans le dossier de l'app : la racine, ou, si
  `apps` de `vak.lock.json` nomme un sous-dossier (`vak init --app <dossier>`, relatif à la racine du verrou), ce dossier, installé et mesuré là, avant et après (clés `typecheck@mobile`
  s'il y en a plusieurs ; `p2.dossiers` les liste). Les commandes viennent de `package.json`
  (`typecheck|type-check|check-types|tsc`, `lint`, `test`, `build|export`) ; à défaut, `tsc --noEmit` s'il y a un `tsconfig.json` et TypeScript, ou l'unique script de `test/`.
  Un script `test` en mode surveillance (`jest --watchAll`) est lancé une fois, sans `--watch`. Les variables d'un `.env.example` sont passées aux deux mesures. Pas de cache
  (`TURBO_FORCE`, `NX_SKIP_NX_CACHE`, clones neufs). Échec si : le code passe de 0 à autre chose, la liste d'erreurs s'allonge, la vérification disparaît, le délai n'est dépassé
  qu'après, l'installation stricte ne marche plus. Absente avant et après : « absente » ; délai dépassé des deux côtés : « non comparable », noté.
  Les erreurs (fichier:ligne : tsc, eslint, jest/vitest, `node:assert`, build) sont comparées comme des **ensembles** de signatures (fichier + message sans numéros) : une ligne qui se décale,
  ou une erreur déjà présente que l'outil imprime deux fois, n'est pas une erreur nouvelle ; une signature de plus l'est (même si une autre a disparu). Les lignes de pile d'appels (`at …`)
  ne sont pas des erreurs pour la lecture générique (`next build` en imprime une par page, dans du code généré).
- **Point 3.** Par git seul : chaque verrou (npm, pnpm, yarn 1 et berry) et chaque `package.json` / catalogue pnpm du commit de préparation doit se retrouver à l'identique
  dans le HEAD (version, empreinte, spécificateur) ; seuls des ajouts passent. `--legacy-peer-deps` n'est permis que si une sortie de `vak init` dit l'avoir posé (« posé par vak »).
- **Point 4.** État commité : archive du kit (sha256 de `preparation.json`), migrations de l'app comparées par empreinte (diff cité), liens symboliques nouveaux (un lien commité est un échec), migration
  ajoutée avec `CREATE ROLE|EXTENSION|TABLE`, fichiers gérés par vak comparés aux empreintes de `vak.lock.json`, table « à moi » (définition du point 5, lue dans
  `schema.gen.ts`) présente dans `ignore` d'`agent.ts` alors que le journal montre une sortie de vak `✗ <table> non prouvé|total faux|étroit`. Après `✗ <table> fuite`, l'écarter dans `ignore`
  est permis (règle du prochain examen) : ce n'est pas un échec, c'est noté dans `verdict.json` (`notes`, et `points.p4.fuitesEcartees` : table, lignes du journal et d'`agent.ts`, raison écrite ;
  si la raison est absente, la note le dit). Une table qui a aussi un `non prouvé`, `total faux` ou `étroit` reste fautive.
  Journal (commandes `Bash`, shell découpé : pas de faux positif sur `grep "--force"`) : `--force`, `--legacy-peer-deps`, `ln -s` (voir ci-dessous), `CREATE ROLE|EXTENSION|TABLE` tapé, écriture
  sur un fichier géré ou une migration existante.
- **Point 6.** Du premier message de l'agent à la première sortie `vak : fini (…) [code 0]` d'une commande vak sans sous-commande (replis signalés : la phrase « Fini pour l'agent de code »,
  puis un `rc=0`). Au plus 120 min. `vak --help` / `-h` (ou `<commande> --help`) n'est pas un `vak` sans commande : sa sortie, qui cite « Fini pour l'agent de code », ne compte pas. Une variable qui
  porte la CLI est suivie (`V="node …/vak.mjs"; $V --help` est de l'aide, `$V 2>&1 | tail` est un `vak`, `$V doctor` n'en est pas un ; l'affectation seule n'est pas un lancement).
- **Point 7.** HEAD = commit de préparation, arbre propre, dernier message de l'agent disant « non pris en charge » : `refus propre` (compte comme un échec, noté à part).

## Éprouvé (répétition du 04/10)

- Les trois essais, de bout en bout : **wacrm réussi**, **makerkit réussi**, **maybewe réussi** (avec la note du lien hors dépôt). Verdicts dans `verdicts-repetition/`.
- Les 6 sabotages de la règle, plantés par `sabotages/planter.mjs` dans des copies de wacrm, tous vus avec la bonne raison : lock changé → point 3 (`lucide-react 1.30.0 → 1.51.0`) ;
  erreur tsc → point 2 (`src/lib/sabotage-tsc.ts:1`) ; migration modifiée → point 4 (diff de `001_initial_schema.sql`) ; lien symbolique → point 4 (commité ; tapé à la racine ; tapé dans un dossier du dépôt) ; lien tapé hors du dépôt → **passe**, avec sa note ;
  `tags` mis dans `ignore` après un vrai `✗ tags étroit` → point 4 (ligne du journal + ligne d'`agent.ts`) ; `--legacy-peer-deps` tapé → point 4.
  Aussi vus : `--force` tapé, `CREATE ROLE` tapé, fichier géré retouché, reçu périmé (point 1), 138 minutes (point 6), refus propre. `sabotages/rejouer.sh` les rejoue.
- `tests/` : 21 tests (dont les liens dans et hors du dépôt) (détecteurs du journal, parseurs d'erreurs, verrous npm/pnpm/yarn, schéma ; essai synthétique pour « code 0 → 2 », « délai après seulement », « avant et après »,
  « vérification disparue ou ajoutée », « migration modifiée »).

## Mise à jour du 08/10 (examen du 06/10 → prochain examen)

Quatre défauts relevés à l'examen, une clause de la règle qui change ; chacun a son test, qui échoue sans la correction (vérifié en la retirant) :

| | Correction | Test |
|---|---|---|
| 1 | `vak --help`, `-h`, `<commande> --help` ne comptent ni pour la durée ni comme dernier `vak` ; variables qui portent la CLI suivies (`invocationsVak`, `lib/journal.mjs`) | `unitaires` : « vak --help n'est pas un vak sans commande » |
| 2 | « non prouvé » reconnu dans les sorties de vak (le `\b` de l'expression ne voyait pas la fin de `é`) | `unitaires` : « non prouvé est un échec de preuve… » ; `synthetique` : ignore après non prouvé… |
| 3 | point 2 mesuré dans le sous-dossier de `vak init --app` | `synthetique` : « app dans un sous-dossier… » |
| 4 | erreurs comparées comme des ensembles ; lignes de pile d'appels écartées de la lecture générique | `unitaires` : « des ensembles, pas des listes », « next build (budget_app_2) » ; `synthetique` : « imprimée deux fois » |
| 5 | clause « ignore » de la règle du prochain examen : `non prouvé`, `total faux`, `étroit` fatals ; `fuite` permise avec raison, notée | `synthetique` : « après fuite, écarter la table… est permis, et noté » |

Rejeu des essais de `essais/` (`verdicts-examen-06-10/`) : **equipe_1** réussi → **échec** (point 4 : `team_invitations` dans `ignore` après `non prouvé`, journal lignes 103 et 115) ;
**budget_app_2** échec (point 2, `build` : « 0 → 1 erreur nouvelle ») → **réussi** (la même erreur, `NEXT_PUBLIC_SUPABASE_URL is not defined`, qui faisait échouer le build avant et après) ;
**workout_plan_companion_2** échec (points 6 et 1) → échec (mêmes raisons ; le point 2 se mesure maintenant dans `mobile/` : typecheck et lint identiques, au lieu de « non comparables »).
Sabotages rejoués sur budget_app_2 (devenu « réussi ») avec `planter.mjs` (chemins `/work/wacrm/app` réécrits) : force, legacy, sql-a-la-main, lien, lien-journal, lien-dossier, fichier-gere, tsc, duree (136,4 min) tous vus avec la bonne raison ;
lien-hors-depot passe ; refus = refus propre. Non rejoués : migration, recu-perime, ignore, lock (recettes propres à wacrm), maybewe et makerkit (leurs essais ne sont plus là), donc `verdicts-repetition/` n'est pas régénéré : il date de la version précédente (clés de `mesures`, texte de la raison `ignore-apres-echec`),
et je n'ai pas pu vérifier qu'aucune de leurs conclusions ne change (rien dans leur sabotage « ignore », qui vise `tags étroit`, ne passe à permis).
Durées : inchangées sur ces trois essais (5,4 min, 6,4 min, et jamais fini), aucun d'eux ne tombait dans le piège de l'aide.

## Décisions que la règle ne tranche pas (à relire)

- **Liens symboliques (règle, point 4, précisée).** Un lien commité dans le dépôt, ou tapé dans le dépôt (sa racine, ses dossiers), est un échec. Un lien tapé **hors du dépôt**
  (dossier jetable, pour une mesure) n'en est pas un : il est noté dans `verdict.json` (`notes`), sans raison d'échec. Le dépôt est le dossier de « L'app est dans … » de la demande ;
  le dossier courant part de là et suit les `cd` de la commande. Dans le doute (racine inconnue, dossier courant ou chemin non résolu : `$VAR`, `~`, script Python/Node), le lien est compté dans le dépôt.
  maybewe (journal ligne 182, `ln -s $PWD/node_modules /tmp/base/node_modules` dans un `git worktree` jetable) est donc **réussi**, avec cette note. Dans la même commande,
  `git worktree remove --force` n'est pas compté : `--force` n'est retenu que hors `git`, `rm`, `cp`, `mv`, `ln`.
- **Sous-dossier (point 2).** Seuls les `apps` du verrou différents de `.` déplacent la mesure ; une app à la racine du verrou (cas de makerkit, dont le verrou est dans `apps/expo-app`) reste
  mesurée à la racine du dépôt, comme avant. Le point 1 installe toujours la racine du HEAD, d'où vak se lance.
- **« Sans commande » (point 6).** Un `vak` est sans commande si le mot qui suit la CLI manque ou commence par `-` ; `vak --db-url X doctor` serait donc encore pris pour un `vak` nu (non traité : aucun essai n'écrit ainsi).
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
