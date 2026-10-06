# Le tirage

Tour **32828212** de la chaîne drand « quicknet », produit le 06/10/2026 à 12:00:00 UTC. Il a été annoncé avant d'exister :
`PUBLICATION.md` (commit `698f07b`, poussé le 06/10/2026 à 09:54:30 UTC) et le ticket #1 du dépôt.

- Chaîne : `52db9ba70e0cc0f6eaf7803dd07447a1f5477735fd3f661792ba94600c84e971`.
- Aléa : `c9869a89b9cc99d6d15bcf57e100cfa1b4122304a43bf4fccca288c8e945ff13`.
- Signature (vérifiée : son SHA-256 est l'aléa) :
  `966baa7388e3e27ade82d8c6362541f2d6d210b020a166ecc71ed9f722c8787e0a6b08076761d70176d90393690aeb6a`.
- Liste : `candidats/historique.tsv` (SHA-256 `9cad401aed68e9ab6d9551115500ff824159f225c4bee79231c0e58c5ea05f72`), 23 apps éligibles.

## Les 4 apps tirées

| plateforme | app | commit | rang (SHA-256 du texte « aléa, saut de ligne, url ») | essais |
|---|---|---|---|---|
| next | https://github.com/AndrerezaMedya/budget-app | `f1f3ef1bdbac` | `09b6efb80f5e4263…` | `budget_app_1`, `budget_app_2` |
| expo | https://github.com/aprescod12/track-training-app | `00acb94c39f8` | `0cbecc161a3b8e51…` | `track_training_app_1`, `track_training_app_2` |
| expo | https://github.com/AndreuCrespo/workout-plan-companion | `ebf680c396b9` | `186d9dd2c82051c2…` | `workout_plan_companion_1`, `workout_plan_companion_2` |
| next | https://github.com/xtshepana/company-invoicing | `e999749419b1` | `302d3f881b5dce4d…` | `company_invoicing_1`, `company_invoicing_2` |

Les 4 commits se clonent (vérifié le 06/10/2026 à 12:00 UTC) : aucune app tirée n'est sautée. Les champs de leur
demande sont ceux de [`champs-candidats.tsv`](champs-candidats.tsv), publiés avant le tirage.

## La réserve, dans l'ordre

Une app tirée n'est remplacée que si son commit ne peut plus être cloné, et rien n'est remplacé après le premier
essai (REGLE.md, « Tirage »).

- expo : ChathuraJT/meditrack-mobile, SoulSej10/spliteven, battisteb/habitquest, ducanhnguyen223/future-box, MarkMGill/pups-supabase, mawadSur/dbf-fitness, PanagiotisKaraliolios/medication-tracker, Razikus/supabase-nextjs-template, j769chen/splitbill, itejaskumbhar/Expense-Sharing, navysum/StreakMates, abdullahozer11/split-free-frontend.
- next : lekhanakalyanraj/gamenight, antoineross/Hikari, quitefrank/workout-app, NikolayAngelov90/Smart-Budget-Application, bluebridgetechnology/my-saas-boilerplate, Alexandre-Pascal/flow-finance, Ant3xes/budget_web_app.

## Refaire le tirage

- Sur un relais public de drand : `node vak-examen/tirage.mjs 32828212`.
- Avec le tour enregistré ici : `node vak-examen/tirage.mjs 32828212 vak-examen/tirage-tour.json`.
