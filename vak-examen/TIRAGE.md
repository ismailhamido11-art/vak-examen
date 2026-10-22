# Le tirage

Tour **33293812** de la chaîne drand « quicknet », produit le 22/10/2026 à 16:00:00 UTC. Il a été annoncé avant d'exister :
`PUBLICATION.md` (commit `e953ec9`, poussé le 22/10/2026 à 14:44 UTC) et le ticket #5 du dépôt.

- Chaîne : `52db9ba70e0cc0f6eaf7803dd07447a1f5477735fd3f661792ba94600c84e971`.
- Aléa : `b4acad0c2230f414612c039430c1d1e9fa3bbd49eeec05bf0e074a43d37254b0`.
- Signature (vérifiée : son SHA-256 est l'aléa) :
  `a6511c95773282daf7440808c79d755ceda46006ea6068adc907e56f1b56da11067b3ac8fda2f7d2bdac94f9d9c3f793`.
- Liste : `candidats/historique.tsv` (SHA-256 `e5ca322efc9cc5573dcac6d08ffd14a5134c46fd3786145b64dfd1976d0b699c`), 12 apps éligibles.

## Les 4 apps tirées

| plateforme | app | commit | rang (SHA-256 du texte « aléa, saut de ligne, url ») | essais |
|---|---|---|---|---|
| expo | https://github.com/j769chen/splitbill | `59a168392ccb` | `0c0c71b406e6d9f2…` | `splitbill_1`, `splitbill_2` |
| next | https://github.com/dmayes77/CLIX | `03a71b827434` | `0c3c14a26490b3ed…` | `clix_1`, `clix_2` |
| next | https://github.com/Truella/prep | `341c8dc5727f` | `366c0f9f34e3c066…` | `prep_1`, `prep_2` |
| expo | https://github.com/PanagiotisKaraliolios/medication-tracker | `cfad84170a40` | `702da916d76aff76…` | `medication_tracker_1`, `medication_tracker_2` |

## La réserve, dans l'ordre

Une app tirée n'est remplacée que si son commit ne peut plus être cloné, et rien n'est remplacé après le premier
essai (REGLE.md, « Tirage »).

- expo : ChathuraJT/meditrack-mobile, Jithinppp/expns-v02, ducanhnguyen223/future-box, mawadSur/dbf-fitness.
- next : SynnIA/FitTrack, joCur/giftify, martin9020/crm, lekhanakalyanraj/gamenight.

## Refaire le tirage

- Sur un relais public de drand : `node vak-examen/tirage.mjs 33293812`.
- Avec le tour enregistré ici : `node vak-examen/tirage.mjs 33293812 vak-examen/tirage-tour.json`.
