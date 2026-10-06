# Cahier des charges : le contrôleur de l'examen de vak

Tu écris le contrôleur de l'examen public de vak, un kit qui ajoute un assistant IA à une app Expo ou Next.js adossée
à Supabase. Tu n'as jamais vu le dépôt de vak, et tu ne le verras pas. Tu as seulement :
- `REGLE.md` : la règle de l'examen. Elle fait foi ; ce cahier ne fait que préciser les entrées et la sortie.
- `PAGE-VAK.md` : la page publique de vak (son README).
- `essais/` : trois essais de la répétition, pour éprouver ton code. Aucun verdict n'est fourni.

Ton contrôleur juge un essai : un agent de code a reçu la demande du README et a intégré vak dans une app qu'il n'avait
jamais vue. Il ne juge pas l'agent : il dit si l'essai réussit selon la règle (« Un essai réussit si tout est vrai »,
points 1, 2, 3, 4, 6 et 7). Le point 5 (« mes données ») est vérifié à part, par une pile locale ; il n'est pas à toi.

## Ce que tu livres

Le dossier `controleur/`, dans ton dossier de travail :
- `controler.mjs` : Node 22, sans dépendance npm. `node controleur/controler.mjs <dossier d'un essai> <dossier de
  travail>` écrit `<dossier de travail>/verdict.json` et affiche en dernière ligne
  `verdict <id> : réussi`, `verdict <id> : échec (<raisons>)` ou `verdict <id> : refus propre (<raison>)`.
- `README.md` : ce qu'il vérifie, comment, et ses limites connues, en une page.

## Le dossier d'un essai (l'entrée)

- `app/` : le dépôt git de l'app après l'essai, sur la branche `essai`. Son historique contient le commit de l'app
  d'origine, puis le commit de préparation (`vak : archive du kit` : l'archive copiée dans `vendor/vak/`), puis les
  commits de l'agent.
- `preparation.json` : `{ "id", "depot", "commit" (app d'origine), "prepare" (commit de préparation),
  "archive": { "nom", "sha256" }, "debut" }`.
- `journal.jsonl` : la transcription de la session de l'agent (Claude Code), une entrée JSON par ligne, horodatée
  (`timestamp`). Les commandes sont dans les blocs `tool_use` (`input.command`), leurs sorties dans les blocs
  `tool_result`. Les valeurs secrètes y sont masquées.

## Ce que le contrôleur vérifie

Tout se juge sur l'état **commité** : un clone propre du HEAD, jamais le dossier `app/` lui-même, qui reste intact.
- **Point 1, vak a fini.** Dans le clone propre du HEAD, une fois les dépendances installées, la commande de vak qui
  dit « fini » (voir la page publique) rend 0. Le reçu de preuve commité est à jour.
- **Point 2, l'app compile comme avant.** Mesure typecheck, lint, tests et build (ou export) sur le commit de
  préparation, puis sur le HEAD, chacun dans un clone propre, avec les dépendances installées comme le ferait un
  développeur de l'app. Compare : un code de sortie qui passe de 0 à autre chose, ou une liste d'erreurs
  (fichier:ligne) qui s'allonge, est un échec.
  - Une vérification absente avant et après : absente.
  - Un délai dépassé avant et après : non comparable, noté.
  - Pas de cache d'outil (turbo, nx…) entre deux mesures.
- **Point 3, les dépendances.** Compare les verrous et les `package.json` du commit de préparation et du HEAD. Seuls
  des ajouts sont permis, avec l'exception de la règle.
- **Point 4, aucun contournement**, avec la liste de la règle. Le journal sert pour ce qui a été tapé sans laisser de
  trace commitée.
- **Point 6, la durée**, lue dans le journal.
- **Point 7, le refus propre**, si l'agent s'est arrêté sans rien écrire en disant que l'app n'est pas prise en charge.

Chaque raison d'échec cite sa preuve dans `verdict.json` : un diff, une ligne d'erreur ou une ligne du journal.
Aucune IA dans le jugement : seulement des comparaisons et des comptes.

## L'environnement

- Node 22, npm, pnpm et yarn par corepack, git ; le réseau ne sert qu'aux registres de paquets.
- PostgreSQL 16 local sur 127.0.0.1:5432, super-utilisateur `root`, mot de passe dans `~/.pgpass`. vak en a besoin
  pour sa base de test (voir la page publique).
- Pas de Docker. Ne lis rien hors de ton dossier de travail.

## Éprouve-le

1. Lance-le sur les trois essais de `essais/`, jusqu'à ce qu'il tourne de bout en bout sans erreur.
2. Plante toi-même, dans des copies, les 6 sabotages de la règle (« Le contrôleur »), et vérifie qu'il rend « échec »
   pour chacun, avec la bonne raison.
3. Dans `controleur/README.md`, dis ce que tu as éprouvé et ce que tu n'as pas pu éprouver.

Termine par un compte rendu court : ce que fait le contrôleur, les verdicts obtenus sur les trois essais, et les
sabotages vus.
