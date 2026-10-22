# Publication avant le tirage (cinquième examen)

Publiée le 22/10/2026, avant le tirage. Ce fichier fige ce que la règle ([`REGLE.md`](REGLE.md), « La publication »)
demande de publier avant le tirage. Après lui, plus rien ne change. Les publications des quatre premiers examens
(06/10/2026, échoué : 2 essais réussis sur 14 ; 10/10/2026, échoué : 9 sur 14 ; 11/10/2026, échoué : 6 sur 14 ;
14/10/2026, échoué : 12 sur 14) restent lisibles dans l'historique de ce dépôt.

## Les empreintes

Ce sont des SHA-256. Les mêmes sont dans [`EMPREINTES.sha256`](EMPREINTES.sha256), avec des chemins pris depuis la
racine du dépôt : `sha256sum -c --ignore-missing vak-examen/EMPREINTES.sha256` vérifie tout ce qui est déjà publié.

- **La règle** : `vak-examen/REGLE.md`, `01c947c4bb0c973732dd4927fc6d720dc170ec74ea9e7a393727d47ac75d867e`.
- **L'archive gelée du kit** : `vak-agent-0.29.2.tgz` (3 010 886 octets),
  `29a2856be79e1fc35164293cff4eafa29f980d41ae53a1985d4bf47f6843e641`. C'est la seule archive des 14 essais. Son
  empreinte a été publiée sur le ticket n°5 de ce dépôt avant la construction des 3 apps (22/10, 13:08:30 UTC). Elle
  sera publiée si l'examen est réussi.
- **La page de vak**, d'où vient la demande (son README ; il n'est pas dans l'archive) : `vertical-agent-kit/README.md`,
  `3e22424f7dbf2f932cc05166bae24ca517315bdb76b253f0912ff5d1047755aa`. Elle sera publiée avec l'archive.
- **Les fiches de forme et les 3 apps construites** : `fiches-5/*.md` et `apps/randonnee.bundle`,
  `apps/troupe.bundle`, `apps/revisions.bundle`, publiées ici. Les empreintes des fiches l'ont été sur le ticket n°5
  avant la construction. Toutes sont aussi dans [`apps/SHA256SUMS`](apps/SHA256SUMS). Branches `main` des apps :
  randonnee `4f43b027399c074f06de28aff08c967a752d6bd4`, troupe `e3c2605fa1ccf3c6cdb560bef834693509c18717`, revisions
  `fd44d3346a948512168a8c16e4496fee43bf1ce3`.
- **Les graines A et B** des 3 apps construites, l'outil qui les éprouve et les comptes rendus des sessions scellées
  qui les ont écrites : les 12 fichiers de `graines/` listés plus bas. Ils seront publiés après les essais.
- **La liste des apps éligibles** : `candidats/historique.tsv`, `e5ca322efc9cc5573dcac6d08ffd14a5134c46fd3786145b64dfd1976d0b699c` : 12 apps éligibles, 6 Expo et 6 Next,
  chacune à son commit de `candidats/candidats.tsv`. La liste d'exclusion complète est
  [`candidats/exclusions.txt`](candidats/exclusions.txt) : elle exclut aussi les apps tirées des quatre premiers
  examens, une app au nom d'une app des répétitions et trois modèles de départ (plus bas, « Ce qui a changé »). Les
  champs de la demande (métier, emplacement) de chaque app éligible sont fixés dans
  [`champs-candidats.tsv`](champs-candidats.tsv), avant le tirage.
- **Les outils figés** avec la règle sont ceux de ce commit : le contrôleur (`controleur/`), le juge « mes données »
  (`mesdonnees/`, avec les cas de ses tests, `cas/`), la pile (`pile/`), `verdict.mjs`, le tirage (`tirage.mjs`,
  `candidats/`), le lecteur des étiquettes (`lecteurs.sh`, `etiquettes/`, `scelle/ETIQUETTE.md`), le relevé de la
  clause « ignore » (`releve-ignore.mjs`) et l'assemblage du résultat (`resultat.mjs`). Le lanceur (`repetition2/`,
  `essai.sh`) l'est pour le texte que reçoit l'agent, la bulle, la transcription du journal et la limite de temps.
  **Aucun de ces outils n'a changé depuis le quatrième examen** ; leurs données si : la liste des apps éligibles
  (`candidats/candidats.tsv`, `exclusions.txt`, `historique.tsv`) et les champs de la demande
  (`champs-candidats.tsv`), qui décident quelles apps peuvent être tirées et ce que l'agent reçoit. Voir « Ce qui a
  changé » plus bas.

```text
01c947c4bb0c973732dd4927fc6d720dc170ec74ea9e7a393727d47ac75d867e  vak-examen/REGLE.md
29a2856be79e1fc35164293cff4eafa29f980d41ae53a1985d4bf47f6843e641  vertical-agent-kit/releases/vak-agent-0.29.2.tgz
3e22424f7dbf2f932cc05166bae24ca517315bdb76b253f0912ff5d1047755aa  vertical-agent-kit/README.md
96086b254b3fd0ecc4470664e599526f88c431c0a9193ded4e16bb17e078d084  vak-examen/fiches-5/demarre.md
cc8661fed338173a7a6a7ea32a5d566207611bd8d121fe58e3cd1c10e5d9f442  vak-examen/fiches-5/equipe.md
367e00f757797fd52464e699807d2d815520df4131939aed6515999716fc237e  vak-examen/fiches-5/fonctions.md
142829ae370f3546975ad0a154a83f99d2ef0bc8708c45a113ef2cf4c3912cb6  vak-examen/apps/randonnee.bundle
d14143f1b0bec2bcf91c75f9d76da286babf82da677ac32f92b830b108254750  vak-examen/apps/troupe.bundle
f4effd5f1848f3a3c7d9903ca4d477bc0c976260716f571194a17f599967948a  vak-examen/apps/revisions.bundle
e5ca322efc9cc5573dcac6d08ffd14a5134c46fd3786145b64dfd1976d0b699c  vak-examen/candidats/historique.tsv
b4110d7273c17fafabdbe1a9258e7476f6ea03060650f2aec6bf9e412089e43e  vak-examen/graines/RAPPORT-randonnee.md
75f3652ed20312dcaebc29bb4ac37c5dfaa05265d76872ae0a6ce8d34a5f5c8b  vak-examen/graines/RAPPORT-troupe.md
355557af26e93ceb0759c00b376eed93eb1026a29e5bb33aea00da06955116d3  vak-examen/graines/RAPPORT-revisions.md
11ef8dee34d059aa2bb14b4fb737420402488a9c74ab110696e401e78baadc8e  vak-examen/graines/randonnee/attendu.json
e328f1a8a3228b13323170499e5f64917b72fcaa971948f815066822133f557d  vak-examen/graines/randonnee/graine.sql
baa117cb516d33c9dbffa4ccdbe324cb3271e8f94346962e1a4a1b7c5e3efbb3  vak-examen/graines/troupe/attendu.json
dde42955873bdcf82c4020a1690b1ed2acf49cda0e8dc65ed4095023fad0f72c  vak-examen/graines/troupe/graine.sql
89deeff9f9121b018db70eaec41f6e19e3564c2d43e3de65c22648810cae99cb  vak-examen/graines/revisions/attendu.json
3ca0832b5cabdeb46667d6e45d74642e7951f2b58525405539d931cc61c1ce32  vak-examen/graines/revisions/graine.sql
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

Le texte est le même, mot pour mot, que celui des quatre premiers examens : il est vérifié tel que le harnais le
lit dans la page (`repetition2/messages.sh` joint les lignes du bloc). Le harnais remplit les trois champs :
- le métier et l'emplacement, fixés pour chaque app avant ses essais ;
- le chemin `/work/vak-agent.tgz`, où `repetition2/preparer.sh` copie l'archive.

Il place la demande après trois phrases d'introduction (l'essai, personne ne répond, où est l'app) et avant les
règles de l'essai et la consigne du compte rendu, écrites dans ce même fichier.

## L'environnement des essais

- La machine : un conteneur Linux x86_64 (Ubuntu 24.04.5 LTS, 16 Go de mémoire, 4 processeurs), dans le cloud de
  Claude Code. C'est le même type de machine qu'aux quatre premiers examens. Le conteneur redémarre parfois de
  lui-même (plusieurs fois le 22/10) ; PostgreSQL ne repart pas seul, l'installateur de la machine le relance. Un essai
  coupé ainsi n'a pas eu lieu et il est rejoué à neuf (la règle, « Un essai coupé par la machine »).
- Node 22.22.0.
- PostgreSQL 16.15 (paquet `postgresql-16` 16.15-0ubuntu0.24.04.1), avec pgTAP 1.3.2 (`postgresql-16-pgtap`) pour
  les tests du kit. Aucune autre extension n'est ajoutée, pgvector compris. Son paquet (`postgresql-16-pgvector`
  0.6.0), que l'installateur de la machine pose pour les tests du kit, a été retiré le 22/10 avant la vérification des
  nouvelles apps candidates, puis de nouveau après chaque passage de l'installateur. Il a été présent quelques secondes
  vers 12:07 UTC, puis moins d'une minute au début de la construction des apps (13:10:30 à 13:11:12 UTC), chaque fois
  que l'installateur relançait PostgreSQL après un redémarrage, sans effet : aucune app construite ne crée
  l'extension. Son absence est vérifiée avant le premier essai et après chaque redémarrage de la machine pendant
  l'examen, et chaque vérification est notée, avec son heure, dans le journal de l'examen (`EXAMEN.md`).
- La CLI Supabase 2.118.0, la version que fixe l'archive gelée. Pas de Docker.
- L'agent :
  - Claude Code 2.1.308 à cette publication (`claude -p`, mode `bypassPermissions`), avec le modèle par défaut de
    cette version ; la version de chaque essai, consignée dans son `lanceur.json` et publiée avec lui, fait foi. Le
    modèle par défaut n'est pas publié, et rien ici ne dit s'il est le même qu'avec les versions des examens passés
    (2.1.291 au premier, 2.1.296 aux deuxième et troisième, 2.1.299 au quatrième) ;
  - il tourne dans la bulle de `repetition2/lancer.sh`. Elle lui cache la session, `/srv`, le `/tmp` de la machine
    et les autres essais de `/work` (vides pour lui). Les bases locales sont supprimées avant chaque essai.
- La pile « mes données » :
  - PostgREST 12.2.12 et Deno 2.9.6 ;
  - pour l'assistant, le modèle `deepseek-flash` par l'API de DeepSeek, avec la clé du propriétaire.

## Le tirage

- La chaîne drand « quicknet » : `52db9ba70e0cc0f6eaf7803dd07447a1f5477735fd3f661792ba94600c84e971`. Elle produit un
  tour toutes les 3 secondes depuis le 23/08/2023 à 15:09:27 UTC (genèse 1692803367).
- **Le tour choisi est le 33293812**. Il sera produit le **22 octobre 2026 à 16:00:00 UTC**. Quand ce fichier est
  publié, il n'existe pas encore.
- La commande : `node vak-examen/tirage.mjs 33293812`. Elle lit l'aléa du tour sur un relais public de drand et
  contrôle qu'il est bien l'empreinte SHA-256 de sa signature ; elle ne vérifie pas la signature elle-même avec la clé
  publique de la chaîne (chacun peut comparer l'aléa sur un autre relais, ou le vérifier avec un client drand). Elle
  classe ensuite les 12 apps éligibles, et prend les 2 premières apps Expo et les 2 premières apps Next. Les
  publications des examens passés disaient à tort qu'elle vérifie la signature.
- Son résultat sera publié dans `vak-examen/TIRAGE.md`, avant les essais.

## L'ordre des étapes

- **14/10, 21:46 UTC** : le quatrième examen est publié, échoué (12 sur 14), avec les quatre défauts de vak qu'il a
  trouvés, H1 à H4 (son `EXAMEN.md`, dans l'historique de ce dépôt).
- **20/10** : vak 0.29.0 corrige H1 à H4, chacun avec un test qui échoue sans sa correction : la préparation des
  données d'essai de la preuve, qui réessaie une ligne refusée par un déclencheur de l'app (H1) ; l'étiquette, qui
  nomme les tables qu'une fonction de l'app écrit (H2) ; la forme du compte rendu final, rappelée par `vak` juste
  avant sa ligne finale (H3) ; le thème de l'app, que `vak init` marque à reprendre (H4).
- **20/10 au 21/10, 06:10 UTC** : une répétition privée rejoue, avec la 0.29.0, les 6 essais du quatrième examen
  ratés ou sous un seuil (journal, prets, split_free_frontend, deux fois chacun, aux mêmes commits) : 5 réussis sur
  6. Un défaut nouveau, **H5** : vak proposait d'appeler deux fonctions de split_free_frontend que l'utilisateur
  connecté ne peut pas appeler (un schéma de l'app sans le droit `USAGE`), puis interdisait de les retirer.
- **21/10** : vak 0.29.1 corrige H5 et resserre H3 et H4, chacun avec un test qui échoue sans sa correction ; une
  répétition privée de split_free_frontend (deux essais) : 2 réussis sur 2. Puis vak 0.29.2 corrige les constats d'une
  relecture adverse de la 0.29.1, chacun avec un test qui échoue sans sa correction.
- **21/10, de 16:44 à 17:18 UTC** : une répétition privée avec la 0.29.2 (journal, prets, split_free_frontend, un
  essai chacun) : 3 réussis sur 3, tous les seuils par essai tenus. Les résultats des répétitions privées ne sont pas
  publiés et ne comptent pas. Aucune de leurs apps n'est de ce cinquième examen, mais deux fiches reprennent la forme
  de journal et de prets (plus bas, « Les apps »).
- **21/10 et 22/10** : le propriétaire décide le cinquième examen (« Répétition puis examen », puis, la répétition
  bonne, « Oui, lance-le »). Les 4 apps tirées le 14/10 sont exclues.
- **22/10, de 07:14 à 07:20 UTC** : il ne restait qu'une app Next éligible. Une session scellée, sans le dépôt de vak,
  examine 95 dépôts nouveaux avec `candidats/verifier.mjs`, inchangé : 9 nouvelles apps éligibles (7 Next, 2 Expo).
  Elle a reçu sa consigne (`scelle/CANDIDATS-2.md`), la règle du quatrième examen (celle du cinquième n'était pas encore
  écrite ; les critères d'éligibilité sont les mêmes) et quatre fichiers de `candidats/` (`verifier.mjs`,
  `candidats.tsv`, `exclusions.txt`, `README.md`). La liste est refaite par `historique.mjs`. Une app jugée éligible
  par l'outil est écartée à la main, dans le doute (elle porte le nom d'une app des répétitions) ; une app éligible du
  04/10 ne se clone plus.
- **22/10, de 07:30 à 12:47 UTC** : les fiches de forme des 3 apps nouvelles sont écrites, relues par trois tours de
  relectures adverses (équité, constructeur, cohérence avec les fiches passées, puis graines et juge), et commitées
  (`fiches-5/`). La parenté avec deux apps du quatrième examen et les traits nouveaux sont dits dans la règle.
- **22/10, 13:08:30 UTC** : les empreintes des fiches et de l'archive gelée sont publiées sur le ticket n°5 de ce
  dépôt, avant la construction.
- **22/10, de 13:10:27 à 13:16 UTC** : les 3 apps sont construites par trois sessions scellées, qui n'ont reçu que
  leur fiche et `scelle/CONSTRUIRE.md` ; vérifiées ensuite sur des clones neufs (`apps/README.md`).
- **22/10, de 13:22:21 à 13:23:41 UTC** (écriture et épreuve) : les graines A et B des 3 apps sont écrites par trois
  sessions scellées (`scelle/GRAINES-CONSTRUITES.md`), puis éprouvées sur des bases neuves : « tout est conforme » pour
  les trois. Un premier passage, de 13:19 à 13:20 UTC, avait la même consigne, dont le titre disait encore « quatrième
  examen » : il a été écarté et relancé une fois le titre corrigé (ses graines étaient aussi conformes).
- **22/10, de 14:35:18 à 14:36:30 UTC** : la relecture finale a vu que la graine de revisions datait deux révisions de
  A après les essais (24/10 et 30/10), ce qui ouvrait une seconde lecture de « mes révisions ». La graine de revisions
  seule est réécrite par une nouvelle session scellée, même consigne : « tout est conforme », toutes les révisions de A
  datées avant le 22/10. Puis les 3 graines sont éprouvées sur la base même de la pile (`graines/eprouver-pile.mjs`,
  `vak localdb` de la 0.29.2) : « tout est conforme », 104 vérifications (randonnee 31, troupe 38, revisions 35 ;
  `graines/EPREUVE-PILE-5.txt`, publié avec les graines).
- **22/10** : les champs de la demande des 9 nouvelles apps éligibles sont fixés (`champs-candidats.tsv`), chacun
  d'après le README et la navigation de l'app à son commit (pour clix, dont le README n'est qu'un gabarit, d'après ce
  que l'app dit d'elle-même sur sa page d'accueil), puis vérifié par une seconde lecture. Ils sont écrits par des agents
  lancés par la session de travail, qui connaît vak, sans rien installer ni exécuter des apps.
- **22/10** : la relecture finale relève aussi que trois des apps ajoutées sont des modèles de départ ; ils sont
  écartés à la main, avant le tirage (plus bas) : restent **12 apps éligibles, 6 Expo et 6 Next**.
- **22/10** : la règle, cette publication, les apps et leurs graines sont relues par la session de travail, ligne à
  ligne contre celles du quatrième examen, et par des relectures adverses (agents de la même famille de modèles, sans
  écrire). Ce qui change est listé ci-dessous.
- **22/10** : cette publication.

Seuls la publication du quatrième examen (commit `ff57d67`), le ticket n°5 et cette publication sont datés par
GitHub. Les autres étapes le sont par l'histoire du dépôt de vak, qui n'est pas public.

## Ce qui a changé depuis le quatrième examen

0. **La règle.** Même règle qu'au quatrième examen, sauf :
   - **la façon de compter les gestes humains** (« Comment on compte les seuils »), acceptée par le propriétaire le
     20/10 et suivie par les répétitions privées : un geste est aussi une action laissée à faire ; le circuit de
     contribution du dépôt de l'app (issue, branche, demande de fusion), s'il est nécessaire, compte pour un seul geste ;
     une question n'est pas un geste si le compte rendu la donne tranchée avec la façon d'y revenir, et en est un
     sinon (une supposition ou un choix « à confirmer » aussi) ; seule une suggestion facultative **marquée comme
     telle** n'en est pas un. C'est la lecture stricte qu'avait suivie le recompte du quatrième examen
     (`recompte-gestes-4.json`), sauf le circuit de contribution, compté là un geste par commande. **Sur ce point, la
     règle est plus douce pour vak** que le compte du quatrième examen, et elle a été écrite après lui, sur ce cas même
     : à split_free_frontend_1, les trois commandes du circuit y comptaient pour trois gestes (4 en tout, pour 3 au
     plus), et compteraient pour un. Ailleurs, elle est plus dure (une action laissée à faire compte ; une suggestion
     facultative n'est écartée que marquée comme telle). Les répétitions privées l'ont suivie : leur « tous les seuils
     par essai tenus » en dépend (à split_free_frontend_14 et _16, le circuit, donné en plusieurs commandes, est compté
     pour un geste) ;
   - l'exclusion des 28 apps des quatre premiers examens, de leurs copies et de leurs propriétaires (les 16 apps
     tirées dans `candidats/exclusions.txt`), d'une app écartée à la main, et des modèles de départ (un dépôt qui se dit
     lui-même modèle, starter, template ou boilerplate) : les examens passés en avaient pris, ils n'en prennent plus ;
   - la liste des apps éligibles complétée le 22/10 ;
   - les fiches `fiches-5/`, ce qui est su de leur parenté avec les apps passées, et qui les a écrites (la session
     qui écrit vak, après le gel du kit et ses répétitions privées) ;
   - le kit gelé publié avec les fiches, avant la construction des 3 apps ;
   - la version de Claude Code des examens passés, et celle de celui-ci dans ce fichier ; le groupe témoin, toujours
     pas rejoué.
1. **Les apps.**
   - Les 7 apps du quatrième examen sortent de la liste : vak a été corrigé sur trois d'entre elles (journal, prets,
     split_free_frontend : H1, H2, H5), puis rejoué sur elles en répétition ; toutes ont été vues (les 4 apps tirées
     rejoignent `candidats/exclusions.txt`).
   - Restent 12 apps éligibles, jamais vues de vak : 6 de la liste du 04/10 (à leurs commits du 04/10) et 6 ajoutées
     le 22/10 (à leurs commits du 22/10). Aucune n'a servi au développement du kit. Trois autres apps ajoutées le 22/10
     sont des modèles de départ (`app-template`, `nextjs-supabase-auth-starter`, `next-supabase-starter`) : elles
     remplissaient les critères de `verifier.mjs`, mais sont écartées à la main, avant le tirage (la règle veut de
     vraies apps ; deux n'avaient qu'une table « à moi », le profil du compte). Les examens passés avaient pris des
     modèles (my_saas_boilerplate au deuxième, supabase_nextjs_template et hikari au troisième). Dans le doute, contre
     vak : vak a été développé et corrigé sur des modèles de ce genre.
   - 3 apps construites nouvelles, sur des domaines jamais pris par un examen ni par les exemples du kit : un carnet de
     randonnée ; les spectacles d'une troupe de théâtre amateur (un titulaire et une doublure par personnage) ; des
     cartes de révision (trois tables, une fonction qui écrit deux tables, un compte remonté sur deux niveaux par un
     déclencheur, des refus de doublon, un effacement refusé selon une date).
   - Leurs fiches reprennent les trois formes de la règle, et la structure de celles du quatrième examen. Au quatrième
     examen, vak a réussi deux fois l'app de la première forme (disques) ; il a été corrigé sur les deux autres
     (journal, H1 ; prets, H2), puis les a réussies en répétition privée. Elles sont écrites par la session qui écrit
     vak, après le gel du kit : elle sait ce que le kit gelé traite. La règle le dit (« Les apps : 7, jamais vues »),
     avec un exemple : la fiche d'équipe dit qu'un `viewer` ne joue aucun personnage, et le constructeur en a tiré un
     déclencheur qui refuse des lignes, le cas même de H1.
   - La consigne de construction (`scelle/CONSTRUIRE.md`) n'a pas changé.
2. **Le kit gelé** : vak 0.29.2, au lieu de la 0.28.1. Il corrige les quatre défauts trouvés par le quatrième examen
   (H1 à H4) et celui que la répétition privée de la 0.29.0 a montré (H5), plus des constats de relectures (plus haut,
   « L'ordre des étapes »).
3. **Les outils figés** n'ont pas changé depuis le quatrième examen. Les 6 sabotages ne sont pas rejoués : le
   contrôleur n'a pas changé depuis leur rejeu du 13/10 (`controleur/verdicts-sabotages-13-10/`). Changent :
   - les données de la liste et des demandes, qui décident quelles apps peuvent être tirées et ce que l'agent reçoit :
     `candidats/candidats.tsv`, `README.md` (« Ajouts du 22/10/2026 »), `exclusions.txt` et `historique.tsv` (plus
     haut) ; `champs-candidats.tsv` (les champs des 9 apps ajoutées) ; `verifier.mjs` et `historique.mjs` sont
     inchangés ;
   - sans effet sur les essais : `scelle/lancer.sh`, un mode `CANDIDATS=1` pour la session qui a complété la liste, et
     `scelle/CANDIDATS-2.md`, sa consigne ; le titre de `scelle/GRAINES-CONSTRUITES.md` (« cinquième examen ») ;
     `AVANT-ESSAIS.md`, remis à son modèle, et `TIRAGE.md`, `tirage-tour.json` et `graines-tirees.tsv` du quatrième
     examen, retirés de l'arbre (ils sont refaits après le tirage) ;
   - après cette publication, avant le tirage : la ligne de `tirage-publier.mjs` qui cite la publication et le ticket
     du tirage, mise à jour avec le commit de cette publication (comme à chaque examen ; le calcul du tirage,
     `tirage.mjs`, ne change pas).
4. **Le groupe témoin** n'est pas rejoué, comme aux deuxième, troisième et quatrième examens. C'est le choix du
   propriétaire du 10/10, reconduit sans nouvelle décision : son accord du 21/10 au cinquième examen ne portait pas sur
   le témoin. Celui du 06/10 reste publié.
5. **L'environnement.** Mise à jour de la machine, non choisie pour l'examen : Claude Code 2.1.308 au lieu de 2.1.299.
   Restent les mêmes : Ubuntu 24.04.5, Node 22.22.0, PostgreSQL 16.15, la CLI Supabase 2.118.0, PostgREST 12.2.12,
   Deno 2.9.6 et le modèle de l'assistant. pgvector est retiré (plus haut, « L'environnement des essais »).

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
