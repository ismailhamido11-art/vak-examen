# Avant le premier essai (quatrième examen)

Publié après le tirage et avant le premier essai, comme le veut la règle (`REGLE.md`, « La publication » et « Le
verdict d'un essai »). Les outils figés (la règle, le contrôleur, le juge, la pile, `verdict.mjs`, le tirage, les
candidats, le lecteur des étiquettes, les apps construites et leurs fiches) n'ont pas changé depuis la publication du
14/10 (`PUBLICATION.md`, dépôt public, commit `6f47e5e`).

## Le tirage

Voir [`TIRAGE.md`](TIRAGE.md). Les 4 apps tirées sont :

- **split_free_frontend** (Expo) : https://github.com/abdullahozer11/split-free-frontend, commit `74b6612`. Métier : « Le partage de dépenses entre amis ou en groupe, réglé avec le moins de virements possible. » Emplacement : un onglet « Assistant » (onglets : `src/app/(tabs)/_layout.tsx`).
- **smart_budget_application** (Next.js) : https://github.com/NikolayAngelov90/Smart-Budget-Application, commit `d8173d6`. Métier : « Un budget personnel : on y note ses dépenses par catégorie, on y fixe ses budgets et on les partage avec son foyer. » Emplacement : un bouton flottant sur tous les écrans.
- **flow_finance** (Next.js) : https://github.com/Alexandre-Pascal/flow-finance, commit `6428801`. Métier : « Un suivi de finances personnelles : on y voit ses comptes courants et livrets, leurs soldes et ses transactions. » Emplacement : un bouton flottant sur tous les écrans.
- **streakmates** (Expo) : https://github.com/navysum/StreakMates, commit `79c610d`. Métier : « Un suivi d'habitudes à plusieurs : on y suit ses habitudes, seules ou partagées avec un groupe d'amis. » Emplacement : un onglet « Assistant » (onglets : `app/(tabs)/_layout.tsx`).

## Les graines des 4 apps tirées

Elles ont été écrites par des sessions Claude Code scellées, une par app, d'après
[`scelle/GRAINES-TIREES.md`](scelle/GRAINES-TIREES.md) (`bash vak-examen/graines-tirees.sh`), puis éprouvées sur des
bases neuves. Elles seront publiées après les essais, avec les autres ; voici leurs empreintes SHA-256 :

```text
94573b499bf377e65bb8a96b966a00ecde3b80c664f05e481af8a04c25b57959  vak-examen/graines/split_free_frontend/graine.sql
6599e97d924f6288a6b6c3070dd5db8b20a996d782825010b9980367382b8688  vak-examen/graines/split_free_frontend/attendu.json
69f257b27ee5a30c539127c590bdeb9e187fe72dcc176b4c1284dfa1162ef2ce  vak-examen/graines/smart_budget_application/graine.sql
8c1ce085fc860f317fbf60588ab68bfbdea50ef919c18ea526ece305177ec829  vak-examen/graines/smart_budget_application/attendu.json
24b748d95326d3f6bf0697a0ef6f9684ca3e2158559d791aac93c1c83c12c219  vak-examen/graines/flow_finance/graine.sql
b18f9ae5e1bacc469eeb620e433a7bfa6591265c9a73f7b63181be64c69e75e7  vak-examen/graines/flow_finance/attendu.json
fd2c3ad691f8bc7c84a35e791a39a41b0e191a638a233d659269660ca9cc2794  vak-examen/graines/streakmates/graine.sql
9f6792b9190dcf6103aa90bbf1d80d6b28816f3aec6a178cb66e45ed2868059b  vak-examen/graines/streakmates/attendu.json
```

### Leur épreuve

L'outil d'épreuve publié avec la règle (`graines/eprouver.mjs` et `graines/supabase-minimum.sql`, empreintes dans
`EMPREINTES.sha256`) dit « tout est conforme » pour flow_finance (177 vérifications). Il s'arrête pour les trois
autres apps tirées, sur des migrations que son minimum de Supabase ne sait pas jouer ; chaque session scellée l'a écrit
dans son rapport et a éprouvé sa graine avec une copie adaptée de l'outil, sans toucher l'original :
- **split_free_frontend** : sa première migration crée des extensions absentes de ce PostgreSQL (`pg_net`,
  `pgsodium`, `pg_graphql`, `pgjwt`, `supabase_vault`, `vector`) et vise la publication `supabase_realtime` ; aucun
  objet de l'app n'utilise ces extensions. La copie tolère ces seules erreurs : « tout est conforme ».
- **smart_budget_application** : deux migrations demandent la publication `supabase_realtime` et le schéma
  `storage`. Avec ces deux objets ajoutés au minimum : les 42 migrations passent, « tout est conforme », 0 échec.
- **streakmates** : une migration demande la publication `supabase_realtime`. Avec elle : « tout est conforme ».

La session de travail a rejoué les 7 graines le 14/10, hors de la bulle, sur la base même de la pile des essais, avec
`graines/eprouver-pile.mjs` (`vak localdb` de l'archive 0.28.1, qui crée la publication et un `storage` réduit ; les
vérifications d'`eprouver.mjs`, mot pour mot) : **« tout est conforme » pour les 7 apps, 580 vérifications, 0 échec**
(disques 30, journal 54, prets 23, split_free_frontend 36, smart_budget_application 188, flow_finance 177,
streakmates 72). La pile applique donc toutes leurs migrations : les arrêts venaient du minimum de l'outil d'épreuve,
ni des apps ni des graines. pgvector est absent de la machine (la règle) : `vak localdb` remplace l'extension `vector`
que crée split_free_frontend.

## Les essais et les champs de leur demande

[`essais.tsv`](essais.tsv) : 14 essais, 2 par app, et les deux champs de la demande que fixe chaque app (le chemin de
l'archive est toujours `/work/vak-agent.tgz`) :
- **les apps construites** : le métier reprend la phrase de leur fiche (`fiches-4/`) ;
- **les apps tirées** : le métier résume le README de l'app, en une phrase, fixé avant le premier tirage
  (`champs-candidats.tsv`, 06/10) ;
- **l'emplacement** : un onglet « Assistant » si l'app a des onglets ; sinon un bouton flottant sur tous les écrans.

Dans l'ordre où ils sont joués :

```sh
bash vak-examen/essai.sh disques_1 journal_1 prets_1 split_free_frontend_1 smart_budget_application_1 flow_finance_1 streakmates_1 disques_2 journal_2 prets_2 split_free_frontend_2 smart_budget_application_2 flow_finance_2 streakmates_2
```

Ordre : un premier essai de chaque app, puis le second de chaque app, dans le même ordre. `essai.sh` les joue l'un après
l'autre.

## Les corrections du lanceur depuis la publication

Aucune.

Une seule correction a été faite ailleurs, hors des outils figés, avant que `TIRAGE.md` soit écrit.
`tirage-publier.mjs` écrit `TIRAGE.md`. Il citait encore l'annonce du troisième examen (commit `b86b760`, ticket #3). Il
cite maintenant celle de ce tirage : commit `6f47e5e`, ticket #4. C'est une ligne de texte, comme aux deuxième et
troisième examens ; le calcul du tirage (`tirage.mjs`) n'a pas changé.
