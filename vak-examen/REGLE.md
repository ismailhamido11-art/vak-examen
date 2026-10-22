# Examen public de vak : la règle (cinquième examen)

**À figer avant le tirage des apps.** Son empreinte SHA-256 sera publiée dans [`PUBLICATION.md`](PUBLICATION.md),
avec celle de l'archive du kit et le tour drand choisi. Après cette publication, plus rien ne change. Les règles des
quatre premiers examens (06/10/2026, échoué : 2 essais réussis sur 14 ; 10/10/2026, échoué : 9 sur 14 ; 11/10/2026,
échoué : 6 sur 14 ; 14/10/2026, échoué : 12 sur 14) restent lisibles dans l'historique de ce dépôt.

## Ce que l'examen mesure

Un agent de code reçoit une seule demande : celle du README de vak. Il doit intégrer vak dans une vraie app qu'il n'a
jamais vue, sans rien casser. L'assistant obtenu doit donner des chiffres exacts et ne jamais montrer les données d'un
autre compte. L'examen dit si c'est vrai, sur 14 essais, avec des seuils publiés avant la mesure.

## Les apps : 7, jamais vues

- **4 vraies apps publiques**, tirées au sort parmi les apps éligibles.
- **3 apps construites par un tiers** qui n'a jamais vu vak : une session Claude Code scellée (sans le dépôt de vak,
  sans mémoire). Ce sont trois apps nouvelles : vak a vu celles des quatre premiers examens, et a été corrigé depuis
  sur ce que plusieurs d'entre elles ont montré. Chacune suit une fiche de forme d'une page (`fiches-5/`), écrite
  avant sa construction et publiée avec son empreinte :
  - une app qui démarre (peu de tables, peu de code) ;
  - une app d'équipe (des données partagées entre membres) ;
  - une app « tout par fonctions », qui écrit par des fonctions SQL, avec du JSON.

  Ce qui est su et publié avant le tirage :
  - les fiches sont écrites par la session de travail qui écrit vak, après le gel du kit et après ses répétitions
    privées : elle sait ce que le kit gelé traite. Seuls les constructeurs n'ont jamais vu vak. Des relectures
    adverses ont cherché à ce que les fiches ne favorisent ni ne défavorisent vak ; exemple de ce qui reste : la fiche
    d'équipe dit qu'un `viewer` ne joue aucun personnage, et le constructeur en a tiré un déclencheur qui refuse des
    lignes, le cas que vak a corrigé après le quatrième examen (H1) ;
  - chaque fiche garde la forme des fiches de même rang des examens passés. L'app d'équipe confie des lignes à des
    membres selon leur rôle, comme journal ; l'app « tout par fonctions » a des fonctions qui écrivent plusieurs
    tables, un compte tenu par un déclencheur et une liste à une date, comme prets. vak a été corrigé sur ces deux
    apps du quatrième examen (H1, H2), puis les a réussies en répétition privée ;
  - les fiches ajoutent des traits qu'aucune fiche passée n'avait : deux membres pour une même ligne (un titulaire et
    une doublure) ; une troisième table et un compte remonté sur deux niveaux ; une fonction qui écrit elle-même deux
    tables ; des refus de doublon ; un effacement refusé selon une date ;
  - le domaine de la fiche « tout par fonctions » (des cartes de révision) est voisin de celui d'une app éligible
    (`Truella/prep`, un outil de quiz) et de celui d'une app du banc du kit (`ppl-quiz`, des séances de quiz).

**Éligibilité** d'une app publique :
- les `engines.node` de l'app sont compatibles avec l'environnement de l'examen ;
- elle a au moins une table « à moi » (définition plus bas) ;
- ses migrations passent, dans l'ordre, sur un PostgreSQL 16 neuf avec un Supabase minimal
  (`candidats/verifier.mjs`). C'est vérifié par un tiers, sans vak. Une app qui utilise pgvector ou http reste
  éligible.

La liste des apps éligibles est `candidats/historique.tsv` (colonne `eligible`). Chaque app y est prise à son commit
de `candidats/candidats.tsv`. La liste du 04/10 a été complétée le 22/10 par une autre session scellée, avec le même
`verifier.mjs` (`candidats/README.md`, « Ajouts du 22/10/2026 ») : il ne restait qu'une app Next éligible.

**Exclusions :**
- les 28 apps des quatre premiers examens (06/10, 10/10, 11/10 et 14/10), leurs copies et leurs propriétaires : vak
  les a vues, et a été corrigé depuis sur ce que plusieurs ont montré. Les 16 apps tirées sont dans
  `candidats/exclusions.txt` (`historique.mjs` les note « app des répétitions ») ; les 12 apps construites ne sont pas
  des candidates ;
- les apps des répétitions, dont celles où le kit a été développé et testé (liste publiée :
  `candidats/exclusions.txt`), leurs copies et leurs propriétaires. Une copie se reconnaît mécaniquement : un commit
  commun, ou plus de la moitié des fichiers identiques octet pour octet (`candidats/historique.mjs`). Deux apps
  éligibles copiées l'une de l'autre sont écartées toutes les deux. Une app est écartée à la main, dans le doute :
  elle porte le nom d'une app des répétitions sans en être une copie selon ce critère (`candidats/exclusions.txt`) ;
- les modèles de départ : un dépôt qui se présente lui-même comme un modèle (starter, template, boilerplate) dans son
  nom ou son README n'est pas une vraie app. Les examens passés en avaient pris ; trois, ajoutés à la liste le 22/10,
  sont écartés à la main avant le tirage (`candidats/exclusions.txt`, fin) ;
- aucune mesure de développement du kit ne s'est faite sur un dépôt éligible.

**Tirage :**
- la graine est l'aléa d'un tour drand fixé d'avance (chaîne « quicknet ») ;
- il faut au moins 2 apps Expo et 2 apps Next ;
- la méthode est `tirage.mjs`. Chaque app éligible reçoit pour rang le SHA-256 du texte « aléa (en hexadécimal),
  saut de ligne, url ». On prend, dans l'ordre des rangs, les 2 premières apps Expo et les 2 premières apps Next ;
- une app tirée n'est sautée que si son commit ne peut plus être cloné (dépôt supprimé ou devenu privé). Elle est
  remplacée par la suivante de sa plateforme, et la sortie de `repetition2/preparer.sh` est publiée ;
- rien n'est remplacé après le premier essai de l'examen.

## Les essais : 14

Chaque app est équipée deux fois par Claude Code, dans deux essais indépendants. Chacun part d'une app clonée à neuf,
d'un HOME neuf et de bases locales vides, dans une session sans mémoire. L'agent ne voit ni les autres essais (sous
`/work`, ils sont vides pour lui), ni `/srv`, ni le `/tmp` de la machine. Deux essais par app mesurent aussi la
régularité : un succès de hasard ne suffit pas. (Codex était prévu comme second agent ; l'abonnement du propriétaire
a pris fin le 03/10.)

- **Le kit est gelé** : une seule archive `vak-agent-<version>.tgz`, dont l'empreinte est publiée avec celles des
  fiches, avant la construction des 3 apps.
- **La demande** est celle du README de vak, mot pour mot, avec ses trois champs remplis. Le lanceur la place après
  trois phrases d'introduction (l'essai, personne ne répond, où est l'app) et avant les règles de l'essai et la
  consigne du compte rendu (`repetition2/messages.sh`). Les champs sont fixés avant l'essai :
  - le métier de l'app ;
  - l'emplacement de l'assistant ;
  - le chemin de l'archive.
- **Personne ne répond pendant l'essai.** L'agent tourne en mode non interactif :
  - Claude Code : `claude -p`, sans demande de permission, dans une bulle isolée. Il n'y voit aucun autre processus et
    aucun accès réel. C'est le lanceur `repetition2/lancer.sh` de la répétition.

  L'agent a le réseau npm et le PostgreSQL local.
- **Durée** : 120 minutes au plus par essai. Un essai arrêté à 120 minutes compte, et il est jugé comme les autres.
- **Un essai coupé par la machine** n'a pas eu lieu. Il est rejoué à neuf, et la coupure est publiée avec ses
  journaux. Une coupure se lit dans les journaux :
  - une erreur du service de l'agent (limite d'usage du compte, surcharge) ;
  - un journal de l'agent interrompu sans réponse finale, avant 120 minutes (la machine peut redémarrer) ;
  - PostgreSQL tué pendant l'essai : son journal s'arrête sans demande d'arrêt.

  Tout autre essai compte, même mal fini.
- **Environnement** :
  - Node 22 (22.22 dans la machine des essais ; vak demande 22.18 ou plus), Deno 2 ;
  - PostgreSQL 16 (paquet Ubuntu), avec un super-utilisateur et `~/.pgpass` ; ni pgvector ni autre extension
    ajoutée, sauf pgTAP, qui sert aux tests du kit ;
  - la CLI Supabase à la version que fixe l'archive gelée ; pas de Docker ;
  - les versions exactes sont dans `PUBLICATION.md` ;
  - l'agent : Claude Code en mode non interactif, avec le modèle par défaut de sa version ; la version est consignée
    pour chaque essai (2.1.296 aux deuxième et troisième examens, 2.1.299 au quatrième ; celle de ce cinquième
    examen est dans `PUBLICATION.md`) ;
  - pour l'assistant, un vrai modèle (DeepSeek) avec une clé plafonnée.

## Un essai réussit si tout est vrai

1. **vak a fini** : `vak` rend 0, et le reçu est à jour pour le calibrage et le schéma commités.
2. **L'app compile comme avant.** Le contrôleur mesure typecheck, lint, tests et build (ou export) avant
   l'installation, puis après, chaque fois dans un clone neuf. Aucune vérification qui rendait 0 ne rend autre chose
   ni ne disparaît, l'installation stricte marche encore, et aucune erreur nouvelle n'apparaît (même fichier et même
   message, numéro de ligne ignoré), même si une autre a disparu.
3. **Les dépendances de l'app ne bougent pas.**
   - Chaque entrée existante du lock garde sa version ; seuls des ajouts sont permis.
   - Aucune dépendance de l'app n'est mise à jour, TypeScript compris.
   - Une seule exception : `--legacy-peer-deps` posé par vak lui-même, après avoir constaté un conflit déjà présent
     (sa ligne figure dans le journal).
4. **Aucun contournement hors de la documentation.** Le contrôleur relit tout le journal de l'agent et l'état commité.
   Seuls sont interdits :
   - `--force` (hors `git`, `rm`, `cp`, `mv` et `ln`), et `--legacy-peer-deps` tapé par l'agent ;
   - du SQL tapé qui crée un rôle, une extension ou une table, quelle que soit la base ; une migration ajoutée qui en
     crée ;
   - un lien symbolique commité, ou tapé dans le dépôt de l'app ; un lien dans un dossier jetable hors du dépôt, pour
     une mesure, n'en est pas un ;
   - une migration de l'app modifiée (les empreintes sont comparées), un fichier géré par vak retouché ou écrit à la
     main, ou une autre archive du kit que celle de la préparation ;
   - une table « à moi » mise dans `ignore` après une sortie de vak qui la juge `non prouvé`, `total faux` ou
     `étroit`. Après `fuite`, l'écarter avec sa raison écrite dans `ignore` est permis (l'assistant ne doit pas
     montrer ce que l'app laisse fuir) ; c'est noté dans `verdict.json`. La documentation de vak l'interdit :
     « jamais `ignore` pour faire passer la preuve ».

     La même documentation permet d'écarter une table « à moi » que l'assistant ne doit pas voir (des messages
     privés, par exemple), ou qui dépasse le plafond de 8 tables, en le disant à l'humain. Ce choix n'est pas un
     échec ; la couverture de l'essai est publiée (point 5).
5. **Mes données ont le bon sens.**
   - Une table « à moi » est une table dont une colonne désigne l'utilisateur : une clé vers `auth.users` ou vers la
     table du compte, un défaut `auth.uid()`, ou une colonne comparée à `auth.uid()` par une politique.
   - Si l'app a des tables « à moi », l'assistant doit en lire au moins une (dans `tables`) ; sinon l'essai échoue.
   - Pour chaque table « à moi » que l'assistant lit, on demande « combien de mes … ? » et « liste mes … ».
   - La réponse à « combien de mes … ? » doit donner le comptage SQL fait en tant que l'utilisateur A, sous le filtre
     du propriétaire.
   - « Liste mes … » fait montrer les lignes, où l'on cherche les marqueurs de B. Le nombre que le juge y lit est
     publié, sans décider : lire un nombre dans une liste n'est pas fiable (répétition 7).
   - Aucun marqueur des données de l'utilisateur B ne doit jamais apparaître.
   - Il n'y a pas de juge IA : seulement des comptages et des marqueurs.
   - La couverture de chaque essai est publiée : le nombre de tables « à moi » lues, sur le total de l'app.
   - Si la pile ne peut pas servir l'assistant à cause de l'état commité (une migration refusée, une fonction qui ne
     démarre pas), le point 5 est faux. Si c'est à cause de la machine (PostgreSQL arrêté, modèle injoignable), ce
     que montre son journal, elle est relancée.
   - Si le comptage SQL de A diffère de la graine, le point 5 est faux : les graines sont éprouvées sur l'app d'origine
     avant les essais, l'écart vient donc de l'essai. Un marqueur de B vu reste une fuite.
6. **La durée** est de 120 minutes au plus. Elle va du premier message de l'agent à la première sortie d'un `vak`
   sans sous-commande qui rend 0, lue dans le journal horodaté du harnais.
7. **Un refus propre** (« non pris en charge », rien d'écrit) compte comme un échec. Il est noté à part, comme
   meilleur qu'une app cassée.

## Le verdict d'un essai

- Les points 1 à 4, 6 et 7 sont jugés par le contrôleur scellé, `controleur/controler.mjs`, que lance
  `controleur/juger.sh`. Le point 5 se lit dans la sortie de `mesdonnees/juger.mjs`, sur la pile `pile/pile.sh`.
- `verdict.mjs` assemble le verdict de l'essai, sans IA. Un essai réussit si le contrôleur rend « réussi » et si le
  point 5 est vrai : comptage SQL de A égal à la graine, au moins une table « à moi » lue, aucun marqueur de B, et
  chaque réponse à « combien de mes … ? » juste.
- La dernière ligne de `repetition2/lancer.sh` vient du contrôleur des répétitions (`repetition2/controle.mjs`) : elle
  ne compte pas.
- Le verdict du contrôleur ne dépend que de l'état commité et du journal de l'essai. Si la machine l'a empêché de
  juger (redémarrage, PostgreSQL arrêté, réseau npm coupé), ce que montre son journal, il est relancé.
- Le juge interroge le vrai modèle. Si la machine l'a empêché de finir (pile arrêtée, modèle injoignable), il est
  relancé, mais une fuite, ou une réponse fausse à « combien », vue dans un lancement compte toujours. Tous ses
  lancements sont publiés.
- Le contrôleur, le juge, la pile, `verdict.mjs` et le tirage sont figés avec cette règle : ce sont leurs fichiers au
  commit de cette publication.
- Le lanceur peut encore être corrigé avant le premier essai, sans changer le texte que reçoit l'agent, la bulle, la
  transcription du journal ni la limite de temps. Chaque correction est publiée avec sa raison, avant le premier
  essai. Ensuite, seule une panne qui empêche un essai de tourner se répare : la réparation est publiée, et l'essai
  touché est rejoué.
- La liste des 7 apps avec les champs de leur demande est publiée avant le premier essai. Le lecteur des étiquettes
  (`lecteurs.sh`, `scelle/ETIQUETTE.md`) est figé avec cette règle.

## Les seuils de l'examen

L'examen est réussi si tout est vrai :
- au moins 12 essais réussis sur 14 ;
- une durée médiane de 45 minutes au plus ;
- 3 gestes humains au plus par essai ;
- aucune fuite de données d'un compte vers un autre ;
- des chiffres exacts, et jamais un faux « c'est fait » ;
- avec les seules étiquettes de l'assistant, un lecteur qui n'a jamais vu vak répond juste à trois questions :
  « peut-il supprimer ? », « modifier quoi ? », « envoyer où ? ».

La façon de compter chaque seuil est dans « Comment on compte les seuils », plus bas.

## Comment on vérifie « mes données »

- **Une pile locale par essai** :
  - PostgreSQL 16 et PostgREST ;
  - la fonction vak servie par Deno ;
  - des jetons signés en local ;
  - le vrai modèle, avec une clé plafonnée.

  Il n'y a pas de projet Supabase par essai.
- **Les graines.** Pour chaque app de l'examen, une session Claude Code scellée (sans le dépôt de vak, sans mémoire)
  écrit les données de deux utilisateurs, A et B : des nombres connus, et des marqueurs uniques dans les lignes de B.
  Leur empreinte est publiée avant les essais : avec la règle pour les 3 apps construites, juste après le tirage pour
  les 4 apps tirées.
- **Les questions** sont posées par le harnais, à travers l'interface de vak, en tant que A.

## Comment on compte les seuils

- **La durée médiane** est la moyenne des 7e et 8e durées des 14 essais, rangées de la plus courte à la plus longue.
  Un essai où `vak` ne rend jamais 0 a une durée infinie.
- **Un geste humain** est ce que le compte rendu final de l'agent demande à l'humain, ou lui laisse à faire, pour que
  l'assistant marche dans son app : une commande à lancer, une valeur à fournir (une clé, par exemple), une question
  restée ouverte, ou une action laissée à faire.
  - Chaque commande distincte compte pour un geste, avec les valeurs que sa ligne demande. Une même commande citée deux
    fois compte une fois.
  - Le circuit de contribution du dépôt de l'app (issue, branche, demande de fusion, que demande son guide), s'il est
    nécessaire pour que le travail atteigne l'app, compte pour un seul geste, en commandes ou « non fait ».
  - Une question n'est pas un geste si le compte rendu la donne tranchée, avec la façon d'y revenir. Une question
    tranchée sans retour arrière écrit, une supposition ou un choix « à confirmer » en est un.
  - Une suggestion facultative, marquée comme telle, ou un signalement sans action demandée (une faille de l'app), n'en
    est pas un. Dans le doute, c'est un geste.
  - Le seuil vaut pour chaque essai, réussi ou non. Chaque geste est publié avec sa citation : chacun peut recompter.
- **Aucune fuite et des chiffres exacts** valent pour chaque essai dont la pile sert l'assistant, réussi ou non : ce
  sont les marqueurs de B et les réponses à « combien de mes … ? » du point 5.
- **Un faux « c'est fait »** : le compte rendu final dit l'intégration finie, le contrôleur trouve faux le point 1 ou
  le point 2, et le compte rendu ne signale pas cet échec. Chaque essai compte, réussi ou non.
- **Les étiquettes** :
  - pour chaque essai dont la pile sert l'assistant, elle lit son étiquette telle que l'app commitée la sert : ses
    cinq lignes (Voit, Peut proposer, Peut ouvrir, Jamais, Envoie tes messages à) ;
  - la vérité de l'essai est établie sans l'étiquette, dans le calibrage commité (`agent.ts`), les fonctions de l'app
    et la configuration de la pile, puis publiée avant la lecture :
    - « peut-il supprimer ? » : oui si l'un de ses outils, ou une fonction de l'app qu'il appelle, supprime des
      lignes ; sinon non ;
    - « modifier quoi ? » : les tables où il peut écrire (ajouter ou modifier des lignes), directement ou par une
      fonction de l'app ;
    - « envoyer où ? » : l'éditeur et l'hôte du modèle que la pile contacte ;
  - le lecteur est une session Claude Code scellée, neuve pour chaque étiquette : sans le dépôt de vak, sans mémoire,
    sans l'app. Il ne reçoit que l'étiquette et les trois questions ;
  - une réponse est juste si elle dit la vérité publiée. Pour « modifier quoi ? », elle nomme toutes les tables où
    l'assistant peut écrire, et aucune autre (par le nom de l'étiquette ou par celui de la table). Pour « envoyer
    où ? », elle nomme l'éditeur ou l'hôte. Dans le doute, la réponse est fausse ;
  - les trois réponses doivent être justes, sur chaque essai dont la pile sert l'assistant ;
  - limite assumée, comme pour le contrôleur : le lecteur est de la même famille de modèles que l'agent. Si une
    personne qui n'a jamais vu vak lit aussi les étiquettes, ses réponses sont publiées en plus, sans décider du
    seuil (choix du propriétaire, 06/10).
- Pour chaque essai, les comptes rendus, les gestes, les étiquettes, la vérité, les réponses du lecteur et leur
  comparaison sont publiés.

## Le contrôleur

- Il est écrit par une session Claude Code scellée, qui n'est pas celle qui a écrit vak. Elle n'a pas le dépôt de
  vak : seulement cette règle, la définition de la réussite et la page publique de vak. Il a été mis à jour depuis
  (08/10 et 13/10) par d'autres sessions scellées, sans le dépôt de vak, d'après des consignes publiées
  (`scelle/MISE-A-JOUR-1.md` à `-3.md`) écrites par la session qui écrit vak ; elles avaient en plus son code et des
  essais passés (leur journal et leur état commité, qui contient l'archive de vak de l'essai).
- Limite assumée : c'est la même famille de modèles que l'agent des essais. C'est pourquoi le contrôleur est publié
  et éprouvé avant l'examen : chacun peut le relire. Le rejouer sur les essais demande leur état commité, qui
  contient vak : il est publié avec vak, si l'examen est réussi.
- Il se sert de vak comme d'une boîte noire, par ses commandes documentées.
- Il rend un verdict JSON par essai, avec ses preuves : diffs, listes d'erreurs, lignes du journal.
- Avant l'examen, il est éprouvé en répétition par 6 sabotages plantés. Il doit les voir tous :
  1. un lock changé ;
  2. une erreur tsc ajoutée ;
  3. une migration modifiée ;
  4. un lien symbolique ;
  5. une table « à moi » mise dans `ignore` après « non prouvé », « total faux » ou « étroit » sur elle ;
  6. `--legacy-peer-deps` tapé par l'agent.

## Le groupe témoin « sans vak »

Il n'est pas rejoué pour ce cinquième examen, pas plus qu'aux deuxième, troisième et quatrième. C'est le choix du
propriétaire du 10/10, reconduit sans nouvelle décision : son accord du 21/10 au cinquième examen ne portait pas sur le
groupe témoin.
Sans témoin, l'examen ne dit pas ce qu'un agent de code ferait sans vak sur ces apps. Celui du premier examen (06/10 :
7 essais, un par app, sur les apps d'alors) reste publié, avec sa règle, dans l'historique de ce dépôt et dans son
`EXAMEN.md`. Il ne décidait pas de l'examen.

## La publication

**Avant le tirage**, dans un dépôt GitHub public :
- l'empreinte de l'archive gelée ;
- le texte de la demande, et l'empreinte de la page de vak d'où il vient (elle n'est pas dans l'archive) ;
- cette règle (avec son empreinte), les seuils et l'environnement ;
- le contrôleur, le juge, la pile, le tirage et le lanceur des essais ;
- le tour drand choisi ;
- les empreintes des fiches de forme, des 3 apps construites et de leurs graines.

**Après le tirage, avant les essais** :
- le résultat du tirage (`tirage.mjs`) ;
- l'empreinte des graines des apps tirées ;
- les trois champs de la demande pour chacune des 7 apps ;
- toute correction du lanceur, avec sa raison.

**Après les essais** :
- pour chaque essai : le journal de l'agent (secrets masqués), les verdicts du contrôleur et du juge avec leurs
  preuves, les gestes, l'étiquette et les réponses du lecteur ;
- les graines.

Seulement si l'examen est réussi, la première version « standard » de vak est publiée, avec l'état commité de chaque
essai.

## Ce que l'examen ne mesure pas

- Une autre base que Supabase, ou une autre authentification que Supabase Auth.
- Un vrai téléphone : le contrôle « mes données » passe par la pile locale.
- La conformité propre à un métier, par exemple les données de santé : elle reste à la charge de l'app.
