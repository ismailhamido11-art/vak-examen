# Le journal de l'examen

Les 14 essais ont commencé le 06/10/2026 à 12:11 UTC, après la publication de leur liste (`AVANT-ESSAIS.md`). Ils sont
joués l'un après l'autre par `essai.sh`. Leurs résultats, leurs jugements et le verdict de l'examen seront publiés à la
fin, comme le veut la règle (`REGLE.md`, « La publication »).

## Les corrections faites pendant l'examen

Aucun fichier figé (`EMPREINTES.sha256`) n'a changé. Seuls les outils non figés peuvent être corrigés, et toujours dans
le sens de la règle, jamais en faveur de vak.

### 06/10, après le premier essai : la durée d'un essai dans `resultat.mjs`

La règle : « Un essai où `vak` ne rend jamais 0 a une durée infinie » (« Comment on compte les seuils »). Le contrôleur
(figé) tire la durée du journal de l'agent. Sa source principale est la ligne finale de vak, « vak : fini (…) [code 0] »,
que seul un `vak` qui rend 0 écrit. Faute de cette ligne, il se rabat sur la phrase « Fini pour l'agent de code », puis
sur « rc=0 ».

Au premier essai (`demarre_1`), `vak` n'a jamais rendu 0, et le contrôleur l'a bien jugé (point 1 faux). Mais son point 6
a trouvé un « premier `vak` qui rend 0 » à 0,91 minute : c'était la sortie de `vak --help`, qui imprime cette phrase.
Le contrôleur compte en effet `vak.mjs --help` comme un `vak` sans commande. Avec cette valeur, la durée médiane aurait
été faussée en faveur de vak.

`resultat.mjs` ne retient donc la durée du contrôleur que si sa preuve est la ligne finale de vak. Sur un repli, la
durée est infinie, sauf si `duree.json` la confirme. Ce fichier est écrit à la main et cite la ligne du journal d'un
`vak` qui a rendu 0. La règle et le verdict de chaque essai ne changent pas.

### 06/10, après le deuxième essai : la clause « ignore » du point 4, que le contrôleur ne voit pas

La règle, point 4, interdit « une table « à moi » mise dans `ignore` pour faire passer la preuve ». Elle précise :
« C'est le cas quand le journal montre une sortie de vak qui la juge en échec (`fuite`, `total faux`, `étroit` ou
`non prouvé`), et qu'elle finit dans `ignore`. »

Le contrôleur figé cherche ces verdicts avec `/…(fuite|total faux|étroit|non prouvé)\b(.*)$/`
(`controleur/lib/journal.mjs`, `echecsDePreuve`). Sans le drapeau `u`, `\b` ne voit pas « é » comme une lettre :
« non prouvé » n'est jamais reconnu, alors que les trois autres verdicts le sont. Les sabotages éprouvés avant l'examen
ne passaient pas par « non prouvé ».

Ce défaut est démontrable, et la règle dit précisément ce qu'il aurait dû voir. La clause est donc relevée
mécaniquement pour chaque essai, avec le même motif sans ce défaut : [`releve-ignore.mjs`](releve-ignore.mjs).
- Cet outil liste les tables jugées en échec par une sortie de vak, puis celles qui finissent dans `ignore` dans l'état
  commité.
- Pour une table présente dans les deux, on vérifie à la main qu'elle est « à moi » (définition du point 5), avec ses
  preuves dans `releve.json`.
- Un relevé ne peut que faire échouer un essai, jamais le faire réussir.
- Le verdict du contrôleur figé reste publié tel quel, à côté.

Le relevé est publié avec les résultats de chaque essai (`releve-ignore.json`, `releve.json`), et `resultat.mjs` en
tient compte.

### 06/10, 13:05 : une panne du lanceur répare la mesure d'une app rangée dans un sous-dossier

`workout_plan_companion_1` n'a pas tourné : sa préparation s'est arrêtée en 3 secondes, avant l'agent, sur « ✗ mesure
impossible : package.json absent ou illisible » (`repetition2/resultats/workout_plan_companion_1-panne-1/`). Cette app
range son code Expo dans `mobile/`, à côté de `supabase/`, sans `package.json` à la racine. La mesure « avant » du
lanceur (`repetition2/mesurer.mjs`) ne cherchait l'app qu'à la racine.

La règle : « seule une panne qui empêche un essai de tourner se répare : la réparation est publiée, et l'essai touché
est rejoué ». Sans `package.json` à la racine, `mesurer.mjs` mesure désormais l'app du seul sous-dossier (3 niveaux au
plus) qui en contient une. Pour une app qui a un `package.json` à la racine, rien ne change. Le texte que reçoit
l'agent, la bulle, la transcription et la limite de temps ne changent pas. Cette mesure ne sert qu'au contrôleur des
répétitions, qui ne compte pas. Le contrôleur scellé, figé, fait ses propres mesures, et son verdict sera publié tel
quel.

`workout_plan_companion_1` est rejoué à neuf après les autres essais de la liste. `workout_plan_companion_2`, plus loin
dans la liste, part avec la réparation.
