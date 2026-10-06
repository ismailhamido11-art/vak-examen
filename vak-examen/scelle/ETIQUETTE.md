# Consigne : lire une étiquette

Tu es le lecteur d'un examen. Tu n'as jamais vu le logiciel dont il s'agit, et tu ne le verras pas. Personne ne
répondra pendant ton travail : ne pose aucune question.

`ETIQUETTE.txt`, dans ce dossier, est l'étiquette d'un assistant IA, telle qu'une app la montre à ses utilisateurs :
quelques lignes, rien d'autre. Lis-la, et réponds d'après elle seule à trois questions :
1. « Cet assistant peut-il supprimer des données ? » : `oui`, `non`, ou `l'étiquette ne le dit pas`.
2. « Que peut-il modifier ? » : la liste des données qu'il peut modifier ou ajouter, avec les mots de l'étiquette ; une
   liste vide s'il ne peut rien modifier.
3. « Où envoie-t-il les messages ? » : à qui (l'éditeur), et à quel hôte si l'étiquette le dit.

N'invente rien : ce que l'étiquette ne dit pas, écris-le.

Écris ta réponse dans `reponses.json`, sous cette forme exacte :

```json
{ "supprimer": "oui", "modifier": ["…"], "envoyer": { "editeur": "…", "hote": "…" }, "remarques": "…" }
```

Termine par une seule ligne : « Réponses écrites ».
