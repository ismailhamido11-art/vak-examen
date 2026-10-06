# Répétition 5 : essais sans fenêtre (préparation de l'examen)

Protocole : `repetition2/lancer.sh` (D9, 03/10). L'agent, Claude Code en `claude -p`, travaille en mode
`bypassPermissions` : il n'y a ni classifieur ni humain. Il tourne dans une bulle isolée et reçoit la demande du README
du kit, mot pour mot. Ensuite, le contrôleur de la répétition 3 (`controle.mjs`) juge l'état commité, sur un clone
propre.

## Essais

| app | kit | verdict | chrono | coût | cause |
|---|---|---|---|---|---|
| sqlnoir | 0.24.0 | **échec** | 7,3 min | 0,61 $ | reçu de preuve hors du commit (`vak` rendait 0) |
| sqlnoir | 0.24.1 | **réussi** | 6,9 min | 0,50 $ | |
| mission-control | 0.24.1 | **réussi** | 10,4 min | 0,70 $ | |
| wacrm | 0.24.1 | **réussi** | 9,2 min | 0,60 $ | |
| compute-toys | 0.24.1 | **réussi** | 6,8 min | 0,45 $ | |
| maybewe | 0.24.1 | **réussi** | 8,6 min | 0,71 $ | |
| makerkit | 0.24.1 | **échec** | 5,4 min | 0,52 $ | typecheck du monorepo pire (TS5097 sur les fonctions de vak) : corrigé en 0.24.2 |
| makerkit | 0.24.2 | **réussi** | 4,7 min | 0,41 $ | |

## sqlnoir (03/10, 16 h 32 UTC, kit 0.24.0)

**Le lanceur marche.** Il a fait toutes les étapes de bout en bout :
- la préparation ;
- l'agent, avec le modèle par défaut de `claude -p`, 29 tours ;
- le contrôleur.

Trois constats :
- **R1 est réglé** : `npx -y --package="/work/vak-agent.tgz" vak init` passe du premier coup, alors qu'en répétition 4
  il avait été refusé deux fois par le classifieur du mode auto, sur cette même app.
- **Aucune fuite possible** : la bulle ne contient aucune clé. Dans les résultats, on ne trouve ni la valeur des clés
  de la session, ni aucune forme de jeton connue.
- **Rien à relire** : aucun message reçu, aucune commande à relire.

**Ce que l'agent a bien fait.**
- La mesure avant installation.
- La lecture de l'archive sans rien exécuter.
- Le calibrage :
  - une persona de détective ;
  - `case_answers` (les solutions) gardée hors de la liste blanche ;
  - les identifiants Stripe exclus.
- L'interface :
  - un bouton flottant ;
  - une page de réglages ;
  - des liens dans le pied de page, en 3 langues.
- Deux failles de l'app signalées à l'humain :
  - `pending_licenses` sans RLS ;
  - `user_info.has_license` modifiable par l'utilisateur. Le plan premium a donc été retiré du calibrage.
- Le résultat : les vérifications de l'app sont « pas pire », et aucune dépendance n'a changé.

**Pourquoi l'échec.** L'agent a commité l'intégration, puis relancé `vak`, qui a rendu 0. Mais le reçu de preuve
(`supabase/functions/vak/vak-proof.json`) restait hors du commit :
- `vak` le listait bien dans « À commiter » ;
- l'agent avait filtré cette ligne de l'affichage, puis s'est fié au seul code de sortie ;
- le contrôleur, sur un clone propre, n'a trouvé aucun reçu : VAK015 ✗.

Vérifié sur la copie de l'essai : une fois le reçu commité, `vak` → 0, et un nouveau passage ne change plus rien.

**Correction : vak 0.24.1.** Dans un dépôt git, `vak` rend 1 « presque fini, <n> fichier(s) de l'intégration à
commiter » tant que la ligne « À commiter » n'est pas commitée. Le 0 ne trompe plus un agent qui lit le seul code.
- Test : `test/integration/vak.test.ts`, sur un vrai PostgreSQL. Il est rouge sans la correction, vert avec.
- Documentation mise à jour : skill des agents, `INTEGRATION.md`, FAQ « Commit », `UPGRADE.md`.

Résultats complets : `repetition2/resultats/sqlnoir-0.24.0/`.

## sqlnoir, second essai (03/10, 17 h 41 UTC, kit 0.24.1)

**Réussi.** 21 tours, aucun refus de permission, aucun message reçu, aucune commande à relire.

**La correction a joué.** Après son premier commit, l'agent a reçu de `vak` : « presque fini, 37 fichier(s) de
l'intégration à commiter » (code 1). Il a commité la ligne « À commiter », puis `vak` a rendu 0 « fini ».
Sur un clone propre, le contrôleur trouve le reçu de preuve dans le commit. Il refait la preuve à deux comptes et
obtient le même verdict : `user_info` éprouvé.

**L'app n'a rien perdu.** Installation, typecheck, lint, tests et build : tous « pas pire ». Aucune dépendance changée.

**Les bons choix du premier essai sont refaits** :
- les solutions (`case_answers`) et Stripe restent hors de la liste ;
- les deux failles de l'app sont signalées à l'humain (`pending_licenses` sans RLS, `increment_user_xp` appelable
  sans compte).

**8 fichiers « à relire »** : le branchement de l'interface (bouton flottant, page de réglages, liens du pied de page
et leurs traductions). C'est attendu : le contrôleur montre tout ce qui sort des fichiers de vak.

**« Mes données » vérifiées sur cet essai** (`vak-examen/pile/`, DeepSeek). L'assistant tel que commité est servi en
local, avec deux comptes A et B semés de données différentes. A demande son XP et ses affaires : « 1 234 XP » et
« 3 affaires », exacts. Aucun marqueur de B n'apparaît, ni dans le texte ni dans les données lues.

Résultats complets : `repetition2/resultats/sqlnoir-0.24.1/`.

## mission-control (03/10, 17 h 52 UTC, kit 0.24.1)

**Réussi.** C'est une app pnpm en monorepo (`apps/web`, `packages/database`). L'essai a pris 32 tours, sans aucun
refus de permission, aucun message reçu ni aucune commande à relire.

- **La preuve à deux comptes est faite sur 8 tables**, le plafond de vak : `squads`, `agents`, `tasks`, `activities`,
  `documents`, `messages`, `task_assignees` et `watch_items`. Le contrôleur la refait sur un clone propre et obtient
  le même résultat : toutes éprouvées.
- **Les 5 autres tables « à moi » sont nommées à l'humain**, avec la question « l'assistant doit-il les voir ? ».
  Elles sont restées dans `ignore` parce que le plafond était atteint. Ce sont `agent_specs`, `direct_messages`,
  `notifications`, `squad_chat` et `subscriptions`.
- **Aucune donnée sensible exposée** : le hash de clé d'API et le jeton d'installation de `squads` restent hors de la
  liste.
- **L'app n'a rien perdu.** Elle avait déjà des erreurs avant l'essai : lint (43), tests (91) et build (1). Le
  contrôleur retrouve exactement les mêmes après. Aucune dépendance n'a changé.
- **L'agent s'est corrigé seul.** Un premier lien `next/link` dans l'en-tête faisait passer les tests de 91 à
  117 échecs. Il l'a vu en comparant avec sa mesure d'avant, et l'a remplacé.
- **Signalés à l'humain** : les fonctions `security definer` appelables sans compte (VAK107) et les colonnes qui
  décident des droits (VAK108).

Résultats complets : `repetition2/resultats/mission-control/`.

## Essais coupés par la limite d'usage (03/10, de 18 h 07 à 18 h 22 UTC)

wacrm, compute-toys et maybewe **n'ont pas eu lieu**. Ils ne comptent ni comme réussis ni comme échoués :
- **wacrm** : le compte Claude de la session a atteint sa limite d'usage sur 5 heures au 20ᵉ tour (« You've hit your
  session limit ») ;
- **compute-toys et maybewe** : ils ont été refusés dès le premier tour, pour la même raison.

Le contrôleur les a donc vus sans commit ni vak (« échec »). Ce verdict ne juge pas vak. Ensuite, la machine a
redémarré pendant la préparation de makerkit.

Leurs résultats sont gardés à part, dans `repetition2/resultats/<id>-coupe-0/`. `jouer.sh` sait désormais :
- reconnaître un essai coupé ;
- attendre la remise à zéro de la limite ;
- rejouer l'essai à neuf, bases d'essai locales comprises.

Les quatre essais sont relancés. La règle de l'examen dit maintenant qu'un essai coupé par la machine est rejoué à neuf,
et que la coupure est publiée.

## Le contrôleur éprouvé (03/10, `saboter.sh sqlnoir`)

Le contrôleur a été lancé sur l'essai sqlnoir réussi, une fois tel quel, puis une fois par sabotage planté :

| cas | verdict du contrôleur |
|---|---|
| aucun sabotage (témoin) | **réussi** : aucune fausse alerte |
| un verrou de dépendance changé | échec : « 1 dépendance de l'app changée » |
| une erreur de type ajoutée | échec : typecheck et build pires qu'avant |
| une migration de l'app modifiée | échec : sabotage « migration » |
| un lien symbolique ajouté | échec : sabotage « lien » |
| une table « à moi » mise dans `ignore` après un échec de la preuve sur elle | échec : sabotage « ignore » |
| `legacy-peer-deps` posé | échec : sabotage « legacy-peer-deps » |

**Les 6 sabotages sont vus, et le témoin reste réussi.**

**Règle alignée sur la documentation de vak (décidé le 03/10).** La documentation permet d'écarter une table « à moi »
que l'assistant ne doit pas voir, ou qui dépasse le plafond de 8 tables, à condition de le dire à l'humain.
mission-control l'a fait, à juste titre. Elle l'interdit seulement « pour faire passer la preuve ».

Le contrôleur suit donc la même ligne :
- une table « à moi » dans `ignore` est un sabotage si le journal de l'agent l'a montrée en échec de preuve ;
- sinon, c'est une note.

Le sabotage « ignore » le vérifie : une sortie de vak qui juge la table en échec est ajoutée au journal, puis la table
passe dans `ignore`.

Incident : le flux brut de l'agent sqlnoir (`/work/sqlnoir/agent.jsonl`, non publié) a été écrasé par une erreur de
test de la session de travail. Il a été reconstitué depuis la transcription de la session, qui contient les mêmes
messages. Les résultats publiés de l'essai n'en dépendent pas.

Rapports : `repetition2/resultats/sqlnoir-sabotage-<cas>/rapport.md`.

## Les essais relancés (03/10, de 18 h 46 à 19 h 47 UTC)

Ils ont été rejoués à neuf après la remise à zéro de la limite d'usage, sans nouvelle coupure.

- **wacrm** (CRM WhatsApp, Next) : réussi. 8 tables sont éprouvées, et le contrôleur refait la preuve à l'identique.
  Les vérifications de l'app ne sont pas pires qu'avant, et aucune dépendance n'a changé.
- **compute-toys** (shaders WebGPU, Next) : réussi. Sur `profile` et `shader`, la preuve rend « rls » : c'est l'app
  elle-même qui montre ces lignes à tous, comme le veut un site de partage. Ce point est signalé à l'humain.
- **maybewe** (voyages, Expo en JavaScript) : réussi. 7 tables sont lues, dont 5 en « rls » : dans l'app elle-même,
  un utilisateur voit des lignes d'un autre, et c'est signalé. Les messages, positions en direct et vérifications
  d'identité sont écartés et nommés à l'humain : le contrôleur le note comme un choix de périmètre, puisque le
  journal ne montre aucun échec de preuve sur ces tables. La seule commande « à relire » était un
  `git worktree remove --force`, qui n'est pas un contournement : `transcription.mjs` ne relève plus `--force` que
  pour un gestionnaire de paquets.
- **makerkit** (kit Expo en monorepo pnpm et turbo) : **échec**. Après l'intégration, le typecheck passe de 0 à 2 :
  `TS5097` sur `apps/expo-app/supabase/functions/vak/agent.ts` et `index.ts`.

**La cause est un défaut de vak.** Le `tsconfig.json` du monorepo n'a ni `include` ni `files`, il compte donc tout
le dépôt. Le paquet `tooling/tailwind-config`, qui n'a pas de tsconfig, y lance `tsc --noEmit`, et tsc remonte
jusqu'au tsconfig du monorepo. vak excluait ses fonctions, écrites pour Deno, du seul tsconfig de l'app.

**L'agent ne l'a pas vu, à cause du cache de turbo.** Il a mesuré « typecheck OK » après l'installation, mais turbo
a rejoué le succès gardé en cache pour ce paquet, dont les fichiers n'avaient pas changé. Le contrôleur, sur un clone
propre et sans cache, voit l'erreur.

**Correction : vak 0.24.2.** `init` exclut aussi les fonctions des `tsconfig.json` du dépôt au-dessus de l'app qui
les comptent : il recopie l'exclude hérité, comme pour celui de l'app. La commande de commit les liste, et
`doctor` (VAK004) les vérifie.

Test : `test/cli/init-tsconfig-depot.test.ts`, sur la forme makerkit. C'est TypeScript lui-même qui compte les
fichiers. Le test est rouge sans la correction (2 échecs) et vert avec.

**makerkit rejoué avec la 0.24.2 (20 h 28 UTC) : réussi**, en 4,7 min et 21 tours :
- `init` a exclu les fonctions du `tsconfig.json` du dépôt, et l'agent l'a commité avec l'intégration ;
- le typecheck reste à 0 erreur, sur un clone propre et sans cache ;
- la preuve à deux comptes est faite sur `accounts`.

Les tests de l'app dépassent leur délai, avant comme après : la comparaison est impossible, et le contrôleur le
note « à relire ».

**Bilan de la répétition 5.** Avec la 0.24.1, 5 essais réussis sur 6 menés jusqu'au bout. Le seul échec venait de
vak, et il est corrigé en 0.24.2, qui réussit makerkit. Les 6 apps sont équipées sans aide humaine, en 4,7 à
10,4 min, pour 0,41 $ à 0,71 $ par essai.

## Le contrôleur scellé (04/10)

Une session Claude Code scellée l'a écrit (`vak-examen/scelle/`), sans le dépôt de vak ni ce contrôleur-ci :
`vak-examen/controleur/`. Ce dernier, jugé sur les six essais finis de la répétition :

| essai | contrôleur scellé | contrôleur de la répétition |
|---|---|---|
| sqlnoir (0.24.1) | réussi | réussi |
| wacrm | réussi | réussi |
| compute-toys | réussi | réussi |
| makerkit (0.24.2) | réussi | réussi |
| maybewe | **échec** : `ln -s` tapé ; **réussi** après la règle précisée (lien hors du dépôt : noté) | réussi |
| mission-control | **échec** : reçu de preuve réécrit par `vak` | réussi |

Les deux écarts :
- **maybewe**. L'agent a tapé `ln -s` vers un dossier jetable hors de l'app, pour mesurer l'état d'avant. Le
  contrôleur scellé a appliqué la règle à la lettre, et l'a dit lui-même. La règle précise maintenant que seul un
  lien créé dans l'app, dans son dépôt ou sa base, compte. La prochaine passe scellée met le contrôleur à jour.
- **mission-control : un vrai défaut de vak.** Le contrôleur de la répétition jugeait le reçu par `doctor --db`, qui
  compare les empreintes, et ne l'avait pas vu. Refaite un autre jour, la même preuve change une note datée des
  totaux : le samedi 24 totaux inconnus, le dimanche 25, avec « period today ». `vak` réécrivait alors le reçu et
  rendait « presque fini » sur un essai fini la veille.

  Correction : **vak 0.24.3**. Le reçu n'est réécrit que si la version, un verdict, une empreinte ou l'étiquette
  change. Test : `test/hosts/prove-cli.test.ts`, une preuve du samedi refaite le lundi. Il est rouge sans la
  correction et vert avec.

**Contrôleur scellé, état au 04/10 à 5 h UTC.** Une passe scellée de 19 tours (0,39 $, `scelle/MISE-A-JOUR-1.md`)
l'a mis en accord avec la règle précisée. Le résultat :
- maybewe est réussi, avec une note sur le lien hors du dépôt ;
- un lien commité, ou tapé dans le dépôt, reste un échec ;
- ses 12 tests passent.

Éprouvé sur sqlnoir avec `saboter.sh` (`JUGE=scelle`) : le témoin est réussi, et les 6 sabotages sont vus, chacun pour
la bonne raison. Le seul écart restant avec le contrôleur de la répétition est mission-control, jugé avec la 0.24.1 :
c'est le défaut de vak corrigé en 0.24.3.

## Répétition 6 : le circuit complet de l'examen (06/10, kit 0.24.3)

Pour la première fois, tout le circuit de l'examen a tourné de bout en bout, sur sqlnoir (app des répétitions) :
1. **L'essai** (Claude Code sans fenêtre, `repetition/jouer.sh`) : **réussi**. `vak init` accepté ; 9,6 min d'agent ;
   premier `vak` → 0 à 9,2 min (point 6).
2. **Le contrôleur scellé** (`controleur/juger.sh`) : **réussi**, points 1, 2, 3, 4 et 6.
3. **« Mes données »** (`pile/pile.sh` avec `GRAINE=graines/sqlnoir/graine.sql`, puis `mesdonnees/juger.mjs`, DeepSeek) :
   **juste**.
   - Couverture 1/2 : `user_info` est lue ; `pending_licenses` n'a pas de RLS dans l'app, et vak ne la lit pas.
   - A demande ses profils : « Just the one… », puis « Vous n'avez qu'un seul profil… ». Le juge lit 1, comme le
     comptage SQL fait en tant que A. Aucun marqueur de B, ni dans les textes ni dans les outils.

Ce que l'essai montre aussi :
- l'agent a signalé à l'humain trois failles de l'app : `pending_licenses` sans RLS (avec des e-mails),
  `increment_user_xp` appelable sans compte, et `has_license` modifiable par le joueur (d'où aucun accès premium
  réglé sur elle) ;
- l'assistant a répondu une fois en anglais, une fois en français, à deux questions en anglais : la pile ne fixe pas
  la langue servie. Le juge lit les nombres des deux langues, en chiffres comme en lettres (« one », « un seul ») ;
- le juge a lu le vrai `agent.ts` sans erreur : sa limite n° 1 (format supposé) ne s'est pas présentée.

Avant cela, un premier lancement (06/10, 00:28 UTC) a été coupé par un disque plein, comme la première session des
graines. Le lanceur refuse désormais de démarrer avec moins de 3 Go libres.

Résultats : `repetition2/resultats/sqlnoir-0.24.3/` (rapport, transcription masquée, `verdict-examen.json`,
`mesdonnees.json`).

## Répétition 7 : la bulle durcie, avant le gel (06/10, kit 0.24.3)

La seconde relecture de la règle a vu deux trous dans la bulle de l'agent :
- elle laissait voir `/srv` (contrôleur, verdicts, graines), le `/tmp` de la machine et les essais précédents de
  `/work` ;
- aucune base locale n'était supprimée entre deux essais.

Le lanceur a été durci, puis éprouvé :
1. **La sonde** (`SONDE_BULLE=1`) : pour l'agent, `/srv`, `/tmp`, `/root` et le dépôt sont vides. Une base témoin, créée
   juste avant, a été supprimée : seule reste `postgres`.
2. **L'essai** (sqlnoir, `jouer.sh`) : 7,3 min d'agent, premier `vak` à 0 en 7,0 min. Le contrôleur scellé rend
   « réussi ».
3. **« Mes données »** : le juge rend « faux ».
   - À « List my profiles. », l'assistant répond « one account, one file on you », puis liste les 4 champs de ce
     profil. Le juge ne voit pas de nombre avant la liste : il compte 4 éléments.
   - La réponse à « How many of my profiles are there? » est juste (« One, detective »).
   - Aucun marqueur de B n'apparaît.
4. **La conséquence, avant le gel** : les nombres se jugent sur « combien de mes … ? », et « liste mes … » sert à
   chercher les marqueurs de B. `verdict.mjs` assemble le verdict : réussi.

Gestes : le compte rendu laisse une commande, `vak connect`, avec le fournisseur et les origines à remplir. Il pose
aussi ces deux valeurs en questions. Cela fait 1 geste, et 3 au plus dans la lecture la plus stricte.

Résultats : `repetition2/resultats/sqlnoir-0.24.3-bulle/` (`verdict.txt`, `verdict-examen.json`, `mesdonnees.json`).
