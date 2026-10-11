# Rapport : graines des apps tirées (deuxième examen)

## Livré

`apps/TIREES.tsv` ne contient qu'**une** app : `compteurs` (et non trois, comme le disait la consigne). Livré : `graines/compteurs/graine.sql` et `graines/compteurs/attendu.json`.

| app | table « à moi » | colonne | nom | compte de A | marqueurs de B |
|---|---|---|---|---|---|
| compteurs | public.meters | owner_id | compteurs | 4 | 4 |
| compteurs | public.readings | owner_id | relevés | 15 | 0 |

## Empreintes SHA-256

    85402ccb3ac68097ea2d177dd0fdd40867bc5193dab94fda1571161619b1197f  compteurs/graine.sql
    e859328adac87a5cf45429f10235ebaf8b1a583597f156bd04ec68e37e0b56a1  compteurs/attendu.json

## Épreuve

`node graines/eprouver.mjs compteurs` (outil non modifié) : les deux migrations passent sur le minimum de Supabase ; résultat « tout est conforme », 0 échec : 4 lignes (meters) et 15 (readings) pour A sous RLS, aucune ligne de A avec marqueur, A ne voit aucun marqueur de B, 4 marqueurs distincts présents dans la base, aucun autre motif MARQUEUR-. La base d'épreuve est supprimée (vérifié : aucune base `graine_*` restante).

## Choix faits seul

- Langue `fr` (interface en fr-FR). Noms : « compteurs », « relevés ».
- **Pas de marqueur sur `readings`** : la table n'a aucun texte libre (date, nombre, clés). `marqueurs_b` y est donc vide ; une fuite de relevés de B ne se verrait que par les noms de ses compteurs (marqueurs de `meters`, cherchés toutes tables confondues), ou par le compte.
- **Pas de marqueur dans `meters.unit`** : limité à 16 caractères, le marqueur en fait 19. Unités ordinaires (`m³`, `kWh`). Les marqueurs de B sont dans `meters.name` (≤ 80).
- Écriture directe par INSERT dans la graine (les tables n'ont pas de droit d'écriture pour `authenticated`, mais la graine passe en super-utilisateur) ; valeurs croissantes par compteur pour respecter la règle de monotonie des fonctions de l'app.
- Compte des relevés (15) différent de celui des compteurs (4) ; chaque compteur d'A a au moins un relevé, B a ses propres compteurs et relevés. Aucune donnée partagée entre A et B.
- Aucun défaut de RLS constaté dans l'app.

Graines des apps tirées livrées
