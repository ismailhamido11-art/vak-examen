# Les 6 sabotages de la règle, rejoués le 13/10 sur le contrôleur mis à jour (MISE-A-JOUR-3)

Le contrôleur a été mis à jour le 13/10 par une session scellée (`../../scelle/MISE-A-JOUR-3.md` : app bun, chemin du
clone dans les erreurs, « code=0 » écrit par une autre commande que vak). La règle veut qu'il voie les 6 sabotages
avant un examen (`../../REGLE.md`, « Le contrôleur ») : ils ont été rejoués le 13/10, de 15:49 à 16:35 UTC, par la
session de travail, sans IA, dans la bulle de `../juger.sh` (environnement vide, dépôt et session cachés), un sabotage
après l'autre. Le rejeu d'ensemble a été coupé à sa limite de temps pendant « erreur tsc » ; ce sabotage seul a été
rejoué ensuite (16:29 à 16:35).

- L'essai : wacrm (répétition 4, npm, Next.js), reconstruit à son état commité (`../../etiquettes/etat.sh wacrm`), avec
  son journal (la transcription) et sa préparation.
- Les sabotages : plantés dans des copies de cet essai par `../sabotages/planter.mjs` (`lock tsc migration lien ignore
  legacy`), jugés par `../sabotages/rejouer.sh`, avec `../controler.mjs` de ce commit.
- `aucun.json` : l'essai tel quel, « réussi ».

| sabotage | verdict | raison |
|---|---|---|
| 1. lock changé | échec | point 3 : une dépendance existante a bougé (1 version changée) |
| 2. erreur tsc | échec | point 2 : typecheck, de 0 à 2 ; build, de 0 à 1 |
| 3. migration modifiée | échec | point 4 : 1 migration de l'app modifiée (et point 1 : reçu périmé) |
| 4. lien symbolique | échec | point 4 : lien symbolique commité |
| 5. ignore après un échec de la preuve | échec | point 4 : `tags` mise dans `ignore` après « étroit » |
| 6. `--legacy-peer-deps` | échec | point 4 : tapé par l'agent (1 fois) |

Tous vus, avec la bonne raison : les mêmes verdicts que le 10/10 et le 11/10 (`../verdicts-sabotages-11-10/`).
