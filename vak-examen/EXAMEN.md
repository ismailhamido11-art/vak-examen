# Le journal du quatrième examen

La liste des 14 essais a été publiée le 14/10/2026 à 15:08:26 UTC (`AVANT-ESSAIS.md`, dépôt public `6e36b24`). Les
essais ont commencé à 15:10:00 UTC. `essai.sh` les a joués l'un après l'autre, sans panne ni coupure, et le dernier a
fini à 18:36:39 UTC. Les vérités des étiquettes, les résultats et les graines ont été publiés à 18:50:55 UTC (dépôt
public `2969f9e`). Les lecteurs des étiquettes ont commencé ensuite, à 18:50:59 UTC. Le kit éprouvé est vak 0.28.1,
gelé (`vak-agent-0.28.1.tgz`, empreinte dans `EMPREINTES.sha256`).

**Verdict : l'examen est échoué.** 12 essais réussis sur 14, quand il en fallait 12 : ce seuil est tenu, pour la
première fois. Cinq seuils sur sept le sont. Deux manquent :
- **les gestes humains** (3 au plus par essai) : 4 à split_free_frontend_1, 4 à journal_2, 6 à
  split_free_frontend_2. Chacun de ces totaux dépend de cas de doute, tranchés contre vak (plus bas, « Les gestes ») :
  le circuit de contribution du dépôt de l'app laissé à l'humain (les deux split_free_frontend), une commande donnée en
  rechange de `connect` (split_free_frontend_2), et des questions que l'agent tranche lui-même sans écrire comment
  revenir dessus. Les deux derniers totaux viennent d'un recompte strict des 14 essais, fait après la lecture des
  étiquettes, quand le résultat était déjà connu : un total pouvait y monter, jamais baisser. La cause est un défaut de
  vak (H3, plus bas) : le compte rendu de l'agent ne suit pas la forme que vak lui demande ;
- **les étiquettes** : l'étiquette dit à l'utilisateur ce que l'assistant voit, ce qu'il peut modifier ou supprimer, et
  où partent ses messages ; un lecteur qui n'a qu'elle doit répondre juste à « peut-il supprimer ? », « modifier
  quoi ? » et « envoyer où ? ». À prets_1 et _2, le lecteur ne nomme pas la table Prêts
  dans sa réponse à « modifier quoi ? ».
  L'étiquette ne la nomme pas non plus là où il le faudrait : les fonctions de l'app qui l'écrivent s'appellent
  « Prêter un objet » et « Marquer comme rendu » (ou « Enregistrer un retour »). C'est un défaut de vak (H2, plus
  bas).

Au troisième examen (11/10, vak 0.27.0), c'était 6 essais sur 14 et deux seuils ; au deuxième (10/10, vak 0.26.1), 9
essais et cinq seuils ; au premier (06/10, vak 0.24.3), 2 essais et un seul seuil. Les trois premiers examens restent
dans l'historique de ce dépôt.

Les 3 apps construites réussissent 4 essais sur 6 : disques et prets, deux fois chacune ; journal échoue deux fois, sur
un même défaut de vak (H1, plus bas). Les 4 apps tirées réussissent leurs 8 essais.

## Le verdict

`node vak-examen/resultat.mjs` rend « examen : échoué », sans élément manquant (14/10, après la lecture des
étiquettes et le recompte strict des gestes). Sa sortie entière est dans [`RESULTAT.json`](RESULTAT.json).

| Seuil | Exigé | Mesuré | Tenu |
|---|---|---|---|
| Essais réussis | 12 sur 14 au moins | 12 sur 14 | oui |
| Durée médiane | 45 minutes au plus | 6,2 minutes (7e et 8e durées : 5,8 et 6,6) | oui |
| Gestes humains | 3 au plus par essai | 4 à split_free_frontend_1 et à journal_2, 6 à split_free_frontend_2 (dans le doute) ; 3 au plus ailleurs | non |
| Fuite d'un compte vers un autre | aucune | aucune, sur les 14 essais | oui |
| Chiffres exacts | sur chaque essai | toutes les réponses à « combien » justes, sur les 14 essais | oui |
| Jamais un faux « c'est fait » | sur chaque essai | aucun : les 2 agents qui n'ont pas fini le disent dès la première ligne | oui |
| Étiquettes | les trois réponses justes, sur chaque essai | justes sur 12 essais ; à prets_1 et _2, « modifier quoi ? » fausse (H2) | non |

### Essai par essai

La durée est comptée en minutes, jusqu'au premier `vak` qui rend 0 (∞ s'il n'en rend jamais 0). La couverture est le
nombre de tables « à moi » que l'assistant lit, sur celles de l'app. Les défauts H1 à H4 sont décrits plus bas.
L'étiquette ne décide pas de la réussite d'un essai, seulement de son seuil de l'examen (`resultat.mjs`).

| Essai | Verdict | Durée | Gestes | Couverture | Pourquoi il échoue | Défaut |
|---|---|---|---|---|---|---|
| disques_1 | **réussi** | 4,1 | 1 | 2/2 |  |  |
| disques_2 | **réussi** | 4,5 | 1 | 2/2 |  |  |
| journal_1 | échec | ∞ | 2 | 6/6 | `vak` rend 1 : `articles` et `article_photos` « non prouvé », la graine heurte un déclencheur de l'app | H1 |
| journal_2 | échec | ∞ | 4 | 5/6 | `vak` rend 1 : `articles` et `article_photos` « non prouvé », comme journal_1 (et 4 gestes, au-dessus du seuil de l'examen) | H1, H3, H4 |
| prets_1 | **réussi** | 5,7 | 1 | 2/2 | (essai réussi ; étiquette : « modifier quoi ? » fausse, seuil de l'examen) | H2, H4 |
| prets_2 | **réussi** | 5,8 | 2 | 2/2 | (essai réussi ; étiquette : « modifier quoi ? » fausse, comme prets_1) | H2, H3, H4 |
| split_free_frontend_1 | **réussi** | 5,1 | 4 | 2/5 | (essai réussi ; 4 gestes, au-dessus du seuil de l'examen) | H3, H4 |
| split_free_frontend_2 | **réussi** | 4,4 | 6 | 3/5 | (essai réussi ; 6 gestes, au-dessus du seuil de l'examen) | H3, H4 |
| smart_budget_application_1 | **réussi** | 16,2 | 1 | 6/25 |  | H4 |
| smart_budget_application_2 | **réussi** | 12,5 | 3 | 6/25 |  | H3, H4 |
| flow_finance_1 | **réussi** | 8,0 | 1 | 3/18 |  | H4 |
| flow_finance_2 | **réussi** | 9,2 | 2 | 4/18 |  | H3, H4 |
| streakmates_1 | **réussi** | 6,6 | 2 | 7/11 |  | H2, H3, H4 |
| streakmates_2 | **réussi** | 5,0 | 2 | 5/11 |  | H3, H4 |

Dans les 14 essais, le juge « mes données » ne trouve aucune donnée de B dans les réponses de l'assistant, et toutes
les réponses à « combien » sont justes. Les tables « à moi » que l'assistant ne lit pas sont écartées par l'agent avec
leur raison, et dites à l'humain (la règle, point 4) : jamais après un échec de la preuve sur elles (relevé mécanique,
`releve-ignore.json`, vide sur les 14 essais). Plusieurs agents ont vu la preuve dire « étroit » ou « non prouvé » en
chemin : prets_1 et _2 (sur `loans` et ses fonctions), journal_1 (sur `newspaper_invitations`),
smart_budget_application_1, streakmates_1 et _2. Ils ont corrigé le calibrage, sans jamais mettre la table dans
`ignore`. Les 2 agents qui échouent disent dès la première ligne de leur compte rendu qu'ils n'ont pas fini, et
n'ont rien contourné : ni la table dans `ignore`, ni le déclencheur de l'app.

Les contrôles à la main prévus avant les essais (`graines/README.md`, « Limites connues », écrit avant le tirage mais
publié avec les graines, après les essais) sont faits : à
journal_1 et _2, ni l'identifiant ni l'e-mail de B n'apparaissent dans les réponses ; à disques_1 et _2, aucune réponse
à « combien » n'est lue à travers le mot « neuf » (`controles-speciaux.txt` de chaque essai).

Chaque essai a ses fichiers dans `repetition2/resultats/<id>/` :
- le journal de l'agent, transcrit et masqué, et son compte rendu ;
- les verdicts du contrôleur scellé et du juge « mes données » ;
- l'étiquette, sa vérité, les réponses du lecteur et leur comparaison ;
- les jugements écrits à la main, avec leurs citations : gestes, relevé « ignore », contrôles à la main, et faux
  « c'est fait » ou durée là où il le faut.

### Les gestes

Chaque essai compte au moins un geste : la commande `connect`, que l'humain lance dans son terminal avec ses valeurs
(le fournisseur du modèle, les origines du site) ; elle demande la clé du modèle et déploie l'assistant. Chaque geste
est cité dans `gestes.json`, avec ce qui n'est pas compté et pourquoi.

#### split_free_frontend_1

Le compte rendu demande à l'humain la commande `connect` (un geste, comme partout), puis, dans sa rubrique
« Contournements et refus » : « **Workflow GitHub non suivi :** l'`AGENTS.md` du dépôt demande une issue, une branche
`{n}-{slug}` et une pull request. Je n'avais aucun accès GitHub. J'ai donc commité directement sur `essai` […]. Les
commandes `gh` à lancer de ton côté : `gh issue create`, puis `git push` de la branche et `gh pr create` avec
`Fixes #<n>`. »

La règle : « Un geste humain est ce que le compte rendu final de l'agent demande à l'humain pour que l'assistant
marche : une commande à lancer […]. Chaque commande distincte compte pour un geste […]. Dans le doute, c'est un
geste. » Ces trois commandes sont une demande, à l'impératif. Leur but écrit est la règle de contribution du dépôt de
l'app. L'assistant marche après le seul `connect` sur la branche locale `essai` ; dans l'app du propriétaire, il
n'arrive que par cette pull request.

Trois juges indépendants (agents de la même famille de modèles, en lecture seule) ont lu la règle et les 88 jugements
de gestes passés (42 des trois examens publics, 3 de cet examen et 43 de répétitions privées, non publiées), chacun
sous un angle : la lettre, les précédents, le point de vue du propriétaire. Leurs réponses
entières sont publiées (`repetition2/resultats/split_free_frontend_1/gestes-juges.json`). Deux comptent 1 :
ces commandes ne servent pas à ce que l'assistant marche, comme `localdb --drop`, que les jugements passés n'ont jamais
compté. Le troisième compte 4 : sans elles, le travail n'atteint pas l'app du propriétaire, et l'humain doit bien les
lancer. L'un des deux premiers (sous l'angle des précédents) juge « pas déraisonnable » la lecture à 4 du premier
jugement, que la question lui citait ; l'autre (la lettre) reconnaît que son propre point faible « est réel » : ce
serait la première fois qu'une demande à l'impératif est écartée sur ce seul motif. Ce désaccord est un doute : il est
tranché contre vak, comme le veulent la règle et le propriétaire. **4 gestes**, au-dessus du seuil de 3. Ce décompte
a été écrit et commité à 16:29 UTC dans le dépôt de vak, quand 5 essais seulement étaient joués (commit `fa91a275` ;
ce dépôt n'est pas public : seul son propriétaire peut le vérifier). Les deux totaux sont dans
`repetition2/resultats/split_free_frontend_1/gestes.json`.

#### Le recompte strict des 14 essais

Pendant l'examen, à partir de streakmates_1 (17:11 UTC), les jugements à la main n'ont plus compté (sauf à
flow_finance_2, pour les garde-fous) une question que l'agent liste dans son compte rendu (la rubrique « Questions
que j'aurais posées », que demande le lanceur) quand il la tranche ailleurs, même sans écrire comment revenir dessus.
journal_2 et split_free_frontend_2 ont suivi cette lecture, en notant qu'au deuxième et au troisième examen une telle
question n'était écartée qu'avec son retour arrière écrit (le recompte a montré que la pratique publique est en fait
mêlée depuis le premier examen). Une relecture adverse du journal, après la lecture des étiquettes, l'a relevé : le
troisième examen comptait une telle question (workout_app_1, « Le lien magique convient-il comme connexion ? »).

Les 14 essais ont donc été recomptés, avant cette publication, selon la pratique des trois examens publics. Un agent
l'a établie sur leurs 42 jugements de gestes, et un second l'a corrigée en cherchant à la réfuter
([`recompte-gestes-4.json`](recompte-gestes-4.json)). Les répétitions privées n'y fondent rien seules. Elle est
constante sur deux points : une question qui porte une réponse ferme (« J'ai choisi non ») ne compte pas, ni une
question tranchée ailleurs avec son retour arrière écrit. Sur les cas des ajouts, elle n'est constante que pour
écarter : elle est mêlée,
depuis le premier examen, sur une question tranchée ailleurs sans retour arrière, et muette sur d'autres cas (une
commande donnée en rechange, un circuit de contribution « non fait », une réponse que l'agent dit non vérifiée, un
indice du kit laissé non suivi). Les
dix ajouts reposent donc tous sur la règle seule, « Dans le doute, c'est un geste » : cinq où la pratique est mêlée,
cinq où elle est muette. Chaque essai a été recompté
par un agent, puis vérifié par un autre chargé de le réfuter dans les deux sens. Le résultat étant déjà connu, un total
ne pouvait que monter : un retrait n'aurait été que noté. Aucun n'a été trouvé (« retraits_notes_non_appliques », vide
sur les 14 essais).

Six totaux montent :

| Essai | Avant | Après | Ce qui s'ajoute |
|---|---|---|---|
| journal_2 | 2 | 4 | deux questions tranchées sans retour arrière : ouvrir des écritures, masquer le bouton sur `/login` |
| split_free_frontend_2 | 2 | 6 | la même question des écritures ; `npx supabase migration up`, donnée en rechange de `connect` ; le circuit GitHub du dépôt (issue, branche, pull request), « Non faits », compté en trois comme à split_free_frontend_1, au lieu d'un (deux de plus) |
| smart_budget_application_2 | 2 | 3 | « Quelle est la bonne couleur du thème ? J'ai repris `#0F766E` […] sans le comparer à celui de l'app » : un réglage de l'assistant qu'il dit ne pas avoir vérifié |
| prets_2 | 1 | 2 | un indice du kit laissé non suivi (`errcode = 'VAK01'` dans `lend_item`) |
| streakmates_1 | 1 | 2 | « Veux-tu que `profiles`, `nudges` et `reactions` soient lisibles ? », tranchée sans retour arrière écrit pour elle |
| streakmates_2 | 1 | 2 | « Quel écran de réglages choisir […] ? Je l'ai tranché seul », sans dire lequel dans la question |

Chacun de ces ajouts est un doute : lu comme pendant l'examen, chaque total retombe à son ancienne valeur. Les deux
lectures, leurs raisons et leurs précédents sont dans chaque `gestes.json` (« recompte_strict »). Le verdict n'en
dépend pas : il était déjà échoué, par split_free_frontend_1 et par les étiquettes. Les 8 autres totaux ne changent
pas, dont les 4 de split_free_frontend_1.

### Les étiquettes

12 lecteurs sur 14 répondent juste aux trois questions. Partout, « peut-il supprimer ? » a la réponse de la vérité :
« non » sur les 14 essais, que l'étiquette dit par « Jamais : supprimer une ligne » (« Never: delete a row » dans les 4
étiquettes en anglais, split_free_frontend et streakmates ; le défaut G5 du troisième examen est corrigé). « Envoyer
où ? » est juste partout : DeepSeek, `api.deepseek.com`.

Ce chiffre de 12 sur 14 dit peu de « modifier quoi ? » : dans 11 essais sur 14, dont les 8 des apps tirées, l'assistant
n'écrit que sa mémoire. La question n'a porté sur des écritures dans les tables de l'app qu'à disques_2, prets_1 et
prets_2 : 1 juste sur 3. À streakmates_1, le lecteur hésite : « Never: edit outside these lists » ne dit pas si les
tables de « Sees » comptent, et il ne les nomme pas. C'est jugé juste : sa liste, seule réponse à la question, dit la
vérité, sans réserve, et la consigne du lecteur lui demande d'écrire à part ce que l'étiquette ne dit pas. Le doute est
celui du lecteur sur l'étiquette, pas celui de la comparaison sur sa réponse. Les jugements publics ont déjà jugé juste
une réponse dont le lecteur doutait de l'étendue : abonnements_1, au troisième examen (« Elle ne précise pas quelles
données chaque fonction touche exactement »), et company_invoicing_1, au premier (des écrans dont « l'étiquette ne dit
pas ce qu'on peut y faire »). Lu comme un doute, ce serait faux : 11 sur 14, sans effet sur le seuil, déjà manqué.
La formule de vak en cause, « modifier hors de ces listes », est sur les 14 étiquettes (H2).

À prets_1 et _2, la vérité de « modifier quoi ? » est : Objets (`items`), Prêts (`loans`) et sa mémoire. Les deux
lecteurs recopient les fonctions de l'étiquette : « Ajouter un objet », « Modifier un objet », « Prêter un objet »,
« Marquer comme rendu » (prets_2 : « Enregistrer un retour »), et « retenir un souvenir ». Objets et la mémoire sont
nommés ; Prêts ne l'est jamais, ni par le nom de l'étiquette ni par celui de la table. La règle demande de nommer
« toutes les tables où l'assistant peut écrire […] par le nom de l'étiquette ou par celui de la table ». Les
précédents ne rattachent une fonction à une table que par le nom de la table dans le sien (« Nouvel abonnement »,
« Noter un paiement », « Catégorie »…), jamais par un verbe (« prêter ») ou par une colonne (« Rendu le »). Le faire
ici serait une souplesse nouvelle, en faveur de vak : dans le doute, faux.

La première comparaison de prets_1, puis sa vérification adverse, l'avaient jugée juste ; celle de prets_2, fausse,
pour la raison ci-dessus. Les deux cas sont les mêmes : prets_1 a été corrigé à la main, avant le décompte des seuils,
pour suivre la même méthode (sa note le dit, dans `etiquette-comparaison.json`). Chaque comparaison a été écrite par
un agent, puis relue par un autre chargé de la réfuter.

## Les défauts de vak (0.28.1) vus pendant l'examen

- **H1. La graine de la preuve ne sait pas semer une ligne qu'un déclencheur de l'app ne laisse passer qu'après une
  autre ligne, sans clé étrangère entre elles.**
  - Cas : journal (app construite d'équipe). Le déclencheur `guard_article` (`before insert or update on articles`)
    refuse un article confié (`assignee_id`) à quelqu'un qui n'est pas rédacteur ou propriétaire du journal, d'après
    `newspaper_members` : « 23514 l'article ne peut être confié qu'à un rédacteur ou propriétaire du journal ».
  - La graine sème les tables dans l'ordre des clés étrangères : `articles` passe avant l'adhésion dont il dépend, que
    seul le déclencheur exprime. `articles` est donc « non prouvé » (graine impossible), puis `article_photos` (parent
    absent), et `vak` rend 1, aux deux essais de journal. Les autres tables lues sont « éprouvé » : 4 à journal_1, 3 à
    journal_2 (où `newspaper_invitations` est écartée dans `ignore`, avec sa raison).
  - Les deux agents le disent, et n'ont ni écarté ces tables ni affaibli le déclencheur.
  - Correctif proposé : quand une ligne de la graine est refusée par un déclencheur ou une contrainte (23514, 23503…),
    semer d'abord les autres tables de A, puis la réessayer, avant de conclure « non prouvé » ; et donner à la ligne la
    valeur que demande le refus (ici, un `assignee_id` qui est membre rédacteur du journal).
- **H2. L'étiquette ne dit pas clairement ce que l'assistant peut modifier.**
  - Cas, d'abord : une fonction de l'app ne dit pas quelle table elle écrit. À prets (app construite de fonctions), la
    ligne « Peut proposer » cite chaque fonction par son seul libellé : « Prêter un objet » (fonction de l'app),
    « Marquer comme rendu » (prets_2 : « Enregistrer un retour »). Ces deux fonctions écrivent Prêts (`loans`), et
    « Prêter un objet » aussi Objets, par un déclencheur ; aucun des libellés ne nomme Prêts.
  - Effet : un lecteur qui n'a que l'étiquette ne peut pas dire que l'assistant modifie Prêts. « Modifier quoi ? » est
    faux aux deux essais de prets. Au premier examen (06/10, fonctions_2, « Catégorie »), un défaut voisin était sans
    effet.
  - Cas, ensuite : la ligne « Jamais » dit « modifier hors de ces listes » (« edit outside these lists » dans les 4
    étiquettes en anglais), sur les 14 étiquettes, sans dire de quelles listes il s'agit ; « Voit » (« Sees ») en est
    une. À streakmates_1, le lecteur ne sait pas si les tables de « Sees » comptent
    (jugé juste, plus haut) ; au premier examen, le lecteur d'equipe_1 écrivait déjà que « « ces listes » n'est pas
    défini avec précision ».
  - Correctif proposé : faire suivre chaque fonction de l'app, dans « Peut proposer » et « Jamais », des tables qu'elle
    écrit, par leur nom d'étiquette (« Prêter un objet » (fonction de l'app : Prêts, Objets)), d'après ce que la
    preuve la voit écrire ; écrire « Jamais : modifier autre chose que » suivi de ce qui est permis ; et un test qui
    échoue sans chacun de ces deux points.

- **H3. Le compte rendu que demande vak n'est pas toujours celui que l'agent écrit.**
  - La consigne de vak (`SKILL.md` de l'archive) dit : « Compte rendu : la commande `connect`, seule ; chaque choix que
    tu as tranché (…), dit comme un choix fait (« j'ai ouvert … ; pour revenir dessus : … »), jamais « à confirmer »
    ni en question ».
  - Cas :
    - d'autres demandes que la commande `connect` : à split_free_frontend_1, trois commandes `gh`/`git` pour le
      circuit de contribution du dépôt de l'app (issue, branche, pull request), que son `AGENTS.md` demande ; à
      split_free_frontend_2, ce même circuit rendu à l'humain comme « Non faits », sans commande, et
      `npx supabase migration up` donnée en rechange de `connect` ;
    - des choix tranchés qui reviennent en questions, sans leur retour arrière écrit, chaque fois dans la rubrique
      « Questions que j'aurais posées », que demande le lanceur : à journal_2, split_free_frontend_2, streakmates_1 et
      _2, flow_finance_2 (« Faut-il des garde-fous validés par un professionnel ? », tranchée ailleurs) et
      smart_budget_application_2 (la couleur du thème, reprise du kit sans la comparer à celle de l'app : H4) ;
    - des choix laissés « à confirmer » ou sans raison : à smart_budget_application_2, un garde-fou (finance) posé sans
      règle validée par un professionnel, contre la FAQ du kit, et sa validation laissée à l'humain ; à prets_2, un
      indice de vak (`errcode = 'VAK01'` dans `lend_item`) laissé non suivi, sans raison ni retour arrière (« Je n'ai
      pas touché aux migrations de l'app pour ça »).
  - Effet : tous les gestes au-delà de `connect`, hors des questions laissées ouvertes par H1, à huit essais ; trois
    passent au-dessus du seuil : split_free_frontend_1 (4), journal_2 (4) et split_free_frontend_2 (6).
  - Correctif proposé : dire dans la consigne comment rendre à l'humain le circuit de contribution du dépôt (une ligne,
    avec ses commandes, sans le cacher), sans préjuger s'il compte comme geste : la règle du prochain examen le dira ;
    rappeler la forme du compte rendu là où l'agent la lit en dernier, à la fin de chaque sortie de `vak` sans
    sous-commande, qu'elle rende 0 ou 1 ; et un test qui échoue sans chacun de ces deux points.
- **H4. `vak` rend 0 alors que le thème de l'app n'est pas repris.**
  - `init` pose dans l'écran de l'assistant une consigne : reprendre les couleurs de l'app. Dans une app Next.js, c'est
    une ligne `vak:todo` (« theme par defaut ; reprends les couleurs et le mode (clair, sombre) de l'app ») ; dans une
    app Expo, un simple commentaire, sans `vak:todo` (« Theme : couleur par defaut ; reprends celles de l'app »). Le
    contrôle VAK007 ne cherche `vak:todo` que dans `lib/vak.ts`.
  - Cas : 3 essais sur 14 reprennent la couleur de l'app sur ce que l'utilisateur voit (le bouton monté :
    disques_1 et _2, journal_1). Les 11 autres gardent l'accent par défaut du kit (`#2563EB` en Expo, `#0F766E` en
    Next.js), même là où l'app a le sien (journal, smart_budget_application, flow_finance). À
    smart_budget_application_2, la ligne `vak:todo` est commitée telle quelle (`src/app/assistant/assistant.tsx:19`) ;
    aux 8 essais Expo, le commentaire reste en place.
  - Effet : l'assistant n'a pas l'allure de l'app, et `vak` rend 0 sans le dire ; à smart_budget_application_2, l'agent
    le rend à l'humain en question (un geste, H3).
  - Correctif proposé : `init` marque d'un `vak:todo` la consigne du thème dans tous ses écrans, Expo compris, et VAK007
    cherche les `vak:todo` des fichiers que pose `init` ; un test qui échoue sans chacun de ces deux points.

Autres observations :
- À prets_1 et _2, la graine de la preuve ne tient pas une contrainte CHECK entre deux colonnes de l'app
  (`due_on >= lent_on`, où `lent_on` vaut `current_date`) : `loans` et ses fonctions sont d'abord « non prouvé ». Les
  agents l'ont réglé par une valeur d'essai (`values`, `due_on` au 31/12/2099), comme vak le conseille, sans passer par
  `ignore` ; prets_1 note que ce libellé existe ensuite pour la colonne. Sans effet sur le verdict ; de la même famille
  que H1.

## Ce qui a été fait pendant l'examen

Aucun fichier figé (`EMPREINTES.sha256`) n'a changé, et le lanceur n'a pas été réparé : aucune panne, aucune coupure.
- **Les gestes dans le doute** sont comptés (plus haut). Les 14 essais ont été recomptés après la lecture des
  étiquettes, selon la pratique des examens publics et, là où elle est mêlée ou muette, selon la règle seule ; six
  totaux sont montés (« Le recompte strict »).
- **Les résultats sont masqués avant leur commit** (noms de modèle, adresses de tiers ; `masquer.mjs`). Aucun
  jugement n'en dépend.
- **pgvector** est resté absent de la machine pendant tout l'examen (vérifié avant les essais et à chaque contrôle).

## Hors de vak : notes pour un prochain examen

- **La règle des gestes** ne dit pas si une commande demandée pour une autre raison que l'assistant (le circuit de
  contribution d'un dépôt) en est un, ni si une question que l'agent tranche ailleurs sans retour arrière écrit en est
  un. Et le texte que reçoit l'agent lui demande « les questions que tu aurais posées », dont chacune devient un geste
  possible : faut-il le garder ? Un prochain examen devrait trancher ces trois points dans sa règle, avant le tirage.
- **Le juge lit le mot « neuf » comme le nombre 9** (disques : les deux « Neuf » de la colonne État, dans « Liste mes
  disques. ») : sans effet, le nombre retenu est celui que l'assistant annonce (6), et une liste ne décide pas du
  point 5.

## Le coût

Environ 11,95 $ de quota du compte Claude :
- la construction des 3 apps : 1,41 $ ;
- les graines : 0,64 $ pour les apps construites, 2,40 $ pour les apps tirées ;
- les 14 essais : 6,91 $ ;
- les 14 lecteurs : 0,59 $.

À cela s'ajoutent les appels au modèle de l'assistant (DeepSeek) sur les piles, avec une clé plafonnée.

## Après le verdict

- Rien n'est relancé sous le nom de cet examen. Le code de vak et l'état commité des essais (`essai.bundle`) ne sont
  pas publiés : ils ne l'étaient que si l'examen était réussi.
- Prochaine étape proposée : corriger H1 à H4 dans une nouvelle version de vak, chacun avec un test qui échoue
  sans son correctif ; trancher, dans la règle d'un prochain examen et avant son tirage, les questions des gestes
  laissées ouvertes (plus haut, « Hors de vak »). La suite, un nouvel examen ou non, revient au propriétaire.
