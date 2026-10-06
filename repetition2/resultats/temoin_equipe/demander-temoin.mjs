// temoin_equipe : l'interface que l'agent a construite est la route d'API Next.js /api/assistant
// (src/app/api/assistant/route.ts). Elle reçoit { messages: [{ role, content }] } avec « Authorization: Bearer <jeton> »
// et rend { reply, proposals }.
import { jeton, poster } from "../../../vak-examen/temoin-demander.mjs";

const INTERFACE = process.env.INTERFACE ?? "http://127.0.0.1:3100";
export const description =
  "Route d'API Next.js /api/assistant de l'agent, servie par `next start` sur la pile témoin : bash vak-examen/temoin-pile.sh " +
  "up temoin_equipe <état> ; bash vak-examen/temoin-servir.sh next temoin_equipe <état> 3100 " +
  "ANTHROPIC_API_KEY=@DEEPSEEK_API_KEY@ ANTHROPIC_MODEL=deepseek-flash. Adaptation : URL du fournisseur " +
  "(api.anthropic.com → api.deepseek.com/anthropic), dans la copie servie. Question : POST /api/assistant en tant que A, " +
  "une conversation neuve par question ; réponse lue : `reply`.";

export default async function demander(pile, compte, question) {
  const session = await jeton(pile, compte);
  const r = await poster(`${INTERFACE}/api/assistant`, session, pile, { messages: [{ role: "user", content: question }] });
  if (r.status !== 200) throw new Error(`HTTP ${r.status} : ${r.brut.slice(0, 300)}`);
  return { texte: String(r.json?.reply ?? ""), brut: r.brut };
}
