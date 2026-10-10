# Publication avant le tirage (deuxième examen)

Publiée le 10/10/2026, avant le tirage. Ce fichier fige ce que la règle ([`REGLE.md`](REGLE.md), « La publication »)
demande de publier avant le tirage. Après lui, plus rien ne change. La publication du premier examen (06/10/2026,
échoué : 2 essais réussis sur 14) reste lisible dans l'historique de ce dépôt.

## Les empreintes

Ce sont des SHA-256. Les mêmes sont dans [`EMPREINTES.sha256`](EMPREINTES.sha256), avec des chemins pris depuis la
racine du dépôt : `sha256sum -c --ignore-missing vak-examen/EMPREINTES.sha256` vérifie tout ce qui est déjà publié.

- **La règle** : `vak-examen/REGLE.md`, `8c64ce1ed8b489901ef5e84a1432be0865731e303296154e33598a2fff8afadb`.
- **L'archive gelée du kit** : `vak-agent-0.26.1.tgz` (2 991 943 octets),
  `e0516efc36a307cf677a0ca223ae5682a74a0bb5fc35f115984b4804fc225db7`. C'est la seule archive des 14 essais. Elle
  sera publiée si l'examen est réussi.
- **La page de vak**, d'où vient la demande (son README ; il n'est pas dans l'archive) : `vertical-agent-kit/README.md`,
  `72780b7aa4f9367bd1ee3e3fdc88de6cf3b8b992361860528a04ae098a54d942`. Elle sera publiée avec l'archive.
- **Les fiches de forme et les 3 apps construites** : `fiches-2/*.md` et `apps/plantes.bundle`, `apps/agence.bundle`,
  `apps/compteurs.bundle`, publiées ici. Leurs empreintes sont aussi dans [`apps/SHA256SUMS`](apps/SHA256SUMS).
  Branches `main` des apps : plantes `bea4192347a7ecf310391b23278294b6d841c56d`, agence
  `fed608276a1fd66abfd4e6f24b84d08e8f5a9876`, compteurs `5c12ec9ed61311cbd81103de20902210f22ca364`.
- **Les graines A et B** des 3 apps construites, l'outil qui les éprouve et les comptes rendus des sessions scellées
  qui les ont écrites : les 11 fichiers de `graines/` listés plus bas. Ils seront publiés après les essais.
- **La liste des apps éligibles** : `candidats/historique.tsv`,
  `968dc2f416255d5750f1f4c391b1df125679e604bdb414a20975b6faec1edae7` : 19 apps éligibles, 12 Expo et 7 Next, chacune
  à son commit de `candidats/candidats.tsv`. La liste d'exclusion complète est
  [`candidats/exclusions.txt`](candidats/exclusions.txt) : elle exclut aussi les 7 apps du premier examen.
- **Les outils figés** avec la règle sont ceux de ce commit : le contrôleur (`controleur/`), le juge « mes données »
  (`mesdonnees/`), la pile (`pile/`), `verdict.mjs`, le tirage (`tirage.mjs`, `candidats/`), le lecteur des
  étiquettes (`lecteurs.sh`, `etiquettes/`, `scelle/ETIQUETTE.md`), le relevé de la clause « ignore »
  (`releve-ignore.mjs`) et l'assemblage du résultat (`resultat.mjs`). Le lanceur (`repetition2/`, `essai.sh`) l'est
  pour le texte que reçoit l'agent, la bulle, la transcription du journal et la limite de temps.

```text
8c64ce1ed8b489901ef5e84a1432be0865731e303296154e33598a2fff8afadb  vak-examen/REGLE.md
e0516efc36a307cf677a0ca223ae5682a74a0bb5fc35f115984b4804fc225db7  vertical-agent-kit/releases/vak-agent-0.26.1.tgz
72780b7aa4f9367bd1ee3e3fdc88de6cf3b8b992361860528a04ae098a54d942  vertical-agent-kit/README.md
75c895865f47eddc07e65bfea72eb76d5cf6412bf799b41c64fd8661bb6b328f  vak-examen/fiches-2/demarre.md
99bc3d7430c4ca17f812a3c0eed0ec09e3d91e54af06c7e25909912132b7295b  vak-examen/fiches-2/equipe.md
e0b1813797d60a59cc430fee61f6ad613a8a238b41eb583e1536abbd3c138429  vak-examen/fiches-2/fonctions.md
07c56939a038c6e1b3d968d813b3b584bf1f19cb4ac914740e98486e2abeae7a  vak-examen/apps/plantes.bundle
3cca7ff1925013402aba5ed00a9fa1a82253365dd71f3cfb4a9ea780569501eb  vak-examen/apps/agence.bundle
bb6790e62dc0ff486361e3cf7d48ed933527e33d8474a2efac1f5f5c9bf9b7e3  vak-examen/apps/compteurs.bundle
968dc2f416255d5750f1f4c391b1df125679e604bdb414a20975b6faec1edae7  vak-examen/candidats/historique.tsv
caf3c4a7970d34743625f3354a3ae7c88edef5fb3079b6dba044580f81d1f93d  vak-examen/graines/RAPPORT-plantes.md
46cb4fd3d2f1d3e687b0702b06566e5b589a3262d3c188de17820818a963a0b5  vak-examen/graines/RAPPORT-agence.md
636158e0f305018e3a7e9877730c834c85ba8c6490ec6156c313d5d5324d7237  vak-examen/graines/RAPPORT-compteurs.md
b788c65e3074b9991af57f675fef6b290414dfa1c7f7f068ec287b95f959fd76  vak-examen/graines/plantes/attendu.json
a7dc886cb5b38e7992dcb3a2ca900785cf0aece1d2bb30aded43a3bf4eec6f31  vak-examen/graines/plantes/graine.sql
c98fa64d0476fb39dc379a420cfa50f6f2ea60506d80644c79d8ee83b86cf286  vak-examen/graines/agence/attendu.json
a09c042af8d904f2dc5f0e04d5311128e1f33bb20435ea5a29cee917b819c4b6  vak-examen/graines/agence/graine.sql
e859328adac87a5cf45429f10235ebaf8b1a583597f156bd04ec68e37e0b56a1  vak-examen/graines/compteurs/attendu.json
85402ccb3ac68097ea2d177dd0fdd40867bc5193dab94fda1571161619b1197f  vak-examen/graines/compteurs/graine.sql
c6c0e03637c6d062af1c251b022787ee9407ff05cec1d07983eec2e48d9bf1d4  vak-examen/graines/eprouver.mjs
e9675d55ce552bc97ddca7daddc1e3750d4fa1331ed199431260c160bb48484d  vak-examen/graines/supabase-minimum.sql
```

## La demande

L'agent reçoit la demande de la page de vak (bloc « La demande en une ligne »), mot pour mot, avec ses trois champs
remplis. Voici le texte exact, champs non remplis :

```text
Intègre l'assistant IA vak dans cette app. Métier : *<une phrase sur le métier>*. Emplacement : *<un onglet « Assistant » ou un bouton flottant sur tous les écrans>*. L'archive du kit est ici : *<chemin absolu de vak-agent-<version>.tgz>* ; c'est moi qui l'ai fournie (pour un agent en ligne, je l'ai commitée dans `vendor/vak`). Lis-la d'abord sans rien exécuter : `tar -xzOf - package/package.json < "<ce chemin>"` montre `"private": true` et aucun script d'installation (`preinstall`, `install`, `postinstall`, `prepare`). Puis lance `npx -y --package="<ce chemin>" vak init` et suis ce qu'il affiche ; une commande refusée, ne la contourne jamais : arrête-toi et donne-la-moi. Avant de me poser une question, cherche la réponse dans `node_modules/@vak/agent/docs/FAQ.md`. Mesure les vérifications de l'app avant l'installation. Tu as fini quand `node node_modules/@vak/agent/bin/vak.mjs` renvoie 0 et que la phrase « Fini pour l'agent de code » de son aide (`--help`) est vraie. S'il te manque un accès ou une clé, arrête-toi et donne-moi la commande exacte à lancer dans mon terminal.
```

Le texte est le même, mot pour mot, que celui du premier examen. Le harnais (`repetition2/messages.sh`) remplit les
trois champs :
- le métier et l'emplacement, fixés pour chaque app avant ses essais ;
- le chemin `/work/vak-agent.tgz`, où `repetition2/preparer.sh` copie l'archive.

Il place la demande entre deux phrases d'introduction et les règles de l'essai, écrites dans ce même fichier.

## L'environnement des essais

- La machine : un conteneur Linux x86_64 (Ubuntu 24.04.4 LTS, 16 Go de mémoire, 4 processeurs), dans le cloud de
  Claude Code.
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
- **Le tour choisi est le 32950012**. Il sera produit le **10 octobre 2026 à 17:30:00 UTC**. Quand ce fichier
  est publié, il n'existe pas encore.
- La commande : `node vak-examen/tirage.mjs 32950012`. Elle lit l'aléa sur un relais public de drand et vérifie sa
  signature. Elle classe ensuite les 19 apps éligibles, et prend les 2 premières apps Expo et les 2 premières apps
  Next.
- Son résultat sera publié dans `vak-examen/TIRAGE.md`, avant les essais.

## L'ordre des étapes

- **08/10** : le contrôleur et le juge « mes données » sont mis à jour par deux sessions scellées
  (`scelle/MISE-A-JOUR-2.md`, `scelle/JUGE-1.md`), chacune pour des défauts vus à l'examen ou en répétition.
- **10/10, matin** : le propriétaire décide de préparer le deuxième examen. Les 4 apps tirées le 06/10 sont exclues,
  la liste des apps éligibles est refaite par son outil.
- **10/10, 12:31 UTC** : les fiches de forme des 3 apps nouvelles sont commitées (`fiches-2/`).
- **10/10, 14:40 à 14:47 UTC** : les 3 apps sont construites par trois sessions scellées, qui n'ont reçu que leur fiche
  et `scelle/CONSTRUIRE.md` ; vérifiées ensuite sur des clones neufs (`apps/README.md`).
- **10/10, de 14:50 à 14:52 UTC** : les graines A et B des 3 apps sont écrites par trois sessions scellées
  (`scelle/GRAINES-CONSTRUITES.md`), puis éprouvées sur des bases neuves : « tout est conforme ».
- **10/10, de 14:42 à 15:24 UTC** : les 6 sabotages de la règle sont rejoués sur le contrôleur figé (mis à jour le
  08/10), dans des copies de l'essai wacrm de la répétition 4 : tous vus, avec la bonne raison ; l'essai intact reste
  « réussi » (`controleur/verdicts-sabotages-10-10/`).
- **10/10** : la règle est relue par la session de travail, ligne à ligne contre celle du premier examen. Aucun agent
  indépendant ne l'a relue cette fois : le propriétaire n'en a pas demandé, et la règle du premier examen, qui en
  forme le corps, avait été relue deux fois par un agent indépendant avant le 06/10. Ce qui change est listé
  ci-dessous.
- **10/10** : cette publication.

Seule cette publication est datée par GitHub. Les étapes d'avant le sont par l'histoire du dépôt de vak, qui n'est
pas public.

## Ce qui a changé depuis le premier examen

1. **Les apps.**
   - Les 7 apps du premier examen sortent de la liste : vak a été corrigé sur elles, en répétition, de la 0.25 à la
     0.26 (les 4 apps tirées rejoignent `candidats/exclusions.txt`).
   - Restent 19 apps éligibles, jamais vues de vak : 12 Expo, 7 Next, à leurs commits du 04/10. Aucune n'a servi au
     développement du kit : le banc de schémas de vak n'a pris que des apps ni Next ni Expo.
   - 3 apps construites nouvelles, d'après des fiches nouvelles (mêmes trois formes, domaines nouveaux, aucune plus
     facile que celle du 06/10) : des plantes d'intérieur (valeurs bornées par des CHECK) ; les dossiers d'une agence
     de voyages (un rôle qui voit sans modifier) ; des relevés de compteurs (un relevé plus petit que le précédent est
     refusé).
2. **Point 4, clause « ignore »** : écarter une table « à moi » après `fuite`, avec sa raison, est permis et noté.
   C'est un choix de sécurité (l'assistant ne doit pas montrer ce que l'app laisse fuir), que la règle du 06/10
   comptait comme un échec (company_invoicing_2). Après `non prouvé`, `total faux` ou `étroit`, c'est toujours un
   échec. Le contrôleur et le relevé mécanique de cette clause (`releve-ignore.mjs`) suivent ce texte.
3. **Les outils figés ont été réparés depuis le 06/10**, chacun pour un défaut vu à l'examen ou en répétition :
   - le contrôleur (session scellée, 08/10) : `vak --help` ne compte plus comme un `vak` ; « non prouvé » est
     reconnu ; une app en sous-dossier est mesurée dans son dossier ; une erreur de build imprimée deux fois reste
     ancienne ; la clause « ignore » ci-dessus ;
   - le juge « mes données » (session scellée, 08/10) : l'espagnol (« un solo perfil » lu 1) ;
   - la pile : le compteur de quota de vak remis à zéro avant chaque question (le quota n'est pas ce que mesure le
     point 5) ; les parties de texte d'une réponse séparées comme l'interface de vak les affiche (« ça.Deux » n'était
     pas lu) ;
   - `verdict.mjs` (raisons lisibles) et la transcription du lanceur (compte rendu final entier).
4. **Le kit gelé** : vak 0.26.1, au lieu de la 0.24.3.
5. **Le groupe témoin** n'est pas rejoué (choix du propriétaire, 10/10) : celui du 06/10 reste publié.
6. **Une précision sur les gestes** avait été proposée (« une question que l'agent a tranchée lui-même, son choix écrit
   dans le compte rendu, n'est pas restée ouverte ») ; elle n'est pas retenue. La règle reste : dans le doute, c'est
   un geste.

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
