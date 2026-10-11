# Publication avant le tirage (troisième examen)

Publiée le 11/10/2026, avant le tirage. Ce fichier fige ce que la règle ([`REGLE.md`](REGLE.md), « La publication »)
demande de publier avant le tirage. Après lui, plus rien ne change. Les publications des deux premiers examens
(06/10/2026, échoué : 2 essais réussis sur 14 ; 10/10/2026, échoué : 9 sur 14) restent lisibles dans l'historique de
ce dépôt.

## Les empreintes

Ce sont des SHA-256. Les mêmes sont dans [`EMPREINTES.sha256`](EMPREINTES.sha256), avec des chemins pris depuis la
racine du dépôt : `sha256sum -c --ignore-missing vak-examen/EMPREINTES.sha256` vérifie tout ce qui est déjà publié.

- **La règle** : `vak-examen/REGLE.md`, `95614eeaa6dbbba620cdee53beb75edbedb26546bb232a7185c7649050803e0d`.
- **L'archive gelée du kit** : `vak-agent-0.27.0.tgz` (2 993 123 octets),
  `8e695dc7571b18db7bf60967b9e2994b4d8367f102854fe8f83f92fbc7de3284`. C'est la seule archive des 14 essais. Elle
  sera publiée si l'examen est réussi.
- **La page de vak**, d'où vient la demande (son README ; il n'est pas dans l'archive) : `vertical-agent-kit/README.md`,
  `acf2d8bc92346c65c87db73fe6ca13e4821c06900d42f3c87c8efc9da0e080ba`. Elle sera publiée avec l'archive.
- **Les fiches de forme et les 3 apps construites** : `fiches-3/*.md` et `apps/cuisine.bundle`, `apps/club.bundle`,
  `apps/abonnements.bundle`, publiées ici. Leurs empreintes sont aussi dans [`apps/SHA256SUMS`](apps/SHA256SUMS).
  Branches `main` des apps : cuisine `791c04db1ba499b0ebe535cd6551045340912555`, club
  `1b05281d58c9a209e1f118df054ff62377c69098`, abonnements `9ee8a7855a713d15c02b61c9e7774e25027ffc0e`.
- **Les graines A et B** des 3 apps construites, l'outil qui les éprouve et les comptes rendus des sessions scellées
  qui les ont écrites : les 12 fichiers de `graines/` listés plus bas. Ils seront publiés après les essais.
- **La liste des apps éligibles** : `candidats/historique.tsv`,
  `2eb7ee2baf7d25d32da3cb976a362f5c2cba4ba9003cfe04a3d90090df5b19a1` : 15 apps éligibles, 10 Expo et 5 Next, chacune
  à son commit de `candidats/candidats.tsv`. La liste d'exclusion complète est
  [`candidats/exclusions.txt`](candidats/exclusions.txt) : elle exclut aussi les apps tirées des deux premiers examens.
- **Les outils figés** avec la règle sont ceux de ce commit : le contrôleur (`controleur/`), le juge « mes données »
  (`mesdonnees/`), la pile (`pile/`), `verdict.mjs`, le tirage (`tirage.mjs`, `candidats/`), le lecteur des
  étiquettes (`lecteurs.sh`, `etiquettes/`, `scelle/ETIQUETTE.md`), le relevé de la clause « ignore »
  (`releve-ignore.mjs`) et l'assemblage du résultat (`resultat.mjs`). Le lanceur (`repetition2/`, `essai.sh`) l'est
  pour le texte que reçoit l'agent, la bulle, la transcription du journal et la limite de temps. Leur code n'a pas
  changé depuis la publication du deuxième examen (dépôt public, commit `cfa018f`) ; seules les listes de
  `candidats/` (exclusions, apps éligibles) suivent ce troisième examen. L'épreuve des graines sur la base de la pile
  (`graines/eprouver-pile.mjs`), ajoutée pendant le deuxième examen et publiée avant ses essais, sert aussi.

```text
95614eeaa6dbbba620cdee53beb75edbedb26546bb232a7185c7649050803e0d  vak-examen/REGLE.md
8e695dc7571b18db7bf60967b9e2994b4d8367f102854fe8f83f92fbc7de3284  vertical-agent-kit/releases/vak-agent-0.27.0.tgz
acf2d8bc92346c65c87db73fe6ca13e4821c06900d42f3c87c8efc9da0e080ba  vertical-agent-kit/README.md
d2804b4fc2d6f2d503f213713c324f581aaa551a32b365bf8d2af8154ea896fe  vak-examen/fiches-3/demarre.md
7c4eff123301329ed0e9ac826159b40dede654350bc5cfffb11b3b0d2c31fc05  vak-examen/fiches-3/equipe.md
99c1940986096e8f702a9918152993532c0633e6db8b789c823dc8962bcb10bf  vak-examen/fiches-3/fonctions.md
45f6d3dd705e4209dae4a6646f83ffabc3dc957f190287e2ed67aa6d5db97a7a  vak-examen/apps/cuisine.bundle
90d3ef71c5b8a19e70d57131151523173a08cf0a7b7ebd597b7e2e65f0bfcb1a  vak-examen/apps/club.bundle
768d9cdec78bf2ea9fbc971899d1553632416fcd25b05f8683b3baa31bc92f43  vak-examen/apps/abonnements.bundle
2eb7ee2baf7d25d32da3cb976a362f5c2cba4ba9003cfe04a3d90090df5b19a1  vak-examen/candidats/historique.tsv
e60dc62f49ec4266d215b30516ca94b29c89f9198bfbd9cef702bc95868aea34  vak-examen/graines/RAPPORT-cuisine.md
df286b8e2d8bff49dbf5df237f32045446319d8eecc6f8d91dbe935a6b3e3004  vak-examen/graines/RAPPORT-club.md
8d5d83e778da6cd74774abc71dd5685343d8cc2d18d0b63bad50dacb79a2e65b  vak-examen/graines/RAPPORT-abonnements.md
50cc7b8979ec2fedc470402895441403a5df4a2005642ff1006ceb8bd935f477  vak-examen/graines/cuisine/attendu.json
124eb97e58667e3aab034f38e08303e07c7ac8a2c8c22848aa0f046851e44b7e  vak-examen/graines/cuisine/graine.sql
3b5da227d08dfb62a85531d552cac63a7f0e957adaeeead37a924854ebe6e85c  vak-examen/graines/club/attendu.json
fa269ce132dbf1294156d5cb49a8ce6510cd722754b983cc0c545b6bdd17b271  vak-examen/graines/club/graine.sql
17d91e10c2bb8bfd89c16276484bfff8280992d56a8193ca74213cb5ed8e5873  vak-examen/graines/abonnements/attendu.json
48b682d8f53217680a629f927b913248cb47644d8f3c7fe566e3329eee37c9db  vak-examen/graines/abonnements/graine.sql
c6c0e03637c6d062af1c251b022787ee9407ff05cec1d07983eec2e48d9bf1d4  vak-examen/graines/eprouver.mjs
0a52c4c3a4b81a765c523b16d889ed14937e759e25ddafc7cc52731579c0e24c  vak-examen/graines/eprouver-pile.mjs
e9675d55ce552bc97ddca7daddc1e3750d4fa1331ed199431260c160bb48484d  vak-examen/graines/supabase-minimum.sql
```

## La demande

L'agent reçoit la demande de la page de vak (bloc « La demande en une ligne »), mot pour mot, avec ses trois champs
remplis. Voici le texte exact, champs non remplis :

```text
Intègre l'assistant IA vak dans cette app. Métier : *<une phrase sur le métier>*. Emplacement : *<un onglet « Assistant » ou un bouton flottant sur tous les écrans>*. L'archive du kit est ici : *<chemin absolu de vak-agent-<version>.tgz>* ; c'est moi qui l'ai fournie (pour un agent en ligne, je l'ai commitée dans `vendor/vak`). Lis-la d'abord sans rien exécuter : `tar -xzOf - package/package.json < "<ce chemin>"` montre `"private": true` et aucun script d'installation (`preinstall`, `install`, `postinstall`, `prepare`). Puis lance `npx -y --package="<ce chemin>" vak init` et suis ce qu'il affiche ; une commande refusée, ne la contourne jamais : arrête-toi et donne-la-moi. Avant de me poser une question, cherche la réponse dans `node_modules/@vak/agent/docs/FAQ.md`. Mesure les vérifications de l'app avant l'installation. Tu as fini quand `node node_modules/@vak/agent/bin/vak.mjs` renvoie 0 et que la phrase « Fini pour l'agent de code » de son aide (`--help`) est vraie. S'il te manque un accès ou une clé, arrête-toi et donne-moi la commande exacte à lancer dans mon terminal.
```

Le texte est le même, mot pour mot, que celui des deux premiers examens : la page de vak n'a changé que par le numéro
de l'archive, ailleurs que dans ce bloc. Le harnais (`repetition2/messages.sh`) remplit les trois champs :
- le métier et l'emplacement, fixés pour chaque app avant ses essais ;
- le chemin `/work/vak-agent.tgz`, où `repetition2/preparer.sh` copie l'archive.

Il place la demande entre deux phrases d'introduction et les règles de l'essai, écrites dans ce même fichier.

## L'environnement des essais

- La machine : un conteneur Linux x86_64 (Ubuntu 24.04.4 LTS, 16 Go de mémoire, 4 processeurs), dans le cloud de
  Claude Code. C'est la même que pour le deuxième examen.
- Node 22.22.0.
- PostgreSQL 16.14 (paquet `postgresql-16` 16.14-0ubuntu0.24.04.1), avec pgTAP 1.3.2 (`postgresql-16-pgtap`) pour
  les tests du kit. Aucune autre extension n'est ajoutée, pgvector compris.
- La CLI Supabase 2.118.0, la version que fixe l'archive gelée. Pas de Docker.
- L'agent :
  - Claude Code 2.1.296 (`claude -p`, mode `bypassPermissions`), avec le modèle par défaut de cette version ;
  - il tourne dans la bulle de `repetition2/lancer.sh`. Elle lui cache la session, `/srv`, le `/tmp` de la machine
    et les autres essais de `/work` (vides pour lui). Les bases locales sont supprimées avant chaque essai ;
  - chaque essai consigne la version de Claude Code dans son `lanceur.json`.
- La pile « mes données » :
  - PostgREST 12.2.12 et Deno 2.9.6 ;
  - pour l'assistant, le modèle `deepseek-flash` par l'API de DeepSeek, avec la clé du propriétaire.

## Le tirage

- La chaîne drand « quicknet » : `52db9ba70e0cc0f6eaf7803dd07447a1f5477735fd3f661792ba94600c84e971`. Elle produit un
  tour toutes les 3 secondes depuis le 23/08/2023 à 15:09:27 UTC (genèse 1692803367).
- **Le tour choisi est le 32959312**. Il sera produit le **11 octobre 2026 à 01:15:00 UTC**. Quand ce fichier est
  publié, il n'existe pas encore.
- La commande : `node vak-examen/tirage.mjs 32959312`. Elle lit l'aléa sur un relais public de drand et vérifie sa
  signature. Elle classe ensuite les 15 apps éligibles, et prend les 2 premières apps Expo et les 2 premières apps
  Next.
- Son résultat sera publié dans `vak-examen/TIRAGE.md`, avant les essais.

## L'ordre des étapes

- **10/10, 20:32 UTC** : le deuxième examen est publié, échoué (9 sur 14), avec les trois défauts de vak qu'il a
  trouvés (F1 à F3, son `EXAMEN.md`, dans l'historique de ce dépôt).
- **10/10, au soir** : vak 0.27.0 corrige F1 à F3 ; le propriétaire décide le troisième examen. Les 4 apps tirées le
  10/10 sont exclues, la liste des apps éligibles est refaite par son outil.
- **10/10, 23:40 UTC** : les fiches de forme des 3 apps nouvelles sont commitées (`fiches-3/`).
- **10/10, 23:40 à 23:46 UTC** : les 3 apps sont construites par trois sessions scellées, qui n'ont reçu que leur fiche
  et `scelle/CONSTRUIRE.md` ; vérifiées ensuite sur des clones neufs (`apps/README.md`).
- **10/10, de 23:46 à 23:47 UTC** : les graines A et B des 3 apps sont écrites par trois sessions scellées
  (`scelle/GRAINES-CONSTRUITES.md`), puis éprouvées sur des bases neuves : « tout est conforme » pour les trois.
- **10/10, 23:48, au 11/10, 00:23 UTC** : les 6 sabotages de la règle sont rejoués sur le contrôleur figé, dans des
  copies de l'essai wacrm de la répétition 4 : tous vus, avec la bonne raison, comme au deuxième examen ; l'essai
  intact reste « réussi » (`controleur/verdicts-sabotages-11-10/`).
- **11/10** : la règle est relue par la session de travail, ligne à ligne contre celle du deuxième examen. Aucun
  agent indépendant ne l'a relue : le propriétaire n'en a pas demandé, et la règle du premier examen, qui en forme le
  corps, avait été relue deux fois par un agent indépendant avant le 06/10. Ce qui change est listé ci-dessous.
- **11/10** : cette publication.

Seule cette publication est datée par GitHub. Les étapes d'avant le sont par l'histoire du dépôt de vak, qui n'est
pas public.

## Ce qui a changé depuis le deuxième examen

1. **Les apps.**
   - Les 7 apps du deuxième examen sortent de la liste : vak a été corrigé sur trois d'entre elles (F1 à F3), et
     toutes ont été vues (les 4 apps tirées rejoignent `candidats/exclusions.txt`).
   - Restent 15 apps éligibles, jamais vues de vak : 10 Expo, 5 Next, à leurs commits du 04/10. Aucune n'a servi au
     développement du kit : le banc de schémas de vak n'a pris que des apps ni Next ni Expo.
   - 3 apps construites nouvelles, d'après des fiches nouvelles (mêmes trois formes, domaines nouveaux) : un carnet
     de cuisine (une liste de mots-clés, une note bornée) ; le planning d'un club de sport (un rôle qui voit sans
     modifier, un encadrant désigné par entraînement) ; le suivi des abonnements (des fonctions aux arguments simples
     comme en JSON, une fonction qui rend des lignes, un abonnement rendu inactif sans être effacé).
2. **Le kit gelé** : vak 0.27.0, au lieu de la 0.26.1. Il corrige les trois défauts trouvés par le deuxième examen :
   la preuve d'une fonction dont l'argument est un objet JSON (F1), la graine de deux clés vers une même table sous
   une contrainte d'unicité (F2), la langue des réponses et des libellés (F3).
3. **Les outils figés** n'ont pas changé depuis le deuxième examen. Seule la ligne de `tirage-publier.mjs` qui cite la
   publication et le ticket du tirage suit chaque examen (au deuxième : commit `cfa018f`, ticket n°2).
4. **Le groupe témoin** n'est pas rejoué, comme au deuxième examen (choix du propriétaire, 10/10) : celui du 06/10
   reste publié.

## Ce qui viendra

- **Après le tirage, avant les essais** :
  - `TIRAGE.md` ;
  - les empreintes des graines des 4 apps tirées ;
  - la liste des 7 apps, avec les trois champs de leur demande (`essais.tsv`, `AVANT-ESSAIS.md`) ;
  - toute correction du lanceur, avec sa raison.
- **Après les essais** :
  - les journaux des agents, avec les secrets masqués ;
  - les verdicts du contrôleur et du juge « mes données » ;
  - les gestes, les étiquettes, la vérité et les réponses du lecteur ;
  - les graines.
- **Si l'examen est réussi** : l'archive et la page de vak, et l'état commité de chaque essai.
