# Avant le premier essai (cinquième examen)

Publié après le tirage et avant le premier essai, comme le veut la règle (`REGLE.md`, « La publication » et « Le
verdict d'un essai »). Les outils figés (la règle, le contrôleur, le juge, la pile, `verdict.mjs`, le tirage, les
candidats, le lecteur des étiquettes, les apps construites et leurs fiches) n'ont pas changé depuis la publication du
22/10 (`PUBLICATION.md`, dépôt public, commit `e953ec9`).

## Le tirage

Voir [`TIRAGE.md`](TIRAGE.md). Les 4 apps tirées sont :

- **splitbill** (Expo) : https://github.com/j769chen/splitbill, commit `59a1683`. Métier : « Le partage d'additions : on y crée des groupes, on y partage des dépenses et on suit qui doit quoi. » Emplacement : un onglet « Assistant » (onglets : `app/(tabs)/_layout.tsx`).
- **clix** (Next.js) : https://github.com/dmayes77/CLIX, commit `03a71b8`. Métier : « Le site de lancement d'un service itinérant d'entretien de véhicules (propreté et protection), par abonnement : on y découvre ses formules et on s'inscrit sur sa liste d'attente. » Emplacement : un bouton flottant sur tous les écrans.
- **prep** (Next.js) : https://github.com/Truella/prep, commit `341c8dc`. Métier : « Un créateur de quiz : on y compose ses quiz, à la main ou depuis un fichier CSV, on les partage par un lien, et on les passe, minutés ou non, avec son score et la correction. » Emplacement : un bouton flottant sur tous les écrans.
- **medication_tracker** (Expo) : https://github.com/PanagiotisKaraliolios/medication-tracker, commit `cfad841`. Métier : « Le suivi de ses médicaments : on y note ses traitements, ses rappels et ses prises. » Emplacement : un onglet « Assistant » (onglets : `app/(tabs)/_layout.tsx`).

## Les graines des 4 apps tirées

Elles ont été écrites par des sessions Claude Code scellées, une par app, d'après
[`scelle/GRAINES-TIREES.md`](scelle/GRAINES-TIREES.md) (`bash vak-examen/graines-tirees.sh`), puis éprouvées sur des
bases neuves. Elles seront publiées après les essais, avec les autres ; voici leurs empreintes SHA-256 :

```text
b5881c27da0f67a43d5cd58a8bfa100f0f5b0b8eff41e7009293a4c7f8ae99c3  vak-examen/graines/splitbill/graine.sql
796db6b02524f8bce2852dd0ca4af0ce2bb5451f4f4f8f81d6763c3170f35e22  vak-examen/graines/splitbill/attendu.json
bc0bab9a9bff67f4445a47941ba2e59fcbab03d88082230b287da9231e2cf24c  vak-examen/graines/clix/graine.sql
26e1a15f58a12fa2262c6be2131c5f3abf20cdf971867cb0485adf9da164f959  vak-examen/graines/clix/attendu.json
c49fe97095335480814bb2e80ac757c7cc37dc095b380e547badb1f7b7ac35ff  vak-examen/graines/prep/graine.sql
ca89bb7000ce075e76a33840204885484391fc44ed0dc03a3d82a72f78d88e28  vak-examen/graines/prep/attendu.json
7a2a841002aab1aaa5a4e6f889654065086aa5c6d0692c12283b1b751f382732  vak-examen/graines/medication_tracker/graine.sql
12b32a87111b03126a1347128508f17ffd7210c3aa2b64a8f39281f43bcf7e17  vak-examen/graines/medication_tracker/attendu.json
```

### Leur épreuve

L'outil d'épreuve publié avec la règle (`graines/eprouver.mjs` et `graines/supabase-minimum.sql`, empreintes dans
`EMPREINTES.sha256`) dit « tout est conforme » pour clix, prep et medication_tracker. Il s'arrête pour splitbill, dont
une migration vise la publication `supabase_realtime`, que son minimum de Supabase n'a pas ; la session scellée l'a écrit
dans son rapport et a éprouvé sa graine avec une copie adaptée de l'outil (la publication ajoutée), sans toucher
l'original : « tout est conforme ».

La session de travail a rejoué les 7 graines le 22/10, hors de la bulle, sur la base même de la pile des essais, avec
`graines/eprouver-pile.mjs` (`vak localdb` de l'archive 0.29.2 ; les vérifications d'`eprouver.mjs`, mot pour mot) :
**« tout est conforme » pour 6 apps, 270 vérifications, 0 échec** (randonnee 31, troupe 38, revisions 35, splitbill
84, clix 16, medication_tracker 66). **Pour prep, la base de la pile ne se construit pas** : sa migration
`20260728000001_create_quizzes_code_index.sql` crée un index avec `create unique index concurrently`, que PostgreSQL
refuse dans une transaction, et `vak localdb` (archive 0.29.2) applique chaque migration dans une transaction
(`psql --single-transaction`). Le fichier le dit lui-même : « Run with: supabase migration up --no-transaction ».
L'app reste tirée (la règle : rien n'est remplacé, sauf un dépôt qui ne se clone plus), et ce n'est pas corrigé : le
kit est gelé. Dans ses essais, `vak localdb` refusera donc cette migration, et l'agent ne doit pas la modifier (la
règle, point 4) ; si la pile ne peut pas servir l'assistant pour cette raison, le point 5 est faux. C'est une limite
de vak, comptée contre lui. La graine de prep reste éprouvée par la session scellée sur le minimum de Supabase, où
`psql` applique chaque fichier hors transaction : « tout est conforme ».

## Les essais et les champs de leur demande

[`essais.tsv`](essais.tsv) : 14 essais, 2 par app, et les deux champs de la demande que fixe chaque app (le chemin de
l'archive est toujours `/work/vak-agent.tgz`) :
- **les apps construites** : le métier reprend la phrase de leur fiche (`fiches-5/`) ;
- **les apps tirées** : le métier résume le README de l'app, en une phrase, fixé avant le premier tirage
  (`champs-candidats.tsv`, 06/10 et 22/10) ;
- **l'emplacement** : un onglet « Assistant » si l'app a des onglets ; sinon un bouton flottant sur tous les écrans.

Dans l'ordre où ils sont joués :

```sh
bash vak-examen/essai.sh randonnee_1 troupe_1 revisions_1 splitbill_1 clix_1 prep_1 medication_tracker_1 randonnee_2 troupe_2 revisions_2 splitbill_2 clix_2 prep_2 medication_tracker_2
```

Ordre : un premier essai de chaque app, puis le second de chaque app, dans le même ordre. `essai.sh` les joue l'un après
l'autre.

## La machine avant le premier essai

Vérifiée le 22/10 à 16:07 UTC (`machine/verifier.sh --api` : rien de bloquant) : PostgreSQL 16.15 répond, et aucune
extension `vector` n'est disponible (pgvector absent, la règle). La vérification est refaite après tout redémarrage de
la machine pendant l'examen, et notée avec son heure dans `EXAMEN.md`.

## Les corrections du lanceur depuis la publication

Aucune.

Une seule correction a été faite ailleurs, hors des outils figés, avant que `TIRAGE.md` soit écrit.
`tirage-publier.mjs` écrit `TIRAGE.md`. Il citait encore l'annonce du quatrième examen (commit `6f47e5e`, ticket #4). Il
cite maintenant celle de ce tirage : commit `e953ec9`, ticket #5. C'est une ligne de texte, comme aux examens passés ;
le calcul du tirage (`tirage.mjs`) n'a pas changé.
