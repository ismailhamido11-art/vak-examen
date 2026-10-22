# Examen public de vak

vak est un kit qui ajoute un assistant IA à une app Expo ou Next.js adossée à Supabase. Cet examen le mesure sur 14
essais, avec des seuils publiés avant la mesure. Dans chaque essai, un agent de code doit l'intégrer dans une app
qu'il n'a jamais vue, sans rien casser. L'assistant obtenu doit donner des chiffres exacts, et ne jamais montrer les
données d'un autre compte.

- **Le cinquième examen** (22/10/2026), avec vak 0.29.2 gelé : **en cours**.
  - la règle : [`vak-examen/REGLE.md`](vak-examen/REGLE.md), figée le 22/10/2026 ;
  - ce qui est figé avant le tirage : [`vak-examen/PUBLICATION.md`](vak-examen/PUBLICATION.md). On y trouve les
    empreintes, le texte de la demande, l'environnement, le tour drand du tirage et ce qui a changé depuis le
    quatrième examen ; le ticket n°5 suit les étapes.
- **Le quatrième examen** (14/10/2026), avec vak 0.28.1 gelé : **échoué**. 12 essais réussis sur 14 (il en fallait
  12), une durée médiane de 6 minutes (45 au plus), aucune fuite, des chiffres exacts, aucun faux « c'est fait » :
  cinq seuils sur sept tenus ; manquent les gestes demandés à l'humain et les étiquettes. Sa règle, sa publication,
  son journal et son verdict (`vak-examen/EXAMEN.md`, `vak-examen/RESULTAT.json`, encore dans l'arbre jusqu'au
  verdict du cinquième), les résultats de chaque essai et ses graines restent dans l'historique de ce dépôt (commit
  `ff57d67` et avant).
- **Le troisième examen** (11/10/2026) : échoué, 6 essais réussis sur 14 (il en fallait 12), aucune fuite. Sa règle,
  sa publication, son journal et son verdict (`vak-examen/EXAMEN.md`, `vak-examen/RESULTAT.json`), les résultats de
  chaque essai et ses graines restent dans l'historique de ce dépôt (commit `b3e8c89` et avant).
- **Le deuxième examen** (10/10/2026) : échoué, 9 essais réussis sur 14 (il en fallait 12), aucune fuite. Sa règle,
  sa publication, son journal et son verdict (`vak-examen/EXAMEN.md`, `vak-examen/RESULTAT.json`), les résultats de
  chaque essai et ses graines restent dans l'historique de ce dépôt (commit `e7cf599` et avant).
- **Le premier examen** (06/10/2026) : échoué, 2 essais réussis sur 14, aucune fuite. Sa règle, sa publication, ses
  résultats (`vak-examen/EXAMEN.md`, `vak-examen/RESULTAT.json`) et son groupe témoin restent dans l'historique de
  ce dépôt (commit `57f5686` et avant).
- **Les pièces de l'examen** : [`vak-examen/README.md`](vak-examen/README.md). Ce sont le contrôleur, la pile « mes
  données » et son juge, les 3 apps construites, la liste des apps éligibles et le tirage.
- **Le lanceur des essais** : [`repetition2/`](repetition2/) (`lancer.sh`, `preparer.sh`, `messages.sh`…).

Ce dépôt reprend, aux mêmes chemins, les fichiers de l'examen tenus dans le dépôt de vak (`vak-examen/publier.sh` les
recopie). Le dépôt de vak n'est pas public. Les scripts de l'examen y lisent deux fichiers du kit, dont seules les
empreintes sont publiées ici (un outil de développement, `vak-examen/etiquettes/rejouer.sh`, lit en plus le code
source du kit, non publié) :
- l'archive gelée, `vertical-agent-kit/releases/vak-agent-0.29.2.tgz` (cinquième examen) ;
- sa page, `vertical-agent-kit/README.md`, d'où vient la demande.

Les deux ne sont publiés que si un examen est réussi. Les graines des données de test et les résultats sont publiés
après les essais, réussis ou non.
