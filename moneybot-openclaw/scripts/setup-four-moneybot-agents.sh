#!/usr/bin/env bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# Creates four OpenClaw isolated agents: Capital, Media, Code, Labor.
# Idempotent: recopies workspace files; agents add may skip if id exists.
#
# SAFETY: Only touches moneybot-* ids and workspace-moneybot-* under ~/.openclaw.
# Does NOT modify main (Clawski) or whatsapp-main (Clawdia 3000).
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
schemas="${root}/schemas"
agents_root="${root}/agents"
base="${HOME}/.openclaw"

declare -a ids=(moneybot-capital moneybot-media moneybot-code moneybot-labor)
declare -a folders=(moneybot-capital moneybot-media moneybot-code moneybot-labor)

for i in "${!ids[@]}"; do
  id="${ids[$i]}"
  folder="${folders[$i]}"
  ws="${base}/workspace-${id}"
  mkdir -p "${ws}"
  cp -f "${agents_root}/${folder}/AGENTS.md" "${ws}/AGENTS.md"
  cp -f "${agents_root}/${folder}/IDENTITY.md" "${ws}/IDENTITY.md"
  rm -rf "${ws}/schemas"
  cp -R "${schemas}" "${ws}/schemas"
  echo "Workspace ready: ${ws}"
done

for i in "${!ids[@]}"; do
  id="${ids[$i]}"
  ws="${base}/workspace-${id}"
  echo ""
  echo "Registering agent ${id} ..."
  openclaw agents add "${id}" --workspace "${ws}" --non-interactive || echo "(add skipped or agent already exists - continuing)"
  openclaw agents set-identity --agent "${id}" --from-identity --workspace "${ws}"
done

echo ""
echo "Done. Run: openclaw agents list --bindings"
