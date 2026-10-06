# Publication avant le tirage

Publiée le 06/10/2026, avant le tirage. Ce fichier fige ce que la règle ([`REGLE.md`](REGLE.md), « La publication »)
demande de publier avant le tirage. Après lui, plus rien ne change.

## Les empreintes

Ce sont des SHA-256. Les mêmes sont dans [`EMPREINTES.sha256`](EMPREINTES.sha256), avec des chemins pris depuis la
racine du dépôt : `sha256sum -c --ignore-missing vak-examen/EMPREINTES.sha256` vérifie tout ce qui est déjà publié.

- **La règle** : `vak-examen/REGLE.md`, `4c34f324cd6b1fd61a970790eb4b8612a39844d468362e5ecbb270d247ecfa2d`.
- **L'archive gelée du kit** : `vak-agent-0.24.3.tgz` (2 985 693 octets),
  `2765b6929c144be93031b424114dd5f3c0d95c4b94118600edc687e1b811a31f`. C'est la seule archive des 14 essais. Elle
  sera publiée si l'examen est réussi.
- **La page de vak**, d'où vient la demande (son README ; il n'est pas dans l'archive) : `vertical-agent-kit/README.md`,
  `aff4f32095eb5a0981acbce823d8e39efc57121628c6b6286af6c702bcd2f618`. Elle sera publiée avec l'archive.
- **Les fiches de forme et les 3 apps construites** : `fiches/*.md` et `apps/*.bundle`, publiées ici. Leurs
  empreintes sont aussi dans [`apps/SHA256SUMS`](apps/SHA256SUMS). Branches `main` des apps : démarre
  `891485f41f5b5f425c4d5a78bf16db5b907d580c`, équipe `ed96d9a1505e38d72746c80b669a6451a0eaef02`, fonctions
  `824674902a11c6966034c1fa0e1da7c3a34f386d`.
- **Les graines A et B** des 3 apps construites (et de sqlnoir, l'app des répétitions), avec l'outil qui les éprouve
  et le compte rendu de la session scellée qui les a écrites : les 12 fichiers de `graines/`. Ils seront publiés après
  les essais.
- **La liste des apps éligibles** : `candidats/historique.tsv`,
  `9cad401aed68e9ab6d9551115500ff824159f225c4bee79231c0e58c5ea05f72` : 23 apps éligibles, 14 Expo et 9 Next, chacune
  à son commit de `candidats/candidats.tsv`. La liste d'exclusion complète est
  [`candidats/exclusions.txt`](candidats/exclusions.txt).
- **Les outils figés** avec la règle sont ceux de ce commit : le contrôleur (`controleur/`), le juge « mes données »
  (`mesdonnees/`), la pile (`pile/`), `verdict.mjs` et le tirage (`tirage.mjs`, `candidats/`). Le lanceur
  (`repetition2/`) l'est pour le texte que reçoit l'agent, la bulle, la transcription du journal et la limite de
  temps.

```text
4c34f324cd6b1fd61a970790eb4b8612a39844d468362e5ecbb270d247ecfa2d  vak-examen/REGLE.md
2765b6929c144be93031b424114dd5f3c0d95c4b94118600edc687e1b811a31f  vertical-agent-kit/releases/vak-agent-0.24.3.tgz
aff4f32095eb5a0981acbce823d8e39efc57121628c6b6286af6c702bcd2f618  vertical-agent-kit/README.md
7337fd028d43e0fd474c1f37161c6542c19a1a5123adedb3d35664cb0a1063e0  vak-examen/fiches/demarre.md
3effef5ab7cfef8c30dc59cb015efe910c03a6ce6511344d3a180675a094e076  vak-examen/fiches/equipe.md
333e1fecc26c60f093b05d993d22437e092e8aa76898fc72ab36f41f1e549ab9  vak-examen/fiches/fonctions.md
7326e0fddeeb06e6338d538d48ae9b3092a0fd412288ec68f6a6c00b0a8c87ca  vak-examen/apps/demarre.bundle
027c6f93fb883c1b8b0c654acbf315dfabeb20fee80a269efe4040e040db2b01  vak-examen/apps/equipe.bundle
d2d249bdefbc40f3371c976f453f44cd2597f60d289dce0c77581a8353fb7d10  vak-examen/apps/fonctions.bundle
9cad401aed68e9ab6d9551115500ff824159f225c4bee79231c0e58c5ea05f72  vak-examen/candidats/historique.tsv
ed133f12074f949e90302e694d6142a0eb4377ce50a4a6db5206e3bb2b16a9ea  vak-examen/graines/RAPPORT.md
e18d0dc2001d0619a825d2b9459d30b66fcdb99bd722c68d8bdf1edfc84ff055  vak-examen/graines/README.md
aab860abba7434fe459f51af134d414d42a57e1113dcd5b2b7c6379b4f5c7cd1  vak-examen/graines/demarre/attendu.json
ef958be01ccb086f1695bc28def47b9c841993b248346e0370e34517228ddf2d  vak-examen/graines/demarre/graine.sql
c6c0e03637c6d062af1c251b022787ee9407ff05cec1d07983eec2e48d9bf1d4  vak-examen/graines/eprouver.mjs
2c31f7136405dae89b8a7bce987b9a6a2b6d5f966c8604f8ba15c15276a1ab28  vak-examen/graines/equipe/attendu.json
7575a7f2a4837f16d0734e7f8cab8b54b66b3bb20f3f6a6d349a59a37d2a73da  vak-examen/graines/equipe/graine.sql
aa8e7384fd1d0ab6148e01c58c8d65486a93feb2b38badd111979f9be746ada2  vak-examen/graines/fonctions/attendu.json
f720124c8c50cb74db128e75a2c7e23041038c0177d2ac9ddf09b414dfbce6fc  vak-examen/graines/fonctions/graine.sql
fef844193939eff1b8c0b33e69cfdb5207a489055cffecf428839dc814aad212  vak-examen/graines/sqlnoir/attendu.json
93a74b86c7bed9831cf1b49a6787e19b696ae8ee419ab410e00ff84a7500f2ee  vak-examen/graines/sqlnoir/graine.sql
e9675d55ce552bc97ddca7daddc1e3750d4fa1331ed199431260c160bb48484d  vak-examen/graines/supabase-minimum.sql
```

## La demande

L'agent reçoit la demande de la page de vak (bloc « La demande en une ligne »), mot pour mot, avec ses trois champs
remplis. Voici le texte exact, champs non remplis :

```text
Intègre l'assistant IA vak dans cette app. Métier : *<une phrase sur le métier>*. Emplacement : *<un onglet « Assistant » ou un bouton flottant sur tous les écrans>*. L'archive du kit est ici : *<chemin absolu de vak-agent-<version>.tgz>* ; c'est moi qui l'ai fournie (pour un agent en ligne, je l'ai commitée dans `vendor/vak`). Lis-la d'abord sans rien exécuter : `tar -xzOf - package/package.json < "<ce chemin>"` montre `"private": true` et aucun script d'installation (`preinstall`, `install`, `postinstall`, `prepare`). Puis lance `npx -y --package="<ce chemin>" vak init` et suis ce qu'il affiche ; une commande refusée, ne la contourne jamais : arrête-toi et donne-la-moi. Avant de me poser une question, cherche la réponse dans `node_modules/@vak/agent/docs/FAQ.md`. Mesure les vérifications de l'app avant l'installation. Tu as fini quand `node node_modules/@vak/agent/bin/vak.mjs` renvoie 0 et que la phrase « Fini pour l'agent de code » de son aide (`--help`) est vraie. S'il te manque un accès ou une clé, arrête-toi et donne-moi la commande exacte à lancer dans mon terminal.
```

Le harnais (`repetition2/messages.sh`) remplit les trois champs :
- le métier et l'emplacement, fixés pour chaque app avant ses essais ;
- le chemin `/work/vak-agent.tgz`, où `repetition2/preparer.sh` copie l'archive.

Il place la demande entre deux phrases d'introduction et les règles de l'essai, écrites dans ce même fichier.

## L'environnement des essais

- La machine : un conteneur Linux x86_64 (Ubuntu 24.04.4 LTS, 16 Go de mémoire), dans le cloud de Claude Code.
- Node 22.22.2.
- PostgreSQL 16.13 (paquet `postgresql-16` 16.13-0ubuntu0.24.04.1), avec pgTAP 1.3.2 (`postgresql-16-pgtap`) pour
  les tests du kit. Aucune autre extension n'est ajoutée, pgvector compris.
- La CLI Supabase 2.118.0, la version que fixe l'archive gelée. Pas de Docker.
- L'agent :
  - Claude Code 2.1.291 (`claude -p`, mode `bypassPermissions`), avec le modèle par défaut de cette version ;
  - il tourne dans la bulle de `repetition2/lancer.sh`. Elle lui cache la session, `/srv`, le `/tmp` de la machine
    et les autres essais de `/work` (vides pour lui). Les bases locales sont supprimées avant chaque essai ;
  - chaque essai consigne la version de Claude Code dans son `lanceur.json`.
- La pile « mes données » :
  - PostgREST 12.2.12 et Deno 2.9.6 ;
  - pour l'assistant, le modèle `deepseek-flash` par l'API de DeepSeek, avec la clé du propriétaire.

## Le tirage

- La chaîne drand « quicknet » : `52db9ba70e0cc0f6eaf7803dd07447a1f5477735fd3f661792ba94600c84e971`. Elle produit un
  tour toutes les 3 secondes depuis le 23/08/2023 à 15:09:27 UTC (genèse 1692803367).
- **Le tour choisi est le 32828212**. Il sera produit le **6 octobre 2026 à 12:00:00 UTC**. Quand ce fichier
  est publié, il n'existe pas encore.
- La commande : `node vak-examen/tirage.mjs 32828212`. Elle lit l'aléa sur un relais public de drand et vérifie sa
  signature. Elle classe ensuite les 23 apps éligibles, et prend les 2 premières apps Expo et les 2 premières apps
  Next.
- Son résultat sera publié dans `vak-examen/TIRAGE.md`, avant les essais.

## L'ordre des étapes

- **04/10, 09:59 UTC** : les fiches de forme sont commitées (commit `bc7c312` du dépôt de vak).
- **04/10** : le contrôleur est écrit par une session scellée.
- **04/10** : la liste des apps éligibles est établie par une session scellée. Le critère « pas une copie » lui est
  appliqué le 06/10.
- **06/10, entre 00:15 et 00:21 UTC** : les 3 apps sont construites par des sessions scellées.
- **06/10, vers 08:00 UTC** : une session scellée écrit les graines A et B et le juge « mes données ».
- **06/10, de 07:57 à 08:16 UTC** : la répétition 6 joue tout le circuit sur sqlnoir (essai, contrôleur, « mes
  données »).
- **06/10, matin** : un agent indépendant relit la règle deux fois avant le gel. Ses 12 constats, puis les 5 de sa
  seconde lecture, sont traités (plus bas). Le critère « pas une copie » est rejoué avec la liste d'exclusion
  complète, et la bulle durcie est éprouvée sur un vrai essai (répétition 7).
- **06/10** : cette publication.

Seule cette publication est datée par GitHub. Les étapes d'avant le sont par l'histoire du dépôt de vak, qui n'est
pas public.

## Ce qui a changé depuis le brouillon du 03/10

Le brouillon n'avait pas été publié. Il a été précisé le 06/10, avant le gel :
1. **La liste d'exclusion était incomplète.**
   - Celle remise le 04/10 à la session scellée des candidats (`scelle/exclusions.txt`) oubliait les 4 apps de la
     répétition 1 (étape 4, septembre), où le kit a été développé et testé.
   - L'une d'elles, `aaronksaunders/expo-supabase-ai-template`, était éligible : elle est écartée.
   - La liste complète est `candidats/exclusions.txt`. Le critère « pas une copie » a été rejoué avec elle, avec en
     plus l'exclusion par dépôt et par propriétaire : aucune autre app n'est touchée.
   - `Razikus/supabase-nextjs-template` reste éligible : elle a été lue le 30/09, sans rien lancer, pour choisir les
     apps de la répétition 2, puis écartée de celle-ci. Aucune mesure du kit n'a porté sur elle.
2. **Qui juge** : le contrôleur scellé et le juge « mes données », jamais la dernière ligne du lanceur. Ils sont figés
   avec la règle, et relancés si la machine les a empêchés de juger. Le contrôleur et la pile démarrent PostgreSQL
   eux-mêmes, hors de toute bulle, car la machine peut redémarrer.
3. **Les points 2, 4 et 6** disent ce que le contrôleur vérifie vraiment. Le point 5 dit ce que deviennent une pile
   qui ne sert pas l'assistant et un comptage qui diffère de la graine.
4. **Le tirage** : la formule exacte du rang, les seules raisons de sauter une app, et rien de remplacé après le
   premier essai.
5. **Les coupures** : un essai arrêté à 120 minutes compte ; une coupure par la machine se lit dans les journaux.
6. **Les seuils** : la médiane exacte, une seule définition du geste (dans le doute, c'est un geste), et le faux
   « c'est fait ».
7. **Les étiquettes** : le lecteur est une session scellée, au lieu d'une personne (choix du propriétaire). La vérité
   de chaque essai est publiée avant la lecture.
8. **Le groupe témoin** part sans l'archive de vak, et sa mesure est dite.
9. **L'environnement exact** (pgTAP, version de la CLI Supabase), et le texte de la demande, qui n'est pas dans
   l'archive.
10. **Ce qui est publié après les essais**, et ce qui ne l'est qu'avec vak.
11. **La bulle de l'agent** cache aussi `/srv`, le `/tmp` de la machine et les autres essais de `/work`, et les bases
    locales sont supprimées avant chaque essai. Avant ce changement, un essai pouvait voir les essais précédents.
    Elle est figée avec la règle.
12. **Les nombres se jugent sur « combien de mes … ? »**. À la répétition 7, l'assistant a répondu juste à « List my
    profiles. » (« one account, one file on you »), puis a listé les 4 champs de ce profil ; le juge y a lu
    « 4 éléments ». « Liste mes … » sert donc à chercher les marqueurs de B, et sa lecture est publiée sans décider.
    `verdict.mjs` assemble le verdict de chaque essai ; le juge scellé n'est pas modifié.

## Ce qui viendra

- **Après le tirage, avant les essais** :
  - `TIRAGE.md` ;
  - les empreintes des graines des 4 apps tirées ;
  - la liste des 7 apps, avec les trois champs de leur demande ;
  - le mode témoin du lanceur et le lecteur des étiquettes ;
  - toute correction du lanceur, avec sa raison.
- **Après les essais** :
  - les journaux des agents, avec les secrets masqués ;
  - les verdicts du contrôleur et du juge « mes données » ;
  - les gestes, les étiquettes, la vérité et les réponses du lecteur ;
  - le groupe témoin et les graines.
- **Si l'examen est réussi** : l'archive et la page de vak, et l'état commité de chaque essai.
