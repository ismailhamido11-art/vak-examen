# Avant le premier essai (deuxième examen)

Publié après le tirage et avant le premier essai, comme le veut la règle (`REGLE.md`, « La publication » et « Le
verdict d'un essai »). Les outils figés (la règle, le contrôleur, le juge, la pile, `verdict.mjs`, le tirage, les
candidats, le lecteur des étiquettes, les apps construites et leurs fiches) n'ont pas changé depuis la publication du
10/10 (`PUBLICATION.md`, dépôt public, commit `cfa018f`).

## Le tirage

Voir [`TIRAGE.md`](TIRAGE.md). Les 4 apps tirées sont :

- **expense_sharing** (Expo) : https://github.com/itejaskumbhar/Expense-Sharing, commit `8e6020c`. Métier : « Le partage de dépenses à plusieurs : on y crée des groupes, on y partage des dépenses et on règle ses dettes. » Emplacement : un onglet « Assistant » (onglets : `src/app/(app)/(tabs)/_layout.tsx`).
- **pups_supabase** (Expo) : https://github.com/MarkMGill/pups-supabase, commit `405d4df`. Métier : « Une boutique de chiots : on y parcourt un catalogue de chiots, on remplit son panier et on commande. » Emplacement : un bouton flottant sur tous les écrans.
- **my_saas_boilerplate** (Next.js) : https://github.com/bluebridgetechnology/my-saas-boilerplate, commit `bcb2049`. Métier : « Un modèle d'app SaaS par abonnement : on y gère son compte, son abonnement et le journal de ses actions. » Emplacement : un bouton flottant sur tous les écrans.
- **budget_web_app** (Next.js) : https://github.com/Ant3xes/budget_web_app, commit `88061f2`. Métier : « Un suivi budgétaire et bancaire personnel : chacun y suit ses comptes et ses opérations, dans son propre espace. » Emplacement : un bouton flottant sur tous les écrans.

## Les graines des 4 apps tirées

Elles ont été écrites par des sessions Claude Code scellées, une par app, d'après
[`scelle/GRAINES-TIREES.md`](scelle/GRAINES-TIREES.md) (`bash vak-examen/graines-tirees.sh`), puis éprouvées sur des
bases neuves. Elles seront publiées après les essais, avec les autres ; voici leurs empreintes SHA-256 :

```text
32a1bd2cd9a47a44856bba10e1b597ec102a87649fef882cbef6ea7332828525  vak-examen/graines/expense_sharing/graine.sql
022d5fe52b64466c0047cc6b82e5d8fca8bdd4a9257d1758b37ed67873c8f031  vak-examen/graines/expense_sharing/attendu.json
e8bd85e7547d2548ea18ee856e95c579ead2b419458b3a2e67bbb16eb92630c9  vak-examen/graines/pups_supabase/graine.sql
8998398a59f6e839ba1c0321dfa41c0b91f91479098ffabaf473603bf710c620  vak-examen/graines/pups_supabase/attendu.json
4f08ed0ed73918af72df7cd4b907ac08e40ccb1e69e06de78aca088eb569e6c3  vak-examen/graines/my_saas_boilerplate/graine.sql
3793da15649eee113fbffd1a40f18a6d42401649040a3d5dfac8b411565dd916  vak-examen/graines/my_saas_boilerplate/attendu.json
ae75ab631a236854baf850f86667d0c7fd7656bc25f65437eb37a37002bdccc2  vak-examen/graines/budget_web_app/graine.sql
b520c8b1bcbc6ba75e57c33c010cb7b7f232802f94540bcd8142cc1d25a69043  vak-examen/graines/budget_web_app/attendu.json
```

### Leur épreuve

L'outil d'épreuve publié le 10/10 (`graines/eprouver.mjs` et `graines/supabase-minimum.sql`, empreintes dans
`EMPREINTES.sha256`) dit « tout est conforme » pour 6 des 7 apps. Pour expense_sharing, il s'arrête avant la graine. La
migration `0005_polish.sql` de l'app ajoute ses tables à la publication `supabase_realtime`, que ce minimum de Supabase
ne crée pas. La migration 0006 demanderait aussi le schéma `storage`. La session scellée l'a écrit dans son rapport.
Sans modifier l'outil, elle a éprouvé sa graine avec un complément de 8 lignes SQL (la publication et un `storage`
réduit) : « tout est conforme ».

La session de travail a rejoué deux épreuves le 10/10, hors de la bulle :
- **le complément de la session**, recopié de son rapport : « tout est conforme », 43 vérifications ;
- **les 7 graines sur la base même de la pile des essais**, avec `graines/eprouver-pile.mjs`. `pile/pile.sh` fait cette
  base par `vak localdb` de l'archive 0.26.1, qui crée la publication `supabase_realtime` et un `storage` réduit. Ce
  sont les vérifications d'`eprouver.mjs`, mot pour mot, sur cette base : « tout est conforme », 350 vérifications,
  0 échec.

La pile applique donc toutes les migrations d'expense_sharing : l'arrêt venait du minimum de l'outil d'épreuve, ni de
l'app ni de la graine. `eprouver-pile.mjs` sera publié avec les graines ; son empreinte :

```text
0a52c4c3a4b81a765c523b16d889ed14937e759e25ddafc7cc52731579c0e24c  vak-examen/graines/eprouver-pile.mjs
```

## Les essais et les champs de leur demande

[`essais.tsv`](essais.tsv) : 14 essais, 2 par app, et les deux champs de la demande que fixe chaque app (le chemin de
l'archive est toujours `/work/vak-agent.tgz`) :
- **les apps construites** : le métier reprend la phrase de leur fiche (`fiches-2/`) ;
- **les apps tirées** : le métier résume le README de l'app, en une phrase, fixé avant le premier tirage
  (`champs-candidats.tsv`, 06/10) ;
- **l'emplacement** : un onglet « Assistant » si l'app a des onglets ; sinon un bouton flottant sur tous les écrans.

Dans l'ordre où ils sont joués :

```sh
bash vak-examen/essai.sh plantes_1 agence_1 compteurs_1 expense_sharing_1 pups_supabase_1 my_saas_boilerplate_1 budget_web_app_1 plantes_2 agence_2 compteurs_2 expense_sharing_2 pups_supabase_2 my_saas_boilerplate_2 budget_web_app_2
```

Ordre : un premier essai de chaque app, puis le second de chaque app, dans le même ordre. `essai.sh` les joue l'un après
l'autre.

## Les corrections du lanceur depuis la publication

Aucune.

Une seule correction a été faite ailleurs, hors des outils figés, avant que `TIRAGE.md` soit écrit.
`tirage-publier.mjs` écrit `TIRAGE.md`. Il citait encore l'annonce du premier examen (commit `698f07b`, ticket #1). Il
cite maintenant celle de ce tirage : commit `cfa018f`, ticket #2. C'est une ligne de texte ; le calcul du tirage
(`tirage.mjs`) n'a pas changé.
