# Le journal du deuxième examen

La liste des 14 essais a été publiée le 10/10/2026 à 17:42 UTC (`AVANT-ESSAIS.md`, dépôt public `c9993dd`). Les
essais ont commencé à 17:48:53 UTC. `essai.sh` les a joués l'un après l'autre, et le dernier a fini à 20:16 UTC. Les
vérités des étiquettes, les résultats et les graines ont été publiés à 20:28:02 UTC (dépôt public `0de0e0e`). Les
lecteurs des étiquettes ont commencé ensuite, à 20:28:08 UTC. Le kit éprouvé est vak 0.26.1, gelé
(`vak-agent-0.26.1.tgz`, empreinte dans `EMPREINTES.sha256`).

**Verdict : l'examen est échoué.** 9 essais réussis sur 14, quand il en fallait 12. Cinq seuils sur sept sont tenus.
Au premier examen (06/10, vak 0.24.3), c'était 2 essais sur 14 et un seul seuil. Le premier examen reste dans
l'historique de ce dépôt.

## Le verdict

`node vak-examen/resultat.mjs` rend « examen : échoué », sans élément manquant (10/10, après la lecture des étiquettes).
Sa sortie entière est dans [`RESULTAT.json`](RESULTAT.json).

| Seuil | Exigé | Mesuré | Tenu |
|---|---|---|---|
| Essais réussis | 12 sur 14 au moins | 9 sur 14 | non |
| Durée médiane | 45 minutes au plus | 6,83 minutes | oui |
| Gestes humains | 3 au plus par essai | 3 au plus (compteurs_1 : 3) | oui |
| Fuite d'un compte vers un autre | aucune | aucune, sur les 14 essais | oui |
| Chiffres exacts | sur chaque essai | faux dans my_saas_boilerplate_1 | non |
| Jamais un faux « c'est fait » | sur chaque essai | aucun : les 4 agents qui n'ont pas fini le disent | oui |
| Étiquettes | les trois réponses justes, sur chaque essai | justes dans les 14 essais | oui |

### Essai par essai

La durée est comptée en minutes, jusqu'au premier `vak` qui rend 0 (∞ s'il n'en rend jamais 0). La couverture est le
nombre de tables « à moi » que l'assistant lit, sur celles de l'app. Les défauts F1 à F3 sont décrits plus bas.

| Essai | Verdict | Durée | Gestes | Couverture | Pourquoi il échoue | Défaut |
|---|---|---|---|---|---|---|
| plantes_1 | **réussi** | 3,6 | 1 | 2/2 | | |
| agence_1 | **réussi** | 5,6 | 1 | 5/5 | | |
| compteurs_1 | échec | ∞ | 3 | 2/2 | `vak` rend 1 : la preuve ne se prononce pas sur `add_reading`, `update_reading` et `upsert_meter` | F1 |
| expense_sharing_1 | échec | ∞ | 2 | 4/4 | `vak` rend 1 : `settlements` « non prouvé », graine refusée par la contrainte `settlements_distinct_members` | F2 |
| pups_supabase_1 | **réussi** | 3,0 | 1 | 2/2 | | |
| my_saas_boilerplate_1 | échec | 9,3 | 2 | 2/9 | point 5 : à « How many of my profiles are there? », une réponse en français, sans chiffre | F3 |
| budget_web_app_1 | **réussi** | 6,5 | 1 | 8/13 | | |
| plantes_2 | **réussi** | 3,1 | 1 | 2/2 | | |
| agence_2 | **réussi** | 5,3 | 1 | 5/5 | | |
| compteurs_2 | échec | ∞ | 2 | 2/2 | `vak` rend 1 : `add_reading` et `upsert_meter` « non prouvé » | F1 |
| expense_sharing_2 | échec | ∞ | 2 | 4/4 | `vak` rend 1 : `settlements` « non prouvé », comme expense_sharing_1 | F2 |
| pups_supabase_2 | **réussi** | 3,0 | 1 | 2/2 | | |
| my_saas_boilerplate_2 | **réussi** | 8,1 | 1 | 3/9 | | |
| budget_web_app_2 | **réussi** | 7,2 | 2 | 8/13 | | |

Dans les 5 échecs, le point 5 dit qu'aucune donnée de B n'apparaît. Dans les 4 échecs où `vak` rend 1, l'agent le dit
dès la première ligne de son compte rendu (« je n'ai pas fini »). Aucun n'a contourné la preuve. À compteurs_1 et
compteurs_2, l'agent a essayé de mettre les fonctions dans `ignore`. vak l'a refusé (« jamais ignore pour faire passer
la preuve »), et l'agent a tout remis comme avant, sans le commiter.

Chaque essai a ses fichiers dans `repetition2/resultats/<id>/` :
- le journal de l'agent, transcrit et masqué, et son compte rendu ;
- les verdicts du contrôleur scellé et du juge « mes données » ;
- l'étiquette, sa vérité, les réponses du lecteur et leur comparaison ;
- les jugements écrits à la main, avec leurs citations : gestes, relevé « ignore », et faux « c'est fait » ou durée
  là où il le faut.

### Les étiquettes

Les 14 lecteurs répondent juste aux trois questions. Partout, la vérité de « peut-il supprimer ? » est « non », et les
14 lecteurs répondent « non ». L'étiquette dit désormais « Jamais : supprimer une ligne », une correction tirée du premier
examen (E10). Pour « modifier quoi ? », chaque lecteur cite exactement les tables de la vérité, et aucune autre. Il les
nomme par les mots de l'étiquette, y compris les fonctions de compteurs (« Ajouter un relevé », « Créer ou modifier un
compteur »). « Envoyer où ? » est juste partout.

## Les défauts de vak (0.26.1) vus pendant l'examen

- **F1. La preuve ne sait pas appeler une fonction de l'app dont l'argument est un objet json.**
  - Cas : `add_reading(payload jsonb)`, `update_reading(id, payload jsonb)` et `upsert_meter(payload jsonb)` de
    compteurs.
  - Cause : la preuve lit dans le code de la fonction les clés de l'objet. Elle prend une clé `x_id` dans la table x de
    A. Pour les autres clés, elle invente une valeur d'après leur seul nom (`fieldSample`). La valeur de `value` devient
    un texte, que l'app refuse de lire comme un nombre (« Valeur invalide »). Celle de `type` sort de la contrainte
    `meters_type_check`.
  - Le calibrage n'offre aucun moyen de donner une valeur d'essai pour un argument de fonction.
  - Effet : « non prouvé », et `vak` rend 1, aux deux essais de compteurs.
  - Correctif proposé : pour une clé qui nomme une colonne d'une table que la fonction écrit, reprendre la valeur d'une
    ligne de A déjà semée dans cette table. Elle respecte le type, les contraintes et les règles de l'app, comme l'ordre
    des relevés. À défaut, utiliser le type de la colonne et les valeurs permises par sa contrainte.
- **F2. La graine ne sait pas donner deux parents distincts à deux clés étrangères vers la même table.**
  - Cas : `settlements.from_member` et `settlements.to_member` visent tous deux `group_members`, et l'app exige qu'ils
    diffèrent (`settlements_distinct_members`).
  - Cause : le parent « jumeau » que crée la graine viole `unique(group_id, user_id)`, puisqu'il a le même groupe et le
    même compte. La graine retombe alors sur le même parent, que la contrainte refuse (23514).
  - La note de vak (« une valeur d'essai dans `values` ») ne s'applique pas à une clé étrangère.
  - Effet : « non prouvé », et `vak` rend 1, aux deux essais d'expense_sharing.
  - Correctif proposé : faire varier, pour le jumeau, la colonne qui le rend unique. Ici, un membre sans compte, que
    l'app permet.
- **F3. Rien ne garde la langue de l'étiquette et des réponses alignée sur celle de l'app.**
  - Cas : my_saas_boilerplate est en anglais (`locale: "en-US"`, persona en anglais), mais ses deux calibrages libellent
    la table `users` « Mon compte » et le journal « Journal d'activité ».
  - À « How many of my profiles are there? », l'assistant de my_saas_boilerplate_1 répond en français, sans chiffre.
    Il commence par « Je ne trouve pas de « profils » dans votre compte », puis dit « il n'y en a qu'un ». Le juge
    ne lit pas cette tournure, et n'y trouve aucun nombre.
  - Celui de my_saas_boilerplate_2 répond en anglais avec le même libellé (« a single one »), une tournure que le juge
    lit : 1. La même erreur de calibrage passe ou échoue donc selon la langue que choisit le modèle.
  - Correctifs proposés : `doctor` signale des libellés dans une autre langue que `locale` ; l'assistant répond dans la
    langue de la question ; une réponse à « combien » donne toujours le nombre en chiffres.

Observation sans effet sur le verdict : à my_saas_boilerplate_1, `init` a demandé de monter les réglages de vak
(`VakSettings`) sur la page d'administration de l'app. Un utilisateur ordinaire n'aurait donc ni le consentement
révocable ni l'effacement. L'agent l'a signalé, et c'est compté comme un geste. À my_saas_boilerplate_2, l'agent les a
mis aussi sur la page du compte. `init` ne devrait pas choisir une page d'administration.

## Ce qui a été fait pendant l'examen

Aucun fichier figé (`EMPREINTES.sha256`) n'a changé, et le lanceur n'a pas été corrigé. Les points suivants ont été
publiés avant le premier essai, dans `AVANT-ESSAIS.md` :
- l'épreuve des graines sur la base même de la pile des essais (`graines/eprouver-pile.mjs`), parce que l'outil
  d'épreuve figé ne passe pas la migration 0005 d'expense_sharing ;
- une ligne de texte de `tirage-publier.mjs`.

Pendant et après les essais, toujours dans le sens de la règle :
- **Le contrôleur des répétitions ne compte pas** (`REGLE.md`). À agence_1 et agence_2, il comptait comme nouvelle
  l'erreur de typecheck qu'avait déjà `app/layout.tsx`, décalée de 10 lignes par l'intégration. Le contrôleur scellé
  compare sans numéro de ligne, comme le veut la règle (point 2) : 7 erreurs avant, 7 après, aucune nouvelle. Ces deux
  essais sont réussis.
- **Une durée corrigée contre vak** (`compteurs_2/duree.json`). Le contrôleur figé a trouvé un « premier `vak` qui
  rend 0 » à 1,5 minute. Sa source était un repli, « code=0 », écrit par la commande
  `node node_modules/@vak/agent/bin/vak.mjs 2>&1 | tail -60; echo code=$?`. Dans cette commande, `$?` est le code de
  `tail`, et la sortie de vak montre « ✗ VAK008 ». Aucun `vak` n'a rendu 0 : la durée est infinie.
- **Les gestes dans le doute** sont comptés, et la note de chaque `gestes.json` dit le total d'une lecture plus
  stricte ou plus large. Aucune de ces lectures ne fait passer un essai au-dessus de 3 gestes.
- **Les résultats sont masqués avant leur commit**, dans le dépôt de travail aussi (noms de modèle, adresses de tiers ;
  `masquer.mjs`). Aucun jugement n'en dépend.

## Hors de vak : notes pour un prochain examen

- **Le contrôleur figé** prend encore « code=0 » pour un `vak` qui rend 0 quand le code vient d'une autre commande de
  la ligne (compteurs_2, corrigé contre vak dans `duree.json`).
- **Le juge** lit les nombres en chiffres, en lettres (en français et en anglais), et des tournures comme « un seul » ou
  « a single ». Il ne lit pas « il n'y en a qu'un » (my_saas_boilerplate_1). Ce verdict, au détriment de vak, est
  gardé.
- **L'outil d'épreuve des graines** (`graines/eprouver.mjs`) a un minimum de Supabase plus pauvre que celui de la pile.
  Le prochain devrait éprouver sur la base de la pile.

## Le coût

Environ 10,5 $ de quota du compte Claude :
- la construction des 3 apps : 1,51 $ ;
- les graines : 0,58 $ pour les apps construites, 1,55 $ pour les apps tirées ;
- les 14 essais : 6,32 $ ;
- les 14 lecteurs : 0,59 $.

À cela s'ajoutent les appels au modèle de l'assistant (DeepSeek) sur les piles, avec une clé plafonnée.

## Après le verdict

- Rien n'est relancé sous le nom de cet examen. Le code de vak et l'état commité des essais (`essai.bundle`) ne sont
  pas publiés : ils ne l'étaient que si l'examen était réussi.
- Prochaine étape proposée : corriger F1 à F3 dans une nouvelle version de vak, chacun avec un test qui échoue sans
  son correctif. La suite, un nouvel examen ou non, revient au propriétaire.
