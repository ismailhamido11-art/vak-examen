// Répétition 2, contrôle (appelé par controler.sh, après controle.mjs) : copie la transcription de la session d'essai
// dans repetition2/resultats/<id>/, valeurs secrètes masquées, et en tire le chrono et les messages reçus.
// Usage : node repetition2/transcription.mjs <id>
//         node repetition2/transcription.mjs <id> --relire <transcription.jsonl.gz>   (refait le chrono d'une copie, sur la sortie)
// La session de travail ne lit pas la session d'essai : c'est par cette copie qu'elle voit les gestes, les questions
// et les contournements tapés sans trace commitée (--legacy-peer-deps, --force…).
//  - Transcription : ~/.claude/projects/*/<CLAUDE_CODE_SESSION_ID>.jsonl, écrite en transcription.jsonl.gz. Essai Codex
//    (ESSAI_AGENT=codex, lancer.sh) : le flux horodaté de `codex exec --json`, /work/<id>/agent.jsonl.
//  - Masquage : la valeur de chaque variable d'environnement au nom de secret (TOKEN, KEY, SECRET, PASSWORD,
//    CREDENTIAL, AUTH, GIT_CONFIG_VALUE_n), le jeton du fichier CLAUDE_SESSION_INGRESS_TOKEN_FILE, les mots de passe
//    de ~/.pgpass, les valeurs de la connexion Codex (~/.codex/auth.json), puis toute forme de jeton connue (sbp_, sk-,
//    ghp_…, github_pat_, AKIA…, JWT, « Bearer … »).
//    Le masquage est vérifié : aucune des valeurs connues ne reste dans la copie, sinon rien n'est écrit.
//  - chrono.json : début du chrono (demande unique : lecture de la ligne « prêt » de la préparation ; 3 messages : envoi
//    du message 2), réponse finale (dernier texte de l'agent avant le contrôleur ou le message 3), durée, messages
//    reçus entre les deux (gestes à compter), rappels automatiques, commandes avec --legacy-peer-deps, --force ou un
//    accès réel (supabase login, link, secrets, deploy), et commandes lancées avant le chrono (demande unique).
// N'échoue jamais le contrôle : un problème donne une ligne « transcription : … » et le code 0.
import { existsSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { gunzipSync, gzipSync } from "node:zlib";

const HERE = dirname(fileURLToPath(import.meta.url));
const ID = process.argv[2] ?? "";
const RES = join(HERE, "resultats", ID);
const dire = (texte) => console.log(`transcription : ${texte}`);

function trouver() {
  const id = process.env.CLAUDE_CODE_SESSION_ID ?? "";
  const racine = join(homedir(), ".claude", "projects");
  if (!id || !existsSync(racine)) return undefined;
  for (const dossier of readdirSync(racine)) {
    const f = join(racine, dossier, `${id}.jsonl`);
    if (existsSync(f)) return f;
  }
  return undefined;
}

/** Valeurs à masquer, avec leur étiquette (jamais affichées). */
function secrets() {
  const out = [];
  const nom = /(TOKEN|KEY|SECRET|PASSWORD|PASSWD|CREDENTIAL|AUTH)|^GIT_CONFIG_VALUE_\d+$/i;
  for (const [k, v] of Object.entries(process.env)) if (v && v.length >= 8 && nom.test(k)) out.push([v, k]);
  const fichier = process.env.CLAUDE_SESSION_INGRESS_TOKEN_FILE;
  if (fichier && existsSync(fichier)) {
    const v = readFileSync(fichier, "utf8").trim();
    if (v.length >= 8) out.push([v, "jeton de session"]);
  }
  const pgpass = join(homedir(), ".pgpass");
  if (existsSync(pgpass)) {
    for (const ligne of readFileSync(pgpass, "utf8").split("\n")) {
      const v = ligne.split(":").slice(4).join(":").trim();
      if (v.length >= 8) out.push([v, "pgpass"]);
    }
  }
  // Connexion Codex de l'essai (copiée par lancer.sh dans le HOME de l'essai, retirée après le contrôle).
  const codex = join(homedir(), ".codex", "auth.json");
  if (existsSync(codex)) {
    try {
      for (const v of chaines(JSON.parse(readFileSync(codex, "utf8")))) if (v.length >= 8) out.push([v, "connexion Codex"]);
    } catch {
      out.push([readFileSync(codex, "utf8").trim(), "connexion Codex"]);
    }
  }
  return out.sort((a, b) => b[0].length - a[0].length);
}

/** Toutes les chaînes d'une valeur JSON. */
const chaines = (v) => (typeof v === "string" ? [v] : v && typeof v === "object" ? Object.values(v).flatMap(chaines) : []);

const FORMES = [
  /\bsbp_[A-Za-z0-9]{20,}/g,
  /\bsk-[A-Za-z0-9_-]{20,}/g,
  /\bgh[pousr]_[A-Za-z0-9]{20,}/g,
  /\bgithub_pat_[A-Za-z0-9_]{20,}/g,
  /\bAKIA[0-9A-Z]{16}\b/g,
  /\beyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}/g,
  /(?<=Bearer\s{1,4})[A-Za-z0-9._~+/-]{20,}=*/g,
];

const MODELE = /\bclaude-(?:opus|sonnet|haiku|fable)(?:-[0-9a-z]+)+\b/gi;

function masquer(texte, valeurs) {
  let t = texte;
  for (const [v, etiquette] of valeurs) {
    for (const forme of new Set([v, JSON.stringify(v).slice(1, -1)])) t = t.split(forme).join(`«masqué:${etiquette}»`);
  }
  for (const forme of FORMES) t = t.replace(forme, "«masqué»");
  // Identifiant du modèle de l'agent : hors des fichiers commités (consigne des sessions, 06/10).
  return t.replace(MODELE, "«modèle»");
}

/** Texte d'un message (chaîne ou blocs « text »), sinon undefined (résultats d'outils). */
function texte(contenu) {
  if (typeof contenu === "string") return contenu;
  if (!Array.isArray(contenu)) return undefined;
  const t = contenu.filter((b) => b && b.type === "text").map((b) => b.text ?? "");
  return t.length ? t.join("\n") : undefined;
}

/**
 * Messages reçus par la session : ses entrées « user » qui portent du texte (le message 1, à la création), et les
 * corps des notifications qu'elle a lues (les messages suivants arrivent par des déclencheurs, sous la forme
 * « --- Notification 1 of 1 · id: … · origin: … · queued at: <date> --- », dans le résultat de ReadNotifications).
 */
const NOTIF = /--- Notification \d+ of \d+ · id: [^·\n]+ · origin: [^·\n]+ · queued at: (\S+) ---\n([\s\S]*?)(?=\n--- Notification \d+ of \d+ · id: |\n<system-reminder>|\n\d+ notifications? remains? queued|$)/g;

function recus(entrees) {
  const out = [];
  for (const e of entrees) {
    if (e.type !== "user" || e.isMeta || e.isCompactSummary || e.isSidechain) continue;
    const t = texte(e.message?.content);
    if (t !== undefined && !/^\s*<(task-notification|system-reminder|command-|local-command)/.test(t)) out.push({ at: e.timestamp, texte: t });
    if (!Array.isArray(e.message?.content)) continue;
    for (const b of e.message.content) {
      if (b?.type !== "tool_result") continue;
      const c = typeof b.content === "string" ? b.content : Array.isArray(b.content) ? b.content.map((x) => x?.text ?? "").join("\n") : "";
      for (const m of c.matchAll(NOTIF)) out.push({ at: m[1] ?? e.timestamp, texte: (m[2] ?? "").trim() });
    }
  }
  return out.sort((a, b) => Date.parse(a.at) - Date.parse(b.at));
}

/**
 * Commandes à relire. Accès réel : commandes de la CLI Supabase qui visent un projet hébergé, ou qui citent les accès
 * du compte d'essai admis dans l'environnement (03/10) ou leurs API. Sans fenêtre, l'agent peut tout lancer : un dépôt
 * distant ajouté ou poussé est aussi à relire. `--force` ne compte que pour un gestionnaire de paquets (`git worktree
 * remove --force` n'est pas un contournement ; maybewe, 03/10).
 */
const A_RELIRE = /legacy-peer-deps|\b(npm|pnpm|yarn|bun|npx)\b[^;&|\n]*\s--force\b|supabase\s+(login|link|secrets|projects|functions\s+deploy|db\s+push)|SUPABASE_ACCESS_TOKEN|DEEPSEEK_API_KEY|api\.supabase\.com|api\.deepseek\.com|git\s+push\b|git\s+remote\s+add\b/;

/** Commandes Bash des entrées, avec leur heure. */
function bash(entrees) {
  return entrees
    .filter((e) => e.type === "assistant" && Array.isArray(e.message?.content))
    .flatMap((e) => e.message.content.filter((b) => b?.type === "tool_use" && b.name === "Bash").map((b) => ({ at: e.timestamp, commande: String(b.input?.command ?? "") })));
}

/** Texte des résultats d'outils et des messages d'une entrée « user » (pour y chercher la ligne « prêt »). */
function contenu(e) {
  const c = e.message?.content;
  if (typeof c === "string") return c;
  if (!Array.isArray(c)) return "";
  return c
    .map((b) => (b?.type === "text" ? (b.text ?? "") : b?.type === "tool_result" ? (typeof b.content === "string" ? b.content : Array.isArray(b.content) ? b.content.map((x) => x?.text ?? "").join("\n") : "") : ""))
    .join("\n");
}

/**
 * Début et fin du chrono, selon le protocole.
 *  - Demande unique (depuis le 01/10 après-midi) : la demande de création porte à la fois « L'app est dans /work/<id>/app »
 *    et « controler.sh <id> ». Le chrono part quand la session lit la ligne « prêt : /work/<id>/app (<heure>) » de la
 *    préparation (dans un résultat d'outil) et s'arrête à sa première commande « controler.sh <id> ».
 *  - 3 messages (avant) : du message 2 au message 3 « L'essai est fini ».
 * La réponse finale est le dernier texte de l'agent avant la fin.
 */
function bornes(entrees, messages) {
  const unique = messages.find((m) => m.texte.includes(`L'app est dans /work/${ID}/app`) && m.texte.includes(`controler.sh ${ID}`));
  const arret = (t) => messages.find((m) => Date.parse(m.at) > t && m.texte.includes("L'essai est fini : ne corrige rien"));
  if (!unique) {
    // Sans fenêtre (lancer.sh, D9) : la demande est le premier message et le chrono court jusqu'à la réponse finale.
    const demande = messages.find((m) => m.texte.includes(`L'app est dans /work/${ID}/app`));
    const t2 = demande ? Date.parse(demande.at) : NaN;
    const fin = arret(t2);
    const protocole = demande?.texte.startsWith("Essai sans fenêtre") ? "sans fenêtre" : "3 messages";
    return { protocole, debut: demande?.at ?? null, t2, t3: fin ? Date.parse(fin.at) : Infinity, pret_ecrit: null, avant: [] };
  }
  const t0 = Date.parse(unique.at);
  const PRET = new RegExp(`prêt : /work/${ID}/app \\((\\d{4}-\\d\\d-\\d\\dT[\\d:]+Z)\\)`);
  const lue = entrees.find((e) => e.type === "user" && Date.parse(e.timestamp) > t0 && PRET.test(contenu(e)));
  const t2 = lue ? Date.parse(lue.timestamp) : NaN;
  const controle = new RegExp(`controler\\.sh\\s+["']?${ID}(["'\\s;&|]|$)`);
  const fin = bash(entrees).find((c) => Date.parse(c.at) > t2 && controle.test(c.commande));
  const stop = arret(t2);
  const t3 = Math.min(fin ? Date.parse(fin.at) : Infinity, stop ? Date.parse(stop.at) : Infinity);
  const avant = bash(entrees.filter((e) => Date.parse(e.timestamp) > t0 && !(Date.parse(e.timestamp) >= t2))).filter((c) => !c.commande.includes("preparer.sh"));
  return { protocole: "demande unique", debut: lue?.timestamp ?? null, t2, t3, pret_ecrit: lue ? PRET.exec(contenu(lue))[1] : null, fin_commande: fin?.at ?? null, avant };
}

function chrono(lignes) {
  const entrees = [];
  for (const l of lignes) {
    try {
      entrees.push(JSON.parse(l));
    } catch {}
  }
  const messages = recus(entrees);
  const { protocole, debut, t2, t3, pret_ecrit, fin_commande, avant } = bornes(entrees, messages);
  const pendant = entrees.filter((e) => Date.parse(e.timestamp) > t2 && Date.parse(e.timestamp) < t3);
  const reponses = pendant.filter((e) => e.type === "assistant" && texte(e.message?.content)?.trim());
  const finale = reponses.at(-1) ?? (fin_commande ? { timestamp: fin_commande } : undefined);
  const entre = messages.filter((m) => Date.parse(m.at) > t2 && Date.parse(m.at) < t3);
  const commandes = bash(pendant);
  const marquees = commandes.filter((c) => A_RELIRE.test(c.commande));
  const duree = finale && debut ? Math.round((Date.parse(finale.timestamp) - t2) / 6000) / 10 : null;
  return {
    protocole,
    message2: debut,
    ...(protocole === "demande unique" ? { pret_ecrit, controleur_lance: fin_commande ?? null } : {}),
    reponse_finale: finale?.timestamp ?? null,
    duree_min: duree,
    temps_depasse: duree !== null && duree > 120,
    reponse_finale_texte: finale?.message ? texte(finale.message.content).slice(0, 4000) : null,
    messages_recus: entre.filter((m) => !m.texte.startsWith("Stop hook feedback")).map((m) => ({ at: m.at, texte: m.texte.slice(0, 1500) })),
    rappels_automatiques: entre.filter((m) => m.texte.startsWith("Stop hook feedback")).length,
    commandes_bash: commandes.length,
    commandes_a_relire: marquees.map((c) => ({ at: c.at, commande: c.commande.slice(0, 500) })),
    ...(protocole === "demande unique" ? { commandes_avant_le_chrono: avant.slice(0, 30).map((c) => ({ at: c.at, commande: c.commande.slice(0, 300) })) } : {}),
  };
}

/**
 * Chrono d'un essai Codex (flux horodaté par horodater.mjs) : la demande part au lancement, la réponse finale est le
 * dernier message de l'agent ; aucun message ne peut lui parvenir (`codex exec`).
 */
function chronoCodex(lignes) {
  const evenements = lignes.flatMap((l) => {
    try {
      return [JSON.parse(l)];
    } catch {
      return [];
    }
  });
  const debut = evenements[0]?.t ?? null;
  const items = evenements.filter((e) => e.type === "item.completed" && e.item);
  const finale = items.filter((e) => e.item.type === "agent_message" && String(e.item.text ?? "").trim()).at(-1);
  const commandes = items.filter((e) => e.item.type === "command_execution").map((e) => ({ at: e.t, commande: String(e.item.command ?? "") }));
  const duree = finale && debut ? Math.round((Date.parse(finale.t) - Date.parse(debut)) / 6000) / 10 : null;
  return {
    protocole: "sans fenêtre (Codex)",
    message2: debut,
    reponse_finale: finale?.t ?? null,
    duree_min: duree,
    temps_depasse: duree !== null && duree > 120,
    reponse_finale_texte: finale ? String(finale.item.text).slice(0, 4000) : null,
    messages_recus: [],
    rappels_automatiques: 0,
    commandes_bash: commandes.length,
    commandes_a_relire: commandes.filter((c) => A_RELIRE.test(c.commande)).map((c) => ({ at: c.at, commande: c.commande.slice(0, 500) })),
    echecs_du_tour: evenements.filter((e) => e.type === "turn.failed" || e.type === "error").map((e) => ({ at: e.t, erreur: JSON.stringify(e.error ?? e.message ?? e).slice(0, 500) })),
  };
}

const CODEX = process.env.ESSAI_AGENT === "codex";
const RELIRE = process.argv[3] === "--relire" ? process.argv[4] : undefined;

try {
  if (RELIRE) {
    const brut = RELIRE.endsWith(".gz") ? gunzipSync(readFileSync(RELIRE)).toString("utf8") : readFileSync(RELIRE, "utf8");
    console.log(JSON.stringify((CODEX ? chronoCodex : chrono)(brut.split("\n")), null, 2));
  } else if (!ID || !existsSync(RES)) {
    dire(`dossier ${RES} absent (lance d'abord controle.mjs)`);
  } else {
    const flux = join(process.env.TRAVAIL ?? "/work", ID, "agent.jsonl");
    const source = CODEX ? (existsSync(flux) ? flux : undefined) : trouver();
    if (!source) {
      dire(CODEX ? `flux de Codex absent (${flux})` : "introuvable (CLAUDE_CODE_SESSION_ID ou ~/.claude/projects absent) : chrono et gestes à lire dans la session");
    } else {
      const valeurs = secrets();
      const brut = readFileSync(source, "utf8");
      const copie = masquer(brut, valeurs);
      const restes = valeurs.filter(([v]) => copie.includes(v)).map(([, etiquette]) => etiquette);
      if (restes.length) {
        dire(`non copiée : masquage incomplet (${[...new Set(restes)].join(", ")})`);
      } else {
        writeFileSync(join(RES, "transcription.jsonl.gz"), gzipSync(copie));
        const c = (CODEX ? chronoCodex : chrono)(copie.split("\n"));
        writeFileSync(join(RES, "chrono.json"), `${JSON.stringify(c, null, 2)}\n`);
        dire(
          `copiée et masquée (${brut.split("\n").length - 1} lignes) ; chrono ${c.duree_min ?? "?"} min${c.temps_depasse ? " (temps dépassé)" : ""} ; ` +
            `${c.messages_recus.length} message(s) reçu(s) entre la demande et la réponse finale ; ${c.commandes_a_relire.length} commande(s) à relire`,
        );
      }
    }
  }
} catch (e) {
  dire(`erreur : ${e instanceof Error ? e.message : String(e)}`);
}
