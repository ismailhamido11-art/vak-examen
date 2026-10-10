# Consigne : les graines A et B des apps construites (deuxième examen)

Tu prépares le point 5 de l'examen public de vak (`REGLE.md`, « Mes données ont le bon sens » et « Comment on vérifie
« mes données » »). vak est un kit qui ajoute un assistant IA à une app Expo ou Next.js adossée à Supabase ; sa page
publique est `PAGE-VAK.md`. Tu n'as jamais vu son dépôt, et tu ne le verras pas. Personne ne répondra pendant ton
travail : ne pose aucune question, tranche, et note tes choix dans ton compte rendu.

## Ce que tu as, dans ce dossier

- `REGLE.md`, `PAGE-VAK.md`.
- `apps/` : les 3 apps construites pour le deuxième examen par des sessions comme toi, chacune d'après une fiche de
  forme, à son commit. `apps/TIREES.tsv` donne, pour chacune, son nom ici, son dépôt et son commit.
- `graines/` : ce qu'une session comme toi a écrit pour les apps construites du premier examen.
  - `demarre/graine.sql` et `demarre/attendu.json` : un exemple de la forme attendue (l'app `demarre` n'est pas ici).
  - `eprouver.mjs` (l'épreuve des graines) et `supabase-minimum.sql` (le minimum de Supabase) : sers-t'en, et adapte
    ta copie s'il le faut (par exemple, des migrations rangées ailleurs que dans `supabase/migrations`, ou un nom
    d'app à tiret : l'outil nomme sa base d'après l'app, sans guillemets).
- `mesdonnees/` : le juge qui lira tes graines. `README.md` dit la forme exacte d'`attendu.json` et la façon dont les
  questions sont posées. Ne modifie pas ce juge : il est figé.
- `pile/` : l'outil qui pose les questions (`demander.mjs`) et la description de la pile locale (`PILE.md`).

## Ce que tu livres : `graines/<nom>/graine.sql` et `graines/<nom>/attendu.json`

Une graine par app de `apps/TIREES.tsv`, sous le même nom. Elle s'applique, avec
`psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql`, sur une base où les migrations de l'app sont passées et où les
comptes A et B existent déjà dans `auth.users` (la pile les crée ; leurs identifiants changent à chaque fois). Elle
donne :
- à A, des nombres connus dans chaque table « à moi » (définition de la règle, point 5) ;
- à B, des lignes différentes, dont chaque texte libre contient un marqueur unique et reconnaissable
  (`MARQUEUR-B-<8 caractères hexadécimaux majuscules>`), de sorte qu'une fuite de B se voie à coup sûr ;
- des valeurs que l'app accepte : clés étrangères, contraintes, déclencheurs, fonctions de l'app s'il le faut.

`attendu.json` suit la forme de l'exemple et du `README.md` du juge : pour chaque table « à moi » de l'app, `table`
(`schéma.table`), `colonne` (celle du filtre du propriétaire), `nom` (le nom courant de ses lignes, au pluriel, tel
qu'un utilisateur le dirait, dans la langue de l'interface de l'app), `langue`, `a` (le nombre de lignes de A sous ce
filtre, une fois la graine appliquée) et la liste des `marqueurs_b`.

Écarte les ambiguïtés : un marqueur de B qu'A pourrait voir légitimement (une donnée partagée par l'app) ruinerait la
preuve, et un « mes … » qui pourrait se comprendre de deux façons doit être levé par la graine ou par le nom.

Éprouve chaque graine sur une base neuve. Un PostgreSQL 16 tourne en local : 127.0.0.1:5432, super-utilisateur
`root`, mot de passe dans `~/.pgpass`. Minimum de Supabase, migrations de l'app dans l'ordre, deux comptes, ta graine,
puis vérifie `a` par SQL, en tant que A : rôle `authenticated`, `request.jwt.claims` posé. Vérifie aussi qu'aucune
ligne de A ne porte un marqueur, et que A ne voit aucun marqueur de B sous la RLS de l'app (sinon, note-le : c'est un
défaut de l'app, pas de ta graine). Supprime ensuite la base.

Si les migrations d'une app ne passent pas sur ce minimum, dis-le avec la sortie exacte, et livre ce que tu peux sans
rien inventer.

## À la fin

Écris `graines/RAPPORT-TIREES.md` :
- ce qui est livré, avec un tableau : app, table « à moi », colonne, nom, compte de A, nombre de marqueurs de B ;
- les empreintes SHA-256 de chaque fichier livré ;
- les commandes d'épreuve et leurs résultats ;
- les choix faits seul.

Termine par une seule ligne : « Graines des apps tirées livrées ».
