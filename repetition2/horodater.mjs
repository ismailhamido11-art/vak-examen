// Lanceur sans fenêtre, essais Codex (lancer.sh, AGENT=codex) : horodate chaque ligne du flux JSON de `codex exec --json`
// à sa réception, car ses événements ne portent pas d'heure. Le chrono de l'essai en dépend (vak-examen/REGLE.md, point 6).
// Usage : codex exec --json … | node repetition2/horodater.mjs > agent.jsonl
// Sortie : une ligne par événement, {"t": "<heure ISO>", …événement} ; une ligne qui n'est pas du JSON : {"t", "texte"}.
import { createInterface } from "node:readline";

for await (const ligne of createInterface({ input: process.stdin, crlfDelay: Infinity })) {
  if (!ligne.trim()) continue;
  let e;
  try {
    e = JSON.parse(ligne);
  } catch {
    e = { texte: ligne };
  }
  const objet = e && typeof e === "object" && !Array.isArray(e) ? e : { valeur: e };
  process.stdout.write(`${JSON.stringify({ t: new Date().toISOString(), ...objet })}\n`);
}
