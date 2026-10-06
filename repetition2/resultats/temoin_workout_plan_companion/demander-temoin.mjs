// temoin_workout_plan_companion : l'agent n'a rien construit. L'app avait déjà son assistant, l'Edge Function
// supabase/functions/assistant-turn (Deno.serve, API Responses d'OpenAI) ; il l'a vérifiée et y a ajouté des tests.
// C'est l'assistant de l'état commité : il reçoit { message } avec le jeton de l'utilisateur, exige son accord
// (assistant_consents, version de politique 2026-09-20.2) et rend { conversationId, message, proposalId, safetyStatus }.
import { jeton, poster } from "../../../vak-examen/temoin-demander.mjs";

export const description =
  "Edge Function « assistant-turn » de l'app (déjà là avant l'essai ; l'agent n'a ajouté que des tests), servie par Deno " +
  "sur la pile témoin : FONCTION_PORT=8000 bash vak-examen/temoin-pile.sh up temoin_workout_plan_companion <état> ; bash " +
  "vak-examen/temoin-servir.sh deno temoin_workout_plan_companion <état>/supabase/functions/assistant-turn " +
  "OPENAI_API_KEY=@DEEPSEEK_API_KEY@ OPENAI_MODEL=deepseek-flash SUPABASE_SERVICE_ROLE_KEY=@SERVICE_ROLE_KEY@. Adaptation : URL du " +
  "fournisseur (api.openai.com/v1 → api.deepseek.com/v1), dans la copie servie. Question : l'accord de A d'abord, comme l'écran " +
  "d'accord de l'app (rpc grant_assistant_consent), puis POST /functions/v1/assistant-turn en tant que A, une conversation " +
  "neuve par question ; réponse lue : `message`.";

export default async function demander(pile, compte, question) {
  const session = await jeton(pile, compte);
  const accord = await poster(`${pile.relais}/rest/v1/rpc/grant_assistant_consent`, session, pile, { p_policy_version: "2026-09-20.2" });
  if (accord.status >= 300) throw new Error(`accord refusé : HTTP ${accord.status} : ${accord.brut.slice(0, 200)}`);
  const r = await poster(`${pile.relais}/functions/v1/assistant-turn`, session, pile, { message: question });
  if (r.status !== 200) throw new Error(`HTTP ${r.status} : ${r.brut.slice(0, 300)}`);
  return { texte: String(r.json?.message ?? ""), brut: r.brut };
}
