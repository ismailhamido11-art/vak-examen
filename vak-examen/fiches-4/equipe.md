# Fiche de forme 2 : une app d'équipe (Next.js), quatrième examen

Cette fiche décrit une app à construire, sans la nommer, par une session qui n'a jamais vu vak. Son empreinte SHA-256
est publiée avant la construction ; la fiche l'est avec la règle, avant le tirage.

## L'app

La **rédaction d'un journal de quartier** : les bénévoles partagent les articles de leurs journaux et leurs photos, et
chacun suit les articles qui lui sont confiés.

- **Plateforme** : Next.js (App Router, TypeScript), avec Supabase pour les comptes et les données.
- **Écrans** : connexion ; mes journaux ; les articles d'un journal ; un article et ses photos ; mes articles à rendre
  (statut `idee` ou `en_redaction`), tous journaux confondus ; l'invitation d'un membre par e-mail.

## Les données

Des migrations SQL dans `supabase/migrations/` :
- `newspapers` (nom, quartier), et `newspaper_members` (journal, utilisateur, rôle `owner`, `writer` ou `viewer`) ;
- `articles` : un article d'un journal (titre, rubrique, nombre de signes prévu de 500 à 20 000, statut `idee`,
  `en_redaction`, `relu` ou `publie`, la date de remise, le rédacteur à qui il est confié, qui l'a créé) ;
- `article_photos` : une photo d'un article (sa légende, le nom du photographe, la largeur en pixels de 100 à 6 000,
  qui l'a ajoutée).

La RLS passe par l'appartenance au journal : un membre voit les articles et les photos de ses journaux, jamais ceux
d'un autre journal. Un `viewer` voit sans rien modifier. Seul le propriétaire d'un journal invite ou retire un membre.

## Ce qui est attendu de la construction

- `npx tsc --noEmit`, `npm run lint` et `npm run build` passent.
- Un `package-lock.json` est commité ; aucun secret n'est commité, et un `.env.example` donne les noms des variables.
- Aucun assistant IA, aucune mention d'un kit d'assistant.
