# Creates four OpenClaw isolated agents: Capital, Media, Code, Labor.
# Idempotent: recopies workspace files; re-runs agents add (may error if agent id exists).
#
# SAFETY: Only touches agent ids moneybot-capital|media|code|labor and dirs workspace-moneybot-*.
# Does NOT modify main (Clawski), whatsapp-main (Clawdia 3000), or any channel bindings.
# Never add openclaw agents bind here without a dedicated channel for MoneyBot.
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$schemas = Join-Path $root "schemas"
$agentsRoot = Join-Path $root "agents"
$base = Join-Path $env:USERPROFILE ".openclaw"

$defs = @(
  @{ Id = "moneybot-capital"; Folder = "moneybot-capital" },
  @{ Id = "moneybot-media";   Folder = "moneybot-media" },
  @{ Id = "moneybot-code";    Folder = "moneybot-code" },
  @{ Id = "moneybot-labor";   Folder = "moneybot-labor" }
)

foreach ($d in $defs) {
  $ws = Join-Path $base ("workspace-" + $d.Id)
  New-Item -ItemType Directory -Force -Path $ws | Out-Null
  $srcAgent = Join-Path $agentsRoot $d.Folder
  Copy-Item (Join-Path $srcAgent "AGENTS.md") -Destination (Join-Path $ws "AGENTS.md") -Force
  Copy-Item (Join-Path $srcAgent "IDENTITY.md") -Destination (Join-Path $ws "IDENTITY.md") -Force
  $sch = Join-Path $ws "schemas"
  if (Test-Path $sch) { Remove-Item $sch -Recurse -Force }
  Copy-Item $schemas -Destination $sch -Recurse -Force
  Write-Host "Workspace ready: $ws"
}

foreach ($d in $defs) {
  $ws = Join-Path $base ("workspace-" + $d.Id)
  Write-Host "`nRegistering agent $($d.Id) ..."
  openclaw agents add $d.Id --workspace $ws --non-interactive 2>&1
  if ($LASTEXITCODE -ne 0) {
    Write-Host "(add skipped or agent already exists - continuing)"
  }
  openclaw agents set-identity --agent $d.Id --from-identity --workspace $ws 2>&1
}

Write-Host "`nDone. Run: openclaw agents list --bindings"
