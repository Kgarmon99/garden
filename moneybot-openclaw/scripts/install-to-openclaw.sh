#!/usr/bin/env bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# Installs MoneyBot skills into ~/.openclaw/skills/ and mirrors this pack
# to ~/.openclaw/moneybot-openclaw (macOS / Linux).
# Does not change main / whatsapp-main agents.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
skill_src="${root}/.openclaw/skills"
dst="${HOME}/.openclaw/skills"
mirror="${HOME}/.openclaw/moneybot-openclaw"

mkdir -p "${dst}"
for dir in "${skill_src}"/*/; do
  name="$(basename "${dir}")"
  target="${dst}/${name}"
  rm -rf "${target}"
  cp -R "${dir}" "${target}"
  echo "OK: ${name}"
done
rm -rf "${mirror}"
cp -R "${root}" "${mirror}"
echo "Mirror: ${mirror}"
echo "Run: openclaw skills list | grep moneybot || true"
