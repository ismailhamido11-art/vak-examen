# Examen public de vak

Ce dossier est recopié tel quel dans le dépôt public de l'examen, https://github.com/ismailhamido11-art/vak-examen
(publié le 06/10/2026), avec le lanceur des essais (`repetition2/`). C'est [`publier.sh`](publier.sh) qui le recopie.

- [`REGLE.md`](REGLE.md) : la règle. Elle dit ce qui est mesuré, quelles apps sont choisies, ce qu'est un essai réussi
  et quels sont les seuils. Elle est figée depuis le 06/10/2026.
- [`PUBLICATION.md`](PUBLICATION.md) : ce qui est figé avant le tirage (empreintes, texte de la demande,
  environnement, tour drand).
- [`pile/`](pile/) : la vérification « mes données » d'un essai fini.
  - `pile.sh up <id>` sert l'assistant de l'app, tel que commité, en local : une base neuve, les comptes A et B,
    PostgREST, un relais Supabase local et la fonction servie par Deno avec DeepSeek.
  - `demander.mjs` pose une question en tant que A ou B, par le protocole HTTP public de vak.
  - `pile.sh down <id>` arrête tout.
- [`repetition/RESULTATS.md`](repetition/RESULTATS.md) : les essais sans fenêtre de la répétition (`repetition2/lancer.sh`).
  - `repetition/jouer.sh <id>…` joue des essais l'un après l'autre et donne le verdict de chacun.
  - `repetition/saboter.sh <id>` éprouve le contrôleur : sur un essai réussi, il plante tour à tour 6 sabotages et
    vérifie que le contrôleur rend « échec » pour la bonne raison.

- [`candidats/`](candidats/) : les apps publiques éligibles (23 au 06/10), constituées en tiers par une session scellée
  (`verifier.mjs`), puis passées au critère « pas une copie » et à la liste d'exclusion complète (`historique.mjs`,
  06/10).
- [`tirage.mjs`](tirage.mjs) : le tirage des 4 apps publiques. `node tirage.mjs <tour drand>` lit l'aléa du tour
  « quicknet » fixé d'avance, le contrôle, classe les éligibles par le SHA-256 du texte « aléa, saut de ligne, url » et prend les 2 premières apps
  Expo et les 2 premières apps Next ; les suivantes forment la réserve de chaque plateforme.
- [`apps/`](apps/) : les 3 apps construites (06/10), chacune par une session scellée qui n'a reçu que sa fiche ; leurs
  archives git, leurs empreintes et les vérifications.
- [`controleur/`](controleur/) : le contrôleur de l'examen. Une session Claude Code scellée l'a écrit le 04/10, sans
  le dépôt de vak, d'après `REGLE.md`, la page publique et [`scelle/CAHIER.md`](scelle/CAHIER.md) ; le lanceur est
  [`scelle/lancer.sh`](scelle/lancer.sh). `controleur/juger.sh` le lance, dans la bulle des essais.
- [`mesdonnees/`](mesdonnees/) : le juge « mes données » (point 5 de la règle), écrit le 06/10 par une session
  scellée. [`verdict.mjs`](verdict.mjs) assemble le verdict d'un essai (contrôleur et point 5).
- [`essais.tsv`](essais.tsv) : les essais de l'examen et les champs de leur demande (métier, emplacement), lus par le
  lanceur avec `APPS=`. [`essai.sh`](essai.sh) joue un essai de bout en bout : essai, contrôleur, pile, juge,
  étiquette, verdict, puis ménage du disque. Le groupe témoin passe par `TEMOIN=1` (sans l'archive de vak, avec la
  consigne de la règle).
- [`etiquettes/`](etiquettes/) : la lecture des étiquettes, la vérité de chaque essai, le lecteur scellé
  ([`scelle/ETIQUETTE.md`](scelle/ETIQUETTE.md)) et la comparaison.
- [`scelle/GRAINES-TIREES.md`](scelle/GRAINES-TIREES.md) : la consigne des graines des 4 apps tirées (`TIREES=` du
  lanceur scellé).
- `graines/` : les graines A et B de chaque app, écrites par la même session. Elles seront publiées après les
  essais ; leurs empreintes sont dans `PUBLICATION.md`.

Les étapes, dans l'ordre :
1. La répétition privée, sur les apps de `repetition2/apps.tsv` : essais Claude Code par `repetition2/lancer.sh`,
   contrôleur éprouvé par 6 sabotages (fait le 03/10).
2. Le contrôleur, écrit par une session Claude Code scellée, d'après cette règle seulement (fait le 04/10).
3. La liste des apps éligibles (fait le 04/10, critère « pas une copie » le 06/10) et les 3 apps construites (fait le
   06/10).
4. Les graines A et B des 3 apps construites, et le juge « mes données » (point 5 de la règle) (fait le 06/10).
5. La publication, avant le tirage (faite le 06/10, `PUBLICATION.md`) :
   - les empreintes de l'archive, de la règle, des fiches de forme, des 3 apps construites et de leurs graines ;
   - le tour drand.
6. Le tirage (`tirage.mjs`), puis les graines des 4 apps tirées et leur empreinte.
7. L'examen : 14 essais et le groupe témoin, puis la publication de tout.
