# Le tirage

Tour **33062212** de la chaîne drand « quicknet », produit le 14/10/2026 à 15:00:00 UTC. Il a été annoncé avant d'exister :
`PUBLICATION.md` (commit `6f47e5e`, poussé le 14/10/2026 à 14:00 UTC) et le ticket #4 du dépôt.

- Chaîne : `52db9ba70e0cc0f6eaf7803dd07447a1f5477735fd3f661792ba94600c84e971`.
- Aléa : `7c8a9d03bb936d9e32dff104f8df77554370ce5fb9eac6c778f372afb5d525d6`.
- Signature (vérifiée : son SHA-256 est l'aléa) :
  `964964603334a835db08c5e6826eeb4b3d03386718b5eb55ad3f4981e8d2b5aba4f9560843bfd2f82e2a4caffc306a5c`.
- Liste : `candidats/historique.tsv` (SHA-256 `93c506039e5a6a4c63956322440daf355324008a8a177137b3fa4011c63e043a`), 11 apps éligibles.

## Les 4 apps tirées

| plateforme | app | commit | rang (SHA-256 du texte « aléa, saut de ligne, url ») | essais |
|---|---|---|---|---|
| expo | https://github.com/abdullahozer11/split-free-frontend | `74b661256ea2` | `5931658348dbac29…` | `split_free_frontend_1`, `split_free_frontend_2` |
| next | https://github.com/NikolayAngelov90/Smart-Budget-Application | `d8173d6acced` | `598b07358f9ad231…` | `smart_budget_application_1`, `smart_budget_application_2` |
| next | https://github.com/Alexandre-Pascal/flow-finance | `642880178c93` | `6832ec0eca511f86…` | `flow_finance_1`, `flow_finance_2` |
| expo | https://github.com/navysum/StreakMates | `79c610d7b49c` | `7089487aec5e14b2…` | `streakmates_1`, `streakmates_2` |

## La réserve, dans l'ordre

Une app tirée n'est remplacée que si son commit ne peut plus être cloné, et rien n'est remplacé après le premier
essai (REGLE.md, « Tirage »).

- expo : mawadSur/dbf-fitness, SoulSej10/spliteven, ChathuraJT/meditrack-mobile, PanagiotisKaraliolios/medication-tracker, ducanhnguyen223/future-box, j769chen/splitbill.
- next : lekhanakalyanraj/gamenight.

## Refaire le tirage

- Sur un relais public de drand : `node vak-examen/tirage.mjs 33062212`.
- Avec le tour enregistré ici : `node vak-examen/tirage.mjs 33062212 vak-examen/tirage-tour.json`.
