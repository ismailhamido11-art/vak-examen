# Le journal de l'examen

Les 14 essais ont commencé le 06/10/2026 à 12:11 UTC, après la publication de leur liste (`AVANT-ESSAIS.md`). Ils sont
joués l'un après l'autre par `essai.sh`. Leurs résultats, leurs jugements et le verdict de l'examen seront publiés à la
fin, comme le veut la règle (`REGLE.md`, « La publication »).

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
