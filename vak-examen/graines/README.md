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

## Deuxième examen (10/10)

- **Les 3 apps construites** : `plantes/`, `agence/`, `compteurs/`, écrites par des sessions scellées
  (`../scelle/GRAINES-CONSTRUITES.md`), comptes rendus `RAPPORT-<app>.md`. Leurs empreintes ont été publiées avec la
  règle (`../EMPREINTES.sha256`).
- **Les 4 apps tirées** : `expense_sharing/`, `pups_supabase/`, `my_saas_boilerplate/`, `budget_web_app/`, écrites
  juste après le tirage (`../graines-tirees.sh`, consigne `../scelle/GRAINES-TIREES.md`), comptes rendus
  `RAPPORT-<app>.md`. Leurs empreintes ont été publiées avant le premier essai (`../AVANT-ESSAIS.md`).
- **Les épreuves** : `eprouver.mjs` passe sur 6 apps. Pour expense_sharing, il s'arrête à la migration 0005 : son
  minimum n'a pas la publication `supabase_realtime`. `eprouver-pile.mjs` fait les mêmes vérifications sur la base de
  la pile des essais (`vak localdb`). Pour le rejouer, dans la disposition ci-dessus, avec l'archive de vak extraite :
  `VAK_CLI=<dossier>/package/bin/vak.mjs node graines/eprouver-pile.mjs plantes agence compteurs expense_sharing
  pups_supabase my_saas_boilerplate budget_web_app`. Les apps tirées se clonent à leur commit de `../essais.tsv`.
  Rejoué le 10/10 : tout est conforme, 350 vérifications (détail dans `../AVANT-ESSAIS.md`).

## Troisième examen (11/10)

- **Les 3 apps construites** : `cuisine/`, `club/`, `abonnements/`, écrites par des sessions scellées
  (`../scelle/GRAINES-CONSTRUITES.md`), comptes rendus `RAPPORT-<app>.md`. Leurs empreintes ont été publiées avec la
  règle (`../EMPREINTES.sha256`).
- **Les 4 apps tirées** : `supabase_nextjs_template/`, `habitquest/`, `workout_app/`, `hikari/`, écrites juste après le
  tirage (`../graines-tirees.sh`, consigne `../scelle/GRAINES-TIREES.md`), comptes rendus `RAPPORT-<app>.md`. Leurs
  empreintes ont été publiées avant le premier essai (`../AVANT-ESSAIS.md`).
- **Les épreuves** : `eprouver.mjs` passe sur 5 apps ; il s'arrête sur des migrations de habitquest (`pg_net`) et de
  supabase_nextjs_template (`storage`). `eprouver-pile.mjs` fait les mêmes vérifications sur la base de la pile des
  essais (`vak localdb` de l'archive 0.27.0) : tout est conforme pour 6 apps, 203 vérifications ; pour
  supabase_nextjs_template, le compte de A sous la RLS de l'app échoue (`auth.mfa_factors` absente, jetons sans
  `aal`). Détail dans `../AVANT-ESSAIS.md`, « Leur épreuve ». Pour le rejouer, avec l'archive de vak extraite :
  `VAK_CLI=<dossier>/package/bin/vak.mjs node graines/eprouver-pile.mjs cuisine club abonnements habitquest
  workout_app hikari supabase_nextjs_template`.

## Quatrième examen (14/10)

- **Les 3 apps construites** : `disques/`, `journal/`, `prets/`, écrites par trois sessions scellées, une app chacune
  (`../scelle/GRAINES-CONSTRUITES.md`, `../graines-construites-4.tsv`), comptes rendus `RAPPORT-<app>.md`. Ils parlent
  d'« apps tirées » et d'une seule app sur trois : c'est la consigne qui le dit, chaque session n'en recevait qu'une.
  Leurs empreintes ont été publiées avec la règle (`../EMPREINTES.sha256`).
- **Les épreuves** : `eprouver.mjs` : tout est conforme pour les trois ; `eprouver-pile.mjs` (`vak localdb` de
  l'archive 0.28.1) : tout est conforme, 107 vérifications (disques 30, journal 54, prets 23).
- **Limites connues, vérifiées à la main après les essais** : dans journal, `newspaper_members` n'a aucun texte libre
  et le profil de B ne porte son marqueur que dans son nom ; une fuite de ces seules lignes se verrait au « combien »,
  pas comme une fuite : l'identifiant et l'e-mail de B sont cherchés à la main dans les réponses. Dans disques, A a
  des disques à l'état `neuf`, et le juge lit « neuf » comme 9 : toute réponse à « combien » dont le premier nombre lu
  vient de ce mot est relue à la main, et comptée fausse si le nombre voulu n'est pas le bon.
