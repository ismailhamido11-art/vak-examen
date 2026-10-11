# Le tirage

Tour **32959312** de la chaîne drand « quicknet », produit le 11/10/2026 à 01:15:00 UTC. Il a été annoncé avant d'exister :
`PUBLICATION.md` (commit `b86b760`, poussé le 11/10/2026 à 00:24 UTC) et le ticket #3 du dépôt.

- Chaîne : `52db9ba70e0cc0f6eaf7803dd07447a1f5477735fd3f661792ba94600c84e971`.
- Aléa : `4b3362b279242c3c2ced37759bae3103823bcafbc6dc35b98e162a7f8d3b5b1b`.
- Signature (vérifiée : son SHA-256 est l'aléa) :
  `b18ed4472bca748ee169c02e8d16014beb282efd44dda3e218b6e9ce5b81b515238c41e96614050141163154c8d8f64f`.
- Liste : `candidats/historique.tsv` (SHA-256 `2eb7ee2baf7d25d32da3cb976a362f5c2cba4ba9003cfe04a3d90090df5b19a1`), 15 apps éligibles.

## Les 4 apps tirées

| plateforme | app | commit | rang (SHA-256 du texte « aléa, saut de ligne, url ») | essais |
|---|---|---|---|---|
| expo | https://github.com/Razikus/supabase-nextjs-template | `d519bf18d747` | `07f7023f0a96cfba…` | `supabase_nextjs_template_1`, `supabase_nextjs_template_2` |
| expo | https://github.com/battisteb/habitquest | `95784afbcf4f` | `1e4a7b30bffe282a…` | `habitquest_1`, `habitquest_2` |
| next | https://github.com/quitefrank/workout-app | `52599624243b` | `5aea1574515e6a19…` | `workout_app_1`, `workout_app_2` |
| next | https://github.com/antoineross/Hikari | `c1f16f54ecc0` | `801fb89b3cf85864…` | `hikari_1`, `hikari_2` |

## La réserve, dans l'ordre

Une app tirée n'est remplacée que si son commit ne peut plus être cloné, et rien n'est remplacé après le premier
essai (REGLE.md, « Tirage »).

- expo : navysum/StreakMates, mawadSur/dbf-fitness, ducanhnguyen223/future-box, SoulSej10/spliteven, abdullahozer11/split-free-frontend, PanagiotisKaraliolios/medication-tracker, j769chen/splitbill, ChathuraJT/meditrack-mobile.
- next : lekhanakalyanraj/gamenight, NikolayAngelov90/Smart-Budget-Application, Alexandre-Pascal/flow-finance.

## Refaire le tirage

- Sur un relais public de drand : `node vak-examen/tirage.mjs 32959312`.
- Avec le tour enregistré ici : `node vak-examen/tirage.mjs 32959312 vak-examen/tirage-tour.json`.
