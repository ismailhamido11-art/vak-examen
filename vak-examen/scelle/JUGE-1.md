# Mise à jour du juge « mes données », pour le prochain examen

Tu as écrit `mesdonnees/juger.mjs` et son `README.md` d'après `REGLE.md` et ta consigne. L'examen du 06/10 et sa
répétition ont montré une limite : une app tirée au sort parle espagnol (`langue` : `es` dans `attendu.json`). Ses
tables reçoivent les questions anglaises, et les nombres espagnols écrits en lettres ne sont pas lus. Les sorties
réelles du juge sont dans `cas/` (questions, réponses complètes, lecture).

Exemple (`cas/workout_plan_companion_1.json`) : à « How many of my perfiles are there? », la réponse « Tienes **un solo
perfil**, Marta. […] tu disponibilidad (3 días) » est lue 3 au lieu de 1.

Ce que tu fais :
1. L'espagnol, comme le français et l'anglais :
   - les questions : « ¿Cuántos de mis *nom* hay? », puis « Lista mis *nom*. » ;
   - les nombres en toutes lettres de cero à veinte (« dieciséis » compris), les formes d'un seul (« un solo », « una
     sola », « solo uno », « solo una », « únicamente uno », « únicamente una »), et « un / una / uno » suivi du nom
     compté, avec une épithète permise entre les deux. « un », « una », « uno » seuls ne sont pas des nombres.
2. Rien d'autre ne change : le premier nombre décide toujours, en espagnol comme ailleurs.
3. Des tests dans `mesdonnees/tests/juger.test.mjs` qui échouent sans ta correction, dont l'exemple ci-dessus.
   Fais tourner `node --test mesdonnees/tests/juger.test.mjs` (l'épreuve de bout en bout demande les graines et les
   apps, absentes ici : ne la lance pas). Mets à jour la règle de lecture de `mesdonnees/README.md`.

Ne change rien d'autre. Termine par un compte rendu court : ce que tu as changé, et comment les réponses de `cas/`
seraient lues désormais (sans les rejouer : elles sont données).
