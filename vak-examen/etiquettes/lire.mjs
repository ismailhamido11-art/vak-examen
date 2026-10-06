#!/usr/bin/env node
// Lit l'étiquette de l'assistant d'un essai sur la pile locale (REGLE.md, « Comment on compte les seuils ») : la route
// publique `GET config` du protocole de vak, telle que l'app commitée la sert, dans sa langue par défaut. Node 22,
// aucune dépendance.
// Usage : node vak-examen/etiquettes/lire.mjs <pile.json>  →  JSON sur la sortie standard :
// { lue_le, langue, nom, etiquette: [5 lignes], destinations, fournisseurs_accord, prises, empreintes: { schema, calibrage } }
import { readFileSync } from "node:fs";

const [fichier] = process.argv.slice(2);
if (!fichier) {
  console.error("usage : node vak-examen/etiquettes/lire.mjs <pile.json>");
  process.exit(2);
}
const pile = JSON.parse(readFileSync(fichier, "utf8"));
const reponse = await fetch(`${pile.fonction}/config`, { headers: { apikey: pile.anon } });
if (!reponse.ok) {
  console.error(`✗ GET config : HTTP ${reponse.status} ${(await reponse.text()).slice(0, 200)}`);
  process.exit(1);
}
const c = await reponse.json();
if (!Array.isArray(c.label) || c.label.length === 0) {
  console.error("✗ GET config ne rend aucune étiquette (champ label)");
  process.exit(1);
}
console.log(
  JSON.stringify(
    {
      lue_le: new Date().toISOString(),
      langue: c.lang ?? null,
      nom: c.name ?? null,
      etiquette: c.label,
      destinations: c.destinations ?? [],
      fournisseurs_accord: c.consent?.providers ?? [],
      prises: (c.plugins ?? []).map((p) => p.id),
      empreintes: { schema: c.schemaHash ?? null, calibrage: c.calibrationHash ?? null },
    },
    null,
    2,
  ),
);
