# Installs MoneyBot skills into the current user's OpenClaw skills directory
# and mirrors the full pack to ~/.openclaw/moneybot-openclaw for reference.
#
# SAFETY: Only adds/overwrites moneybot-* skill folders under .openclaw/skills.
# Does not change main agent (Clawski), whatsapp-main (Clawdia 3000), or openclaw.json agent list.
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$skillSrc = Join-Path $here ".openclaw\skills"
$dst = Join-Path $env:USERPROFILE ".openclaw\skills"
$mirror = Join-Path $env:USERPROFILE ".openclaw\moneybot-openclaw"

New-Item -ItemType Directory -Force -Path $dst | Out-Null
Get-ChildItem $skillSrc -Directory | ForEach-Object {
  $target = Join-Path $dst $_.Name
  if (Test-Path $target) { Remove-Item $target -Recurse -Force }
  Copy-Item $_.FullName -Destination $target -Recurse -Force
  Write-Host "OK: $($_.Name)"
}
if (Test-Path $mirror) { Remove-Item $mirror -Recurse -Force }
Copy-Item $here -Destination $mirror -Recurse -Force
Write-Host "Mirror: $mirror"
Write-Host "Run: openclaw skills list | Select-String moneybot"
