# Examen public de vak

vak est un kit qui ajoute un assistant IA à une app Expo ou Next.js adossée à Supabase. Cet examen le mesure sur 14
essais, avec des seuils publiés avant la mesure. Dans chaque essai, un agent de code doit l'intégrer dans une app
qu'il n'a jamais vue, sans rien casser. L'assistant obtenu doit donner des chiffres exacts, et ne jamais montrer les
données d'un autre compte.

- **La règle** : [`vak-examen/REGLE.md`](vak-examen/REGLE.md), figée le 06/10/2026.
- **Ce qui est figé avant le tirage** : [`vak-examen/PUBLICATION.md`](vak-examen/PUBLICATION.md). On y trouve les
  empreintes, le texte de la demande, l'environnement et le tour drand du tirage.
- **Les pièces de l'examen** : [`vak-examen/README.md`](vak-examen/README.md). Ce sont le contrôleur, la pile « mes
  données » et son juge, les 3 apps construites, la liste des apps éligibles et le tirage.
- **Le lanceur des essais** : [`repetition2/`](repetition2/) (`lancer.sh`, `preparer.sh`, `messages.sh`…).

Ce dépôt reprend, aux mêmes chemins, les fichiers de l'examen tenus dans le dépôt de vak (`vak-examen/publier.sh` les
recopie). Le dépôt de vak n'est pas public. Les scripts y lisent deux fichiers du kit, dont seules les empreintes sont
publiées ici :
- l'archive gelée, `vertical-agent-kit/releases/vak-agent-0.24.3.tgz` ;
- sa page, `vertical-agent-kit/README.md`, d'où vient la demande.

Les deux seront publiés si l'examen est réussi. Les graines des données de test seront publiées après les essais, et
les résultats aussi, réussis ou non.
