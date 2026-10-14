# Rapport : graines des apps tirées

## Livré

Une seule app est présente dans `apps/` : `disques` (`apps/TIREES.tsv` n'a qu'une ligne, commit 398bb03d983fe88fe3e97d720c90dfea67d9269a). La consigne parle de 3 apps ; les deux autres ne sont pas dans le dossier, je n'ai rien inventé pour elles.

| app | table « à moi » | colonne | nom | compte de A | marqueurs de B |
|---|---|---|---|---|---|
| disques | public.vinyls | user_id | disques | 6 | 12 |
| disques | public.listenings | user_id | écoutes | 9 | 5 |

Fichiers : `graines/disques/graine.sql`, `graines/disques/attendu.json`.

## Empreintes SHA-256

```
68e4167750d290059c297018e15304704bfa2553e7ec0d355103b3978324eb63  disques/graine.sql
c6f81fe6073f0ff5fe790ba033be9d58fc4c36fca76a34232cc9834fb08c7631  disques/attendu.json
```

## Épreuve

Commande (depuis le dossier de travail) : `node graines/eprouver.mjs disques`. Résultat : toutes les vérifications « ok », « tout est conforme », code 0.
- migration unique (`20260101000000_collection_vinyles.sql`) passée sans erreur sur `supabase-minimum.sql` ;
- sous le rôle `authenticated` en tant que A : 6 disques et 9 écoutes, conformes à `attendu.json` ;
- aucune ligne de A ne porte de marqueur ; A ne voit aucun marqueur de B (RLS active sur les deux tables) ;
- 17 marqueurs distincts dans la base, tous listés dans `attendu.json`, aucun autre motif `MARQUEUR-` ;
- base temporaire supprimée (vérifié : aucune base `graine_disques%` restante). `eprouver.mjs` utilisé sans modification.

## Choix faits seul

- Noms : « disques » (vinyls) et « écoutes » (listenings), en `fr`, la langue de l'interface (`src/app` en français).
- Pas de `agent.ts` dans l'app : je n'ai pas pu vérifier quelles tables seront déclarées lisibles ; les deux tables sont livrées.
- Marqueurs de B dans chaque texte libre : `titre`, `artiste` et `genres` (tableau) des disques ; `commentaire` des écoutes. Marqueurs aléatoires, uniques. Les 4 disques de B ont chacun 3 marqueurs ; 5 écoutes de B.
- Ambiguïté levée : « mes disques » = lignes de `vinyls` de A, sans disque partagé ; les écoutes de A ne visent que des disques de A (clé composite). Les titres de B sont préfixés pour ne jamais coïncider avec ceux de A.
- A a un disque sans prix (`prix_achat` null) et des états variés ; valeurs conformes aux contraintes (année, note 1–5, face A/B/AB, enum d'état).

Graines des apps tirées livrées
