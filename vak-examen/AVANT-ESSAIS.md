# Avant le premier essai (deuxième examen)

Publié après le tirage et avant le premier essai, comme le veut la règle (`REGLE.md`, « La publication » et « Le
verdict d'un essai »). Les outils figés (la règle, le contrôleur, le juge, la pile, `verdict.mjs`, le tirage, les
candidats, le lecteur des étiquettes, les apps construites et leurs fiches) n'ont pas changé depuis la publication du
10/10 (`PUBLICATION.md`).

## Le tirage

Voir [`TIRAGE.md`](TIRAGE.md). Les 4 apps tirées sont :

@TIREES@

## Les graines des 4 apps tirées

Elles ont été écrites par des sessions Claude Code scellées, une par app, d'après
[`scelle/GRAINES-TIREES.md`](scelle/GRAINES-TIREES.md) (`bash vak-examen/graines-tirees.sh`), puis éprouvées sur des
bases neuves. Elles seront publiées après les essais, avec les autres ; voici leurs empreintes SHA-256 :

```text
@GRAINES@
```

## Les essais et les champs de leur demande

[`essais.tsv`](essais.tsv) : 14 essais, 2 par app, et les deux champs de la demande que fixe chaque app (le chemin de
l'archive est toujours `/work/vak-agent.tgz`) :
- **les apps construites** : le métier reprend la phrase de leur fiche (`fiches-2/`) ;
- **les apps tirées** : le métier résume le README de l'app, en une phrase, fixé avant le premier tirage
  (`champs-candidats.tsv`, 06/10) ;
- **l'emplacement** : un onglet « Assistant » si l'app a des onglets ; sinon un bouton flottant sur tous les écrans.

@ESSAIS@

Ordre : un premier essai de chaque app, puis le second de chaque app, dans le même ordre. `essai.sh` les joue l'un après
l'autre.

## Les corrections du lanceur depuis la publication

Aucune.
