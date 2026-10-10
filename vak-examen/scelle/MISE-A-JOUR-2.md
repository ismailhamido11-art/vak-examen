# Mise à jour du contrôleur, pour le prochain examen

Tu as écrit `controleur/` d'après `REGLE.md`, `PAGE-VAK.md` et `CAHIER.md`, tous trois dans ce dossier, puis tu l'as mis
à jour une fois (le lien symbolique hors du dépôt). L'examen du 06/10 a été joué avec lui. Quatre défauts du
contrôleur y ont été relevés, et la règle du prochain examen change une clause. Les essais cités sont dans `essais/`.

Ce que tu fais :
1. `vak --help` (ou `vak <commande> --help`) n'est pas un `vak` sans commande : il ne compte ni pour la durée, ni
   comme le dernier `vak` lancé. Des durées de moins de 2 minutes en sont sorties à l'examen.
2. « non prouvé » est un échec de la preuve sur une table, comme `fuite`, `total faux` et `étroit` : reconnais-le dans
   les sorties de vak du journal (equipe_1 a mis `team_invitations` dans `ignore` après « non prouvé »).
3. Une app rangée dans un sous-dossier du dépôt (`vak init --app <dossier>`) : le point 2 se mesure dans ce dossier,
   avant l'intégration et après. Il était vide (workout_plan_companion_2).
4. Une erreur de build déjà présente avant l'intégration reste ancienne, même quand l'outil l'imprime deux fois
   (`next build`, budget_app_2) : compare des ensembles d'erreurs, pas des listes.
5. La clause « ignore » du point 4 devient, dans la règle du prochain examen :

   > une table « à moi » mise dans `ignore` après une sortie de vak qui la juge `non prouvé`, `total faux` ou
   > `étroit`. Après `fuite`, l'écarter avec sa raison écrite dans `ignore` est permis (l'assistant ne doit pas
   > montrer ce que l'app laisse fuir) ; c'est noté dans `verdict.json`.

   Mets le contrôleur en accord avec cette phrase, et seulement avec elle.
6. Pour chaque point, un test dans `controleur/tests/` qui échoue sans ta correction. Rejoue tes sabotages et les
   essais de `essais/`. Mets à jour `controleur/README.md` et les verdicts de `verdicts-repetition/` qui changent.

Ne change rien d'autre. Termine par un compte rendu court : chaque correction, son test, et les verdicts qui changent.
