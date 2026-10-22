# Rapport : graines des apps tirées (quatrième examen)

## Livré

`apps/TIREES.tsv` ne contient qu'**une** app (`prets`), alors que la consigne en annonce trois. Je n'ai rien écrit pour
les deux autres : leurs sources ne sont pas dans `apps/`.

| app | table « à moi » | colonne | nom | compte de A | marqueurs de B |
|---|---|---|---|---|---|
| prets | public.items | owner_id | objets | 10 | 4 |
| prets | public.loans | owner_id | prêts | 8 | 6 |

## Empreintes SHA-256

```
51991e7e7dbf28c88c7751a62fd48e0f8173f0566d22f542ea87de5dd59d905a  graines/prets/graine.sql
40e3de9f32842cf640f18588fc75e936d58016e64c757082f45f0ae9a1e57d4d  graines/prets/attendu.json
```

## Épreuve

`node graines/eprouver.mjs prets` (outil inchangé : migrations dans `supabase/migrations`, nom d'app sans tiret).
Base neuve, minimum de Supabase, 2 migrations, 2 comptes, graine ; comptes de A sous `authenticated` avec
`request.jwt.claims` posé. Résultat : « tout est conforme », 0 échec.
- items : 10 lignes de A (attendu 10) ; loans : 8 (attendu 8).
- Aucune ligne de A ne porte de marqueur ; A ne voit aucun marqueur de B (RLS active sur les deux tables).
- Les 10 marqueurs de B sont présents dans la base, distincts, sans autre motif `MARQUEUR-`.
- Les migrations passent sans erreur. La base d'épreuve est supprimée (vérifié : 0 base `graine_prets%`).

## Choix faits seul

- **Tous les prêts de A sont en cours** (un par objet, 8 objets sur 10) : « mes prêts » et « mes prêts en cours »
  donnent le même nombre, 8. B a un prêt rendu et deux en cours, sans effet sur A.
- **Objets** : « mes objets » = tous les objets de A (10), prêtés ou non ; 2 ne sont pas prêtés, c'est voulu.
- **Noms** : « objets » et « prêts », termes de l'interface (items, loans).
- **Marqueurs de B** : dans `items.name`, `loans.borrower` et `loans.condition_note` (les seuls textes libres).
  `times_lent` est fixé par le déclencheur `loans_bump_times_lent`, pas par la graine.
- **Dates** fixes, `due_on >= lent_on` respecté ; les écritures de la graine passent en super-utilisateur, sans les
  fonctions de l'app.
- Les tables sont en lecture seule pour `authenticated` (écritures par fonctions) : la graine n'en dépend pas.

Graines des apps tirées livrées
