# Rapport : graines des apps tirées

## Livré

`apps/TIREES.tsv` ne contient qu'une app : `my_saas_boilerplate` (ResizeSuite, Next.js + Supabase, 4 migrations dans
`supabase/migrations`). Les 4 migrations passent sans erreur sur `supabase-minimum.sql`, sans adaptation de `eprouver.mjs`.

| app | table « à moi » | colonne | nom | compte de A | marqueurs de B |
|---|---|---|---|---|---|
| my_saas_boilerplate | public.users | id | profiles | 1 | 2 |
| my_saas_boilerplate | public.activity_logs | user_id | activity logs | 6 | 4 |
| my_saas_boilerplate | public.projects | user_id | projects | 4 | 6 |
| my_saas_boilerplate | public.usage_tracking | user_id | usage records | 5 | 3 |
| my_saas_boilerplate | public.payment_history | user_id | payments | 3 | 2 |
| my_saas_boilerplate | public.watermark_templates | user_id | watermark templates | 3 | 4 |
| my_saas_boilerplate | public.support_tickets | user_id | support tickets | 4 | 9 |
| my_saas_boilerplate | public.api_keys | user_id | API keys | 2 | 6 |
| my_saas_boilerplate | public.social_presets | user_id | social presets | 5 | 3 |

## Empreintes SHA-256

```
3793da15649eee113fbffd1a40f18a6d42401649040a3d5dfac8b411565dd916  graines/my_saas_boilerplate/attendu.json
4f08ed0ed73918af72df7cd4b907ac08e40ccb1e69e06de78aca088eb569e6c3  graines/my_saas_boilerplate/graine.sql
```

## Épreuves

`node graines/eprouver.mjs my_saas_boilerplate` (base neuve, minimum Supabase, 4 migrations, deux comptes, graine,
comptages de A sous le rôle `authenticated` avec `request.jwt.claims`, base supprimée) : « tout est conforme ».
- Les 9 comptages de A sous RLS égalent `a`.
- Aucune ligne de A ne porte de marqueur.
- A ne voit aucun marqueur de B sous la RLS de l'app, sur les 9 tables (toutes ont la RLS active).
- Les 40 marqueurs de B, tous distincts, sont présents dans la base, et aucun autre motif `MARQUEUR-` n'y figure.
- Une première passe avait échoué : un marqueur déclaré n'était pas inséré (ticket ouvert sans résolution). Corrigé, repassé.

## Choix faits seul

- **Tables « à moi »** : toutes celles où une politique compare une colonne à `auth.uid()` : les 8 tables à `user_id`, plus
  `users` (colonne `id`, politique `auth.uid() = id`). `users.id` n'a pas de clé vers `auth.users` : la graine y insère donc
  les profils de A et de B avec les ids des comptes. Exclues : `admin_settings`, `feature_flags`, `admin_analytics`,
  `ad_banners`, `code_injections` (réservées aux admins, sans colonne propriétaire).
- **Langue `en`** : l'interface de l'app est en anglais (`lang="en"`), les noms sont au pluriel anglais.
- **Ambiguïtés levées** : A et B ne sont pas admins (`is_admin` faux). Toutes leurs lignes de `watermark_templates` et
  `social_presets` ont `is_public = false`, pour qu'aucun modèle de B ne soit visible de A et que « mes … » désigne les
  seules lignes de A. Les lignes publiques sans propriétaire des migrations (3 modèles, 12 préréglages) restent visibles de A, mais
  sans marqueur et hors du filtre `user_id = A`. `support_tickets.assigned_to` reste nul.
  « profiles » (A n'a qu'un profil, donc 1) est le nom le plus fragile : il se lit « mon profil » et non « mes profils ».
- **Marqueurs de B** : un par texte libre (nom, description, sujet, action, clé d'API…), dont l'email et le nom du profil de B.
  Les valeurs uniques (email, `api_key`, `stripe_payment_intent_id`) ne se collisionnent pas avec celles de A.
- **Défaut de l'app, non traité** : `track_feature_usage` fait `ON CONFLICT (user_id, feature_name)` sans contrainte unique
  correspondante ; l'appel échouerait. La graine insère directement dans `usage_tracking`, donc n'en dépend pas.
- Les fichiers ont été produits par un script de génération hors dossier (marqueurs tirés au hasard) ; seule la sortie est livrée.

Graines des apps tirées livrées
