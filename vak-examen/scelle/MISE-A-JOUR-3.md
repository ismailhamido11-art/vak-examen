# Troisième mise à jour du contrôleur, pour le prochain examen

Tu as écrit `controleur/` d'après `REGLE.md`, `PAGE-VAK.md` et `CAHIER.md`, tous trois dans ce dossier, puis tu l'as mis
à jour deux fois. Les examens du 10/10 et du 11/10 ont été joués avec lui. Trois défauts du contrôleur y ont été
relevés. Les essais cités sont dans `essais/`, avec `wacrm`, « réussi » aujourd'hui, qui doit le rester.

Ce que tu fais :
1. **Une app bun.** À workout_app_1, le point 1 est faux d'office (« gestionnaire de paquets non géré (bun) ») : l'app
   a `bun.lock` et pas de `packageManager`, quoi qu'ait fait l'agent. Une app bun se traite comme les autres :
   - le gestionnaire se décide sur le commit de préparation, comme npm, pnpm et yarn (`bun.lock` ou `bun.lockb` dans
     son arbre, dans `pmDe`) : un verrou d'un autre gestionnaire ajouté au HEAD reste une note du point 3, et
     l'installation reste bun avant et après ;
   - l'installation : `bun install --frozen-lockfile`, puis `bun install` si l'installation stricte échoue, avant et
     après l'intégration ; les vérifications de l'app (typecheck, lint, test, build) par `bun run <script>` ;
   - bun par `bun` s'il est sur la machine, sinon par `npx -y --package=bun@<version> bun`, où `<version>` est celle de
     `packageManager` (`bun@x.y.z`), sinon une version fixe écrite dans le contrôleur (1.3.11). Dans cette bulle, bun
     n'est pas sur la machine : la branche `npx` doit marcher, et elle est éprouvée ici. Écris dans `verdict.json` la
     version de bun utilisée ;
   - au point 3, `bun.lock` (du JSON avec virgules finales) se compare comme les autres verrous : chaque entrée de
     `packages` garde son `nom@version` et son empreinte (`sha512-…`), chaque spécificateur de `workspaces` garde sa
     valeur, seuls des ajouts sont permis. Aujourd'hui, rien de `bun.lock` n'est lu : un verrou bun changé passerait
     sans un mot.

   À workout_app_1, l'agent a ajouté `@vak/agent` à `package.json` avec npm, sans toucher `bun.lock` : l'installation
   stricte passe avant et est refusée après. Le point 2 y devient `verrou`, comme il le serait avec npm. C'est
   attendu, et ce n'est pas un défaut de ta correction.
2. **Le chemin du clone dans les erreurs.** À supabase_nextjs_template_1, le point 2 compte une erreur de typecheck
   comme nouvelle (« 1 erreur(s) nouvelle(s) (2 → 2 erreurs distinctes) ») : l'erreur de `lib/i18n.ts(10,37)` existait
   avant l'intégration, mais son texte cite un fichier de `node_modules` par son chemin absolu, `…/clones/prep/…`
   avant et `…/clones/head/…` après. Compare les erreurs avec le dossier de chaque clone remplacé par un même repère
   (avant comme après, dans tout le texte de l'erreur), et rien d'autre.
3. **« code=0 » écrit par une autre commande.** À abonnements_1, l'agent a lancé
   `node node_modules/@vak/agent/bin/vak.mjs 2>&1 | tail -60; echo code=$?; cat supabase/migrations/…` (des lignes
   SQL suivent « code=0 » dans la sortie). La sortie montre « vak doctor : doctor : à corriger (…) [code 1] », puis
   « code=0 » : `$?` y est le code de `tail`, la dernière commande du tube. Le repli « rc=0 écrit par l'agent » y a vu
   un « vak » qui rend 0 (durée, point 6). compteurs_2, au deuxième examen, a la même commande (son essai n'est pas
   fourni). Désormais :
   - une ligne finale de vak dont le code n'est pas 0 (`vak[ <commande>] : … [code N]`, N ≠ 0) dans la même sortie
     annule tout repli pour cette commande (« rc=0 », phrase « Fini pour l'agent de code ») ;
   - le repli « rc=0 » ne compte que si la ligne du repli (`rc=0`, `code=0`, `exit=0` ou `status=0`, comme
     aujourd'hui) est la sortie d'un `echo` qui suit directement le lancement de vak (par `;`, `&&` ou une nouvelle
     ligne), et que le code écrit est celui de vak : `$?` quand vak est seul, sans tube, sans `!`, `||` ni `&` ;
     `${PIPESTATUS[0]}` dans cet `echo` même, quand vak est le premier élément du tube qui le précède ; `$?` après un
     tube seulement si `set -o pipefail` (ou `-eo pipefail`, `-euo pipefail`) est posé plus tôt dans la même commande.
     S'il y a plusieurs `echo` de code dans la commande, le repli ne compte pas ;
   - la ligne finale de vak (« vak : fini (…) [code 0] ») fait toujours foi.
4. Rien d'autre ne change.
5. Pour chaque point, un test dans `controleur/tests/` qui échoue sans ta correction (au point 1, dont un `bun.lock`
   qui change la version d'un paquet existant : point 3 en échec, `version changée` ; au point 3, un test fait de la
   commande et de la sortie d'abonnements_1). Rejoue les essais de `essais/` et écris leurs verdicts dans
   `controleur/verdicts-examen-11-10/<id>.json`. Ne touche pas à `verdicts-repetition/` : maybewe et makerkit ne sont
   pas là ; le verdict de wacrm va, comme les autres, dans `verdicts-examen-11-10/`. Les six sabotages de la règle
   seront rejoués hors de cette session, sur le contrôleur que tu rends. Mets à jour `controleur/README.md`.

Termine par un compte rendu court : chaque correction, son test, et le verdict de chaque essai de `essais/`.
