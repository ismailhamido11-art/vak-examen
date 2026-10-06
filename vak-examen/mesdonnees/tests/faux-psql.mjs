#!/usr/bin/env node
// Remplace psql dans les tests : lit la table dans le SQL du juge et rend le nombre de FAUX_COMPTES (JSON { "schéma.table": n }).
import { readFileSync } from "node:fs";
const sql = process.argv[process.argv.indexOf("-c") + 1] ?? "";
const m = sql.match(/from "([^"]+)"\."([^"]+)" where "([^"]+)" = '([0-9a-f-]{36})'/);
if (!m || !/set local role authenticated/.test(sql) || !/request\.jwt\.claims/.test(sql)) { console.error("SQL inattendu : " + sql); process.exit(1); }
const comptes = JSON.parse(readFileSync(process.env.FAUX_COMPTES, "utf8"));
const n = comptes[`${m[1]}.${m[2]}`];
if (n === undefined) { console.error("table inconnue du faux psql : " + m[1] + "." + m[2]); process.exit(1); }
console.log('{"sub":"..."}');
console.log(String(n));
