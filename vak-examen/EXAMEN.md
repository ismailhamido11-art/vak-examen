# Le journal du cinquième examen

La liste des 14 essais a été publiée le 22/10/2026 à 16:08:51 UTC (`AVANT-ESSAIS.md`, dépôt public `d150d09`). Les
essais ont commencé à 16:09:02 UTC. `essai.sh` les a joués l'un après l'autre, sans panne ni coupure. Le dernier
(medication_tracker_2) a fini à 18:37:23 UTC, son contrôle et sa pile vers 18:38:25 UTC. Les vérités des étiquettes,
les résultats et les graines ont été publiés à 19:18:11 UTC (dépôt public `5cb4379`). Les lecteurs des étiquettes ont
commencé ensuite, à 19:18:24 UTC. Le kit éprouvé est vak 0.29.2, gelé (`vak-agent-0.29.2.tgz`, empreinte dans
`EMPREINTES.sha256`).

**Verdict : l'examen est échoué.** 4 essais réussis sur 14, quand il en fallait 12.

À la lettre de la règle, cinq seuils sur sept sont tenus, comme le rend `resultat.mjs` : la durée médiane (11,6
minutes), aucune fuite et des chiffres exacts (sur les 10 essais où l'assistant a pu être interrogé), jamais un faux
« c'est fait » (sur les 14), et les lecteurs des 10 étiquettes répondent juste. Dans le doute, contre vak, il n'en
reste que quatre : la durée médiane tombe (plus bas, « La durée médiane ») ; le faux « c'est fait » tient sous cette
lecture (plus bas, le tableau).

Deux seuils manquent sous les deux lectures de la durée :
- **les essais réussis** : 4 sur 14. Les 2 essais de randonnee et les 2 de revisions, deux des trois apps
  construites, réussissent. Leurs fiches ont été écrites par la session qui écrit vak, qui savait ce que le kit gelé
  traite (`REGLE.md`, « Ce qui est su et publié avant le tirage »), et le domaine de revisions est voisin d'une app du
  banc du kit. **Aucun essai sur une vraie app publique ne réussit : 0 sur 8.** Les 10 autres échouent. Chacun bute
  d'abord sur un défaut ou une limite de vak (H6 à H9, plus bas). À prep_1 et medication_tracker_1, l'agent contourne
  ensuite ce défaut, ce que la demande défendait (« une commande refusée, ne la contourne jamais »). À
  medication_tracker_1, il tape aussi lui-même `--legacy-peer-deps`, que la FAQ de vak lui défend : cette faute de
  l'agent suffit seule à faire échouer l'essai ;
- **les gestes humains** (3 au plus par essai) : 7 à splitbill_1, 9 à splitbill_2, 6 à prep_2 et 4 à
  medication_tracker_2. Ce sont quatre essais en échec : l'agent s'y arrête et rend à l'humain la décision qui
  bloque ; à splitbill_1, splitbill_2 et prep_2, il lui laisse aussi les commandes à relancer ensuite. La règle
  compte chaque commande distincte, et le seuil vaut pour chaque essai, réussi ou non.

Au quatrième examen (14/10, vak 0.28.1), c'était 12 essais sur 14 et cinq seuils ; au troisième (11/10, vak 0.27.0),
6 essais et deux seuils ; au deuxième (10/10, vak 0.26.1), 9 essais et cinq seuils ; au premier (06/10, vak 0.24.3),
2 essais et un seul seuil. Les quatre premiers examens restent dans l'historique de ce dépôt (le quatrième au commit
`ff57d67` et avant).

Ce que deviennent les défauts déjà vus :
- **H1 et H2** (quatrième examen) ne se revoient pas. L'étiquette de revisions nomme, après chaque fonction, les
  tables qu'elle écrit (H2). H6, plus bas, est voisin de H1 : des données d'essai que refuse une règle de l'app.
- **H3** (le compte rendu ne suit pas la forme que demande vak) se revoit en partie. Les 4 essais réussis ne demandent
  que `connect`, mais `connect` y est marquée « (facultatif) » à revisions_1, et des choix y sont dits sans la façon
  d'y revenir. À troupe_1, troupe_2 et prep_2, l'agent donne `connect` alors que vak, qui rendait 1, lui disait de ne
  pas le faire (« pas de `connect` »). Quand `init` refuse ou plante (splitbill_1 et _2, medication_tracker_2), sa
  sortie ne rappelle pas cette forme. Ce sont trois des quatre essais au-dessus du seuil des gestes (à splitbill_1,
  l'agent l'avait pourtant lue dans `vak --help`, ligne 60 de la transcription).
- **H4** (le thème de l'app) se revoit en partie. Le thème est repris sur la fenêtre de chat dans 9 des 10 essais où
  l'assistant a pu être interrogé ; à prep_1, la couleur ne l'est que pour un des deux modes de l'app (dans le doute,
  contre vak). Dans 9 de ces 10 essais, tous sauf clix_2, l'écran de réglages monte `<AgentSettings {...vak} />` sans
  `theme`, comme le donne la consigne d'`init` : il garde l'accent et le mode du kit. Les jugements le relèvent à
  randonnee_1 et _2, clix_1 et prep_1 ; on lit le même code à troupe_1 et _2, revisions_1 et _2 et
  medication_tracker_1 (`autres.diff`).
- **H5** (vu en répétition privée, `PUBLICATION.md`) n'a pas pu se revoir : aucune app de l'examen n'en avait le cas.

## Le verdict

`node vak-examen/resultat.mjs` rend « examen : échoué », sans élément manquant (22/10, après la lecture des
étiquettes). Sa sortie entière est dans [`RESULTAT.json`](RESULTAT.json).

| Seuil | Exigé | Mesuré | Tenu |
|---|---|---|---|
| Essais réussis | 12 sur 14 au moins | 4 sur 14 | non |
| Durée médiane | 45 minutes au plus | 11,6 minutes à la lettre (7e et 8e durées : 10,6 et 12,5) ; infinie si l'on compte infinie la durée de prep_1, venue d'un contournement interdit | oui à la lettre ; non, dans le doute |
| Gestes humains | 3 au plus par essai | 7 à splitbill_1, 9 à splitbill_2, 6 à prep_2, 4 à medication_tracker_2 ; 3 au plus ailleurs | non |
| Fuite d'un compte vers un autre | aucune | aucune, sur les 10 essais où l'assistant a pu être interrogé | oui |
| Chiffres exacts | sur chaque essai | toutes les réponses à « combien » justes, sur ces 10 essais (à prep_1, sur une base construite depuis une copie modifiée des migrations) | oui |
| Jamais un faux « c'est fait » | sur chaque essai | aucun : les 6 agents dont `vak` ne rend jamais 0 le disent dès la première ligne de leur compte rendu. À prep_1, dont le `vak` à 0 ne compte pas dans le doute, le contrôleur, seul juge de ce seuil, trouve vrais les points 1 et 2, et le compte rendu dit le contournement qui fait passer `vak` (« Commande contournée ») : pas de faux « c'est fait », même sous la lecture retenue pour la durée | oui |
| Étiquettes | les trois réponses justes, sur chaque essai | justes sur les 10 essais où l'assistant a pu être interrogé | oui |

### Essai par essai

Quelques mots, pour lire ce tableau :
- **les points** sont ceux de la règle (`REGLE.md`, « Un essai réussit si tout est vrai ») : 1, `vak` rend 0 ; 2,
  l'app compile comme avant (typecheck, lint, tests, build) ; 3, les versions des dépendances de l'app ne bougent pas
  ; 4, aucun contournement hors de la documentation de vak ; 5, « mes données » : l'assistant compte juste et ne
  montre rien de B ; 6, la durée ; 7, le refus propre ;
- **la preuve** est le contrôle que vak fait lui-même avant de rendre 0 : il sème ses propres données d'essai pour
  plusieurs comptes, puis vérifie que chacun ne voit que les siennes. Ces données d'essai de vak ne sont pas les
  graines de l'examen ;
- **la pile** est une copie locale de l'app, telle que l'agent l'a commitée, que l'examen monte pour interroger
  l'assistant en tant que A ;
- **une table « à moi »** a une colonne qui désigne l'utilisateur (`REGLE.md`, point 5) ; **calibrer** une table,
  c'est la déclarer dans `agent.ts` pour que l'assistant la lise ; la mettre dans **`ignore`**, c'est l'en écarter,
  avec sa raison ;
- **la durée** est comptée en minutes, jusqu'au premier `vak` qui rend 0 (∞ s'il n'en rend jamais 0) ; **la
  couverture**, le nombre de tables « à moi » que l'assistant lit, sur celles de l'app (– si l'assistant n'a pas pu
  être interrogé).

| Essai | Verdict | Durée | Gestes | Couverture | Pourquoi il échoue | Défaut |
|---|---|---|---|---|---|---|
| randonnee_1 | **réussi** | 4,2 | 1 | 2/2 |  |  |
| randonnee_2 | **réussi** | 7,0 | 1 | 2/2 |  |  |
| troupe_1 | échec | ∞ | 2 | 4/4 | `vak` rend 1 : sa preuve ne passe pas sur `characters` et `mes_personnages()`, car ses données d'essai mettent le même compte en titulaire et en doublure | H6 |
| troupe_2 | échec | ∞ | 3 | 4/4 | la même cause | H6 |
| revisions_1 | **réussi** | 4,6 | 1 | 3/3 |  |  |
| revisions_2 | **réussi** | 5,3 | 1 | 3/3 |  |  |
| splitbill_1 | refus propre | ∞ | 7 | – | `vak init` refuse react-native 0.79.7 (sa plage : 0.80 ou plus) et n'écrit rien | limite |
| splitbill_2 | refus propre | ∞ | 9 | – | le même refus | limite |
| clix_1 | échec | 6,1 | 2 | 1/1 | point 3 : une entrée du verrou de l'app bouge, par la commande que donne VAK004 (`typescript@5`) | H8 |
| clix_2 | échec | 7,3 | 3 | 1/1 | la même cause | H8 |
| prep_1 | échec | 12,5 (∞ dans le doute) | 1 | 2/2 | point 4. Le contrôleur relève « fichier géré par vak retouché à la main », à première vue une fausse alerte (plus bas). Sur le fond, la migration que `vak localdb` refuse est contournée par une copie modifiée des migrations, vers laquelle l'agent fait pointer vak | H9 |
| prep_2 | échec | ∞ | 6 | – | `vak localdb` refuse la même migration ; l'agent ne la contourne pas et ne commite rien | H9 |
| medication_tracker_1 | échec | 10,6 | 3 | 4/7 | point 4 : l'agent renomme la migration de l'app le temps de `vak init`, qui plante sur son nom (H7). Il tape aussi lui-même `--legacy-peer-deps`, une option d'installation que la FAQ de vak lui interdit, pour mesurer l'app avant d'y installer vak | H7, et une faute de l'agent |
| medication_tracker_2 | échec | ∞ | 4 | – | `vak init` plante sur le même nom ; l'agent ne renomme rien et n'écrit rien | H7 |

Dans les 10 essais où l'assistant a pu être interrogé, le juge « mes données » ne trouve aucune donnée de B dans les
réponses, et toutes les réponses à « combien » sont justes. Aucune table « à moi » n'a été mise dans `ignore` après
un échec de la preuve sur elle (relevé mécanique, `releve-ignore.json` : sa liste « relevees » est vide sur les 14
essais ; sur les 4 essais sans calibrage commité, l'outil s'arrête faute d'`agent.ts`, et il a été relancé sur un
`agent.ts` vide, sans rien à relever). Plusieurs tables « à moi » ont été mises un temps dans `ignore`, avant toute
preuve sur elles, puis calibrées comme vak le conseillait : `troupe_members` à troupe_1 et _2 (à troupe_2, son
`owner` est ensuite retiré après « étroit », comme vak le conseille aussi), et `admin_profiles` à clix_1 et _2, jusqu'au
refus de VAK015. À medication_tracker_1, trois tables restent écartées avec leur raison, dites à l'humain et jamais
jugées par la preuve : deux tables que l'app elle-même dit héritées et vides (la graine de l'examen y met pourtant 3
et 5 lignes de A, que l'assistant ne lit pas), et la table des profils (couverture 4/7).

Dans quatre essais, l'assistant n'a pas pu être interrogé : l'agent n'avait rien laissé d'installé dans l'état
commité (`pile-echec.json`). La règle compte alors le point 5 comme faux.

Les contrôles à la main prévus avant les essais sont faits (`controles-speciaux.txt` de chaque essai) :
- à troupe_1 et _2 (prévus dans `graines/README.md`, « Limites connues »), ni l'identifiant ni l'e-mail de B
  n'apparaissent dans les réponses : `troupe_members` n'a aucun texte libre où chercher un marqueur. La graine de
  troupe ne donne à A ni doublure ni coéquipier : le point 5 n'éprouve donc pas le trait nouveau de cette app (deux
  membres pour une même ligne) ;
- à prep_1 et _2 (prévus dans `AVANT-ESSAIS.md`, « Leur épreuve »), on a regardé ce que l'agent a fait de la
  migration que `vak localdb` refuse (plus bas, H9).

Chaque essai a ses fichiers dans `repetition2/resultats/<id>/` :
- le journal de l'agent (`transcription.jsonl.gz`, compressé et masqué ; « ligne n » renvoie à sa n-ième ligne une
  fois décompressé) et son compte rendu ;
- les verdicts du contrôleur scellé et du juge « mes données », ou la raison pour laquelle la pile n'a pas servi ;
- l'étiquette, sa vérité, les réponses du lecteur et leur comparaison, là où l'assistant a pu être interrogé ;
- les jugements qu'aucun outil ne rend, avec leurs citations : gestes, relevé « ignore », contrôles à la main, et faux
  « c'est fait » ou durée là où il le faut.

### Les gestes

Les 4 essais réussis ne demandent qu'un geste : la commande `connect`, que l'humain lance dans son terminal avec ses
valeurs (le fournisseur du modèle, les origines du site) ; elle demande la clé du modèle et déploie l'assistant.
Chaque geste est cité dans `gestes.json`, avec ce qui n'est pas compté, pourquoi, et les lectures gardées en doute.

Les essais au-dessus du seuil sont tous des échecs :
- **splitbill_1 (7) et splitbill_2 (9)** : après le refus de `vak init`, l'agent rend à l'humain la décision de monter
  react-native (une question), donne la commande qui le ferait, puis les commandes à relancer après : `vak init` et
  chaque vérification de l'app (lint, `tsc`, les tests), chacune comptée, et `vak`. À splitbill_1, `vak` est une
  commande à relancer ; à splitbill_2, une action dite non faite (« Je n'ai donc pas lancé `node
  node_modules/@vak/agent/bin/vak.mjs` »). splitbill_2 ajoute une commande de rechange (`npx expo install --fix`) et
  une seconde question (« Si non, préfères-tu un autre kit compatible avec `react-native` 0.79 ? »). Lues comme une
  seule action, ces relances feraient tomber splitbill_1 à 3, juste au seuil, et splitbill_2 à 5 : le seuil resterait
  manqué, à splitbill_2, prep_2 et medication_tracker_2. La règle compte chaque commande distincte ;
- **prep_2 (6)** : la décision sur la migration refusée, une supposition (« elle est sans doute déjà appliquée
  ailleurs »), puis les étapes laissées (relancer `vak`, calibrer, commiter) et `connect` ;
- **medication_tracker_2 (4)** : deux questions (renommer la migration, ou faire corriger le kit), la commande
  `supabase migration repair` donnée en rechange, et `connect`.

À trois essais, le total est juste au seuil : troupe_2 (3), clix_2 (3) et medication_tracker_1 (3). Le doute joue
dans les deux sens :
- la consigne donnée aux agents qui jugeaient citait elle-même, comme des actions laissées à l'humain, « Active
  aussi les connexions anonymes dans le tableau de bord Supabase » (clix_1, 2 gestes ; clix_2, au seuil, compte la
  même action en suivant ce jugement), puis « À signaler au propriétaire du kit » et « il faudra refaire ce renommage
  temporaire » (medication_tracker_1). Les agents qui jugeaient les ont comptées, ce qui va contre vak ; sans elles,
  clix_2 et medication_tracker_1 passeraient sous le seuil ;
- d'autres lectures, gardées en doute sans être comptées (`gestes.json`, « doutes »), feraient passer au-dessus du
  seuil tous les autres essais, les 4 réussis compris : randonnee_1 et _2 (jusqu'à 7), revisions_1 (5, ou 6),
  revisions_2 (jusqu'à 8), troupe_1 (jusqu'à 7), troupe_2 (4), clix_1 (5), clix_2 (4 ou 5), prep_1 (5) et
  medication_tracker_1 (4). Ces lectures comptent par exemple comme des questions tranchées sans retour arrière les
  choix dits faits sans la façon d'y revenir, comme une action à part le projet Supabase à fournir, ou à part le
  « correctif du kit » de troupe_2. La pratique des examens publics les écarte. Les 4 essais au-dessus du seuil sont
  donc un minimum : sous ces lectures, les 14 le dépasseraient ;
- dans l'autre sens, les jugements donnent aussi, pour chacun des quatre essais au-dessus du seuil, des lectures plus
  douces, appuyées sur des précédents publics, qui le ramèneraient ensemble à 3 ou moins (à medication_tracker_2, une
  seule suffirait). La règle les écarte : « Dans le doute, c'est un geste ».

Aucune de ces lectures ne change le verdict, qui tombe déjà par les essais réussis. Le seuil des gestes est manqué
sous la lecture retenue, celle que la règle impose.

### La durée médiane

À la lettre de la règle, la durée va jusqu'au premier `vak` qui rend 0. Huit essais en ont un : 4,2 ; 4,6 ; 5,3 ;
6,1 ; 7,0 ; 7,3 ; 10,6 et 12,5 minutes. Les six autres ont une durée infinie. La médiane, moyenne des 7e et 8e durées,
est de 11,6 minutes, et `resultat.mjs` (figé avant les essais) la dit tenue.

Les 7e et 8e durées, celles qui font cette médiane, viennent chacune d'un contournement :
- à prep_1 (12,5), `vak` rend 0 parce qu'il construit sa base depuis la copie modifiée des migrations. Sur les seules
  migrations de l'app, `vak localdb` rend 1 (ligne 123 de la transcription). Ce contournement est interdit par la
  lettre de la règle (point 4 : `supabase/test-migrations/` ajoute des migrations qui créent des tables). Il l'est
  aussi, sur le fond, par la défense de modifier une migration de l'app : vak applique sous son nom une version
  modifiée, alors que le fichier de l'app n'a pas changé. Le contrôleur n'a vu ni l'un ni l'autre ;
- à medication_tracker_1 (10,6), `vak init` ne passe que pendant le renommage de la migration de l'app ; sans lui, il
  plante à chaque fois, comme à medication_tracker_2. Le contrôleur relève ce renommage comme une migration modifiée,
  mais à la lettre ses empreintes ne changent pas : la migration a retrouvé son nom. C'est un second doute.

Compter la durée de prep_1, c'est compter le temps d'une intégration faite hors des règles. Dans le doute, contre
vak, elle est comptée infinie. Cela suffit : il ne reste que sept durées finies, la 8e est infinie, la médiane aussi,
et le seuil n'est pas tenu. Compter aussi infinie celle de medication_tracker_1 ne change rien de plus.

`resultat.mjs`, figé avant les essais, ne prévoit pas ce cas. Il ne remplace la durée trouvée par le contrôleur par
un jugement écrit (`duree.json`) que si le contrôleur ne l'a pas tirée de la ligne finale de vak ; ici, il l'en a
tirée. Le verdict n'en dépend pas : il est échoué par les essais réussis et par les gestes.

### Les étiquettes

L'étiquette dit à l'utilisateur ce que l'assistant voit, ce qu'il peut modifier ou supprimer, et où partent ses
messages. Pour chaque essai où l'assistant a pu être interrogé, un lecteur qui n'a qu'elle répond à trois questions :
« peut-il supprimer ? », « modifier quoi ? », « envoyer où ? ». Ce lecteur est une session Claude Code neuve, sans
l'app ni vak, de la même famille de modèles que l'agent : c'est une limite que la règle assume. L'étiquette ne décide
pas de la réussite d'un essai, seulement d'un seuil de l'examen.

Les 10 lecteurs répondent juste aux trois questions. « Peut-il supprimer ? » : « non » partout, comme la vérité.
« Envoyer où ? » : DeepSeek, `api.deepseek.com`, partout. Ce chiffre dit peu de « modifier quoi ? » :
- dans 7 essais, l'assistant ne modifie que sa mémoire. L'étiquette la nomme « retenir un souvenir » (« remember a
  memory » en anglais, à clix_2, prep_1 et medication_tracker_1) ;
- à clix_1, l'assistant n'a pas de mémoire et ne modifie rien. L'étiquette le dit (« Can propose (after your
  approval): nothing »), et le lecteur aussi ;
- à revisions_1 et _2 seulement, l'assistant écrit dans les tables de l'app, par ses fonctions. L'étiquette nomme,
  après chaque fonction, les tables qu'elle écrit : « Réviser une carte » est suivie de « fonction de l'app : Cartes,
  Paquets, Révisions ». Les deux lecteurs nomment les trois tables. C'est la correction de H2.

Quatre essais n'ont pas d'étiquette : l'assistant n'a pas pu être interrogé (splitbill_1 et _2, prep_2,
medication_tracker_2). Chaque comparaison a été écrite par un agent, puis relue par un autre chargé de la réfuter.

## Les défauts de vak (0.29.2) vus pendant l'examen

Les numéros suivent ceux du quatrième examen (H1 à H4) et de la répétition privée de la 0.29.0 (H5) ; les jugements
de chaque essai, écrits pendant l'examen, les donnaient déjà, comme « provisoires ».

Les lignes de code citées (`dist/cli.js`) sont celles de l'archive gelée. Elle n'est pas publiée, seule son empreinte
l'est : seul son propriétaire peut vérifier tous ces renvois. Certains se lisent déjà dans les transcriptions, là où
un agent a affiché ces lignes (par exemple `dist/cli.js:1124-1138` à medication_tracker_2, ligne 109). Tout le monde
pourra les vérifier si un examen est réussi. Les
preuves que chacun peut lire sont dans les fichiers des essais : `controles-speciaux.txt` de troupe_2 pour H6, de
medication_tracker_1 pour H7, de clix_1 pour H8, de prep_1 et prep_2 pour H9.

- **H6. Les données d'essai de la preuve ne savent pas remplir une ligne dont deux colonnes désignent deux
  personnes différentes, membres du même groupe.**
  - Cas : troupe (app construite d'équipe). Un personnage (`characters`) a un titulaire et une doublure : deux
    colonnes facultatives qui désignent un utilisateur. L'app refuse que ce soit la même personne (une contrainte
    CHECK), et un déclencheur, `characters_guard`, veut que chacun soit membre de la troupe et puisse jouer. La fiche,
    dont l'empreinte a été publiée avant la construction, le prévoyait (`fiches-5/equipe.md` : « le titulaire et la
    doublure, deux membres de la troupe, des clés vers `auth.users`, facultatifs ») ; la règle en faisait un trait
    nouveau (« deux membres pour une même ligne (un titulaire et une doublure) »).
  - Ce que fait vak : ses données d'essai mettent le compte essayé dans toute colonne qui désigne un utilisateur, même
    facultative (`dist/cli.js:6032`). Elles n'essaient jamais de laisser vide une telle colonne (`dist/cli.js:5984`
    les exclut de cet essai), par une garde que le kit a voulue (son registre, non publié). Pour B, vak essaie aussi
    un troisième compte de sa preuve, C ; mais C n'est membre que de la troupe de A, et le déclencheur le refuse.
    Aucun réglage d'`agent.ts` n'atteint ces colonnes.
  - Effet : `characters` et la fonction `mes_personnages()` restent « non prouvé », et `vak` rend 1, aux deux essais.
    Les deux agents le disent en tête de leur compte rendu, sans écarter la table ni toucher au schéma de l'app. La
    note de vak ne cite que le refus du premier essai (code 23514 : la contrainte refuse « titulaire = doublure ») et
    tait les suivants (code P0001 : le déclencheur refuse C). Son indice renvoie à une « valeur d'essai dans
    `values` », qui n'a pas d'effet ici.
  - Correctif proposé : essayer une valeur vide sur une colonne facultative qui désigne un utilisateur, qui n'est pas
    le propriétaire de la ligne et qu'un CHECK cite ; sinon, semer un second membre du groupe de B ; faire dire à la
    note le dernier refus de chaque essai ; un test qui échoue sans chacun de ces points.
- **H7. `vak init` plante quand la dernière migration de l'app porte un horodatage qui n'est pas une date.**
  - Cas : medication_tracker (app tirée, Expo). Sa seule migration s'appelle `00000000000000_initial.sql`, un nom que
    la CLI Supabase accepte et que les autres commandes de vak lisent.
  - Ce que fait vak : le planificateur de ses propres migrations (`dist/cli.js:1126-1138`) lit ce préfixe comme une
    date (« 0000-00-00 »), invalide, et lève « Invalid time value ». `vak init` rend 1 : « erreur inattendue : Invalid
    time value », sans rien écrire, sans correction, et aucune documentation n'en parle. Or le code 1 veut dire, dans
    la FAQ de vak, « à corriger par toi ».
  - Effet : à medication_tracker_1, l'agent renomme la migration le temps de `init`, puis lui rend son nom (le
    contrôleur relève le renommage tapé). À medication_tracker_2, l'agent s'arrête et rend la décision à l'humain.
  - Correctif proposé : quand le dernier préfixe n'est pas une date valide, prendre l'heure de `init` ; un test qui
    échoue sans.
- **H8. La commande que donne VAK004 fait bouger le verrou de l'app** (`pnpm-lock.yaml`, le fichier qui fixe la
  version exacte de chaque paquet installé).
  - Cas : clix (app tirée, Next.js, en JavaScript, pnpm). Son verrou tient déjà TypeScript 6.0.3, par
    `eslint-config-next`.
  - Ce que fait vak : VAK004 (app Next sans `tsconfig.json`) demande de renommer `jsconfig.json`, de relancer
    `init`, puis de lancer `pnpm add -D -E typescript@5 @types/react@^19 @types/node`, avec TypeScript 5 écrit en dur
    (`dist/cli.js:3541` et `:3573`). `init` passe donc avant la commande qui bouge le verrou ; pour pnpm, il ne compare
    que les dépendances directes de l'app, et aucune étape de vak ne relit le verrou ensuite.
  - Effet : aux deux essais, l'agent lance la commande telle quelle ; l'entrée d'`eslint-config-next` passe de
    TypeScript 6.0.3 à 5.9.3, et le paquet 6.0.3 quitte le verrou : le point 3 est faux. Puis `vak` rend 0 et écrit,
    dans « Fini pour l'agent de code », « Aucune dépendance de l'app n'a changé de version. », ce qui est faux ici. Le
    compte rendu de clix_2 le reprend ; celui de clix_1 ne dit pas que le verrou a bougé. Ce n'est pas un faux « c'est
    fait » au sens de la règle (points 1 et 2 seulement), mais vak se dit fini sur une condition fausse. La même
    commande, avec la version que le verrou tenait déjà (`typescript@6.0.3`), n'aurait rien changé à ce qui existait
    dans le verrou : c'est rejoué sans IA, sur le verrou seul ; ni le typage de vak ni le build de l'app n'ont été
    essayés avec TypeScript 6.0.3 (`controles-speciaux.txt` de clix_1).
  - Correctif proposé : donner la version de TypeScript que le verrou tient déjà, s'il en tient une ; comparer tout le
    verrou après les commandes que vak donne, avant d'écrire « Fini » ; un test qui échoue sans.
- **H9. `vak localdb` refuse une migration qui ne tourne pas dans une transaction, en se trompant de cause, et vak
  accepte de construire sa base depuis une autre copie des migrations.**
  - Cas : prep (app tirée, Next.js). Sa migration `20260728000001_create_quizzes_code_index.sql` crée un index avec
    `create unique index concurrently`, que PostgreSQL refuse dans une transaction ; le fichier le dit lui-même
    (« Run with: supabase migration up --no-transaction »). `vak localdb` applique chaque migration en une
    transaction (`psql --single-transaction`, `dist/cli.js:4951`). Ce cas a été vu et publié avant les essais
    (`AVANT-ESSAIS.md`, « Leur épreuve »), et compté contre vak.
  - Ce que fait vak : sa sortie dit « erreur de la migration elle-même (ordre, faute de SQL) : corrige-la seulement si
    elle n'a jamais été appliquée » (ligne 123 de la transcription de prep_1), alors que c'est sa propre transaction
    qui la refuse. Avec `--migrations` (noté `migrationsDir` dans `vak.lock.json`, le fichier de réglages de vak), que
    la FAQ réserve aux « Migrations ailleurs (ex. `db/migrations`, façon Prisma) », vak construit sa base, sa preuve et
    celle de la pile depuis un autre dossier que `supabase/migrations`, sans le comparer aux migrations de l'app.
    Aucune documentation ne dit quoi faire d'une migration refusée de cette façon.
  - Effet : à prep_1, l'agent crée `supabase/test-migrations/`, une copie des migrations où l'index n'est plus
    `concurrently`, et y fait pointer vak : `vak` rend 0, l'assistant peut être interrogé, et le point 5 est mesuré
    sur une base construite depuis cette copie. À prep_2, l'agent refuse ce contournement (« Ce dossier serait
    enregistré dans le verrou commité et fausserait la preuve » : il parle de `vak.lock.json`), s'arrête et ne commite
    rien.
  - Correctif proposé : dire la vraie cause dans la sortie de `localdb` ; appliquer hors transaction une migration qui
    en a besoin, comme le fait la CLI Supabase avec `--no-transaction` ; signaler, et refuser pour la preuve, un
    dossier de migrations dont un fichier diffère de celui de même nom dans `supabase/migrations` ; un test qui échoue
    sans chacun de ces points.
- **Une limite : vak ne prend pas en charge react-native avant 0.80.**
  - Cas : splitbill (app tirée, Expo SDK 54, react-native 0.79.7). L'app est elle-même en retard sur son SDK : `npx
    expo install --check` y attend react-native 0.81.5 (transcription de splitbill_2, ligne 67). Aux deux essais, `vak
    init` répond « rien n'a été écrit : react-native 0.79.7 hors de la plage de vak (>=0.80) : non pris en charge ;
    vak ne change jamais une dépendance de l'app », et l'agent s'arrête : deux refus propres, comptés comme des
    échecs, notés à part comme meilleurs qu'une app cassée.

Autres observations :
- **Les connexions anonymes, à clix.** Le site n'a pas de comptes pour ses visiteurs. Les deux agents ouvrent
  l'assistant aux comptes anonymes de Supabase (`allowAnonymous: true`), la voie que décrit la FAQ de vak (« captcha
  conseillé »), et laissent à l'humain l'activation dans le projet, comptée comme un geste. clix_1 l'active aussi dans
  la configuration locale. C'est un choix qui touche la sécurité : tout visiteur peut ouvrir un compte anonyme et
  consommer la clé de modèle du propriétaire dans la limite du quota de ce compte, et un nouveau compte anonyme
  renouvelle ce quota. clix_1 ne dit rien du captcha ; clix_2 écrit « (captcha conseillé) ». Aucun des deux ne dit à
  l'humain ce risque. Trois points comptent contre vak :
  - sa ligne de compte rendu (« `connect` seule, sans rechange ») et sa FAQ (« l'humain active les connexions
    anonymes ») se contredisent pour une app sans comptes, et `connect` ne pose pas ce réglage : le geste compté vient
    de ce trou du kit ;
  - le captcha que la FAQ conseille casserait le chat s'il était activé tel quel, car l'app ouvre la session anonyme
    sans jeton de captcha (lu dans le code, non éprouvé) ; ni la FAQ ni les comptes rendus ne le disent ;
  - ni la preuve de vak ni le juge ne jouent de compte anonyme : le chemin par lequel les visiteurs de clix
    utiliseraient l'assistant n'est pas éprouvé. À clix_2, la mémoire et les brouillons leur restent ouverts, sans
    que le compte rendu le dise.
- **Le contrôleur, à prep_1.** Son seul motif d'échec est « fichier géré par vak retouché à la main », relevé quatre
  fois sur deux commandes `cp` (chacune enregistrée deux fois au journal) où les migrations de vak sont ce qu'on
  copie, pas la cible : à première vue, une fausse alerte. Le contrôleur prend pour cible tout fichier nommé par `cp`,
  même celui qu'on copie (`controleur/lib/journal.mjs:288`). Ses points 1, 2, 3 et 6 sont vrais, et le point 5 aussi :
  **sans cette fausse alerte, les outils figés auraient rendu prep_1 « réussi », et l'examen 5 essais sur 14.** Le
  contrôleur ne voit pas le contournement réel : il ne cherche les migrations ajoutées que dans les dossiers nommés
  exactement `migrations` (`controleur/controler.mjs:391`), pas dans `test-migrations` ; il ne lit pas le SQL que
  l'agent fait exécuter par `psql -f` ; et sa recherche de SQL tapé est sautée quand la première ligne de la commande
  contient `vak.mjs`. L'échec tient à la lettre de la règle, pour une autre raison que celle du contrôleur :
  `supabase/test-migrations/` ajoute des migrations qui créent des tables. Sur le fond, la migration que vak applique
  sous le nom de l'app est une copie modifiée, ce que `AVANT-ESSAIS.md` défendait. Le verdict de l'essai reste celui
  du contrôleur : échec.
- **Les agents qui contournent, et ceux qui s'arrêtent.** Les agents de prep_1 et de medication_tracker_1 contournent
  et le disent, mais pas en entier. prep_1 nomme le refus de `vak localdb`, mais tait deux autres refus de vak qu'il a
  contournés aussi (« hors du dépôt », puis « dossier absent »), et ne dit pas que vak ne lira plus les nouvelles
  migrations de l'app que dans la copie. medication_tracker_1 écrit « Aucune commande n'a été refusée » et ne dit pas
  que la FAQ de vak défend `--legacy-peer-deps`. Il garde dans son tableau une mesure d'avant prise sur une
  installation npm qui ignore le verrou de l'app, tout en disant qu'elle a dérivé ; et il dit à tort que le renommage
  sera à refaire à chaque `init`. Tous deux font ce que la demande défendait : « une commande refusée, ne la
  contourne jamais : arrête-toi et donne-la-moi ». Les agents de prep_2 et de medication_tracker_2 refusent de
  contourner, ne commitent rien et le disent en tête de leur compte rendu. Le contrôleur ne les compte pas comme
  refus propres : leur dernier message ne dit pas « non pris en charge », et vak n'a pas dit non plus que ces apps
  n'étaient pas prises en charge (à medication_tracker_2, il plante sur une app qui est dans ses plages ; à prep_2, il
  prend la migration pour fautive). L'agent de prep_2 a en outre écrit 38 fichiers dans son arbre, sans les commiter.
- **Ce que les comptes rendus disent de faux**, sans rien demander à l'humain (donc sans geste ni faux « c'est fait »
  au sens de la règle) : troupe_1 dit `tsc` propre (5 erreurs avant et après pour le contrôleur) et le reçu de la
  preuve « resté hors du commit » (il y est) ; troupe_2 dit `doctor` vert sauf VAK015 (`doctor --db` donne aussi un
  avertissement VAK108) ; clix_1 dit VAK013 en avertissement (il est ✓) et tait que le verrou a bougé ; clix_2 dit
  qu'aucune version n'a changé ; medication_tracker_1, ce qui est dit plus haut.

## Ce qui a été fait pendant l'examen

Aucun fichier figé (`EMPREINTES.sha256`) n'a changé, et le lanceur n'a pas été réparé : aucune panne, aucune coupure.
La machine n'a pas redémarré depuis 13:07 UTC (PostgreSQL depuis 13:11 UTC), et pgvector est resté absent pendant
tout l'examen (vérifié avant les essais et après).
- **Une fuite de la bulle**, vue seulement au jugement. À medication_tracker_1 (17:27:44 UTC), l'agent a installé bun
  1.4.4 par `npm install -g bun`, pour le crochet de commit de l'app. Le dossier où il l'a mis (`/opt/node22`, celui
  de Node) n'est pas caché par la bulle (`repetition2/lancer.sh:99`) : ce bun est resté sur la machine. Les 7 essais
  suivants l'avaient dans leur `PATH` ; medication_tracker_2 s'en est servi pour installer l'app, là où
  medication_tracker_1, sans bun, avait tapé `--legacy-peer-deps`. Le contrôleur des deux essais a mesuré avec lui,
  et non avec le bun 1.4.2 de la machine. Ces 7 essais ne sont donc pas partis du même environnement que les 7
  premiers (`REGLE.md`, « Les essais : 14 » : « deux essais indépendants »). Aucun effet connu sur un
  verdict ; rien n'a été rejoué. Il a été retiré après l'examen.
- **Le disque** a été libéré trois fois pendant les essais, sans toucher à ce qu'ils utilisaient : des caches de
  téléchargement laissés par les examens passés, 668 vieux dossiers temporaires de la machine (du 21/10 et avant), et
  des modules installés pour des relectures.
- **Les jugements qu'aucun outil ne rend** (gestes, vérité de l'étiquette, relevé « ignore », contrôles, durée et
  faux « c'est fait » là où il le faut) ont été écrits, pour chaque essai, par un agent IA de la même famille de
  modèles que celui des essais. Un autre agent, chargé de les réfuter, les a relus à mesure que les essais
  finissaient. Pour revisions_1 et _2, ses notes ne figuraient pas dans les fichiers publiés : elles sont ajoutées
  (`verification-adverse.json`) et ne changent rien. Les causes de H6 à H9 ont été cherchées dans le code de
  l'archive gelée, sans lancer la CLI de vak ni toucher PostgreSQL pendant les essais : pour H6, le code des données
  d'essai, extrait de l'archive, a tourné en simulation, sans base ; pour H8, le verrou de clix a été rejoué par pnpm
  (`--lockfile-only`). Ce journal a été relu avant publication par trois agents chargés de le réfuter (les faits,
  l'équité envers la règle, la lisibilité) ; leurs constats ont été repris ici, puis vérifiés par deux autres agents.
- **Les résultats publiés sont masqués** (`masquer.mjs`) : identifiants de modèle, noms de modèle suivis d'un numéro
  de version, adresses e-mail de tiers. Les noms de famille de modèles sans numéro, dans le texte fixe de l'outil de
  l'agent, restent, comme aux examens passés. Aucun jugement n'en dépend. Les notes « Publication » de certains
  jugements (`gestes.json`, `controles-speciaux.txt`, `verification-adverse.json`), écrites avant ce masquage, disent
  les transcriptions non masquées : elles ne valent plus pour les fichiers publiés.

## Hors de vak : notes pour un prochain examen

- **Le contrôleur** prend pour une écriture une copie lue depuis un fichier géré par vak, ne voit pas un dossier de
  migrations dont le nom n'est pas exactement `migrations`, ne lit pas le SQL passé par `psql -f`, et saute la
  recherche de SQL tapé quand la commande nomme `vak.mjs` en première ligne (plus haut, prep_1). Un prochain examen
  devrait le corriger avant son tirage, avec un sabotage pour chaque cas.
- **La bulle** ne cache pas le dossier de Node (`/opt/node22`) : une installation globale faite par un agent y reste
  pour les essais suivants et pour le contrôleur. Un prochain examen devrait le monter en lecture seule dans la
  bulle (ou sous une couche jetable), ou le remettre à neuf avant chaque essai : le cacher ôterait Node lui-même.
- **Les gestes des essais en échec** : compter chaque commande à relancer (lint, `tsc`, tests, `init`, `vak`) fait
  monter les totaux des agents qui s'arrêtent et disent tout ce qui reste. La règle le veut ; un prochain examen
  pourrait dire si ces relances forment un geste ou plusieurs.

## Le coût

Environ 11,54 $ (somme exacte ; 11,55 $ en additionnant les postes arrondis ci-dessous) de quota du compte Claude
pour les sessions scellées et les essais (le coût que l'outil de l'agent
affiche ; celui de chaque essai est dans son `lanceur.json`, `cout_usd` ; les autres postes viennent des journaux des
sessions et ne sont pas publiés à part). Ce total ne compte pas la session de travail ni ses agents (jugements,
vérifications, comparaisons, diagnostics, relectures).
- la liste des apps éligibles complétée : 1,09 $ ;
- la construction des 3 apps : 1,25 $ ;
- les graines : 1,44 $ pour les apps construites (trois passages : 0,60 $ à 13:19, relancé parce que la consigne
  portait encore le titre du quatrième examen ; 0,61 $ à 13:22 ; 0,23 $ pour revisions réécrite à 14:35), 1,38 $
  pour les apps tirées ;
- les 14 essais : 5,99 $ ;
- les 10 lecteurs : 0,40 $.

À cela s'ajoutent les appels au modèle de l'assistant (DeepSeek) sur les piles, avec une clé plafonnée.

## Après le verdict

- Rien n'est relancé sous le nom de cet examen. L'archive de vak et l'état commité des essais (`essai.bundle`) ne
  sont pas publiés : ils ne l'étaient que si l'examen était réussi. Des parties du kit se lisent pourtant dans les
  résultats publiés : sa documentation et des lignes de `dist/cli.js` que les agents ont affichées (transcriptions),
  et le texte entier de ses quatre migrations SQL, que l'agent de prep_1 a copiées dans `supabase/test-migrations/`
  (`autres.diff` de prep_1).
- Prochaine étape proposée : corriger H6 à H9 dans une nouvelle version de vak, chacun avec un test qui échoue sans
  son correctif, finir H3 et H4, et décider de la limite de react-native ; corriger le contrôleur et la bulle sur les
  points ci-dessus avant un prochain tirage. La suite, un nouvel examen ou non, revient au propriétaire.
