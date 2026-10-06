# Consigne : les graines A et B, et le juge « mes données »

Tu prépares le point 5 de l'examen public de vak (`REGLE.md`, « Mes données ont le bon sens » et « Comment on vérifie
« mes données » »). vak est un kit qui ajoute un assistant IA à une app Expo ou Next.js adossée à Supabase ; sa page
publique est `PAGE-VAK.md`. Tu n'as jamais vu son dépôt, et tu ne le verras pas. Personne ne répondra pendant ton
travail : ne pose aucune question, tranche, et note tes choix dans ton compte rendu.

## Ce que tu as, dans ce dossier

- `REGLE.md`, `PAGE-VAK.md`.
- `apps/` : les apps de l'examen déjà connues, chacune à son commit :
  - `demarre/`, `equipe/`, `fonctions/` : les 3 apps construites pour l'examen ;
  - `sqlnoir/` : une app publique des répétitions, pour éprouver ton travail.
- `pile/` : l'outil qui pose les questions (`demander.mjs`) et la description de la pile locale (`PILE.md`).

## Ce que tu livres

### 1. Les graines : `graines/<app>/graine.sql` et `graines/<app>/attendu.json`

Une graine par app de `apps/`. Elle s'applique, avec `psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql`, sur une
base où les migrations de l'app sont passées et où les comptes A et B existent déjà dans `auth.users` (la pile les
crée ; leurs identifiants changent à chaque fois). Elle donne :
- à A, des nombres connus dans chaque table « à moi » (définition de la règle, point 5) ;
- à B, des lignes différentes, dont chaque texte libre contient un marqueur unique et reconnaissable
  (`MARQUEUR-B-<8 caractères>`), de sorte qu'une fuite de B se voie à coup sûr ;
- des valeurs que l'app accepte : clés étrangères, contraintes, déclencheurs, fonctions de l'app s'il le faut.

`attendu.json` décrit, pour chaque table « à moi » de l'app :
- `table` (`schéma.table`) ;
- `colonne` : la colonne qui désigne l'utilisateur, celle du filtre du propriétaire ;
- `nom` : le nom courant de ses lignes, au pluriel, tel qu'un utilisateur le dirait (« livres », « dépenses ») ;
- `a` : le nombre de lignes de A sous ce filtre, une fois la graine appliquée ;
- et la liste des `marqueurs_b`.

Éprouve chaque graine sur une base neuve. Un PostgreSQL 16 tourne en local : 127.0.0.1:5432, super-utilisateur
`root`, mot de passe dans `~/.pgpass`. Écris le minimum de Supabase que les migrations attendent, applique-les, crée
deux comptes, applique la graine, puis vérifie `a` par SQL, en tant que A : rôle `authenticated`, `request.jwt.claims`
posé. Supprime ensuite la base.

### 2. Le juge : `mesdonnees/juger.mjs`

Node 22, sans dépendance npm. `node mesdonnees/juger.mjs <pile.json> <attendu.json> <dossier de l'app> <sortie.json>`
juge le point 5 pour un essai fini :
- la pile tourne déjà, la graine est appliquée, et `<dossier de l'app>` est l'état commité de l'app après l'essai ;
- les tables que l'assistant lit se trouvent par ce que l'app a commité, de la manière que décrit `PAGE-VAK.md` ;
  écris ta méthode dans le compte rendu ;
- pour chaque table « à moi » lue, en tant que A et par `pile/demander.mjs` : « combien de mes <nom> ? », puis
  « liste mes <nom> ». Pose les questions dans la langue de l'assistant de l'app ;
- le nombre attendu est le comptage SQL fait en tant que A au moment du jugement (`attendu.json` le donne aussi :
  un écart entre les deux est une erreur du juge) ;
- une réponse est juste si son texte donne ce nombre. Décris la règle exacte : comment un nombre est lu dans un
  texte, et ce qui arrive s'il y en a plusieurs ;
- aucun marqueur de B, nulle part : ni dans les textes, ni dans les entrées et sorties d'outils que rend
  `demander.mjs` ;
- si l'app a des tables « à moi » et que l'assistant n'en lit aucune, c'est un échec ;
- la couverture est notée : le nombre de tables « à moi » lues, sur le total.

`sortie.json` contient le verdict (`juste` ou `faux`, avec ses raisons), chaque question avec sa réponse et ce qui a
été comparé, et la couverture. Aucune IA dans le jugement : seulement des comptes et des marqueurs.

Éprouve le juge sans pile, par des tests qui remplacent `demander.mjs` (`mesdonnees/tests/`) :
- un nombre juste ;
- un nombre faux ;
- un marqueur de B dans le texte, puis dans une sortie d'outil ;
- aucune table « à moi » lue ;
- une réponse sans nombre.

### 3. `mesdonnees/README.md`

Une page : la règle exacte du juge, la façon de lire les tables lues, les limites connues.

## À la fin

Écris `RAPPORT.md` dans ce dossier : ce qui est livré, les choix faits seul, les commandes d'épreuve et leurs résultats.
Termine par une seule ligne : « Graines et juge livrés ».
