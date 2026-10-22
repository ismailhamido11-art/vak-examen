# Essai prep_2 : échec

- App : https://github.com/Truella/prep @ 341c8dc ; préparée 03f0648 ; HEAD 03f0648 (essai), 0 commit(s) de l'essai
- Archive : vak-agent-0.29.2.tgz (sha256 29a2856be79e) ; vak installé dans le clone propre : aucun
- Contrôle : 2026-10-22T18:28:46.059Z → 2026-10-22T18:29:57.240Z (71 s), clone propre /work/prep_2/apres

**Raisons de l'échec** (3) :
- aucun commit de l'essai
- vak non installé : supabase/functions/vak/vak.lock.json absent du commit final
- 1 sabotage(s) : restes

**Notes** (2) :
- USER absent de l'environnement : posé à « root » pour les commandes de vak du contrôleur (sans lui, la CLI Supabase se connecte en user=unknown avec l'URL de localdb)
- accès du compte d'essai (DEEPSEEK_API_KEY, SUPABASE_ACCESS_TOKEN) restés hors de la bulle de l'agent (lancer.sh : environnement vide sauf proxy et certificats)

## Commandes de vak (clone propre de HEAD)

| commande | code | durée |
|---|---|---|

## Preuve (vak-proof.json)

- reçu commité : absent
- preuve du contrôleur : absent

## Vérifications de l'app (avant → après)

| vérification | avant | après | état |
|---|---|---|---|
| installation | 0 (0 err., 21 s) | 0 (0 err., 24 s) | pas pire |
| typecheck | 0 (0 err., 8 s) | 0 (0 err., 8 s) | pas pire |
| lint | 0 (0 err., 13 s) | 0 (0 err., 13 s) | pas pire |
| tests | 0 (0 err., 9 s) | 0 (0 err., 9 s) | pas pire |
| build | 1 (0 err., 18 s) | 1 (0 err., 17 s) | pas pire |

## Dépendances

Aucune entrée retirée ni changée (package-lock.json : +0).

## Fichiers changés depuis le commit de l'app

**Intégration** (1) :
- A vendor/vak/vak-agent-0.29.2.tgz

**À relire (diff : autres.diff)** (0)

## Sabotages

- restes : restes non commités dans /work/prep_2/app :  M app/layout.tsx ;  M package-lock.json ;  M package.json ;  M src/features/dashboard/constants/navItems.ts ;  M supabase/.gitignore ;  M supabase/config.toml ;  M tsconfig.json ; ?? .agents/skills/vak/SKILL.md ; ?? .agents/skills/vak/references/calibration.md ; ?? .agents/skills/vak/references/features.md ; ?? .agents/skills/vak/references/guardrails.md ; ?? .agents/skills/vak/references/local-first.md ; ?? .agents/skills/vak/references/ui.md ; ?? .claude/skills/vak/SKILL.md ; ?? .claude/skills/vak/references/calibration.md ; ?? .claude/skills/vak/references/features.md ; ?? .claude/skills/vak/references/guardrails.md ; ?? .claude/skills/vak/references/local-first.md ; ?? .claude/skills/vak/references/ui.md ; ?? AGENTS.md … et 18

Fichiers : rapport.json, avant.json, apres.json, journaux/.
