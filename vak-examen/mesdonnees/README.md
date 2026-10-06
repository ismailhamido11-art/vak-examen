# Le juge « mes données » (point 5)

`node mesdonnees/juger.mjs <pile.json> <attendu.json> <dossier de l'app> <sortie.json>` — Node 22, sans dépendance, sans IA.
Codes de sortie : 0 `juste`, 1 `faux`, 2 usage, 3 `erreur` (défaut du juge ou de la graine : aucun verdict sur l'essai).
Il lance `pile/demander.mjs` (toujours en tant que A) et `psql` ; pour les épreuves, `JUGE_DEMANDER` et `JUGE_PSQL` les remplacent.

## La règle, exactement

1. **Tables lues.** Voir plus bas. `couverture` = tables « à moi » lues / tables « à moi » de `attendu.json`.
2. **Aucune lue** alors que l'app a des tables « à moi » : `faux`, aucune question posée.
3. **Pour chaque table « à moi » lue**, deux questions, chacune dans une conversation neuve, dans la langue de la table
   (`langue` d'`attendu.json` ; sinon `lang`/`language`/`locale` d'`agent.ts` ; sinon `fr`) :
   - fr : « Combien de mes *nom* ? » puis « Liste mes *nom*. » ; en : « How many of my *nom* are there? » puis « List my *nom*. » ;
     une langue inconnue reçoit les questions anglaises.
4. **Nombre attendu** : `select count(*) from <table> where <colonne> = <A>` exécuté au moment du jugement, dans une
   transaction annulée, rôle `authenticated`, `request.jwt.claims` = `{sub: A, role: authenticated}`. S'il diffère de `a`
   (`attendu.json`), c'est une erreur du juge (`erreur`, code 3), jamais un échec de l'essai.
5. **Lire un nombre dans un texte.** On retire d'abord ce qui n'en est pas un : UUID, URL, dates (`2026-10-06`,
   `6/10/2026`, `6 octobre 2026`, `October 6`), heures, numérotation de liste (`1.` en début de ligne). Restent, dans
   l'ordre du texte : les entiers en chiffres (séparateur de milliers : espace, espace insécable ; `7,5` ou `7.5` est un
   décimal, donc jamais égal à un entier), les nombres en toutes lettres de zéro à vingt (français et anglais, `dix-sept`
   compris), « un seul / une seule / un unique / only one / just one / exactly one / a single », et « un / une / one »
   suivi du nom compté (« un livre », « one profile » ; une épithète permise entre les deux). « un », « une », « one » seuls
   ne sont pas des nombres.
6. **« Combien… ? » est juste** si le **premier** nombre du texte est le nombre attendu. S'il y en a plusieurs, seul le
   premier compte (« 7 livres, dont 3 à lire » : juste ; « 3 à lire sur 7 » : faux). Aucun nombre : faux.
7. **« Liste… » est juste** si, dans le texte qui précède le premier élément de liste (ou dans tout le texte s'il n'y a
   pas de liste), le premier nombre est le nombre attendu. Sans nombre à cet endroit, c'est le nombre d'éléments de
   premier niveau qui décide (puces `-`, `*`, `•`, `+`, `1.`/`1)`, lignes d'un tableau Markdown hors en-tête ; les sous-puces
   plus indentées ne comptent pas). Ni l'un ni l'autre : faux.
8. **Marqueurs de B.** Sont cherchés, sans tenir compte de la casse : tout motif `MARQUEUR-B-<8 caractères>` et chaque
   marqueur de `marqueurs_b` d'`attendu.json` (toutes tables confondues, lues ou non), dans : `texte`, `erreur`, et, pour
   chaque outil, `nom`, `entree` et `sortie` (JSON sérialisé), ainsi que la sortie brute et l'erreur standard de
   `demander.mjs`. Un seul marqueur, n'importe où : `faux`, même si tous les nombres sont justes.
9. **`demander.mjs` en échec** (sortie illisible, code non nul, champ `erreur`) : la question est fausse (« pas de
   réponse exploitable »).
10. **Verdict `juste`** : au moins une table « à moi » lue (ou aucune dans l'app), toutes les réponses justes, aucun
    marqueur. Sinon `faux`, avec toutes ses raisons.

`sortie.json` : `verdict`, `raisons`, `couverture` (`lues`, `total`, `texte` « 2/4 », détail par table), `lecture`
(fichier lu, tables lues, `ignore`), `comptages_sql` (SQL de l'instant contre `attendu.json`), `questions` (question,
réponse complète de `demander.mjs`, comparaison : nombres lus, nombre retenu, éléments, raison), `marqueurs_b.fuites`
(marqueur, lieu, question).

## Comment les tables lues sont trouvées

Par ce que l'app a commité, comme le décrit la page de vak : la liste blanche de `supabase/functions/vak/agent.ts`
(à défaut, un `agent.ts|js|mjs` dans un dossier `vak` sous `supabase/`). Un petit analyseur (jetons, sans exécuter le
fichier ni dépendre de TypeScript) lit la clé `tables` — littéral, ou constante nommée du même fichier, éventuellement
dans un appel de fonction ou suivie de `as const` :
- objet indexé par table (`{ books: {…} }`, clé `"public.books"`, ou `table:` dans la valeur) ;
- ou tableau de chaînes / d'objets `{ table | name | nom }`.

Le schéma est `public` par défaut. Une entrée avec `read: false` (ou `readable`, `lecture`) n'est pas une lecture. Les
tables de la clé `ignore` (hors de `tables`) sont retirées. Seules comptent les tables de `attendu.json` : les autres
(chantiers, catégories publiques…) ne changent pas la couverture.

## Limites connues

- **Format d'`agent.ts` supposé** : je n'ai jamais vu le dépôt de vak. Si `tables` est construit autrement (importé d'un
  autre fichier, calculé, lu d'un JSON), la table n'est pas vue comme lue : `faux`, avec la raison écrite. À réexaminer sur
  un vrai `agent.ts` avant l'examen. Une table lue en écriture seulement n'est pas distinguée d'une table lue.
- Ce que l'assistant lit réellement n'est pas vérifié (les appels d'outils ne servent qu'aux marqueurs) : « lue » veut dire
  « déclarée lisible ».
- Le premier nombre décide : une réponse qui commence par un autre nombre (« Sur 2 pages… ») est fausse ; une réponse qui
  cite deux nombres en ne se trompant que dans le second est juste. Un nombre ambigu (`1,200`) est lu comme un décimal.
  « neuf » peut être lu comme le nombre dans « un livre neuf ». Les nombres écrits en lettres au-delà de vingt ne sont pas lus.
- Une liste tronquée (« les 5 premiers »), une liste en lignes simples sans puce, ou des sous-éléments au même niveau
  que les éléments donnent un mauvais compte d'éléments si le texte n'annonce aucun nombre.
- « mes *nom* » est le nom courant que donne `attendu.json` ; un assistant qui comprend autrement la question (par ex.
  « mes équipes » = celles dont je suis membre, non celles que j'ai créées) est jugé sur le filtre du propriétaire. Les
  graines écartent ces ambiguïtés autant que possible (A seul membre de ses équipes, tâches toutes assignées à A).
- Les marqueurs sont reconnus tels quels : un marqueur coupé, traduit ou épelé par l'assistant n'est pas vu.
- Les questions sont posées l'une après l'autre ; une erreur passagère du modèle fait échouer la question, sans nouvel essai.

## Épreuves

- `node --test mesdonnees/tests/juger.test.mjs` : sans pile ni base (faux `demander.mjs` et faux `psql`) : nombre juste, faux,
  marqueur dans le texte, dans une sortie d'outil, aucune table lue, réponse sans nombre, et la règle de lecture.
- `node mesdonnees/tests/bout-en-bout.mjs` : sur une base PostgreSQL neuve par app (graines réelles, `psql` réel), avec trois
  assistants simulés : fidèle, fuyard, menteur.
- `node graines/eprouver.mjs` : épreuve des graines (voir `RAPPORT.md`).
