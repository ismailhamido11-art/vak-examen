# Avant le premier essai (troisième examen)

Publié après le tirage et avant le premier essai, comme le veut la règle (`REGLE.md`, « La publication » et « Le
verdict d'un essai »). Les outils figés (la règle, le contrôleur, le juge, la pile, `verdict.mjs`, le tirage, les
candidats, le lecteur des étiquettes, les apps construites et leurs fiches) n'ont pas changé depuis la publication du
11/10 (`PUBLICATION.md`, dépôt public, commit `b86b760`).

## Le tirage

Voir [`TIRAGE.md`](TIRAGE.md). Les 4 apps tirées sont :

- **supabase_nextjs_template** (Expo) : https://github.com/Razikus/supabase-nextjs-template, commit `d519bf1`. Métier : « Un modèle d'app SaaS mobile : on y gère son compte, ses fichiers et ses tâches. » Emplacement : un onglet « Assistant » (onglets : `supabase-expo-template/app/(app)/_layout.tsx`).
- **habitquest** (Expo) : https://github.com/battisteb/habitquest, commit `95784af`. Métier : « Un suivi d'habitudes façon jeu de rôle : on y accomplit des quêtes, on gagne de l'expérience et on défie ses amis. » Emplacement : un onglet « Assistant » (onglets : `app/(tabs)/_layout.tsx`).
- **workout_app** (Next.js) : https://github.com/quitefrank/workout-app, commit `5259962`. Métier : « Un carnet de musculation personnel : on y note ses séances, série par série, et on suit ses progrès. » Emplacement : un bouton flottant sur tous les écrans.
- **hikari** (Next.js) : https://github.com/antoineross/Hikari, commit `c1f16f5`. Métier : « Un modèle d'app SaaS par abonnement : on y gère son compte et son abonnement. » Emplacement : un bouton flottant sur tous les écrans.

## Les graines des 4 apps tirées

Elles ont été écrites par des sessions Claude Code scellées, une par app, d'après
[`scelle/GRAINES-TIREES.md`](scelle/GRAINES-TIREES.md) (`bash vak-examen/graines-tirees.sh`), puis éprouvées sur des
bases neuves. Elles seront publiées après les essais, avec les autres ; voici leurs empreintes SHA-256 :

```text
3ca0c84e5ee9cb20ca2489953c9b08a8a269b1f3739c7072637be83d50692671  vak-examen/graines/supabase_nextjs_template/graine.sql
f3c404811a30df0e7fd804a5328b7a0dc756d1a075865bcbfb814367ab282686  vak-examen/graines/supabase_nextjs_template/attendu.json
d2f1bf4cb60d0218cc5ee9940b364adc737b1ff42a297371aa4e8df35b81fba4  vak-examen/graines/habitquest/graine.sql
0e192516dd27a9a627c0c6d798e16607b658831f0d206629b4d5b8764e71e36b  vak-examen/graines/habitquest/attendu.json
1729154b1687f1d2e283f81638171c305df35fa548bdb79184529ff9058f54ea  vak-examen/graines/workout_app/graine.sql
3928407d70fabd4c65d0bb95f2cadbadfd36d2e1dea499bdad6b70cef01f5647  vak-examen/graines/workout_app/attendu.json
922c1220452f25d9491de08f4d0370c94c7050b8d599178a024941f4d59a9617  vak-examen/graines/hikari/graine.sql
565f46e39c007f3843221ebe9679dc70a148d6441220b693c253d7545ddb42d4  vak-examen/graines/hikari/attendu.json
```

### Leur épreuve

L'outil d'épreuve publié avec la règle (`graines/eprouver.mjs` et `graines/supabase-minimum.sql`, empreintes dans
`EMPREINTES.sha256`) dit « tout est conforme » pour 5 des 7 apps : les 3 apps construites, workout_app et hikari. Il
s'arrête pour les deux autres, sur des migrations que son minimum de Supabase ne sait pas jouer. Chaque session
scellée l'a écrit dans son rapport :
- **habitquest** : une migration crée l'extension `pg_net`, absente de ce minimum. La session a éprouvé sa graine avec
  une copie de l'outil qui retire seulement cette ligne : « tout est conforme », 47 vérifications.
- **supabase_nextjs_template** : ses migrations demandent le schéma `storage`, absent du minimum. Et la RLS de sa seule
  table « à moi », `todo_list`, dépend du niveau MFA du compte : la politique « Owner can do everything » appelle
  `authenticative.is_user_authenticated()`, qui lit `auth.mfa_factors` et la revendication `aal` du jeton. Avec un
  complément (un `storage` réduit, `auth.mfa_factors`) et `aal` posé à `aal1`, comme le fait Supabase Auth après une
  connexion par mot de passe, la session trouve les 6 lignes de A : « tout est conforme ». Sans `aal`, A n'en voit
  aucune.

La session de travail a rejoué les 7 graines le 11/10, hors de la bulle, sur la base même de la pile des essais, avec
`graines/eprouver-pile.mjs` (`vak localdb` de l'archive 0.27.0 ; les vérifications d'`eprouver.mjs`, mot pour mot) :
- **6 apps** : « tout est conforme », 203 vérifications, 0 échec (cuisine 27, club 46, abonnements 17, habitquest 47,
  workout_app 35, hikari 31). La pile applique toutes les migrations d'habitquest : l'arrêt venait du minimum de
  l'outil d'épreuve, ni de l'app ni de la graine.
- **supabase_nextjs_template** : les migrations passent, mais le compte des lignes de A dans `todo_list` échoue :
  « relation "auth.mfa_factors" does not exist ». La base que fait `vak localdb` n'a pas cette table de Supabase
  Auth ; et les jetons que signent la pile (`pile/relais.mjs`) et le juge (`mesdonnees/juger.mjs`) n'ont pas de
  revendication `aal`.

**Ce que cela veut dire pour supabase_nextjs_template.** Ses deux essais sont joués et jugés tels quels. La règle ne
permet ni de remplacer l'app (son commit se clone toujours), ni de changer la pile ou le juge, figés à la publication.
Dans le doute, c'est contre vak : sauf surprise, le point 5 de ces deux essais sera faux, car le juge ne peut pas
compter les lignes de A sous la RLS de l'app ; et vak lui-même ne traite pas ce cas (`candidats/README.md`, 06/10).
L'examen reste réussi si les 12 autres essais le sont.

## Les essais et les champs de leur demande

[`essais.tsv`](essais.tsv) : 14 essais, 2 par app, et les deux champs de la demande que fixe chaque app (le chemin de
l'archive est toujours `/work/vak-agent.tgz`) :
- **les apps construites** : le métier reprend la phrase de leur fiche (`fiches-3/`) ;
- **les apps tirées** : le métier résume le README de l'app, en une phrase, fixé avant le premier tirage
  (`champs-candidats.tsv`, 06/10) ;
- **l'emplacement** : un onglet « Assistant » si l'app a des onglets ; sinon un bouton flottant sur tous les écrans.

Dans l'ordre où ils sont joués :

```sh
bash vak-examen/essai.sh cuisine_1 club_1 abonnements_1 supabase_nextjs_template_1 habitquest_1 workout_app_1 hikari_1 cuisine_2 club_2 abonnements_2 supabase_nextjs_template_2 habitquest_2 workout_app_2 hikari_2
```

Ordre : un premier essai de chaque app, puis le second de chaque app, dans le même ordre. `essai.sh` les joue l'un après
l'autre.

## Les corrections du lanceur depuis la publication

Aucune.

Une seule correction a été faite ailleurs, hors des outils figés, avant que `TIRAGE.md` soit écrit.
`tirage-publier.mjs` écrit `TIRAGE.md`. Il citait encore l'annonce du deuxième examen (commit `cfa018f`, ticket #2). Il
cite maintenant celle de ce tirage : commit `b86b760`, ticket #3. C'est une ligne de texte, comme au deuxième examen ;
le calcul du tirage (`tirage.mjs`) n'a pas changé.
