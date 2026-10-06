# Le journal de l'examen

Les 14 essais ont commencé le 06/10/2026 à 12:11 UTC, après la publication de leur liste (`AVANT-ESSAIS.md`). Ils ont
été joués l'un après l'autre par `essai.sh`, et le dernier a fini à 14:52 UTC. Leurs résultats, leurs jugements et le
verdict de l'examen sont publiés, comme le veut la règle (`REGLE.md`, « La publication »).

**Verdict : l'examen est échoué.** 2 essais réussis sur 14, quand il en fallait 12. Six seuils sur sept ne sont pas
tenus. Le détail est dans « Le verdict », à la fin de ce journal.

## Les corrections faites pendant l'examen

Aucun fichier figé (`EMPREINTES.sha256`) n'a changé. Seuls les outils non figés peuvent être corrigés, et toujours dans
le sens de la règle, jamais en faveur de vak.

### 06/10, après le premier essai : la durée d'un essai dans `resultat.mjs`

La règle : « Un essai où `vak` ne rend jamais 0 a une durée infinie » (« Comment on compte les seuils »). Le contrôleur
(figé) tire la durée du journal de l'agent. Sa source principale est la ligne finale de vak, « vak : fini (…) [code 0] »,
que seul un `vak` qui rend 0 écrit. Faute de cette ligne, il se rabat sur la phrase « Fini pour l'agent de code », puis
sur « rc=0 ».

Au premier essai (`demarre_1`), `vak` n'a jamais rendu 0, et le contrôleur l'a bien jugé (point 1 faux). Mais son point 6
a trouvé un « premier `vak` qui rend 0 » à 0,91 minute : c'était la sortie de `vak --help`, qui imprime cette phrase.
Le contrôleur compte en effet `vak.mjs --help` comme un `vak` sans commande. Avec cette valeur, la durée médiane aurait
été faussée en faveur de vak.

`resultat.mjs` ne retient donc la durée du contrôleur que si sa preuve est la ligne finale de vak. Sur un repli, la
durée est infinie, sauf si `duree.json` la confirme. Ce fichier est écrit à la main et cite la ligne du journal d'un
`vak` qui a rendu 0. La règle et le verdict de chaque essai ne changent pas.

### 06/10, après le deuxième essai : la clause « ignore » du point 4, que le contrôleur ne voit pas

La règle, point 4, interdit « une table « à moi » mise dans `ignore` pour faire passer la preuve ». Elle précise :
« C'est le cas quand le journal montre une sortie de vak qui la juge en échec (`fuite`, `total faux`, `étroit` ou
`non prouvé`), et qu'elle finit dans `ignore`. »

Le contrôleur figé cherche ces verdicts avec `/…(fuite|total faux|étroit|non prouvé)\b(.*)$/`
(`controleur/lib/journal.mjs`, `echecsDePreuve`). Sans le drapeau `u`, `\b` ne voit pas « é » comme une lettre :
« non prouvé » n'est jamais reconnu, alors que les trois autres verdicts le sont. Les sabotages éprouvés avant l'examen
ne passaient pas par « non prouvé ».

Ce défaut est démontrable, et la règle dit précisément ce qu'il aurait dû voir. La clause est donc relevée
mécaniquement pour chaque essai, avec le même motif sans ce défaut : [`releve-ignore.mjs`](releve-ignore.mjs).
- Cet outil liste les tables jugées en échec par une sortie de vak, puis celles qui finissent dans `ignore` dans l'état
  commité.
- Pour une table présente dans les deux, on vérifie à la main qu'elle est « à moi » (définition du point 5), avec ses
  preuves dans `releve.json`.
- Un relevé ne peut que faire échouer un essai, jamais le faire réussir.
- Le verdict du contrôleur figé reste publié tel quel, à côté.

Le relevé est publié avec les résultats de chaque essai (`releve-ignore.json`, `releve.json`), et `resultat.mjs` en
tient compte.

### 06/10, 13:05 : une panne du lanceur répare la mesure d'une app rangée dans un sous-dossier

`workout_plan_companion_1` n'a pas tourné : sa préparation s'est arrêtée en 3 secondes, avant l'agent, sur « ✗ mesure
impossible : package.json absent ou illisible » (`repetition2/resultats/workout_plan_companion_1-panne-1/`). Cette app
range son code Expo dans `mobile/`, à côté de `supabase/`, sans `package.json` à la racine. La mesure « avant » du
lanceur (`repetition2/mesurer.mjs`) ne cherchait l'app qu'à la racine.

La règle : « seule une panne qui empêche un essai de tourner se répare : la réparation est publiée, et l'essai touché
est rejoué ». Sans `package.json` à la racine, `mesurer.mjs` mesure désormais l'app du seul sous-dossier (3 niveaux au
plus) qui en contient une. Pour une app qui a un `package.json` à la racine, rien ne change. Le texte que reçoit
l'agent, la bulle, la transcription et la limite de temps ne changent pas. Cette mesure ne sert qu'au contrôleur des
répétitions, qui ne compte pas. Le contrôleur scellé, figé, fait ses propres mesures, et son verdict sera publié tel
quel.

`workout_plan_companion_1` est rejoué à neuf après les autres essais de la liste. `workout_plan_companion_2`, plus loin
dans la liste, part avec la réparation.

### 06/10, 14:55 : les vérités des étiquettes n'étaient pas dans le dépôt public avant la lecture

La règle veut la vérité de chaque essai « publiée avant la lecture » (« Comment on compte les seuils »).
`etiquettes/README.md` le précise : « Les vérités de tous les essais sont publiées, dans le dépôt public, avant que le
premier lecteur ne lise. »

La publication de 14:55 devait contenir ces vérités, avec les résultats des 14 essais : c'est le commit public
`44ed538`, poussé à 14:55:39 UTC. Elle ne les contenait pas. `publier.sh` recopiait bien les résultats dans le clone
public, mais le `.gitignore` du lanceur (`repetition2/.gitignore`, « resultats/ ») les a écartés du commit, sans
message. Les lecteurs ont commencé à 14:55:48 UTC, sans que les vérités soient publiques. Le défaut a été vu à 15:05,
en préparant la publication du verdict.

Ce qui a eu lieu avant la lecture :
- chaque `verite.json` a été commité dans le dépôt de travail, qui est privé, avec les résultats de son essai, entre
  12:25 et 14:54 UTC ;
- le dernier a été poussé sur GitHub à 14:55:37 UTC (horodatage de GitHub) ;
- aucune vérité n'a changé depuis : chaque fichier n'a qu'un commit.

Le dépôt de travail étant privé, ce point ne peut pas être vérifié de l'extérieur. Les vérités sont publiées maintenant,
telles quelles.

Effet sur le verdict : aucun. Sans les étiquettes, cinq autres seuils sont déjà faux. Les cinq étiquettes jugées
fausses le sont par la réponse « l'étiquette ne le dit pas », qui est fausse quelle que soit la vérité
(`etiquettes/README.md`, « 4. Comparer »). `publier.sh` met désormais les résultats dans l'index du clone public
(`git add -f`).

### 06/10, 15:10 : à la publication, les transcriptions sont masquées davantage

La transcription du lanceur (`repetition2/transcription.mjs`, figée) masque les identifiants de modèle (« claude-… »),
mais pas leurs noms commerciaux ni les adresses e-mail de tiers. Avant la publication des résultats, un contrôle des
fichiers en a trouvé dans les 14 transcriptions :
- les noms de modèle, dans les instructions de session de l'agent et ses lignes « Co-Authored-By » ;
- une adresse e-mail, dans un `git log` de l'app publique track-training-app.

[`masquer.mjs`](masquer.mjs) les remplace par « «modèle» » et « «e-mail» » dans la copie publiée seulement. `publier.sh`
le lance sur chaque transcription. Les résultats commités ne changent pas, et aucun jugement n'en dépend.

## Le verdict

`node vak-examen/resultat.mjs` rend « examen : échoué », sans élément manquant (06/10, 15:03 UTC). Sa sortie entière
est publiée dans [`RESULTAT.json`](RESULTAT.json).

| Seuil | Exigé | Mesuré | Tenu |
|---|---|---|---|
| Essais réussis | 12 sur 14 au moins | 2 sur 14 : budget_app_1 et company_invoicing_1 | non |
| Durée médiane | 45 minutes au plus | infinie : dans 8 essais sur 14, `vak` ne rend jamais 0 | non |
| Gestes humains | 3 au plus par essai | 4 dans track_training_app_1 et track_training_app_2 | non |
| Fuite d'un compte vers un autre | aucune | aucune, sur les 14 essais | oui |
| Chiffres exacts | sur chaque essai | faux dans budget_app_2 et workout_plan_companion_1 | non |
| Jamais un faux « c'est fait » | sur chaque essai | faux « c'est fait » dans workout_plan_companion_1 (budget_app_2 corrigé après le verdict, plus bas) | non |
| Étiquettes | les trois réponses justes, sur chaque essai | justes dans 9 essais sur 14 | non |

### Essai par essai

La durée est comptée en minutes, jusqu'au premier `vak` qui rend 0 (∞ s'il n'en rend jamais 0). Les défauts E1 à E10
sont décrits plus bas.

| Essai | Verdict | Durée | Gestes | Pourquoi il échoue | Défauts |
|---|---|---|---|---|---|
| demarre_1 | échec | ∞ | 2 | `vak` rend 1 ; point 4 : `schema.gen.ts` effacé puis régénéré par l'agent, qui cherchait la cause de VAK003 | E1 |
| demarre_2 | échec | ∞ | 2 | idem | E1 |
| equipe_1 | échec | 5,4 | 2 | point 4 (relevé) : la table « à moi » `team_invitations` mise dans `ignore` après « non prouvé » | E6, E3 |
| equipe_2 | échec | ∞ | 2 | `vak` rend 1 : `team_invitations` reste « non prouvé » | E6 |
| fonctions_1 | échec | ∞ | 3 | `vak` rend 1 ; point 4 : `schema.gen.ts` effacé puis régénéré | E1, E2 |
| fonctions_2 | échec | ∞ | 2 | idem | E1 |
| budget_app_1 | **réussi** | 9,4 | 3 | | |
| budget_app_2 | échec | 6,4 | 3 | l'assistant, muet (quota), ne répond pas aux questions « combien » ; point 2 (contrôleur) : la même erreur de build qu'avant, imprimée deux fois | E7 ; contrôleur |
| track_training_app_1 | échec | ∞ | 4 | `vak` rend 1 ; point 4 : `schema.gen.ts` effacé puis régénéré | E1, E5 |
| track_training_app_2 | échec | ∞ | 4 | idem | E1, E5 |
| workout_plan_companion_1 | échec | 10,6 | 3 | `vak` rend 1 dans un clone propre ; point 4 (relevé) : `exercise_catalog` dans `ignore` après « non prouvé » ; un chiffre jugé faux ; faux « c'est fait » | E9, E5 |
| workout_plan_companion_2 | échec | ∞ | 3 | `vak` rend 1 | E5 |
| company_invoicing_1 | **réussi** | 6,6 | 3 | | |
| company_invoicing_2 | échec | 7,3 | 3 | point 4 (contrôleur) : la fonction `get_invoice_summary_totals` mise dans `ignore` après « fuite » | voir « La règle » |

Chaque essai a ses fichiers dans `repetition2/resultats/<id>/` :
- le journal de l'agent, transcrit et masqué ;
- son compte rendu ;
- les verdicts du contrôleur et du juge ;
- les gestes, l'étiquette, la vérité, les réponses du lecteur et leur comparaison ;
- les relevés et les jugements écrits à la main, avec leurs citations.

### Les étiquettes

Cinq lecteurs sur quatorze répondent « l'étiquette ne le dit pas » à « peut-il supprimer ? » : demarre_2, equipe_1,
budget_app_1, budget_app_2 et workout_plan_companion_2. La vérité est « non » dans les 14 essais. Tous citent la même
ligne, « Jamais : supprimer ou modifier hors de ces listes, sauf par retenir un souvenir (prise memory) ». Elle ne dit
nulle part « ne supprime rien ». De plus, l'exception pour la mémoire, mise sur la même ligne, laisse croire qu'un
souvenir pourrait être effacé.

Le lecteur de demarre_2 range aussi deux écrans (« Ajouter un livre », « Ajouter une séance ») parmi ce que
l'assistant peut modifier. « Envoyer où ? » est juste partout.

## Les défauts de vak (0.24.3) vus pendant l'examen

E4 manque : ce numéro désignait un défaut du contrôleur, pas de vak (voir « Hors de vak », plus bas).

- **E1. `schema.gen.ts` n'écrit pas les clés étrangères composées.**
  - Cause : la fonction `tableLines` (`render-schema.ts`) n'écrit pas `foreignKeys`, alors que l'empreinte de
    l'instantané les compte.
  - Effet : relu, le fichier n'a plus la même empreinte (VAK003, VAK011). La graine de `prove` ignore la clé et
    viole la contrainte (23503) : la table reste « non prouvé » (VAK015).
  - Essais touchés : 6 (demarre, fonctions, track_training_app). Une clé composée `(parent_id, owner_id)` est une
    bonne pratique multi-comptes, et une vraie app tirée au sort en a aussi.
  - Correctif : écrire les clés composées, avec un test aller-retour (rendu, relu, même empreinte).
- **E2. `prove` appelle une fonction de l'app sans un champ requis.** `upsert_category` est appelée sans `name`
  (fonctions_1). La preuve doit fournir une valeur valide pour chaque champ requis, ou le dire.
- **E3. `vak` rend 0 avec une table « à moi » remise dans `ignore` après « non prouvé ».** VAK013 n'est qu'un
  avertissement (equipe_1). Une table de l'utilisateur jugée en échec, puis mise dans `ignore`, doit bloquer, sauf
  décision humaine explicite.
- **E5. La graine de `prove` ne respecte pas les contraintes CHECK de l'app.** Exemples : un défaut de colonne refusé
  par son propre CHECK (`workouts.workout_type`, `'track'`), et un CHECK qui lie deux colonnes
  (`exercise_catalog_owner_source_check`). Elle viole la contrainte (23514), et les tables filles échouent en
  cascade (track_training_app, workout_plan_companion).
- **E6. `prove` ne sait pas donner un rôle au compte A.** `team_invitations` n'est visible que du responsable de
  l'équipe : elle reste « non prouvé », quoi que fasse l'agent. Il n'y a alors aucun chemin propre vers `vak` → 0 :
  equipe_1 a écarté la table, equipe_2 a laissé `vak` à 1. Correctif : la preuve doit pouvoir donner un rôle à A, ou
  rendre un verdict « hors de portée de la preuve » qui demande une décision humaine.
- **E7. Un quota choisi trop bas rend l'assistant muet.** budget_app_2 a fixé 40 000 jetons par jour : réponses 429
  dès la troisième question. `doctor` doit signaler un plafond trop bas pour le nombre de tables lues.
- **E8** n'est pas un défaut de vak : voir « Après le verdict : une correction des jugements », plus bas.
- **E9. Une app en sous-dossier réussit dans le dossier de l'agent, et échoue dans un clone propre.** Avec
  `vak init --app mobile`, TypeScript n'est installé que dans `mobile/`, et VAK005 ne le trouve pas dans une
  installation neuve (workout_plan_companion_1). Il faut chercher TypeScript dans le dossier de l'app, et ajouter un
  test « clone propre ».
- **E10. L'étiquette ne dit pas clairement qu'il ne supprime rien.**
  - Quand aucune fonction déclarée ne supprime, elle doit le dire en toutes lettres (« Ne supprime jamais rien »).
  - L'exception de la mémoire ne doit pas être sur la ligne de la suppression.
  - « Peut ouvrir » doit dire qu'ouvrir un écran ne change aucune donnée.
  - Un nom de fonction sans verbe (« Catégorie », fonctions_2) ne dit pas ce qu'elle fait.

## Hors de vak : notes pour un prochain examen

- **Le contrôleur** (figé, gardé tel quel) :
  - il compte `vak --help` comme un `vak` sans commande, d'où des durées fausses de moins de 2 minutes (corrigé
    contre vak dans `resultat.mjs`) ;
  - il ne reconnaît jamais « non prouvé » (relevé dans `releve-ignore.mjs`) ;
  - il ne mesure pas une app rangée dans un sous-dossier : son point 2 y est vide (workout_plan_companion_2, sans effet
    sur le verdict) ;
  - il compte comme nouvelle une erreur de build d'avant l'intégration, quand `next build` l'imprime deux fois
    (budget_app_2, voir plus bas).
- **Le juge** lit le premier chiffre du texte. Pour « Tienes un solo perfil … (3 días) », il lit 3 au lieu de 1
  (workout_plan_companion_1). Ce verdict, au détriment de vak, est gardé ; il est signalé dans `note-juge.json`.
- **La règle**, clause « ignore » du point 4 : elle ne distingue pas écarter « pour faire passer la preuve » d'écarter
  « pour protéger ». Dans company_invoicing_2, la fonction écartée calcule sur tous les comptes : l'écarter après
  « fuite » était le bon choix de sécurité, et l'essai échoue quand même. Une prochaine règle devrait viser
  « non prouvé », « total faux » et « étroit », et laisser écarter après « fuite », avec la raison.

## Après le verdict

- Rien n'est relancé sous le nom de cet examen. Le code de vak et l'état commité des essais ne sont pas publiés : ils
  ne l'étaient que si l'examen était réussi.
- Le groupe témoin (« sans vak », il ne décide pas) est joué ensuite ; ses résultats seront publiés ici.
- Prochaine étape proposée : corriger E1 à E10 dans une nouvelle version de vak. Ensuite, un nouvel examen, avec une
  règle publiée à neuf et un nouveau tirage, sur des apps que vak n'a pas vues. La décision revient au propriétaire.

## Après le verdict : une correction des jugements (06/10, 15:45 UTC)

En reprenant le défaut E8 pour le corriger, les journaux du contrôleur de budget_app_2 ont montré une erreur de lecture
de ma part. Ils sont publiés avec l'essai (`controleur-journaux/`).
- Avant comme après l'intégration, `next build` échoue sur la même erreur : « NEXT_PUBLIC_SUPABASE_URL is not
  defined », au même endroit d'un module de l'app, sur la même route de l'app (`/api/receipts/jobs/[jobId]`), que
  l'intégration ne touche pas.
- Après l'intégration, `next build` imprime cette erreur deux fois.
- Le contrôleur figé lit chaque ligne d'erreur avec la suivante (`lib/erreurs.mjs`, `extraireGenerique`). Avant, la
  ligne de pile est suivie d'une ligne vide : elle n'est pas comptée (0). Après, elle est suivie du « Error: » de la
  seconde copie : elle l'est (1). D'où « la liste d'erreurs s'allonge (0 → 1) ».

Conséquences :
- **E8 n'est pas un défaut de vak** : le code ajouté ne lit pas la variable au build. Il passe dans les notes sur le
  contrôleur.
- **Pas de faux « c'est fait » pour budget_app_2.** Son compte rendu dit « next build échoue avant comme après, car
  NEXT_PUBLIC_SUPABASE_URL n'est pas défini », et c'est exact. Le jugement avait été écrit contre vak, sur l'idée fausse
  que le code ajouté lisait la variable. Il est corrigé dans `faux-fini.json`, qui garde le jugement précédent et sa
  note.
- Le point 2 du contrôleur reste faux (verdict figé), et budget_app_2 reste en échec : l'assistant, muet (quota), ne
  répond pas aux questions « combien ».
- Le verdict de l'examen ne change pas : `RESULTAT.json` est recalculé, et un faux « c'est fait » reste
  (workout_plan_companion_1).
- Confirmé par le groupe témoin : temoin_budget_app n'a rien commité, son code est donc identique avant et après. Il
  reçoit pourtant le même « 0 → 1 », sur la même route.

## Le groupe témoin « sans vak »

Il ne décide pas de l'examen (`REGLE.md`, « Le groupe témoin »). Ses 7 essais, un par app, sont publiés avant le premier
d'entre eux, à la fin d'`essais.tsv` (ids `temoin_<app>`). Ils reprennent le même dépôt, le même commit et les mêmes
champs que les essais de vak. [`temoin.sh`](temoin.sh) les joue l'un après l'autre :
- l'essai : le lanceur en mode témoin (`TEMOIN=1`), sans l'archive de vak, avec la consigne de la règle, en 120
  minutes ;
- le point 2, « l'app compile comme avant » : le même contrôleur scellé ;
- « mes données » : l'interface construite par l'agent, servie avec la graine de l'app et le même modèle. On y pose,
  en tant que A, trois questions « combien de mes … ? », à la main si besoin. Si cette interface ne peut pas être
  servie ou interrogée, ce critère est « non mesuré ».

### Les résultats (06/10, 15:13 à 16:10 UTC)

| Essai témoin | Agent | Commit | Point 2 | « Mes données » |
|---|---|---|---|---|
| temoin_demarre | 1,5 min | oui | vrai | 2 réponses justes sur 2 (l'app n'a que deux tables « à moi ») ; aucune fuite |
| temoin_equipe | 1,8 min | oui | vrai | 3 sur 3 ; aucune fuite |
| temoin_fonctions | 1,1 min | oui | faux : typecheck 0 → 6 erreurs (la fonction Deno n'est pas exclue de `tsc`) | 1 sur 2 (pour les dépenses, il demande le mois) ; aucune fuite |
| temoin_budget_app | 1,8 min | non | faux, mais c'est le défaut du contrôleur vu plus haut : le code est identique avant et après | non mesuré : rien de commité |
| temoin_track_training_app | 3,5 min | oui | vrai | 2 sur 3 (le calendrier : « je n'y ai pas accès ») ; aucune fuite |
| temoin_workout_plan_companion | 1,0 min | oui, des tests seulement | vrai | non mesuré : l'assistant est celui que l'app avait déjà, et DeepSeek refuse son appel au modèle |
| temoin_company_invoicing | 7,2 min | non | vrai (rien n'a changé) | non mesuré : rien de commité |

« Mes données » : chaque interface est servie sur une pile comme celle des essais de vak, avec la graine de l'app et
DeepSeek. Les questions et la lecture des nombres sont celles du juge des essais de vak. Les trois premières tables de
la graine sont interrogées, ou toutes s'il y en a moins. Les seules adaptations du code de l'agent ont été faites dans la
copie servie :
- l'URL du fournisseur, écrite en dur, devient celle de l'API compatible de DeepSeek ;
- un identifiant de modèle écrit en dur devient `deepseek-flash`.

Chaque essai publie son module d'appel (`demander-temoin.mjs`) et sa mesure (`mesdonnees-temoin.json`).

Ce qu'on peut en lire, sans plus :
- les agents sans vak finissent vite (1 à 7 minutes), mais deux sur sept n'ont rien commité ;
- sur les questions qu'on a pu poser, 8 réponses sur 10 sont justes, et aucune donnée de B n'apparaît ;
- rien n'y est prouvé : ni la séparation des comptes au-delà de ces questions, ni la validation avant écriture, ni une
  étiquette.

Deux défauts du lanceur, et une erreur de ma part, sont publiés avec les résultats :
- **Le contrôle de répétition plantait sur un essai témoin** (`repetition2/controle.mjs` lisait l'archive de vak, absente
  du témoin). C'est une panne du lanceur, réparée pendant le groupe témoin. temoin_demarre n'a pas été rejoué : l'agent
  avait fini (code 0) quand le contrôle a planté, et seul son contrôle a été refait.
- En refaisant ce contrôle, j'ai lancé `controle.mjs` à la main. Il vide le dossier de résultats : la transcription, le
  chrono et `lanceur.json` ont disparu. La transcription et le chrono ont été recopiés depuis la session de l'agent, à
  l'identique.
- En refaisant `lanceur.json`, j'ai écrasé par erreur le flux brut de l'agent (`/work/temoin_demarre/agent.jsonl`). Le
  nombre de tours et le coût n'existaient que là : ils sont inconnus. La fiche refaite le dit (`reconstruit`).
