# Mise à jour du contrôleur : la règle est précisée

Tu as écrit `controleur/` d'après `REGLE.md`, `PAGE-VAK.md` et `CAHIER.md`, tous trois dans ce dossier. Tu avais
signalé une décision que la règle ne tranchait pas : le `ln -s` tapé par l'agent de maybewe vers un dossier jetable
hors du dépôt de l'app (`/tmp/base/node_modules`), pour mesurer l'état d'avant.

La règle est maintenant précisée, au point 4 :

> un rôle, une extension, une table ou un lien symbolique créé à la main dans l'app (son dépôt ou sa base) ; un lien
> dans un dossier jetable hors du dépôt, pour une mesure, n'en est pas un

Ce que tu fais :
1. Mets le contrôleur en accord avec cette phrase, et seulement avec elle. Un lien commité dans le dépôt, ou tapé
   dans le dépôt (sa racine, ses dossiers), reste un échec. Un lien tapé hors du dépôt n'en est pas un, mais il est
   noté dans `verdict.json`.
2. Rejoue l'essai `essais/maybewe`, et tes sabotages de liens : commité, tapé dans le dépôt, et tapé hors du dépôt
   (ce dernier doit passer, avec sa note). Fais aussi tourner les tests de `controleur/tests/`.
3. Mets à jour `controleur/README.md`, ainsi que les verdicts de `verdicts-repetition/` qui changent.

Ne change rien d'autre. Termine par un compte rendu court : ce que tu as changé, et le nouveau verdict de maybewe.
