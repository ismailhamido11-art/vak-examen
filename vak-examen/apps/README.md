# Les apps construites des examens

Celles du quatrième examen (disques, journal, prets) sont plus bas, section « Quatrième examen », et celles du
cinquième (randonnee, troupe, revisions) à la fin, section « Cinquième examen ».

## Premier examen : 3 apps (06/10)

Construites le 06/10/2026, entre 00:15 et 00:21 UTC. Chacune l'a été par une session Claude Code scellée
(`../scelle/lancer.sh`, mode « fiche »), qui n'a reçu que [`../scelle/CONSTRUIRE.md`](../scelle/CONSTRUIRE.md) et sa
fiche de forme : ni vak, ni la règle, ni le dépôt du kit. Les fiches étaient commitées depuis le 04/10.

| forme | app | plateforme | commit | session |
|---|---|---|---|---|
| [démarre](../fiches/demarre.md) | carnet de lecture | Expo 57 | `891485f` | 15 tours, 0,32 $, 3 min |
| [équipe](../fiches/equipe.md) | chantiers d'une entreprise de rénovation | Next.js 16.3 | `ed96d9a` | 17 tours, 0,58 $, 5 min |
| [fonctions](../fiches/fonctions.md) | budget d'un foyer, écritures par RPC | Expo 57 | `8246749` | 13 tours, 0,38 $, 4 min |

- Chaque app est un fichier `<forme>.bundle` (toute l'histoire git) : `git clone <forme>.bundle <dossier>`.
- Les empreintes des archives et des fiches sont dans [`SHA256SUMS`](SHA256SUMS).
- Le compte rendu de chaque session est recopié tel quel dans [`rapports/`](rapports/).

### Vérifications du 06/10

Faites par la session de travail, sur un clone neuf de chaque archive.

- **Critères d'une app publique** (`../candidats/verifier.mjs`, avec `SOURCE=`) : les trois sont éligibles. Leurs
  migrations passent sur un PostgreSQL 16 neuf. Tables « à moi » :
  - démarre : `books`, `reading_sessions` ;
  - équipe : `teams`, `team_members`, `team_invitations`, `tasks` ;
  - fonctions : `categories`, `expenses`.
- **Ce que demande la fiche** :
  - toutes : `npm ci` passe ; `package-lock.json` et `.env.example` sont commités ; aucun `.env` ni secret n'est
    commité ;
  - démarre et fonctions : `npx tsc --noEmit` et `npx expo export -p web` passent ;
  - équipe : `npm run lint` et `npm run build` passent. `npx tsc --noEmit` rend 1 erreur sur un clone neuf
    (`LayoutProps`, un type que Next 16 génère au build), puis 0 après `npm run build`. `next-env.d.ts` est ignoré
    par git, comme le règle `create-next-app`. L'app est gardée telle quelle : c'est l'état d'une vraie app Next 16.

## Deuxième examen : 3 apps nouvelles (10/10)

Construites le 10/10/2026, de 14:40 à 14:47 UTC, chacune par une session Claude Code scellée (`../scelle/lancer.sh`,
mode « fiche »), qui n'a reçu que [`../scelle/CONSTRUIRE.md`](../scelle/CONSTRUIRE.md) et sa fiche de forme : ni vak,
ni la règle, ni le dépôt du kit. Les fiches (`../fiches-2/`) étaient commitées depuis 12:31 UTC le même jour.

| forme | app | plateforme | commit | session |
|---|---|---|---|---|
| [démarre](../fiches-2/demarre.md) | plantes d'intérieur et arrosages | Expo 57 | `bea4192` | 16 tours, 0,34 $, 5 min |
| [équipe](../fiches-2/equipe.md) | dossiers d'une agence de voyages, réservations | Next.js 16.4 | `fed6082` | 25 tours, 0,66 $, 6 min |
| [fonctions](../fiches-2/fonctions.md) | relevés de compteurs, écritures par RPC | Expo 57 | `5c12ec9` | 21 tours, 0,52 $, 6 min |

- Chaque app est un fichier `<nom>.bundle` (`plantes`, `agence`, `compteurs`) : `git clone <nom>.bundle <dossier>`.
- Les comptes rendus des sessions sont recopiés tels quels dans [`rapports/`](rapports/).

Vérifications du 10/10, par la session de travail, sur un clone neuf de chaque archive, dans un environnement vide :
- **critères d'une app publique** (`../candidats/verifier.mjs`, `SOURCE=` un clone de l'archive) : les trois sont
  éligibles, leurs migrations passent sur un PostgreSQL 16 neuf. Tables « à moi » : plantes : `plants`, `waterings` ;
  agence : `agencies`, `agency_invitations`, `agency_members`, `bookings`, `trips` ; compteurs : `meters`, `readings` ;
- **ce que demande la fiche** : `npm ci` passe ; `package-lock.json` et `.env.example` sont commités ; aucun `.env` ni
  secret n'est commité. plantes et compteurs : `npx tsc --noEmit` et `npx expo export -p web` passent. agence :
  `npm run lint` et `npm run build` passent ; `npx tsc --noEmit` rend 7 erreurs sur un clone neuf (`PageProps`,
  `LayoutProps` : des types que Next 16 génère au build), puis 0 après `npm run build`, comme l'app d'équipe du
  premier examen. Les apps sont gardées telles quelles ;
- **navigation** : les trois naviguent par pile (Expo Router `Stack`, ou Next.js) : leur emplacement est un bouton
  flottant sur tous les écrans (`../essais.tsv`).

## Troisième examen : 3 apps nouvelles (10/10, au soir)

Construites le 10/10/2026, de 23:40 à 23:46 UTC, chacune par une session Claude Code scellée (`../scelle/lancer.sh`,
mode « fiche »), qui n'a reçu que [`../scelle/CONSTRUIRE.md`](../scelle/CONSTRUIRE.md) et sa fiche de forme : ni vak,
ni la règle, ni le dépôt du kit. Les fiches (`../fiches-3/`) étaient commitées depuis 23:40:44 UTC le même jour.

| forme | app | plateforme | commit | session |
|---|---|---|---|---|
| [démarre](../fiches-3/demarre.md) | carnet de cuisine : recettes et fois cuisinées | Expo 57 | `791c04d` | 15 tours, 0,30 $, 4 min |
| [équipe](../fiches-3/equipe.md) | planning d'un club de sport : entraînements et présents | Next.js 16.4 | `1b05281` | 18 tours, 0,55 $, 5 min |
| [fonctions](../fiches-3/fonctions.md) | suivi des abonnements, écritures par RPC | Expo 57 | `9ee8a78` | 17 tours, 0,45 $, 5 min |

- Chaque app est un fichier `<nom>.bundle` (`cuisine`, `club`, `abonnements`) : `git clone <nom>.bundle <dossier>`.
- Les comptes rendus des sessions sont recopiés tels quels dans [`rapports/`](rapports/).

Vérifications du 10/10, par la session de travail, sur un clone neuf de chaque archive, dans un environnement vide :
- **critères d'une app publique** (`../candidats/verifier.mjs`, `SOURCE=` un clone de l'archive) : les trois sont
  éligibles, leurs migrations passent sur un PostgreSQL 16 neuf. Tables « à moi » : cuisine : `cookings`, `recipes` ;
  club : `attendances`, `club_invitations`, `club_members`, `clubs`, `trainings` ; abonnements : `payments`,
  `subscriptions` ;
- **ce que demande la fiche** : `npm ci` passe ; `package-lock.json` et `.env.example` sont commités ; aucun `.env` ni
  secret n'est commité. cuisine et abonnements : `npx tsc --noEmit` et `npx expo export -p web` passent. club :
  `npm run lint` et `npm run build` passent ; `npx tsc --noEmit` rend 8 erreurs sur un clone neuf (`PageProps`,
  `LayoutProps` : des types que Next 16 génère au build), puis 0 après `npm run build`, comme les apps d'équipe des
  deux premiers examens. Les apps sont gardées telles quelles ;
- **navigation** : les trois naviguent par pile (Expo Router `Stack`, ou Next.js) : leur emplacement est un bouton
  flottant sur tous les écrans (`../essais.tsv`).

## Quatrième examen : 3 apps nouvelles (14/10)

Construites le 14/10/2026, de 12:51:54 à 12:59 UTC, chacune par une session Claude Code scellée (`../scelle/lancer.sh`,
mode « fiche »), qui n'a reçu que [`../scelle/CONSTRUIRE.md`](../scelle/CONSTRUIRE.md) et sa fiche de forme : ni vak,
ni la règle, ni le dépôt du kit. Les fiches (`../fiches-4/`) étaient commitées depuis 12:51:28 UTC, et leurs
empreintes publiées sur le ticket n°4 du dépôt public avant la construction. Depuis cet examen, la consigne demande
aussi d'appeler chaque fonction de la fiche et de vérifier qu'aucun utilisateur n'atteint les lignes de l'autre par
une fonction.

| forme | app | plateforme | commit | session |
|---|---|---|---|---|
| [démarre](../fiches-4/demarre.md) | collection de disques vinyles et écoutes | Expo 57 | `398bb03` | 15 tours, 0,32 $, 5 min |
| [équipe](../fiches-4/equipe.md) | rédaction d'un journal de quartier : articles et photos | Next.js 16.4 | `af3d891` | 20 tours, 0,73 $, 7 min |
| [fonctions](../fiches-4/fonctions.md) | prêts d'objets, écritures par RPC | Expo 57 | `9c8fe30` | 18 tours, 0,36 $, 5 min |

- Chaque app est un fichier `<nom>.bundle` (`disques`, `journal`, `prets`) : `git clone <nom>.bundle <dossier>`.
- Les comptes rendus des sessions sont recopiés tels quels dans [`rapports/`](rapports/).
- **Messages de commit** : les sessions signaient leurs commits d'une ligne `Co-Authored-By` qui nomme le modèle.
  La session de travail a retiré cette seule ligne des messages (`git filter-branch --msg-filter`), sans toucher aux
  fichiers : arbres, auteurs et dates de chaque commit sont identiques à ceux des sessions ; seuls les identifiants des
  commits réécrits changent (le premier commit de disques et de journal, celui du gabarit, garde le sien). Les
  archives des examens passés gardent cette ligne : déjà publiées avec leurs empreintes, elles ne peuvent plus être
  réécrites. C'est la ligne d'attribution que Claude Code met à ses commits, comme celle des commits de ce dépôt.
- Les gabarits de `create-expo-app` et `create-next-app` apportaient un `AGENTS.md` (et, pour Expo, un dossier
  `.claude/`) : les sessions les ont retirés de l'app, comme le veut la fiche (« aucune mention d'un kit
  d'assistant »). Pour disques, ils restent dans le premier commit, celui du gabarit ; pour journal, `AGENTS.md` reste
  dans les deux premiers (le gabarit, puis le schéma) et n'est retiré qu'au dernier ; la session de prets a recréé son
  dépôt sans eux.
- **Écarts aux fiches**, gardés tels quels (détail dans [`rapports/`](rapports/)) : disques supprime un disque (ses
  écoutes partent en cascade), ce que sa fiche ne demande pas ; une écoute vise un disque par la clé composite
  `(vinyl_id, user_id)`. journal a deux tables « à moi » de plus que sa fiche : `profiles` (une ligne par compte,
  posée par un déclencheur sur `auth.users`, visible des co-membres) et `newspaper_invitations` (invitations en
  attente, vues du seul propriétaire) ; sa RLS passe par des fonctions `security definer` d'un schéma `private` ; ses
  droits de mise à jour sont donnés colonne par colonne ; journaux et invitations ne s'écrivent que par fonctions
  (`create_newspaper`, `invite_member`, `remove_member`, `claim_invitations`) ; il commite un test SQL
  (`supabase/tests/`). prets n'admet qu'un prêt ouvert par objet (index unique partiel), ses fonctions sont
  `security definer`, et `forget_item` est sa seule suppression.

Vérifications du 14/10, par la session de travail, sur un clone neuf de chaque archive, dans un environnement vide :
- **critères d'une app publique** (`../candidats/verifier.mjs`, `SOURCE=` un clone de l'archive) : les trois sont
  éligibles, leurs migrations passent sur un PostgreSQL 16 neuf. Tables « à moi » : disques : `listenings`,
  `vinyls` ; journal : `article_photos`, `articles`, `newspaper_invitations`, `newspaper_members`, `newspapers`,
  `profiles` ; prets : `items`, `loans` ;
- **ce que demande la fiche** : `npm ci` passe ; `package-lock.json` et `.env.example` sont commités ; aucun `.env` ni
  secret n'est commité. disques et prets : `npx tsc --noEmit` et `npx expo export -p web` passent. journal :
  `npm run lint` et `npm run build` passent ; `npx tsc --noEmit` rend 1 erreur sur un clone neuf (`LayoutProps`, un
  type que Next 16 génère au build), puis 0 après `npm run build`, comme les apps d'équipe des examens passés. Les
  apps sont gardées telles quelles ;
- **navigation** : les trois naviguent par pile (Expo Router `Stack`, ou Next.js) : leur emplacement est un bouton
  flottant sur tous les écrans (`../essais.tsv`).

## Cinquième examen : 3 apps nouvelles (22/10)

Construites le 22/10/2026, de 13:10:27 à 13:16 UTC, chacune par une session Claude Code scellée (`../scelle/lancer.sh`,
mode « fiche »), qui n'a reçu que [`../scelle/CONSTRUIRE.md`](../scelle/CONSTRUIRE.md) et sa fiche de forme : ni vak,
ni la règle, ni le dépôt du kit. Les fiches (`../fiches-5/`) étaient commitées avant, et leurs empreintes publiées,
avec celle de l'archive gelée du kit, sur le ticket n°5 du dépôt public avant la construction.

| forme | app | plateforme | commit | session |
|---|---|---|---|---|
| [démarre](../fiches-5/demarre.md) | carnet de randonnée : itinéraires et sorties | Expo 58 | `4f43b02` | 13 tours, 0,30 $, 4 min |
| [équipe](../fiches-5/equipe.md) | spectacles d'une troupe de théâtre : distribution | Next.js 16.4 | `e3c2605` | 16 tours, 0,44 $, 5 min |
| [fonctions](../fiches-5/fonctions.md) | cartes de révision, écritures par RPC | Expo 58 | `fd44d33` | 19 tours, 0,51 $, 5 min |

- Chaque app est un fichier `<nom>.bundle` (`randonnee`, `troupe`, `revisions`) : `git clone <nom>.bundle <dossier>`.
- Les comptes rendus des sessions sont recopiés tels quels dans [`rapports/`](rapports/).
- **Messages de commit** : comme au quatrième examen, la seule ligne `Co-Authored-By` (la ligne d'attribution que
  Claude Code met à ses commits, qui nomme le modèle) est retirée des messages (`git filter-branch --msg-filter`), sans
  toucher aux fichiers : arbres, auteurs et dates sont identiques à ceux des sessions ; seuls les identifiants des
  commits réécrits changent. Les comptes rendus citent les identifiants d'avant : randonnee `3d6cc8a` devenu
  `4f43b02`, troupe `cec3ea0` devenu `e3c2605`, revisions `ab67170` devenu `fd44d33` (les premiers commits de
  randonnee et de revisions, ceux du gabarit, gardent les leurs).
- Les gabarits de `create-expo-app` apportaient un `AGENTS.md` et un `.claude/settings.json` : pour randonnee et
  revisions, ils restent dans le premier commit, celui du gabarit, et sont retirés au second, comme le veut la fiche
  (« aucune mention d'un kit d'assistant »). La session de troupe a retiré l'`AGENTS.md` de `create-next-app` avant
  son seul commit.
- **Écarts aux fiches**, gardés tels quels (détail dans [`rapports/`](rapports/)) : randonnee lie une sortie à son
  itinéraire par la clé composite `(trail_id, owner_id)`, et n'a ni modification ni suppression dans l'interface ;
  troupe ajoute `troupes.created_by`, n'invite que des personnes qui ont déjà un compte (pas de table d'invitations),
  réserve titulaire et doublure aux `owner` et `actor` par un déclencheur, et écrit les membres par des fonctions
  `security definer` (`create_troupe`, `invite_member`, `remove_member`, `set_member_role`). Ses lectures passent
  aussi par des fonctions `security definer` : `troupe_member_list` rend l'e-mail de chaque co-membre, `mes_personnages`
  lit hors RLS ; sa RLS s'appuie sur des aides `security definer` appelables en RPC, dont `show_troupe`, qui rend la
  troupe de n'importe quel spectacle sans vérifier l'appartenance ; un déclencheur libère les personnages d'un membre
  retiré ou passé `viewer`. revisions a ses fonctions en `security definer`, sauf `cards_due` (`security invoker`).
  Comme la fiche le dit, `delete_deck` refuse un paquet qui contient une carte neuve du jour (elle est à revoir ce
  jour-là).

Vérifications du 22/10, par la session de travail, sur un clone neuf de chaque archive :
- **critères d'une app publique** (`../candidats/verifier.mjs`, `SOURCE=` un clone de l'archive) : les trois sont
  éligibles, leurs migrations passent sur un PostgreSQL 16 neuf. Tables « à moi » : randonnee : `outings`, `trails` ;
  troupe : `characters`, `shows`, `troupe_members`, `troupes` ; revisions : `cards`, `decks`, `reviews` ;
- **ce que demande la fiche** : `npm ci` passe ; `package-lock.json` et `.env.example` sont commités ; aucun `.env` ni
  secret n'est commité. randonnee et revisions : `npx tsc --noEmit` et `npx expo export -p web` passent. troupe :
  `npm run lint` et `npm run build` passent ; `npx tsc --noEmit` rend 5 erreurs sur un clone neuf (`LayoutProps` et
  `PageProps`, des types que Next 16 génère au build), puis 0 après `npm run build`, comme les apps d'équipe des
  examens passés. Les apps sont gardées telles quelles ;
- **navigation** : les trois naviguent par pile (Expo Router `Stack`, ou Next.js) : leur emplacement est un bouton
  flottant sur tous les écrans (`../essais.tsv`).
