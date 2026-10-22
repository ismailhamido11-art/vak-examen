# Rapport : graines des apps tirées (cinquième examen)

## Livré

`apps/TIREES.tsv` ne contient qu'**une** app (`randonnee`, dépôt `vak-examen/apps/randonnee.bundle`, commit
`4f43b027399c074f06de28aff08c967a752d6bd4`), et `apps/` ne contient que celle-là, alors que la consigne parle de 3 apps.
Je n'ai pas inventé les deux autres : une graine est livrée, pour `randonnee`.

| app | table « à moi » | colonne | nom | compte de A | marqueurs de B |
|---|---|---|---|---|---|
| randonnee | public.trails | owner_id | itinéraires | 6 | 8 |
| randonnee | public.outings | owner_id | sorties | 9 | 10 |

B a 4 itinéraires et 5 sorties. Marqueurs de B : nom et région des itinéraires, compagnons et commentaire des sorties.

## Empreintes SHA-256

```
e328f1a8a3228b13323170499e5f64917b72fcaa971948f815066822133f557d  graines/randonnee/graine.sql
11ef8dee34d059aa2bb14b4fb737420402488a9c74ab110696e401e78baadc8e  graines/randonnee/attendu.json
```

## Épreuve

`node graines/eprouver.mjs randonnee` (outil non modifié : une seule migration, `supabase/migrations`, nom d'app sans
tiret). Résultat : « tout est conforme », 0 échec. La migration passe sur le minimum de Supabase. Vérifié :
- A voit 6 lignes de `trails` et 9 de `outings` sous `owner_id`, en tant que `authenticated` avec `request.jwt.claims` posé ;
- aucune ligne de A ne porte de marqueur ;
- A ne voit aucun marqueur de B (RLS active sur les deux tables) ;
- les 18 marqueurs sont distincts, tous présents dans la base, et il n'y a aucun autre motif `MARQUEUR-`.

La base d'épreuve a été supprimée (aucune base `graine_*` restante).

## Choix faits seul

- Une seule graine, faute des deux autres apps (voir plus haut).
- Pas d'`agent.ts` dans l'app : la langue de `attendu.json` vient de l'interface (français), d'où `fr`.
- Noms « itinéraires » et « sorties », ceux de l'interface (« Mes itinéraires », « Ajouter une sortie »).
- Une sortie a forcément le même propriétaire que son itinéraire (clé étrangère composite) : aucune donnée partagée,
  donc aucune ambiguïté sur « mes … ». A est le seul propriétaire de ses lignes.
- Les marqueurs de B sont placés uniquement dans des textes libres (pas dans les enums ni les nombres).
- Les `attendu.json` de `trails` listent les marqueurs des itinéraires, ceux de `outings` ceux des sorties.

Graines des apps tirées livrées
