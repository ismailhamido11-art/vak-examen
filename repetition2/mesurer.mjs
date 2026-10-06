// Répétition 2 : mesure les vérifications d'une app, comme le contrôleur de l'examen. Elle sert deux fois : avant
// l'installation de vak (clone neuf du commit de l'app, par preparer.sh), puis après (clone propre de HEAD, par
// controle.mjs).
// Usage : node mesurer.mjs <dossier de l'app> <sortie.json>
// 1. Installe les dépendances avec le gestionnaire de l'app, choisi par son verrou (npm ci, pnpm install
//    --frozen-lockfile, yarn install --frozen-lockfile ou --immutable, bun install --frozen-lockfile ; corepack pour la
//    version de « packageManager »).
// 2. Lance les vérifications de l'app, chacune avec un délai de 10 min : typecheck (script typecheck ou type-check,
//    sinon tsc --noEmit s'il y a un tsconfig.json), lint (script lint), tests (script test, CI=1, jamais en mode
//    surveillance), build (script build pour Next ; Expo : expo export --platform web si l'app déclare le web, sinon
//    rien). En monorepo, les scripts de la racine (turbo) d'abord.
// 3. Écrit pour chaque vérification : commande, code, durée, lignes d'erreur (fichier:ligne avec « error », tsc
//    « error TS », ESLint, « FAIL » des tests) ; « absent » si l'app ne l'a pas. Journaux complets à côté :
//    <sortie sans .json>-journaux/<vérification>.txt.
// Code 0 dès que la mesure est écrite : une vérification en échec est un résultat, pas une erreur.
import { spawn, spawnSync } from "node:child_process";
import { existsSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, realpathSync, rmSync, statSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const MIN = 60_000;
export const DELAI = 10 * MIN;
const DELAI_INSTALLATION = 20 * MIN;
/** Variables fixes : pas de télémétrie, pas de couleurs (lignes d'erreur comparables). */
const ENV_FIXE = {
  NEXT_TELEMETRY_DISABLED: "1",
  TURBO_TELEMETRY_DISABLED: "1",
  EXPO_NO_TELEMETRY: "1",
  DO_NOT_TRACK: "1",
  NO_COLOR: "1",
  FORCE_COLOR: "0",
  npm_config_audit: "false",
  npm_config_fund: "false",
  // pnpm 10 essaie de passer à la version de « packageManager » quand il est lancé par un script (turbo) et échoue si
  // elle n'est pas installée : avant et après n'auraient pas le même environnement (essai mission-control, 01/10).
  npm_config_manage_package_manager_versions: "false",
  npm_config_update_notifier: "false",
  // Turbo 2 en mode strict retire des tâches qu'il lance toute variable non déclarée dans turbo.json, dont les deux
  // précédentes et NO_COLOR : sans ce mode, le build d'avant s'arrêtait en 2 s sur « Failed to switch pnpm » et celui
  // d'après, une fois pnpm 9.15.0 installé par l'essai, allait jusqu'au bout (vague 2 de mission-control, 01/10).
  TURBO_ENV_MODE: "loose",
};

export const lireTexte = (f) => {
  try {
    return readFileSync(f, "utf8");
  } catch {
    return undefined;
  }
};
export const lireJson = (f) => {
  const t = lireTexte(f);
  if (t === undefined) return undefined;
  try {
    return JSON.parse(t);
  } catch {
    return undefined;
  }
};
const estDossier = (d) => {
  try {
    return statSync(d).isDirectory();
  } catch {
    return false;
  }
};
const cite = (s) => (/^[\w@%+=:,./-]+$/.test(s) ? s : `'${s.replaceAll("'", `'\\''`)}'`);
const commandeExiste = (c) => spawnSync("bash", ["-c", `command -v ${cite(c)}`], { stdio: "ignore" }).status === 0;

const ANSI = /\x1b\[[0-9;?]*[A-Za-z]/g;
const FICHIER_SEUL = /^(?:\.{0,2}\/|<racine>\/)?[\w@.()[\]{}+~$-][^\s:]*\.[A-Za-z]{1,6}$/;
const LIGNE_ESLINT = /^\s*(\d+):(\d+)\s+(?:error|Error:?)\s+(.+?)\s*$/;
/** Préfixe des lignes de turbo (« paquet:tâche: ») : la tâche commence par une lettre (jamais « 12:5 »). */
const TURBO = /^(?:@[\w.-]+\/)?[\w.-]+:[A-Za-z][\w:-]*: /;
const FICHIER_LIGNE = /[^\s:'"()]+\.[A-Za-z]{1,6}(?::\d+(?::\d+)?|\(\d+,\d+\))/;

/**
 * Lignes d'erreur d'un journal, normalisées pour comparer avant et après : couleurs retirées, dossier de l'app
 * remplacé par « <racine> », durées retirées, sans doublon. Formes reconnues : tsc (« error TS »), fichier:ligne avec
 * « error » sur la ligne ou la suivante (next build), ESLint (fichier, puis « ligne:col error … »), « FAIL » des tests.
 */
export function erreurs(texte, racines = []) {
  let t = texte.replace(ANSI, "");
  for (const r of racines.filter(Boolean).sort((a, b) => b.length - a.length)) t = t.replaceAll(r, "<racine>");
  const lignes = t.split(/\r?\n/).map((l) => l.replace(TURBO, ""));
  const out = new Set();
  let fichier;
  for (let i = 0; i < lignes.length; i++) {
    const l = lignes[i];
    const s = l.trim();
    if (!s) continue;
    if (FICHIER_SEUL.test(s) && !/:\d+/.test(s)) {
      fichier = s;
      continue;
    }
    const m = LIGNE_ESLINT.exec(l);
    if (m && fichier) {
      out.add(`${fichier}:${m[1]}:${m[2]} error ${m[3]}`);
      continue;
    }
    if (fichier && FICHIER_SEUL.test((lignes[i - 1] ?? "").trim()) && /^(?:Module not found|Type error|SyntaxError|Error)\b/.test(s)) {
      out.add(`${fichier} ${s}`); // next build : « ./src/x.ts » puis « Module not found: … »
      continue;
    }
    if (/\berror TS\d+/.test(s)) {
      out.add(s);
      continue;
    }
    if (FICHIER_LIGNE.test(s) && /\berror\b/i.test(s)) {
      out.add(s);
      continue;
    }
    if (/^\S+\.[A-Za-z]{1,6}:\d+(?::\d+)?$/.test(s) && /\berror\b/i.test(lignes[i + 1] ?? "")) {
      out.add(`${s} ${lignes[i + 1].trim()}`);
      continue;
    }
    if (/^(?:FAIL|×|✗)\s+\S/.test(s) && /\.(?:test|spec)\.|\btests?\//.test(s)) out.add(s.replace(/\s+\d+(?:\.\d+)?\s?m?s$/, ""));
  }
  return [...out];
}

/**
 * Lance une commande (bash -c) dans son propre groupe de processus ; au délai, tout le groupe est tué. Journal complet
 * dans `journal` (commande et dossier en tête). Rend { commande, dossier, code, duree_s, erreurs, journal, fin }.
 */
export function lancer(commande, { cwd, journal, env = {}, delai = DELAI, racines = [cwd], affichage = commande }) {
  return new Promise((ok) => {
    const debut = Date.now();
    const morceaux = [];
    let taille = 0;
    const enfant = spawn("bash", ["-c", commande], {
      cwd,
      env: { ...process.env, ...ENV_FIXE, ...env },
      detached: true,
      stdio: ["ignore", "pipe", "pipe"],
    });
    const garder = (d) => {
      morceaux.push(d);
      taille += d.length;
      while (taille > 32 * 1024 * 1024 && morceaux.length > 1) taille -= morceaux.shift().length;
    };
    enfant.stdout.on("data", garder);
    enfant.stderr.on("data", garder);
    let depasse = false;
    const tuer = () => {
      try {
        process.kill(-enfant.pid, "SIGKILL");
      } catch {}
    };
    const minuterie = setTimeout(() => {
      depasse = true;
      tuer();
    }, delai);
    let fini = false;
    const finir = (code, signal) => {
      if (fini) return;
      fini = true;
      clearTimeout(minuterie);
      tuer();
      const texte = Buffer.concat(morceaux).toString("utf8");
      if (journal) writeFileSync(journal, `$ ${affichage}\n(dossier : ${cwd})\n\n${texte}`);
      const nonVides = texte.replace(ANSI, "").split(/\r?\n/).filter((l) => l.trim());
      ok({
        commande: affichage,
        dossier: cwd,
        code: depasse ? "délai" : (code ?? `signal ${signal}`),
        duree_s: Math.round((Date.now() - debut) / 1000),
        erreurs: erreurs(texte, racines),
        fin: nonVides.slice(-3).map((l) => l.trim().slice(0, 300)),
        ...(journal ? { journal } : {}),
      });
    };
    enfant.on("close", finir);
    enfant.on("exit", (code, signal) => setTimeout(() => finir(code, signal), 5000));
    enfant.on("error", (e) => {
      morceaux.push(Buffer.from(String(e)));
      finir(127, undefined);
    });
  });
}

/** Gestionnaire de paquets de l'app : celui de « packageManager » si son verrou est là, sinon le premier verrou. */
function gestionnaire(dir, pkg) {
  const verrous = ["pnpm-lock.yaml", "yarn.lock", "bun.lock", "bun.lockb", "package-lock.json", "npm-shrinkwrap.json"].filter((f) => existsSync(join(dir, f)));
  const declare = typeof pkg?.packageManager === "string" ? pkg.packageManager.split("+")[0] : undefined;
  const [nomDeclare, versionDeclaree] = declare ? [declare.slice(0, declare.lastIndexOf("@")), declare.slice(declare.lastIndexOf("@") + 1)] : [];
  const DE = { "pnpm-lock.yaml": "pnpm", "yarn.lock": "yarn", "bun.lock": "bun", "bun.lockb": "bun", "package-lock.json": "npm", "npm-shrinkwrap.json": "npm" };
  const parVerrou = verrous.map((f) => DE[f]);
  const nom = nomDeclare && parVerrou.includes(nomDeclare) ? nomDeclare : (parVerrou[0] ?? nomDeclare ?? "npm");
  const version = nom === nomDeclare ? versionDeclaree : undefined;
  let lanceur;
  if (nom === "npm") lanceur = "npm";
  else if (nom === "bun") lanceur = commandeExiste("bun") ? "bun" : "npx -y bun@1";
  else if (version) lanceur = `corepack ${nom}@${version}`;
  else lanceur = commandeExiste(nom) ? nom : `corepack ${nom}`;
  const berry = nom === "yarn" && (Number((version ?? "1").split(".")[0]) >= 2 || existsSync(join(dir, ".yarnrc.yml")) || /^__metadata:/m.test(lireTexte(join(dir, "yarn.lock")) ?? ""));
  const avecVerrou = verrous.some((f) => DE[f] === nom);
  const installation = {
    npm: avecVerrou ? "npm ci" : "npm install",
    pnpm: avecVerrou ? `${lanceur} install --frozen-lockfile` : `${lanceur} install`,
    yarn: berry ? `${lanceur} install --immutable` : `${lanceur} install --frozen-lockfile --non-interactive`,
    bun: avecVerrou ? `${lanceur} install --frozen-lockfile` : `${lanceur} install`,
  }[nom];
  // verrou désynchronisé de package.json (faute de l'app, déjà là avant vak) : installation simple, notée
  const repli = {
    npm: { motif: /can only install packages when your package\.json and package-lock\.json/, commande: "npm install" },
    pnpm: { motif: /ERR_PNPM_OUTDATED_LOCKFILE|not up to date with/, commande: `${lanceur} install --no-frozen-lockfile` },
    yarn: berry
      ? { motif: /YN0028|lockfile would have been modified/, commande: `YARN_ENABLE_IMMUTABLE_INSTALLS=false ${lanceur} install` }
      : { motif: /Your lockfile needs to be updated/, commande: `${lanceur} install --non-interactive` },
    bun: { motif: /lockfile had changes, but lockfile is frozen/, commande: `${lanceur} install` },
  }[nom];
  return { nom, version, lanceur, verrous, installation, repli: avecVerrou ? repli : undefined, avecVerrou };
}

/** Dossiers des paquets du workspace (package.json « workspaces » ou pnpm-workspace.yaml), motifs simples. */
function espaces(dir, pkg) {
  const motifs = Array.isArray(pkg?.workspaces) ? [...pkg.workspaces] : [...(pkg?.workspaces?.packages ?? [])];
  const yaml = lireTexte(join(dir, "pnpm-workspace.yaml"));
  if (yaml) {
    let dedans = false;
    for (const l of yaml.split(/\r?\n/)) {
      if (/^packages:\s*$/.test(l)) {
        dedans = true;
        continue;
      }
      if (!dedans) continue;
      const m = /^\s+-\s+['"]?([^'"#]+?)['"]?\s*(?:#.*)?$/.exec(l);
      if (m) motifs.push(m[1]);
      else if (/^\S/.test(l)) dedans = false;
    }
  }
  const out = new Set();
  for (const m of motifs.filter((x) => !x.startsWith("!"))) {
    const base = m.replace(/\/\*\*?$/, "").replace(/\/$/, "");
    if (/\/\*\*?$/.test(m)) {
      const abs = join(dir, base);
      if (estDossier(abs)) for (const n of readdirSync(abs)) if (existsSync(join(abs, n, "package.json"))) out.add(join(abs, n));
    } else if (!m.includes("*") && existsSync(join(dir, m, "package.json"))) out.add(join(dir, m));
  }
  return { motifs, dossiers: [...out].sort() };
}

const dependances = (p) => ({ ...p?.dependencies, ...p?.devDependencies });
const typeApp = (p) => (dependances(p).next ? "next" : dependances(p).expo ? "expo" : undefined);
/** App Expo qui publie aussi le web : react-native-web parmi ses dépendances et « web » dans expo.platforms s'il est écrit. */
function webDeclare(dir, pkg) {
  if (!dependances(pkg)["react-native-web"]) return false;
  const plateformes = lireJson(join(dir, "app.json"))?.expo?.platforms;
  return !Array.isArray(plateformes) || plateformes.includes("web");
}
const PAS_DE_TEST = /no test specified/;

export async function mesurer(dirArg, sortieArg) {
  const DIR = realpathSync(resolve(dirArg));
  const SORTIE = resolve(sortieArg);
  const JOURNAUX = `${SORTIE.replace(/\.json$/, "")}-journaux`;
  rmSync(JOURNAUX, { recursive: true, force: true });
  mkdirSync(JOURNAUX, { recursive: true });
  const pkg = lireJson(join(DIR, "package.json"));
  if (!pkg) throw new Error(`package.json absent ou illisible : ${DIR}`);
  const pm = gestionnaire(DIR, pkg);
  const ws = espaces(DIR, pkg);
  const monorepo = ws.dossiers.length > 0;
  const apps = [DIR, ...ws.dossiers]
    .map((d) => ({ d, p: lireJson(join(d, "package.json")) }))
    .filter(({ p }) => typeApp(p))
    .map(({ d, p }) => ({ dossier: relative(DIR, d) || ".", abs: d, type: typeApp(p), ...(typeApp(p) === "expo" ? { web: webDeclare(d, p) } : {}), scripts: p.scripts ?? {} }));
  const debut = new Date();
  const racines = [DIR, resolve(dirArg)];
  const run = (nom, commande, opts = {}) => lancer(commande, { cwd: DIR, journal: join(JOURNAUX, `${nom}.txt`), racines, ...opts });
  const script = (s) => `${pm.lanceur} run ${s}`;
  console.log(`mesure de ${DIR} (${pm.nom}${pm.version ? ` ${pm.version}` : ""}${monorepo ? ", monorepo" : ""} ; apps : ${apps.map((a) => `${a.dossier} ${a.type}`).join(", ") || "aucune Next ni Expo"})`);

  let installation = await run("installation", pm.installation, { delai: DELAI_INSTALLATION });
  console.log(`  installation  ${installation.commande} → ${installation.code} (${installation.duree_s} s)`);
  const texteRefus = lireTexte(installation.journal) ?? "";
  if (installation.code !== 0 && pm.repli && pm.repli.motif.test(texteRefus)) {
    const refus = installation;
    const details = texteRefus
      .split(/\r?\n/)
      .filter((l) => pm.repli.motif.test(l) || /\b(?:Missing|Invalid):/.test(l))
      .map((l) => l.replace(/^npm (?:error|ERR!) /, "").trim())
      .slice(0, 8);
    installation = await run("installation-repli", pm.repli.commande, { delai: DELAI_INSTALLATION });
    installation.verrouDesynchronise = { refus: refus.commande, code: refus.code, details };
    console.log(`  ! verrou désynchronisé de package.json : ${refus.commande} refusé, ${installation.commande} → ${installation.code} (${installation.duree_s} s)`);
  }
  const bin = (nom, ...dossiers) => [...dossiers, DIR].map((d) => join(d, "node_modules", ".bin", nom)).find((f) => existsSync(f));
  const scripts = pkg.scripts ?? {};
  const absent = (raison) => ({ absent: true, raison });
  const controles = {};

  // typecheck
  const tc = scripts.typecheck !== undefined ? "typecheck" : scripts["type-check"] !== undefined ? "type-check" : undefined;
  const tsc = bin("tsc");
  if (tc) controles.typecheck = await run("typecheck", script(tc));
  else if (!existsSync(join(DIR, "tsconfig.json"))) controles.typecheck = absent("ni script typecheck ni tsconfig.json");
  else if (!tsc) controles.typecheck = absent("tsconfig.json sans typescript installé");
  else controles.typecheck = await run("typecheck", `${cite(tsc)} --noEmit`, { affichage: "tsc --noEmit" });

  // lint
  controles.lint = scripts.lint !== undefined ? await run("lint", script("lint")) : absent("pas de script lint");

  // tests : CI=1 (vitest et jest sans surveillance) ; jest --watch(All) direct : --watchAll=false ajouté
  if (scripts.test === undefined || PAS_DE_TEST.test(scripts.test)) controles.tests = absent("pas de script test");
  else {
    const surveille = /\bjest\b/.test(scripts.test) && /--watch/.test(scripts.test);
    const commande = surveille ? `${script("test")} ${pm.nom === "npm" ? "-- " : ""}--watchAll=false` : script("test");
    controles.tests = await run("tests", commande, { env: { CI: "1" } });
  }

  // build : racine d'un monorepo (turbo) ou app Next ; Expo : export web si l'app déclare le web
  const next = apps.find((a) => a.type === "next");
  const expo = apps.find((a) => a.type === "expo");
  if (scripts.build !== undefined && (monorepo || next?.abs === DIR)) controles.build = await run("build", script("build"));
  else if (next && next.scripts.build !== undefined) controles.build = await run("build", script("build"), { cwd: next.abs });
  else if (next) controles.build = absent("app Next sans script build");
  else if (expo?.web) {
    const exp = bin("expo", expo.abs);
    const dest = mkdtempSync(join(tmpdir(), "mesure-export-"));
    controles.build = exp
      ? await run("build", `${cite(exp)} export --platform web --output-dir ${cite(dest)}`, { cwd: expo.abs, env: { CI: "1" }, affichage: "expo export --platform web" })
      : absent("expo non installé");
    rmSync(dest, { recursive: true, force: true });
  } else if (expo) controles.build = absent("app Expo sans cible web : export sauté");
  else controles.build = absent("ni Next ni Expo");

  for (const [nom, c] of Object.entries(controles)) {
    console.log(`  ${nom.padEnd(12)}  ${c.absent ? `absent (${c.raison})` : `${c.commande} → ${c.code} (${c.duree_s} s, ${c.erreurs.length} ligne(s) d'erreur)`}`);
  }
  const git = (...a) => spawnSync("git", ["-C", DIR, ...a], { encoding: "utf8" }).stdout?.trim();
  const mesure = {
    dossier: DIR,
    commit: git("rev-parse", "HEAD") || undefined,
    debut: debut.toISOString(),
    fin: new Date().toISOString(),
    node: process.version,
    gestionnaire: { nom: pm.nom, version: pm.version ?? null, lanceur: pm.lanceur, verrous: pm.verrous },
    monorepo,
    apps: apps.map(({ dossier, type, web }) => ({ dossier, type, ...(web !== undefined ? { web } : {}) })),
    journaux: JOURNAUX,
    installation,
    controles,
  };
  writeFileSync(SORTIE, `${JSON.stringify(mesure, null, 2)}\n`);
  console.log(`mesure écrite : ${SORTIE}`);
  return mesure;
}

if (process.argv[1] && realpathSync(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const [dir, sortie] = process.argv.slice(2);
  if (!dir || !sortie) {
    console.error("usage : node mesurer.mjs <dossier de l'app> <sortie.json>");
    process.exit(1);
  }
  try {
    await mesurer(dir, sortie);
  } catch (e) {
    console.error(`✗ mesure impossible : ${e instanceof Error ? e.message : e}`);
    process.exit(1);
  }
}
