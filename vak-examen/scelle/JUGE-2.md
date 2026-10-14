# Deuxième mise à jour du juge « mes données », pour le prochain examen

Tu as écrit `mesdonnees/juger.mjs` et son `README.md` d'après `REGLE.md` et ta consigne, puis tu l'as mis à jour une
fois (l'espagnol). Les examens du 10/10 et du 11/10 ont montré deux limites. Les sorties réelles du juge sont dans
`cas/` (questions, réponses complètes, lecture). La pile a changé depuis : lis `pile/PILE.md`.

Ce que tu fais :
1. **Le comptage SQL en tant que A, avec les revendications du jeton de la pile.** La pile signe maintenant ses jetons
   comme Supabase Auth après une connexion par mot de passe, sans second facteur : `sub`, `role: "authenticated"`,
   `aud: "authenticated"`, `email` (l'adresse de A, `comptes.A.email` de `pile.json`), `aal: "aal1"`,
   `amr: [{ "method": "password", "timestamp": <maintenant> }]`, `session_id`, `is_anonymous: false` (le jeton porte
   aussi `iat` et `exp`, facultatifs ici ; `comptes.A.email` devient requis dans `pile.json`, comme `db` et
   `comptes.A.id`). Ton comptage pose `request.jwt.claims` avec `sub` et `role` seulement : une RLS qui lit le niveau
   MFA (`auth.jwt() ->> 'aal'`) ou l'adresse (`auth.jwt() ->> 'email'`) ne compte alors rien de juste. Pose les mêmes
   revendications que le jeton (un `session_id` tiré au hasard suffit). Exemple : `cas/supabase_nextjs_template_1.json`,
   où la base de la pile n'avait pas encore `auth.mfa_factors` (elle l'a maintenant) et où le jeton n'avait pas `aal`.
2. **« il n'y en a qu'un ».** `cas/my_saas_boilerplate_1.json` : à « How many of my profiles are there? », la réponse
   dit « Côté compte, il n'y en a qu'un » ; le juge n'y lit aucun nombre. « qu'un » et « qu'une » (apostrophe droite
   ou typographique) valent 1 seulement dans la tournure restrictive : une négation « ne » ou « n' » (apostrophe
   droite ou typographique) les précède d'au plus quatre mots, dans la même phrase (une phrase finit à `.`, `!`, `?`,
   `;`, `:` ou à un retour à la ligne), sans « pas » ni « jamais » entre les deux ; et ils sont suivis d'une
   ponctuation, de la fin du texte, de « seul » ou « seule », ou du nom compté. Ainsi « il n'y en a qu'un » et « vous
   n'en avez qu'une » valent 1 ; « vous n'avez pas qu'un profil », « n'oubliez pas qu'un compte … » et « il n'y a
   qu'un compte, mais 4 profils » (nom compté : profils) ne valent pas 1 par cette règle (en comptant des profils,
   « vous n'avez pas qu'un profil » reste lu 1 par la règle « un / une + nom compté »). La règle « un / une + nom
   compté » ne change pas : « parce qu'une table » reste lu 1 quand on compte des tables, comme aujourd'hui ; ailleurs
   (« parce qu'une erreur … »), « qu'un » n'est pas un nombre. Le premier nombre décide toujours.
3. Rien d'autre ne change.
4. Des tests dans `mesdonnees/tests/juger.test.mjs` qui échouent sans ta correction : pour le point 1, sur
   `faux-psql.mjs`, les revendications posées (`aal` et `email` compris) ; pour le point 2, l'exemple ci-dessus,
   « il n'y en a qu'un » et « vous n'en avez qu'une » (lus 1). Puis, en garde (ils passent déjà et doivent passer
   après), les autres phrases citées avec leur nom compté : « vous n'avez pas qu'un profil » (tables), « n'oubliez pas
   qu'un compte … » (profils) et « parce qu'une erreur … » (tables) : aucun nombre ; « il n'y a qu'un compte, mais 4
   profils » (profils) : 4 ; « parce qu'une table » (tables) : 1. Fais tourner
   `node --test mesdonnees/tests/juger.test.mjs` (l'épreuve de bout en bout demande les graines et les apps, absentes
   ici : ne la lance pas). Mets à jour `mesdonnees/README.md`.

Termine par un compte rendu court : ce que tu as changé, et comment les réponses de `cas/` seraient lues désormais
(sans les rejouer : elles sont données).
