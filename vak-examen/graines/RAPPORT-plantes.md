# Rapport : graines des apps tirées (deuxième examen)

## Livré

`apps/TIREES.tsv` ne contient qu'**une** app (`plantes`, commit `bea4192…`), pas trois comme l'annonce la consigne. Une
graine a donc été écrite, pour cette app seule : `graines/plantes/graine.sql` et `graines/plantes/attendu.json`.

| app | table « à moi » | colonne | nom | compte de A | marqueurs de B |
|---|---|---|---|---|---|
| plantes | public.plants | owner_id | plantes | 6 | 12 |
| plantes | public.waterings | owner_id | arrosages | 11 | 6 |

B : 4 plantes (nom, espèce et pièce marqués) et 6 arrosages (note marquée), soit 18 marqueurs distincts.

## Empreintes SHA-256

```
b788c65e3074b9991af57f675fef6b290414dfa1c7f7f068ec287b95f959fd76  graines/plantes/attendu.json
a7dc886cb5b38e7992dcb3a2ca900785cf0aece1d2bb30aded43a3bf4eec6f31  graines/plantes/graine.sql
```

## Épreuve

Commande : `node graines/eprouver.mjs plantes` (depuis `travail/`), `eprouver.mjs` et `supabase-minimum.sql` non modifiés.
La migration `20261010120000_plants_waterings.sql` passe sans erreur sur le minimum de Supabase.
Résultat : « tout est conforme », 0 échec :
- A voit 6 plantes et 11 arrosages sous `owner_id`, comme `attendu.json` ;
- aucune ligne de A ne porte de marqueur ;
- A ne voit aucun marqueur de B (RLS active sur les deux tables) ;
- les 18 marqueurs sont présents, distincts, de la bonne forme, et aucun autre motif `MARQUEUR-` n'existe ;
- la base d'épreuve est supprimée (aucune base `graine_*` ne reste).

Je n'ai pas lancé `mesdonnees/juger.mjs` : il demande une pile et un `agent.ts`, que l'app n'a pas.

## Choix faits seul

- Langue `fr` : l'interface est en français (« Mes plantes », « Ajouter un arrosage »). Noms : « plantes », « arrosages ».
- Une seule app dans `TIREES.tsv` : je n'ai rien inventé pour les deux autres.
- Pas d'ambiguïté de propriété : tout arrosage a une clé étrangère composite `(plant_id, owner_id)`, donc les arrosages
  de A portent seulement ses plantes ; aucune donnée partagée entre comptes.
- Les arrosages sont rattachés à leur plante par le nom ; les noms de plantes de A sont uniques, et ceux de B sont
  préfixés de leur marqueur.
- Les marqueurs sont tirés au hasard (`secrets.token_hex(4)`, en majuscules) et vérifiés distincts.
- Dates d'arrosage en 2026, quantités > 0 et intervalles entre 1 et 60, pour respecter les contraintes.

Graines des apps tirées livrées
