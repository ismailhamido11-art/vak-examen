# Publication avant le tirage (quatrième examen)

Publiée le 14/10/2026, avant le tirage. Ce fichier fige ce que la règle ([`REGLE.md`](REGLE.md), « La publication »)
demande de publier avant le tirage. Après lui, plus rien ne change. Les publications des trois premiers examens
(06/10/2026, échoué : 2 essais réussis sur 14 ; 10/10/2026, échoué : 9 sur 14 ; 11/10/2026, échoué : 6 sur 14)
restent lisibles dans l'historique de ce dépôt.

## Les empreintes

Ce sont des SHA-256. Les mêmes sont dans [`EMPREINTES.sha256`](EMPREINTES.sha256), avec des chemins pris depuis la
racine du dépôt : `sha256sum -c --ignore-missing vak-examen/EMPREINTES.sha256` vérifie tout ce qui est déjà publié.

- **La règle** : `vak-examen/REGLE.md`, `9150f623d000aa26ad6f3f1b39ab8127ef7fa88e8f3d9738cfa3089b8565f67e`.
- **L'archive gelée du kit** : `vak-agent-0.28.1.tgz` (2 999 778 octets),
  `b95df736c5b65e317856976d4754e9497ce9868743b4725c141ea584da636d26`. C'est la seule archive des 14 essais. Elle
  sera publiée si l'examen est réussi.
- **La page de vak**, d'où vient la demande (son README ; il n'est pas dans l'archive) : `vertical-agent-kit/README.md`,
  `cdade98b5e0a84f9147f16bc739b183f7cf4ebedd0014d0bbafec5f28c60a092`. Elle sera publiée avec l'archive.
- **Les fiches de forme et les 3 apps construites** : `fiches-4/*.md` et `apps/disques.bundle`, `apps/journal.bundle`,
  `apps/prets.bundle`, publiées ici. Leurs empreintes sont aussi dans [`apps/SHA256SUMS`](apps/SHA256SUMS).
  Branches `main` des apps : disques `398bb03d983fe88fe3e97d720c90dfea67d9269a`, journal `af3d891a02374dbc938f61018bbd6f690573d729`, prets `9c8fe30d622d869a72ee04cff55e3d4e0740f162`.
- **Les graines A et B** des 3 apps construites, l'outil qui les éprouve et les comptes rendus des sessions scellées
  qui les ont écrites : les 12 fichiers de `graines/` listés plus bas. Ils seront publiés après les essais.
- **La liste des apps éligibles** : `candidats/historique.tsv`,
  `93c506039e5a6a4c63956322440daf355324008a8a177137b3fa4011c63e043a` : 11 apps éligibles, 8 Expo et 3 Next, chacune
  à son commit de `candidats/candidats.tsv`. La liste d'exclusion complète est
  [`candidats/exclusions.txt`](candidats/exclusions.txt) : elle exclut aussi les apps tirées des trois premiers
  examens.
- **Les outils figés** avec la règle sont ceux de ce commit : le contrôleur (`controleur/`), le juge « mes données »
  (`mesdonnees/`, avec les cas de ses tests, `cas/`), la pile (`pile/`), `verdict.mjs`, le tirage (`tirage.mjs`, `candidats/`), le lecteur des
  étiquettes (`lecteurs.sh`, `etiquettes/`, `scelle/ETIQUETTE.md`), le relevé de la clause « ignore »
  (`releve-ignore.mjs`) et l'assemblage du résultat (`resultat.mjs`). Le lanceur (`repetition2/`, `essai.sh`) l'est
  pour le texte que reçoit l'agent, la bulle, la transcription du journal et la limite de temps. Quatre de ces outils
  ont changé depuis le troisième examen, pour des limites qu'il avait montrées : voir « Ce qui a changé » plus bas.
  S'y ajoutent, sans effet sur les essais : `etiquettes/rejouer.sh` (13/10), un rejeu sans IA de la preuve sur l'état
  d'un essai, pour le développement du kit, qu'aucun outil de l'examen n'appelle (il lit le code source du kit, non
  publié) ; les verdicts du contrôleur mis à jour sur quatre essais passés (`controleur/verdicts-examen-11-10/`) ; la
  mesure du lanceur (`repetition2/mesurer.mjs`), réparée pendant le troisième examen (dépôt public, commit
  `ed556d0`) ; le titre de `scelle/GRAINES-CONSTRUITES.md`. L'épreuve des graines sur la base de la pile
  (`graines/eprouver-pile.mjs`) sert aussi.

```text
9150f623d000aa26ad6f3f1b39ab8127ef7fa88e8f3d9738cfa3089b8565f67e  vak-examen/REGLE.md
b95df736c5b65e317856976d4754e9497ce9868743b4725c141ea584da636d26  vertical-agent-kit/releases/vak-agent-0.28.1.tgz
cdade98b5e0a84f9147f16bc739b183f7cf4ebedd0014d0bbafec5f28c60a092  vertical-agent-kit/README.md
9ff1293d9c3c4774b9f098dd0c476d4b5174a9113f3c17e37255210b8fa3d73b  vak-examen/fiches-4/demarre.md
2f67bb0560ed57c0cf75d4fa872bda82375985d5035e05de4ea6a31a5f7ba9e5  vak-examen/fiches-4/equipe.md
bb198c976c4846fb49238dbd63db03971f76308dae29160a4c0d396bc5482a93  vak-examen/fiches-4/fonctions.md
e6b4c93c4240a8d2cf9cfe2aa25d4233e636b46a3c7507b7e22d77848bcd44f5  vak-examen/apps/disques.bundle
e0d2a55ba403a538d80be4bd9a0fede25e221217fe40db3ec45830960f8e4bbd  vak-examen/apps/journal.bundle
571f8cdae0e460ee4d130139b6fd6f70d2b835176922a737af84ea699e17636f  vak-examen/apps/prets.bundle
93c506039e5a6a4c63956322440daf355324008a8a177137b3fa4011c63e043a  vak-examen/candidats/historique.tsv
a80d74e674def7ec8185c432b2eac77022dfd48e4c8503a00d8d44b830937bbb  vak-examen/graines/RAPPORT-disques.md
ddae2d097de0cc56637c810d763eea9d030a6c18bd821439ce30569881f5b4d9  vak-examen/graines/RAPPORT-journal.md
414b968b322c0e5d9fa21bf69194d266b9f4371bec6ec5680899a5207afc143e  vak-examen/graines/RAPPORT-prets.md
c6f81fe6073f0ff5fe790ba033be9d58fc4c36fca76a34232cc9834fb08c7631  vak-examen/graines/disques/attendu.json
68e4167750d290059c297018e15304704bfa2553e7ec0d355103b3978324eb63  vak-examen/graines/disques/graine.sql
566f1a5379f6056d203b795b30666baf203b3eca79aa7c61488f8b440c5b62aa  vak-examen/graines/journal/attendu.json
409a0ced225e65161dea185e8593a8ae7ce643719f22820fe045ffdcb8eb55bc  vak-examen/graines/journal/graine.sql
40e3de9f32842cf640f18588fc75e936d58016e64c757082f45f0ae9a1e57d4d  vak-examen/graines/prets/attendu.json
51991e7e7dbf28c88c7751a62fd48e0f8173f0566d22f542ea87de5dd59d905a  vak-examen/graines/prets/graine.sql
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

Le texte est le même, mot pour mot, que celui des trois premiers examens : la page de vak n'a changé que par le
numéro de l'archive, ailleurs que dans ce bloc. Le harnais (`repetition2/messages.sh`) remplit les trois champs :
- le métier et l'emplacement, fixés pour chaque app avant ses essais ;
- le chemin `/work/vak-agent.tgz`, où `repetition2/preparer.sh` copie l'archive.

Il place la demande après trois phrases d'introduction (l'essai, personne ne répond, où est l'app) et avant les
règles de l'essai et la consigne du compte rendu, écrites dans ce même fichier.

## L'environnement des essais

- La machine : un conteneur Linux x86_64 (Ubuntu 24.04.5 LTS, 16 Go de mémoire, 4 processeurs), dans le cloud de
  Claude Code. C'est le même type de machine qu'aux trois premiers examens.
- Node 22.22.0.
- PostgreSQL 16.15 (paquet `postgresql-16` 16.15-0ubuntu0.24.04.1), avec pgTAP 1.3.2 (`postgresql-16-pgtap`) pour
  les tests du kit. Aucune autre extension n'est ajoutée, pgvector compris. Son paquet (`postgresql-16-pgvector`
  0.6.0), que l'installateur de la machine pose pour les tests du kit et pour des apps qui créent l'extension, était
  présent du 13/10, 08:37 UTC, au 14/10, 12:49 UTC : la répétition privée du 14/10 l'avait. Il a été retiré avant les
  fiches et la construction des apps, avec l'accord du propriétaire, et son absence est vérifiée avant les essais.
  Aux deuxième et troisième examens, dont la règle disait la même chose, cette absence n'avait pas été vérifiée ;
  aucun de leurs essais n'a touché à `vector`.
- La CLI Supabase 2.118.0, la version que fixe l'archive gelée. Pas de Docker.
- L'agent :
  - Claude Code 2.1.299 à cette publication (`claude -p`, mode `bypassPermissions`), avec le modèle par défaut de
    cette version ; la version de chaque essai, consignée dans son `lanceur.json` et publiée avec lui, fait foi. Le
    modèle par défaut n'est pas publié, et rien ici ne dit s'il est le même qu'avec la version 2.1.296 des deuxième
    et troisième examens ;
  - il tourne dans la bulle de `repetition2/lancer.sh`. Elle lui cache la session, `/srv`, le `/tmp` de la machine
    et les autres essais de `/work` (vides pour lui). Les bases locales sont supprimées avant chaque essai.
- La pile « mes données » :
  - PostgREST 12.2.12 et Deno 2.9.6 ;
  - pour l'assistant, le modèle `deepseek-flash` par l'API de DeepSeek, avec la clé du propriétaire.

## Le tirage

- La chaîne drand « quicknet » : `52db9ba70e0cc0f6eaf7803dd07447a1f5477735fd3f661792ba94600c84e971`. Elle produit un
  tour toutes les 3 secondes depuis le 23/08/2023 à 15:09:27 UTC (genèse 1692803367).
- **Le tour choisi est le 33062212**. Il sera produit le **14 octobre 2026 à 15:00:00 UTC**. Quand ce fichier est publié, il n'existe
  pas encore.
- La commande : `node vak-examen/tirage.mjs 33062212`. Elle lit l'aléa sur un relais public de drand et vérifie sa
  signature. Elle classe ensuite les 11 apps éligibles, et prend les 2 premières apps Expo et les 2 premières apps
  Next.
- Son résultat sera publié dans `vak-examen/TIRAGE.md`, avant les essais.

## L'ordre des étapes

- **11/10, 03:43 UTC** : le troisième examen est publié, échoué (6 sur 14), avec les six défauts de vak qu'il a
  trouvés (G1 à G5 et MFA) et les limites des outils figés (son `EXAMEN.md`, dans l'historique de ce dépôt).
- **13/10** : vak 0.28.0 corrige G1 à G5 et MFA, chacun avec un test qui échoue sans sa correction. Les outils de
  l'examen sont corrigés (plus bas, « Ce qui a changé »), le juge et le contrôleur par deux sessions scellées ; les
  6 sabotages de la règle sont rejoués sur le contrôleur mis à jour, de 15:49 à 16:35 UTC : tous vus, avec la bonne
  raison ; l'essai intact reste « réussi » (`controleur/verdicts-sabotages-13-10/`). Le contrôleur n'a pas changé
  depuis.
- **14/10, matin** : vak 0.28.1. Elle porte les correctifs d'une relecture du 07/10, dont un faux « éprouvé » de la
  preuve, et F6 : une phrase des consignes de l'assistant pour « combien de mes … » sans précision (« d'abord le
  total de toutes les lignes de l'utilisateur, même si une règle de l'app restreint le mot, puis la part
  restreinte »). F6 vient d'un essai raté d'une répétition privée du 07/10 (equipe_4, une app construite du premier
  examen) ; la phrase a été éprouvée sur le modèle de l'assistant des essais : 22 réponses justes sur 22, contre 0
  sur 8 avec la phrase d'avant. Elle vise la forme même des questions du juge (point 5), qui lit le premier nombre
  de la réponse.
- **14/10, de 10:03 à 12:20 UTC** : une répétition privée rejoue, avec vak 0.28.1 et ces outils, les 8 essais
  ratés au troisième examen (abonnements, habitquest, supabase_nextjs_template et workout_app, à leurs mêmes
  commits) : 8 réussis sur 8. Ses résultats ne sont pas publiés et ne comptent pas. Aucune de ces apps n'est de ce
  quatrième examen, mais la fiche des prêts d'objets reprend la forme de celle des abonnements (plus bas, « Les
  apps »).
- **14/10** : le propriétaire décide le quatrième examen. Les 4 apps tirées le 11/10 sont exclues, la liste des apps
  éligibles est refaite par son outil (seules leurs 4 lignes changent).
- **14/10, 12:51:28 UTC** : les fiches de forme des 3 apps nouvelles sont commitées (`fiches-4/`), puis leurs
  empreintes publiées sur le ticket n°4 de ce dépôt (12:51:48 UTC), avant la construction (lancée à 12:51:54 UTC).
- **14/10, de 12:51:54 à 12:59 UTC** : les 3 apps sont construites par trois sessions scellées, qui n'ont reçu que
  leur fiche et `scelle/CONSTRUIRE.md` ; vérifiées ensuite sur des clones neufs (`apps/README.md`).
- **14/10, de 12:59:58 à 13:01:19 UTC** : les graines A et B des 3 apps sont écrites par trois sessions scellées
  (`scelle/GRAINES-CONSTRUITES.md`), puis éprouvées sur des bases neuves : « tout est conforme » pour les trois ;
  puis sur la base même de la pile (`graines/eprouver-pile.mjs`, `vak localdb` de la 0.28.1) : « tout est
  conforme », 107 vérifications (disques 30, journal 54, prets 23). Chaque session des graines n'a reçu qu'une app
  (`graines-tirees.sh` en lance une par app) ; la consigne parle des 3 apps, ce que leurs comptes rendus relèvent.
- **14/10** : la règle, cette publication, les apps et leurs graines sont relues par la session de travail, ligne à
  ligne contre celles du troisième examen, et par six relectures adverses (agents de la même famille de modèles, sans
  écrire). Ce qui change est listé ci-dessous.
- **14/10** : cette publication.

Seuls la publication du troisième examen (commit `b3e8c89`), le ticket n°4 et cette publication sont datés par
GitHub. Les autres étapes le sont par l'histoire du dépôt de vak, qui n'est pas public.

## Ce qui a changé depuis le troisième examen

0. **La règle.** Même règle qu'au troisième examen, sauf : l'exclusion des 21 apps des trois premiers examens, de leurs
   copies et de leurs propriétaires (les 12 apps tirées dans `candidats/exclusions.txt`) ; les fiches `fiches-4/` ;
   la version de Claude Code des examens passés, et celle de celui-ci dans ce fichier ; le texte sur le contrôleur,
   qui dit ses mises à jour ; la place de la demande dans le message de l'essai, décrite comme elle est ; le groupe
   témoin, toujours pas rejoué.
1. **Les apps.**
   - Les 7 apps du troisième examen sortent de la liste : vak a été corrigé sur quatre d'entre elles (G1 à G5 et
     MFA), puis rejoué sur elles en répétition ; toutes ont été vues (les 4 apps tirées rejoignent
     `candidats/exclusions.txt`).
   - Restent 11 apps éligibles, jamais vues de vak : 8 Expo, 3 Next, à leurs commits du 04/10. Aucune n'a servi au
     développement du kit.
   - 3 apps construites nouvelles, sur des domaines jamais pris par un examen ni par les exemples du kit : une
     collection de disques ; la rédaction d'un journal de quartier (un rôle qui voit sans modifier) ; les prêts
     d'objets (des fonctions qui refusent selon l'état d'un prêt, la liste des prêts en retard à une date, un
     compteur tenu par un déclencheur ; les arguments simples des fonctions sont laissés au choix du constructeur).
   - Leurs fiches reprennent les trois formes de la règle, et la structure de celles du troisième examen : une table
     et ses événements, une équipe à trois rôles, des écritures par fonctions avec des objets `changes jsonb` et
     `details jsonb` et une fonction qui rend des lignes pour une date. Au troisième examen, vak a réussi deux fois
     les apps des deux premières formes (cuisine, club) ; il a été corrigé sur la troisième (abonnements, G1 et G5),
     puis l'a réussie deux fois en répétition privée. Leurs formes de données (type énuméré, liste de textes,
     fonction qui rend des lignes, déclencheur, argument à valeur par défaut) figurent aussi dans des apps passées
     ou dans les hôtes de test du kit : elles ne sont pas nouvelles pour vak.
   - La consigne de construction (`scelle/CONSTRUIRE.md`) demande en plus d'appeler chaque fonction de la fiche, et
     de vérifier qu'aucun utilisateur ne voit ni ne modifie les lignes de l'autre par une fonction (les constructeurs
     des examens passés l'avaient fait d'eux-mêmes).
2. **Le kit gelé** : vak 0.28.1, au lieu de la 0.27.0. Il corrige les six défauts trouvés par le troisième examen :
   la valeur d'un argument simple de fonction prise dans la ligne de A (G1), la ligne posée par un déclencheur
   retrouvée par l'unicité de sa table (G2), bun absent de la machine (G3), les colonnes facultatives que des vues
   veulent non vides (G4), l'étiquette qui dit « Jamais : supprimer une ligne » quand le code de l'app ne supprime
   pas (G5), la RLS par niveau MFA de Supabase (MFA). Et les correctifs d'une relecture du 07/10, avec F6 (plus haut,
   « L'ordre des étapes »).
3. **Les outils figés.** Le troisième examen a montré des limites des outils, notées dans son `EXAMEN.md` (« Hors de
   vak ») : avec eux, même un vak sans défaut ne pouvait pas réussir plus de 10 essais sur 14. Elles sont corrigées.
   Le jeton du relais, le juge et le contrôleur ont chacun un test qui échoue sans sa correction
   (`pile/tests/relais.test.mjs`, `mesdonnees/tests/juger.test.mjs`, `controleur/tests/`). `pile/mfa.sql` et
   `resultat.mjs` n'en ont pas : le premier a été rejoué sur une vraie pile, sur l'état de supabase_nextjs_template_1
   (point 5 « juste », là où l'examen avait « juge en erreur ») ; le second sur les 14 essais du troisième examen
   (même sortie que `resultat-corrige.mjs`, là où il plantait) :
   - **la pile** (`pile/relais.mjs`, `pile/mfa.sql`, `pile/pile.sh`) : ses jetons portent, comme ceux de Supabase
     Auth après une connexion par mot de passe, `aal: "aal1"`, `amr`, `session_id` et `is_anonymous` ; la table
     `auth.mfa_factors` est posée si le vak de l'app ne l'a pas fait ;
   - **le juge « mes données »** (`mesdonnees/`), mis à jour par une session scellée (`scelle/JUGE-2.md`) : son
     comptage SQL pose les mêmes revendications que le jeton de la pile ; « il n'y en a qu'un » est lu 1 ;
   - **le contrôleur** (`controleur/`), mis à jour par une session scellée (`scelle/MISE-A-JOUR-3.md`) : une app bun
     est traitée comme les autres (`bun.lock` comparé comme les autres verrous ; bun, absent de la bulle, est pris par
     `npx -y --package=bun@<version>`) ; le chemin du clone est retiré des erreurs comparées ; un « code=0 » ne compte
     plus que s'il sort d'un `echo` qui suit directement ce `vak` et donne son code (`$?`, `${PIPESTATUS[0]}`), et une
     ligne `vak … [code N]` (N ≠ 0) dans la même sortie annule ce repli et la phrase « Fini pour l'agent de code »
     (`controleur/README.md`, « Mise à jour 3 ») ;
   - **`resultat.mjs`** lit une ligne de verdict écrite sur plusieurs lignes (au troisième examen, sa copie
     `resultat-corrige.mjs` l'avait fait à sa place).

   Une seule limite est laissée : le juge lit les puces d'une ligne unique comme des éléments, mais le nombre lu dans
   une liste ne décide pas du point 5 (la règle, point 5). Le `EXAMEN.md` publié du troisième examen dit qu'à
   workout_app_2 le juge « met le point 5 à faux » : c'est inexact. Le juge y rend son propre verdict « faux », mais le
   nombre lu dans une liste ne décide pas du point 5 (`verdict.mjs`), et cet essai échouait déjà au contrôleur (points
   1, 4 et 6) ; le verdict de cet examen ne change pas. La ligne de `tirage-publier.mjs` qui cite la publication et le
   ticket du tirage suit en plus chaque examen (au troisième : commit `b86b760`, ticket n°3).
4. **Le groupe témoin** n'est pas rejoué, comme aux deuxième et troisième examens. C'est le choix du propriétaire du
   10/10, reconduit sans nouvelle décision : son accord du 14/10 au quatrième examen ne portait pas sur le témoin.
   Celui du 06/10 reste publié.
5. **L'environnement.** Mises à jour de la machine, non choisies pour l'examen : Claude Code 2.1.299 au lieu de
   2.1.296, Ubuntu 24.04.5 au lieu de 24.04.4, PostgreSQL 16.15 au lieu de 16.14. pgvector est retiré (plus haut,
   « L'environnement des essais »). Restent les mêmes : Node 22.22.0, la CLI Supabase 2.118.0, PostgREST 12.2.12,
   Deno 2.9.6 et le modèle de l'assistant.

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
