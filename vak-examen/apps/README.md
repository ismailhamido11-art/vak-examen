# Les 3 apps construites de l'examen

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

## Vérifications du 06/10

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
