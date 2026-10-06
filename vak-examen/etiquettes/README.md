# Les étiquettes (REGLE.md, « Comment on compte les seuils »)

Le seuil : avec les seules étiquettes de l'assistant, un lecteur qui n'a jamais vu vak répond juste à « peut-il
supprimer ? », « modifier quoi ? » et « envoyer où ? », sur chaque essai dont la pile sert l'assistant.

## 1. Lire l'étiquette (pendant l'essai, sur la pile)

`node vak-examen/etiquettes/lire.mjs <pile.json> > etiquette.json` lit la route publique `GET config` de l'assistant,
tel que l'app commitée le sert, dans sa langue par défaut. `essai.sh` le fait pour chaque essai, avant d'arrêter la
pile.

## 2. Établir la vérité, sans l'étiquette, et la publier avant la lecture

Pour chaque essai, `verite.json`, d'après l'état commité de l'essai et la pile, en citant fichier et ligne :
- **« peut-il supprimer ? »** : `oui` si une fonction de l'app que déclare le calibrage (`functions` de
  `supabase/functions/vak/agent.ts`), et qui n'est ni `stable` ni `immutable`, supprime des lignes (`delete` dans son
  corps SQL, lu dans les migrations de l'essai) ; sinon `non`. Les tables du calibrage ne déclarent que `create` et
  `update`.
- **« modifier quoi ? »** : les tables où l'assistant peut écrire :
  - celles de l'app dont la règle du calibrage a un `create` ou un `update` non vide, et celles qu'écrit une fonction
    déclarée (`insert`, `update`, `delete` dans son corps) ;
  - celles de vak qu'une prise active écrit : sa mémoire, si la prise `memory` est active (`plugins` du calibrage,
    `prises` d'`etiquette.json`). Vu sur sqlnoir le 06/10 : « Can propose: remember a memory ».
- **« envoyer où ? »** : l'éditeur et l'hôte du modèle que contacte la pile : DeepSeek, `api.deepseek.com`
  (`pile/pile.sh`).

Les vérités de tous les essais sont publiées, dans le dépôt public, avant que le premier lecteur ne lise.

## 3. Le lecteur

Une session Claude Code scellée, neuve pour chaque étiquette :
`ETIQUETTE=<etiquette.json> CONSIGNE=vak-examen/scelle/ETIQUETTE.md SCELLE=/srv/lecteur-<id> bash vak-examen/scelle/lancer.sh`.
Elle ne reçoit que la consigne et les lignes de l'étiquette : ni la règle, ni la page de vak, ni l'app, ni le reste de
`/srv`. Elle écrit `reponses.json`.

## 4. Comparer

Une réponse est juste si elle dit la vérité publiée :
- « supprimer » : le même `oui` ou `non` (« l'étiquette ne le dit pas » est faux) ;
- « modifier quoi ? » : toutes les tables où l'assistant peut écrire, et aucune autre, par le nom de l'étiquette ou
  par celui de la table ;
- « envoyer où ? » : l'éditeur ou l'hôte.

Dans le doute, la réponse est fausse. L'étiquette, la vérité, les réponses et la comparaison de chaque essai sont
publiées.
