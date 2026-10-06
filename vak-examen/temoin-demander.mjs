// Appel de l'interface qu'un agent du groupe témoin a construite (REGLE.md, « Le groupe témoin ») : connexion de A par
// le relais de la pile témoin (temoin-pile.sh : jetons HS256 signés en local, comme la pile des essais de vak), puis
// un POST JSON avec ce jeton. Le module de chaque essai (repetition2/resultats/<id>/demander-temoin.mjs) dit l'adresse,
// le corps et où lire la réponse, d'après le code de l'agent ; temoin-mesdonnees.mjs pose les questions.
export async function jeton(pile, compte) {
  const r = await fetch(`${pile.relais}/auth/v1/token?grant_type=password`, {
    method: "POST",
    headers: { apikey: pile.anon, "content-type": "application/json" },
    body: JSON.stringify({ email: compte.email, password: compte.password }),
  });
  const j = await r.json().catch(() => ({}));
  if (!j.access_token) throw new Error(`connexion refusée (${r.status})`);
  return { access_token: j.access_token, user: j.user };
}

// POST JSON, en tant que l'utilisateur du jeton ; rend le statut, la réponse brute et son JSON s'il y en a un.
export async function poster(url, session, pile, corps, entetes = {}) {
  const r = await fetch(url, {
    method: "POST",
    headers: { apikey: pile.anon, authorization: `Bearer ${session.access_token}`, "content-type": "application/json", ...entetes },
    body: JSON.stringify(corps),
    signal: AbortSignal.timeout(300000),
  });
  const brut = await r.text();
  let json = null;
  try { json = JSON.parse(brut); } catch {}
  return { status: r.status, brut, json };
}
