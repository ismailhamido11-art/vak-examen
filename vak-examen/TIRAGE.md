# Le tirage

Tour **32950012** de la chaîne drand « quicknet », produit le 10/10/2026 à 17:30:00 UTC. Il a été annoncé avant d'exister :
`PUBLICATION.md` (commit `cfa018f`, poussé le 10/10/2026 à 16:46 UTC) et le ticket #2 du dépôt.

- Chaîne : `52db9ba70e0cc0f6eaf7803dd07447a1f5477735fd3f661792ba94600c84e971`.
- Aléa : `7f91b684c01420ded3764278ea7d04e98cf7645266c1f5f5cc839a84c0a550f7`.
- Signature (vérifiée : son SHA-256 est l'aléa) :
  `8cf0bf7a497e1742d59a06923a87887e516878136b0ddd67256e41256b420f5d543f0f8786eb05d23c9581f50ab8a685`.
- Liste : `candidats/historique.tsv` (SHA-256 `968dc2f416255d5750f1f4c391b1df125679e604bdb414a20975b6faec1edae7`), 19 apps éligibles.

## Les 4 apps tirées

| plateforme | app | commit | rang (SHA-256 du texte « aléa, saut de ligne, url ») | essais |
|---|---|---|---|---|
| expo | https://github.com/itejaskumbhar/Expense-Sharing | `8e6020c14ba0` | `06fe14db12a5d757…` | `expense_sharing_1`, `expense_sharing_2` |
| expo | https://github.com/MarkMGill/pups-supabase | `405d4df786d5` | `171ebdc273d5f687…` | `pups_supabase_1`, `pups_supabase_2` |
| next | https://github.com/bluebridgetechnology/my-saas-boilerplate | `bcb20492cdb7` | `218f7b0c7926c175…` | `my_saas_boilerplate_1`, `my_saas_boilerplate_2` |
| next | https://github.com/Ant3xes/budget_web_app | `88061f2c29e9` | `6abc476cb8575bbe…` | `budget_web_app_1`, `budget_web_app_2` |

## La réserve, dans l'ordre

Une app tirée n'est remplacée que si son commit ne peut plus être cloné, et rien n'est remplacé après le premier
essai (REGLE.md, « Tirage »).

- expo : j769chen/splitbill, battisteb/habitquest, navysum/StreakMates, ducanhnguyen223/future-box, abdullahozer11/split-free-frontend, Razikus/supabase-nextjs-template, ChathuraJT/meditrack-mobile, mawadSur/dbf-fitness, PanagiotisKaraliolios/medication-tracker, SoulSej10/spliteven.
- next : lekhanakalyanraj/gamenight, NikolayAngelov90/Smart-Budget-Application, antoineross/Hikari, Alexandre-Pascal/flow-finance, quitefrank/workout-app.

## Refaire le tirage

- Sur un relais public de drand : `node vak-examen/tirage.mjs 32950012`.
- Avec le tour enregistré ici : `node vak-examen/tirage.mjs 32950012 vak-examen/tirage-tour.json`.
