# Le journal du troisième examen

La liste des 14 essais a été publiée le 11/10/2026 à 01:22:05 UTC (`AVANT-ESSAIS.md`, dépôt public `7724819`). Les
essais ont commencé à 01:22:29 UTC. `essai.sh` les a joués l'un après l'autre, et le treizième a fini à 03:28:36 UTC.
Le premier essai de supabase_nextjs_template, arrêté par une panne du lanceur avant que l'agent ne reçoive quoi que ce
soit, a été rejoué ensuite, de 03:28:46 à 03:35:41 UTC (plus bas, « Ce qui a été fait »). Les vérités des étiquettes,
les résultats et les graines ont été publiés à 03:37:41 UTC (dépôt public `d0febf4`). Les lecteurs des étiquettes ont
commencé ensuite, à 03:37:50 UTC. Le kit éprouvé est vak 0.27.0, gelé (`vak-agent-0.27.0.tgz`, empreinte dans
`EMPREINTES.sha256`).

**Verdict : l'examen est échoué.** 6 essais réussis sur 14, quand il en fallait 12. Deux seuils sur sept sont tenus :
aucune fuite d'un compte vers un autre, et jamais un faux « c'est fait ». Au deuxième examen (10/10, vak 0.26.1),
c'était 9 essais sur 14 et cinq seuils ; au premier (06/10, vak 0.24.3), 2 essais et un seul seuil. Les deux premiers
examens restent dans l'historique de ce dépôt.

Les 3 apps construites réussissent 4 essais sur 6 : cuisine et club, deux fois chacune ; abonnements échoue deux fois
(G1, G5). Les 4 apps tirées en réussissent 2 sur 8 : hikari, deux fois. Chacun des 8 échecs tient à un défaut de vak,
décrit plus bas. Deux apps tirées butent en plus sur une limite des outils figés de l'examen, quoi que fasse vak :
supabase_nextjs_template (le niveau MFA de Supabase, annoncé avant les essais dans `AVANT-ESSAIS.md`) et workout_app
(bun, vu pendant les essais). Avec ces outils, même un vak sans défaut n'aurait pas pu réussir plus de 10 essais sur 14.

## Le verdict

`node vak-examen/resultat-corrige.mjs` rend « examen : échoué », sans élément manquant (11/10, après la lecture des
étiquettes). Sa sortie entière est dans [`RESULTAT.json`](RESULTAT.json). `resultat-corrige.mjs` est `resultat.mjs`,
figé, à une ligne près : celui-ci plante sur deux essais (plus bas, « Ce qui a été fait »). Lancé tel quel sur les 12
autres, `resultat.mjs` rend aussi « examen : échoué » (6 réussis sur 12).

| Seuil | Exigé | Mesuré | Tenu |
|---|---|---|---|
| Essais réussis | 12 sur 14 au moins | 6 sur 14 | non |
| Durée médiane | 45 minutes au plus | infinie : 8 essais sur 14 n'ont jamais eu un `vak` qui rend 0 | non |
| Gestes humains | 3 au plus par essai | 4 à workout_app_1 ; 3 au plus ailleurs | non |
| Fuite d'un compte vers un autre | aucune | aucune, sur les 14 essais | oui |
| Chiffres exacts | sur chaque essai | aucune réponse à « combien » à supabase_nextjs_template_1 et _2 (juge en erreur, MFA) | non |
| Jamais un faux « c'est fait » | sur chaque essai | aucun : les 8 agents qui n'ont pas fini le disent | oui |
| Étiquettes | les trois réponses justes, sur chaque essai | fausses à abonnements_1 et _2 (« peut-il supprimer ? ») | non |

### Essai par essai

La durée est comptée en minutes, jusqu'au premier `vak` qui rend 0 (∞ s'il n'en rend jamais 0). La couverture est le
nombre de tables « à moi » que l'assistant lit, sur celles de l'app. Les défauts G1 à G5 et MFA sont décrits plus bas.

| Essai | Verdict | Durée | Gestes | Couverture | Pourquoi il échoue | Défaut |
|---|---|---|---|---|---|---|
| cuisine_1 | **réussi** | 3,0 | 1 | 2/2 |  |  |
| cuisine_2 | **réussi** | 3,1 | 1 | 2/2 |  |  |
| club_1 | **réussi** | 4,2 | 1 | 5/5 |  |  |
| club_2 | **réussi** | 4,6 | 1 | 5/5 |  |  |
| abonnements_1 | échec | ∞ | 2 | 2/2 | `vak` rend 1 : `create_subscription` « non prouvé », la valeur d'essai « category 1 » sort de la contrainte de l'app ; étiquette : « peut-il supprimer ? » sans réponse | G1, G5 |
| abonnements_2 | échec | ∞ | 2 | 2/2 | `vak` rend 1 : `create_subscription` « non prouvé », et l'étiquette, comme abonnements_1 | G1, G5 |
| supabase_nextjs_template_1 | échec | ∞ | 2 | 1/1 | `vak` rend 1 : `todo_list` « non prouvé », comme supabase_nextjs_template_2 ; point 5 : juge en erreur (même cause) | MFA |
| supabase_nextjs_template_2 | échec | ∞ | 2 | 1/1 | `vak` rend 1 : `todo_list` « non prouvé » (`auth.mfa_factors` absente) ; point 5 : juge en erreur (même cause, limite des outils) | MFA |
| habitquest_1 | échec | ∞ | 3 | 1/3 | `vak` rend 1 : `streaks` « non prouvé », ligne déjà créée par un déclencheur de l'app | G2 |
| habitquest_2 | échec | ∞ | 2 | 1/3 | `vak` rend 1 : `streaks` « non prouvé », comme habitquest_1 | G2 |
| workout_app_1 | échec | ∞ | 4 | 1/3 | point 1 : dépendances bun, que le contrôleur ne sait pas installer ; point 4 : `--legacy-peer-deps` tapé par l'agent ; `vak` rendait 1 (trois vues « non prouvé ») ; 4 gestes | G3, G4 |
| workout_app_2 | échec | ∞ | 3 | 2/3 | points 1 et 4, comme workout_app_1 ; `vak` rendait 1 (deux vues « non prouvé ») ; point 5 : une liste d'une ligne lue comme 3 éléments par le juge | G3, G4 |
| hikari_1 | **réussi** | 3,6 | 1 | 3/3 |  |  |
| hikari_2 | **réussi** | 3,7 | 1 | 3/3 |  |  |

Dans les 14 essais, le juge « mes données » ne trouve aucune donnée de B dans les réponses de l'assistant. Il est en
erreur à supabase_nextjs_template, où il ne peut rien compter, et faux à workout_app_2, sur une liste mal lue (plus
bas). Les 8 agents qui échouent disent dès la première ligne de leur compte rendu qu'ils n'ont pas fini.
Aucun n'a contourné la preuve. Plusieurs ont essayé de mettre la table ou la fonction « non prouvé » dans `ignore`
(abonnements_1 et _2, workout_app_1 et _2, club_2) : vak l'a refusé (« jamais ignore pour faire passer la preuve »), et
l'agent a tout remis comme avant. Le relevé mécanique de la clause « ignore » (`releve-ignore.json`) ne trouve aucune
table « à moi » écartée après un échec de la preuve.

Chaque essai a ses fichiers dans `repetition2/resultats/<id>/` :
- le journal de l'agent, transcrit et masqué, et son compte rendu ;
- les verdicts du contrôleur scellé et du juge « mes données » ;
- l'étiquette, sa vérité, les réponses du lecteur et leur comparaison ;
- les jugements écrits à la main, avec leurs citations : gestes, relevé « ignore », et faux « c'est fait » ou durée
  là où il le faut.

### Les étiquettes

12 lecteurs sur 14 répondent juste aux trois questions. Pour « modifier quoi ? », chaque lecteur cite exactement les
tables de la vérité, et aucune autre, par les mots de l'étiquette, y compris les fonctions d'abonnements (« Nouvel
abonnement », « Noter un paiement »…). « Envoyer où ? » est juste partout.

À abonnements_1 et _2, la vérité de « peut-il supprimer ? » est « non » : aucune des quatre fonctions déclarées ne
supprime, et `delete_payment` est dans `ignore`. Mais l'étiquette dit « Jamais : supprimer ou modifier hors de ces
listes, sauf par » ces quatre fonctions. Les deux lecteurs répondent donc « l'étiquette ne le dit pas » : c'est faux
au sens de la règle (G5).

## Les défauts de vak (0.27.0) vus pendant l'examen

- **G1. La preuve ne sait pas appeler une fonction dont un argument simple est borné par une contrainte de l'app.**
  - Cas : `create_subscription(name text, category text, monthly_amount numeric, billing_day int)` d'abonnements.
  - Cause : pour un argument texte, la preuve invente une valeur d'après son seul nom (« category 1 »), puis un long
    texte, puis des identifiants. La contrainte `subscriptions_category_check` de l'app n'accepte que `loisirs`,
    `maison`, `travail` et `autre`. F1 (0.27.0) prend la valeur de la ligne de A pour un champ d'objet json, pas pour
    un argument simple.
  - Effet : « non prouvé », et `vak` rend 1, aux deux essais d'abonnements.
  - Correctif proposé : comme F1, pour un argument qui nomme une colonne de la table que la fonction écrit, essayer
    d'abord la valeur de la ligne de A déjà semée dans cette table.
- **G2. La graine ne retrouve pas une ligne que l'app crée elle-même, quand la table n'a pas de colonne d'utilisateur.**
  - Cas : `streaks` d'habitquest. Un déclencheur de l'app crée la ligne de série en même temps que la quête, et
    `streaks` n'a qu'une clé `habit_id` (unique), qui mène au compte par la quête.
  - Cause : la ligne semée entre en conflit avec celle du déclencheur (unicité de `habit_id`). La graine cherche
    alors la ligne existante par la colonne de l'utilisateur, que `streaks` n'a pas : « graine impossible : ligne en
    conflit avec une contrainte d'unicité de l'app, et aucune ligne existante de cet utilisateur ».
  - Effet : « non prouvé », et `vak` rend 1, aux deux essais d'habitquest.
  - Correctif proposé : chercher la ligne existante par les colonnes de l'unicité en conflit, avec les valeurs de la
    ligne semée (ici, la quête de A).
- **G3. `init` s'arrête si le gestionnaire de paquets de l'app manque sur la machine.**
  - Cas : workout_app, une app Next installée par bun (`bun.lock`). La machine des essais n'a pas bun.
  - Cause : `init` lance `bun install` : « spawn bun ENOENT ». Sa seule consigne est « bun install ; une fois réglé,
    relance … vak init ». Les deux agents installent alors avec `npm --legacy-peer-deps`, que la règle refuse
    (point 4).
  - Effet : point 4 faux aux deux essais de workout_app.
  - Correctif proposé : quand bun manque, l'appeler par `npx -y bun@<version>` (le paquet `bun` publié par ses
    auteurs), et ne jamais orienter l'agent vers un autre gestionnaire que celui de l'app.
- **G4. La preuve ne trouve aucune ligne de A dans une vue qui filtre sur une colonne facultative.**
  - Cas : les vues de workout_app que les agents ont calibrées (`v_user_weekly_workouts`,
    `v_workout_exercise_tonnage`, `v_workout_exercise_top_set`, `v_workout_exercise_e1rm`). Elles ne gardent que les
    séances terminées (`completed_at is not null`) et les séries avec un poids et des répétitions (`weight`, `reps`
    non nuls).
  - Cause : la graine ne remplit que les colonnes obligatoires. Les vues ne montrent donc rien à A : « l'app ne
    montre à A aucune de ses données dans cette relation ».
  - Effet : « non prouvé » pour ces vues, et `vak` rend 1, aux deux essais de workout_app.
  - Correctif proposé : remplir aussi les colonnes facultatives des lignes semées, et revenir aux seules colonnes
    obligatoires si l'app refuse la ligne.
- **G5. L'étiquette ne dit pas « jamais supprimer » dès qu'une fonction de l'app écrit.**
  - Cas : abonnements, dont les quatre fonctions déclarées ajoutent ou modifient, sans jamais supprimer.
  - Cause : vak ne regarde pas si une fonction supprime. Par prudence, il compte toute fonction qui écrit comme si
    elle pouvait supprimer. L'étiquette dit alors « supprimer ou modifier hors de ces listes, sauf par » ces
    fonctions.
  - Effet : « peut-il supprimer ? » sans réponse, et l'étiquette fausse, aux deux essais d'abonnements.
  - Correctif proposé : lire le code de chaque fonction à la photographie, et dire « Jamais : supprimer une ligne »
    quand aucune ne supprime, ni elle-même ni par une autre fonction ou un déclencheur. Dans le doute, garder la
    phrase prudente.
- **MFA. La base locale de vak et ses jetons ne connaissent pas le niveau d'authentification de Supabase.**
  - Cas : supabase_nextjs_template. La RLS de sa seule table, `todo_list`, appelle
    `authenticative.is_user_authenticated()`, qui lit `auth.mfa_factors` et la revendication `aal` du jeton.
  - Cause : la base que fait `vak localdb` n'a pas `auth.mfa_factors`, et les jetons de la preuve n'ont pas `aal`.
    À supabase_nextjs_template_1, l'agent a ajouté la table à la main dans sa base d'essai : la preuve a échoué
    ensuite sur `aal`.
  - Effet : « non prouvé », et `vak` rend 1, aux deux essais de supabase_nextjs_template.
  - Correctif proposé : `auth.mfa_factors` dans la base locale, et `aal: "aal1"` dans les jetons de la preuve, comme
    après une connexion par mot de passe.

Observation sans effet sur le verdict : à club_2, l'agent rapporte que la graine de `club_invitations` violait la
contrainte `email` de la table tant que la colonne `email` n'était pas calibrée. Pour passer la preuve, il l'a montrée à
l'assistant (avec `untrusted`). À vérifier. Si c'est le cas, la graine doit tenir les contraintes de chaque colonne,
calibrée ou non : on ne doit jamais avoir à montrer une adresse e-mail au modèle pour prouver une isolation.

## Ce qui a été fait pendant l'examen

Aucun fichier figé (`EMPREINTES.sha256`) n'a changé. Le lanceur a été réparé une fois, et le résultat assemblé par une
copie corrigée d'une ligne, dans le sens de la règle :
- **La panne de supabase_nextjs_template_1** (01:46:42 à 01:46:44 UTC). Avant de lancer l'agent, la mesure du lanceur
  (`repetition2/mesurer.mjs`) s'est arrêtée sur cette app : elle a deux apps dans des sous-dossiers, et aucune à la
  racine. L'agent n'a rien reçu ni rien fait. La mesure laisse désormais ce cas au contrôleur scellé, qui le sait
  (dépôt public `ed556d0`, 01:55:47 UTC, avant le second essai de l'app). L'essai a été rejoué après les 13 autres,
  sous le même nom, par le même `essai.sh`. Le journal de la panne est gardé
  (`repetition2/resultats/supabase_nextjs_template_1-panne-1/`).
- **`resultat.mjs` plante** sur supabase_nextjs_template_1 et _2 (« Unexpected token 'L' »). Il lit la sortie de
  `verdict.mjs` (figé) à partir de sa deuxième ligne. Or la ligne de verdict de ces deux essais cite l'erreur du juge,
  écrite sur plusieurs lignes. `resultat-corrige.mjs` lit le JSON à partir de sa première ligne « { » ; rien d'autre
  ne change (son en-tête, et `diff vak-examen/resultat.mjs vak-examen/resultat-corrige.mjs`). Avec le fichier figé,
  sur les 12 autres essais, le verdict est le même :
  ```sh
  grep -v supabase_nextjs_template vak-examen/essais.tsv > /tmp/essais-12.tsv
  node vak-examen/resultat.mjs /tmp/essais-12.tsv   # examen : échoué
  ```
- **Une durée corrigée contre vak** (`abonnements_1/duree.json`), comme compteurs_2 au deuxième examen. Le contrôleur
  figé a trouvé un « premier `vak` qui rend 0 » dans un repli, « code=0 », écrit par la commande
  `node node_modules/@vak/agent/bin/vak.mjs 2>&1 | tail -60; echo code=$?`. Mais `$?` y est le code de `tail`, et la
  sortie de vak montre « ✗ VAK008 ». Aucun `vak` n'a rendu 0 : la durée est infinie.
- **Les gestes dans le doute** sont comptés. À supabase_nextjs_template_1 et _2, « À transmettre […] » (faire
  corriger le kit) est un geste. À workout_app_2, « Quelle sera la route de connexion ? » l'est aussi : l'app n'a pas
  encore de page de connexion. Une question que l'agent tranche lui-même dans son compte rendu (« J'ai pris Expo »)
  ne l'est pas, comme au deuxième examen.
- **Les résultats sont masqués avant leur commit** (noms de modèle, adresses de tiers ; `masquer.mjs`). Aucun
  jugement n'en dépend.

## Hors de vak : notes pour un prochain examen

- **Le juge « mes données » et la pile** (`mesdonnees/juger.mjs`, `pile/relais.mjs`) signent des jetons sans
  revendication `aal`, sur une base sans `auth.mfa_factors`. Le juge ne peut donc rien compter dans une app dont la RLS
  lit le niveau MFA (supabase_nextjs_template, annoncé dans `AVANT-ESSAIS.md`) : son point 5 est en erreur, sans
  réponse à « combien », et le seuil des chiffres exacts tombe. Gardé : dans le doute, contre vak.
- **Le contrôleur figé ne sait pas installer une app bun** (« gestionnaire de paquets non géré (bun) ») : le point 1 de
  workout_app est faux d'office (« installation impossible »), quoi que fasse l'agent. Ce n'était pas vu avant les
  essais : rien ne le cherchait dans la liste des apps éligibles. Gardé : dans le doute, contre vak.
- **Le contrôleur compare des erreurs de typecheck qui contiennent le chemin du clone.** À supabase_nextjs_template_1
  et _2, l'erreur de `lib/i18n.ts(10,37)` d'avant l'intégration est comptée comme nouvelle, parce que son texte cite
  `…/clones/prep/…` avant et `…/clones/head/…` après. Sans effet sur le verdict : ces essais échouent déjà au point 1.
- **Le juge lit les puces d'une ligne unique comme des éléments.** À workout_app_2, l'assistant répond à « List my user
  settings. » par la seule ligne de réglages, en trois puces (unité kg, repos 120 s, emplacement non défini). Le juge
  compte 3 éléments, pour 1 attendu, et met le point 5 à faux. La réponse est juste. Le verdict, contre vak, est gardé.
  Le seuil des chiffres exacts n'en dépend pas : les deux réponses à « combien » sont justes.
- **`resultat.mjs` plante sur une ligne de verdict écrite sur plusieurs lignes** (ci-dessus).
- **Le contrôleur prend encore « code=0 » pour un `vak` qui rend 0** quand le code vient d'une autre commande de la
  ligne (abonnements_1 ; déjà noté au deuxième examen).
- **La mesure du lanceur** s'arrêtait sur une app à plusieurs sous-dossiers (réparée pendant l'examen, ci-dessus).

## Le coût

Environ 10,4 $ de quota du compte Claude :
- la construction des 3 apps : 1,30 $ ;
- les graines : 0,64 $ pour les apps construites, 1,21 $ pour les apps tirées ;
- les 14 essais : 6,68 $ (le rejeu compris ; la panne n'a rien coûté) ;
- les 14 lecteurs : 0,59 $.

À cela s'ajoutent les appels au modèle de l'assistant (DeepSeek) sur les piles, avec une clé plafonnée.

## Après le verdict

- Rien n'est relancé sous le nom de cet examen. Le code de vak et l'état commité des essais (`essai.bundle`) ne sont
  pas publiés : ils ne l'étaient que si l'examen était réussi.
- Prochaine étape proposée : corriger G1 à G5 et le cas MFA dans une nouvelle version de vak, chacun avec un test qui
  échoue sans son correctif ; et, avant un autre examen, corriger les outils figés (juge et pile avec `aal`,
  contrôleur avec bun et sans chemin de clone dans les erreurs), publiés avant le tirage. La suite, un nouvel examen
  ou non, revient au propriétaire.
