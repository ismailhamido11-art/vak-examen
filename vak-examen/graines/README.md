# Graines A et B, et juge « mes données »

Écrits le 06/10/2026 par une session Claude Code scellée (consigne [`../scelle/GRAINES.md`](../scelle/GRAINES.md) ;
32 tours, 1,76 $), dans le rôle de l'auteur du contrôleur : elle n'a vu ni le dépôt de vak ni ses essais. Son compte
rendu, empreintes comprises, est [`RAPPORT.md`](RAPPORT.md) ; le juge est dans [`../mesdonnees/`](../mesdonnees/).

- `<app>/graine.sql` et `<app>/attendu.json` pour les 3 apps construites et pour sqlnoir (répétition). La pile les
  applique avec `GRAINE=vak-examen/graines/<app>/graine.sql bash vak-examen/pile/pile.sh up <essai>`.
- Les graines des 4 apps tirées seront écrites de la même façon, juste après le tirage (REGLE.md).

## Rejouer les épreuves

Les scripts attendent chaque app en dossier, dans `apps/<app>/` à côté de `graines/` et `mesdonnees/` (la
disposition de la session scellée). Dans un dossier de travail :
1. copier `graines/` et `mesdonnees/` ;
2. `git clone ../apps/<forme>.bundle apps/<forme>` pour `demarre`, `equipe` et `fonctions`, et sqlnoir à son commit
   de `repetition2/apps.tsv` dans `apps/sqlnoir` ;
3. avec un PostgreSQL 16 local : `node graines/eprouver.mjs`, `node --test mesdonnees/tests/juger.test.mjs` et
   `node mesdonnees/tests/bout-en-bout.mjs`.

Rejouées le 06/10 par la session de travail, hors de la bulle : tout est conforme, 23 tests sur 23.
