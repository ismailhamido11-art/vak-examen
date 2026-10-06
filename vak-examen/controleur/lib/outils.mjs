// Outils communs : processus, git, empreintes, extraits. Aucune dépendance npm.
import { spawn, execFileSync } from 'node:child_process';
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

export const sha256 = (buf) => crypto.createHash('sha256').update(buf).digest('hex');

// git en lecture seule sur le dépôt de l'essai : GIT_OPTIONAL_LOCKS=0 pour ne rien écrire dans app/.git.
export function git(cwd, args, { buffer = false, tolerant = false } = {}) {
  try {
    const out = execFileSync('git', ['-c', 'core.quotepath=off', ...args], {
      cwd,
      env: { ...process.env, GIT_OPTIONAL_LOCKS: '0', GIT_TERMINAL_PROMPT: '0' },
      maxBuffer: 1 << 30,
      stdio: ['ignore', 'pipe', 'pipe'],
    });
    return buffer ? out : out.toString('utf8');
  } catch (e) {
    if (tolerant) return buffer ? null : null;
    throw new Error(`git ${args.join(' ')} : ${String(e.stderr || e.message).trim()}`);
  }
}

export const gitShow = (cwd, rev, file) => git(cwd, ['show', `${rev}:${file}`], { tolerant: true });
export const gitShowBuf = (cwd, rev, file) => git(cwd, ['show', `${rev}:${file}`], { buffer: true, tolerant: true });

// Arbre d'une révision : { chemin -> { mode, sha } }
export function arbre(cwd, rev) {
  const out = git(cwd, ['ls-tree', '-r', '-z', rev]);
  const m = new Map();
  for (const rec of out.split('\0')) {
    if (!rec) continue;
    const tab = rec.indexOf('\t');
    const [mode, , sha] = rec.slice(0, tab).split(' ');
    m.set(rec.slice(tab + 1), { mode, sha });
  }
  return m;
}

// Lance une commande shell dans son propre groupe de processus ; la tue à l'échéance.
export function sh(cmd, { cwd, env = {}, timeoutMs = 20 * 60_000, logFile } = {}) {
  return new Promise((resolve) => {
    const t0 = Date.now();
    const child = spawn('bash', ['-c', cmd], {
      cwd,
      env: { ...process.env, ...env },
      detached: true,
      stdio: ['ignore', 'pipe', 'pipe'],
    });
    const chunks = [];
    let taille = 0;
    const garder = (b) => {
      if (taille < 64 << 20) { chunks.push(b); taille += b.length; }
    };
    child.stdout.on('data', garder);
    child.stderr.on('data', garder);
    let timedOut = false;
    const minuteur = setTimeout(() => {
      timedOut = true;
      try { process.kill(-child.pid, 'SIGKILL'); } catch { /* déjà fini */ }
    }, timeoutMs);
    const fin = (code, signal) => {
      clearTimeout(minuteur);
      const out = Buffer.concat(chunks).toString('utf8');
      if (logFile) {
        fs.mkdirSync(path.dirname(logFile), { recursive: true });
        fs.writeFileSync(logFile, `$ ${cmd}\n# cwd ${cwd}\n\n${out}\n# code ${code} signal ${signal} délai ${timedOut} ${Date.now() - t0} ms\n`);
      }
      resolve({ code: timedOut ? null : code, signal, timedOut, out, ms: Date.now() - t0 });
    };
    child.on('error', (e) => { chunks.push(Buffer.from(String(e))); fin(127, null); });
    child.on('close', fin);
  });
}

export const sansCouleurs = (s) => s.replace(/\x1b\[[0-9;?]*[A-Za-z]/g, '');

export function derniereLignes(txt, n = 15) {
  const l = sansCouleurs(txt).split('\n').filter((x) => x.trim() !== '');
  return l.slice(-n).map((x) => x.slice(0, 300));
}

export const court = (s, n = 240) => {
  const t = String(s).replace(/\s+/g, ' ').trim();
  return t.length > n ? `${t.slice(0, n - 1)}…` : t;
};

export const lireJson = (f) => JSON.parse(fs.readFileSync(f, 'utf8'));

export function supprimer(dir) {
  fs.rmSync(dir, { recursive: true, force: true, maxRetries: 3 });
}
