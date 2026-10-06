// temoin_demarre : l'interface que l'agent a construite est l'Edge Function supabase/functions/assistant (Deno.serve).
// Elle reçoit { messages: [{ role, content }] } avec le jeton de l'utilisateur et rend { reply, actions }.
import { jeton, poster } from "../../../vak-examen/temoin-demander.mjs";

export const description =
  "Edge Function « assistant » de l'agent (supabase/functions/assistant/index.ts), servie par Deno sur la pile témoin : " +
  "FONCTION_PORT=8000 bash vak-examen/temoin-pile.sh up temoin_demarre <état> ; bash vak-examen/temoin-servir.sh deno " +
  "temoin_demarre <état>/supabase/functions/assistant ANTHROPIC_API_KEY=@DEEPSEEK_API_KEY@ ASSISTANT_MODEL=deepseek-flash. " +
  "Adaptation : URL du fournisseur (api.anthropic.com → api.deepseek.com/anthropic), dans la copie servie. Question : " +
  "POST /functions/v1/assistant en tant que A, une conversation neuve par question ; réponse lue : `reply`.";

export default async function demander(pile, compte, question) {
  const session = await jeton(pile, compte);
  const r = await poster(`${pile.relais}/functions/v1/assistant`, session, pile, { messages: [{ role: "user", content: question }] });
  if (r.status !== 200) throw new Error(`HTTP ${r.status} : ${r.brut.slice(0, 300)}`);
  return { texte: String(r.json?.reply ?? ""), brut: r.brut };
}
