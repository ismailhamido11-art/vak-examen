# Avant le premier essai

Publié après le tirage et avant le premier essai, comme le veut la règle (`REGLE.md`, « La publication » et « Le
verdict d'un essai »). Les outils figés (la règle, le contrôleur, le juge, la pile, `verdict.mjs`, le tirage, les
candidats, les apps construites et leurs fiches) n'ont pas changé depuis la publication du 06/10 (commit `698f07b`).

## Le tirage

Voir [`TIRAGE.md`](TIRAGE.md). Les 4 apps tirées sont :

- **budget_app** (Next.js) : https://github.com/AndrerezaMedya/budget-app, commit `f1f3ef1`. Métier : « Un suivi de finances personnelles : on y gère ses comptes, ses catégories, ses transactions et ses budgets. » Emplacement : un bouton flottant sur tous les écrans.
- **track_training_app** (Expo) : https://github.com/aprescod12/track-training-app, commit `00acb94`. Métier : « Le carnet d'entraînement d'un athlète : on y note ses séances sur piste et de musculation, son calendrier et ses performances. » Emplacement : un onglet « Assistant » (onglets : `app/(tabs)/_layout.tsx`).
- **workout_plan_companion** (Expo) : https://github.com/AndreuCrespo/workout-plan-companion, commit `ebf680c`. Métier : « Un compagnon de salle de sport : on y suit son plan d'entraînement du mois, ses séances guidées et ses progrès. » Emplacement : un onglet « Assistant » (onglets : `mobile/app/(tabs)/_layout.tsx`).
- **company_invoicing** (Next.js) : https://github.com/xtshepana/company-invoicing, commit `e999749`. Métier : « La facturation d'une entreprise : on y gère ses factures, ses paiements et le rapprochement bancaire. » Emplacement : un bouton flottant sur tous les écrans.

## Les graines des 4 apps tirées

Elles ont été écrites par une session Claude Code scellée, d'après [`scelle/GRAINES-TIREES.md`](scelle/GRAINES-TIREES.md)
(une session par app, toutes en même temps : `bash vak-examen/graines-tirees.sh`). Elles seront publiées après les
essais, avec les autres ; voici leurs empreintes SHA-256 :

```text
c1c1cd3651a52dce7f0082452b868bfc2deb91c9c0bd7de745f1986f60e03680  vak-examen/graines/budget_app/graine.sql
fe7f0d075ccfb2c60c1edf398975401397c2dfe700c5b7c67b971a0368fb9d5d  vak-examen/graines/budget_app/attendu.json
1ee2f0a95fc4a71a51b5983bd8113d714836f1ed72adbab0ed870b35f1f54b13  vak-examen/graines/track_training_app/graine.sql
f7b956304adc2808ebba8904ddcb36f82b6a1f9643b1e10d71cd9a7c9a579655  vak-examen/graines/track_training_app/attendu.json
6b85679ba1a28dfc82cfd495a21d82fbc357e1877f268ca43e6dede29411757b  vak-examen/graines/workout_plan_companion/graine.sql
aeb89da12e4d02824275d4ffb2435adac36b88779615ce507a0aa59e32cf89d8  vak-examen/graines/workout_plan_companion/attendu.json
c34ec4688d6f982814b10c2b97e23b5ab447f10e6ceeaa92e38fa573fe4df555  vak-examen/graines/company_invoicing/graine.sql
a8e90f751bc0efcd6c570d66defd9ccfe45a4c1c9b71639214a6d76e89df1a0e  vak-examen/graines/company_invoicing/attendu.json
```

L'épreuve figée (`graines/eprouver.mjs`, sur le minimum de Supabase des graines) est conforme pour
workout_plan_companion. Pour budget_app, track_training_app et company_invoicing, les migrations de l'app demandent un
schéma `storage` que ce minimum n'a pas : chaque session l'a ajouté dans sa propre copie de l'outil, sans toucher à
l'original, et son épreuve est conforme (`graines/RAPPORT-<nom>.md`, `graines/outils-tirees/`, publiés avec les
graines). Puis les graines des 7 apps ont été éprouvées dans les conditions de la pile
([`graines-pile.sh`](graines-pile.sh)) : base créée par `vak localdb` de l'archive gelée, comptes A et B insérés comme
la pile, graine appliquée, comptes de A sous la RLS de l'app et marqueurs de B visibles par A. Les 7 sont conformes
(47 tables vérifiées ; `graines/EPREUVE-PILE.txt`, publié avec les graines).

## Les essais et les champs de leur demande

[`essais.tsv`](essais.tsv) : 14 essais, 2 par app, et les deux champs de la demande que fixe chaque app (le chemin de
l'archive est toujours `/work/vak-agent.tgz`) :
- **les apps construites** : le métier reprend la phrase de leur fiche ;
- **les apps tirées** : le métier résume le README de l'app, en une phrase. Les champs des 23 apps éligibles ont été
  fixés et publiés avant le tirage ([`champs-candidats.tsv`](champs-candidats.tsv)) ; ceux des apps tirées en sont
  recopiés tels quels ;
- **l'emplacement** : un onglet « Assistant » si l'app a des onglets (une app Expo dont la navigation principale est un
  navigateur à onglets d'Expo Router) ; sinon un bouton flottant sur tous les écrans.

Dans l'ordre où ils sont joués :

```sh
bash vak-examen/essai.sh demarre_1 equipe_1 fonctions_1 budget_app_1 track_training_app_1 workout_plan_companion_1 company_invoicing_1 demarre_2 equipe_2 fonctions_2 budget_app_2 track_training_app_2 workout_plan_companion_2 company_invoicing_2
```

Ordre : un premier essai de chaque app, puis le second de chaque app, dans le même ordre. `essai.sh` les joue l'un après
l'autre.

Les ids n'ont que des minuscules, des chiffres et « _ » (`demarre_1`) : la pile nomme sa base `examen_<id>`, et
`vak localdb` refuse tout autre caractère. Les ids `<app>-<n>` d'`essais.tsv`, publiés avant le tirage, sont devenus
`<app>_<n>` avant le premier essai ; rien d'autre n'a changé dans la liste.

## Les corrections du lanceur depuis la publication

Aucune ne change le texte que reçoit l'agent d'un essai de vak, la bulle de ces essais, la transcription du journal
ni la limite de temps (`REGLE.md`, « Le verdict d'un essai »).
- `repetition2/preparer.sh` : une app peut venir d'une archive git du dépôt (les 3 apps construites) ; avec
  `TEMOIN=1`, l'app part sans l'archive de vak (groupe témoin).
- `repetition2/messages.sh` : avec `TEMOIN=1`, la consigne du groupe témoin, fixée par la règle, remplace la demande
  de vak.
- `repetition2/lancer.sh` : avec `TEMOIN=1`, la bulle cache aussi l'archive de vak (`REGLE.md`, « Le groupe
  témoin ») ; la sonde (`SONDE_BULLE=1`) montre la taille de l'archive vue dans la bulle.

## Les outils ajoutés

- [`essai.sh`](essai.sh) : un essai de bout en bout, l'un après l'autre (l'essai, le contrôleur scellé, la pile et
  le juge, l'étiquette, `verdict.mjs`), puis le ménage du disque. Relancé après un redémarrage de la machine, il saute
  un essai jugé, reprend au jugement un essai fini, et garde les journaux d'un essai coupé avant de le rejouer à neuf.
- [`etiquettes/`](etiquettes/) : la lecture de l'étiquette sur la pile, la vérité de chaque essai (publiée avant la
  lecture) et la comparaison ; le lecteur scellé, [`scelle/ETIQUETTE.md`](scelle/ETIQUETTE.md) (`ETIQUETTE=` du
  lanceur scellé).
- [`scelle/GRAINES-TIREES.md`](scelle/GRAINES-TIREES.md) et le mode `TIREES=` du lanceur scellé ; chaque session
  scellée ne voit plus que son propre dossier sous `/srv`.
- [`tirage-publier.mjs`](tirage-publier.mjs) : écrit `TIRAGE.md` et la liste des apps tirées pour leurs graines.
- [`liste-essais.mjs`](liste-essais.mjs) : ajoute à `essais.tsv` les essais des apps tirées et remplit cette page.
- [`graines-pile.sh`](graines-pile.sh) : éprouve les graines dans les conditions de la pile (voir plus haut).
- [`etiquettes/etat.sh`](etiquettes/etat.sh) : reconstruit l'état commité d'un essai depuis son `essai.bundle`, pour
  établir la vérité de son étiquette.
- [`resultat.mjs`](resultat.mjs) : le verdict de l'examen, sans IA, écrit avant le premier essai. Il applique les seuils
  de la règle aux résultats des 14 essais. Les jugements faits à la main (gestes, étiquettes, faux « c'est fait »)
  sont des fichiers cités, publiés avec chaque essai ; s'il en manque un, l'examen est « incomplet », jamais
  « réussi ».

Ils ont été éprouvés avant le tirage :
- `essai.sh`, de bout en bout, sur sqlnoir (répétitions 8 et 9, `repetition/RESULTATS.md`) : verdict réussi, la
  seconde avec un id sans tiret (`sqlnoir_9`) ;
- la sonde du mode témoin : archive vide dans la bulle, app à son commit d'origine ;
- la préparation d'une app construite depuis son archive git, au bon commit ;
- le lecteur scellé, sur une étiquette d'exemple ;
- `resultat.mjs`, sur 14 essais simulés : incomplet sans les jugements, réussi avec, échoué avec 4 gestes ou une
  fuite.
