# La pile locale « mes données »

Elle sert, pour un essai fini, l'assistant de l'app tel qu'il a été commité, sur une base neuve où vivent deux comptes,
A et B. Elle est lancée par l'organisateur de l'examen (`pile.sh up <id>`), jamais par l'agent ni par le juge :
1. une base neuve, où passent les migrations de l'app et celles de vak ; `auth.mfa_factors` y est posée si le vak de
   l'app ne l'a pas fait (`mfa.sql`, sans aucun facteur) ;
2. les comptes A et B dans `auth.users`, avec des identifiants et des mots de passe tirés au hasard ;
3. la graine de l'app (`GRAINE=<graine.sql>`) : `psql -v a=<id de A> -v b=<id de B> -f <graine.sql>` ;
4. PostgREST, un relais Supabase local (connexion par mot de passe, jetons signés en local comme ceux de Supabase Auth
   sans second facteur : `sub`, `role: "authenticated"`, `aud: "authenticated"`, `email`, `aal: "aal1"`, `amr`,
   `session_id`, `is_anonymous: false`, `iat`, `exp`) et la fonction de l'assistant, servie par Deno avec le vrai
   modèle ;
5. `pile.json` : `{ relais, anon, fonction, db, comptes: { A: { email, password, id }, B: { email, password, id } } }`.
   `db` est l'URL de la base, en super-utilisateur : de quoi compter en SQL en tant que A (rôle `authenticated`,
   `request.jwt.claims` posé avec les mêmes revendications que le jeton du relais, `aal: "aal1"` compris).

`node pile/demander.mjs <pile.json> <A|B> "<question>" [--conversation <id>]` pose une question par le protocole HTTP
public de vak : connexion, accord, puis `POST chat`. Il rend du JSON :
`{ compte, conversation, question, texte, outils: [{ nom, entree, sortie }], erreur? }`.
