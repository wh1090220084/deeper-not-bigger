param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
$skill = Join-Path $Root 'SKILL.md'
$manifest = Join-Path $Root 'manifest.json'
$ui = Join-Path $Root 'agents/openai.yaml'

foreach ($path in @($skill, $manifest, $ui)) {
    if (-not (Test-Path -LiteralPath $path)) { throw "Missing required file: $path" }
}

$text = Get-Content -Raw -Encoding utf8 -LiteralPath $skill
if (-not $text.StartsWith('---')) { throw 'SKILL.md must start with YAML frontmatter.' }
if ($text -notmatch '(?m)^name:\s*ambitious-task-upgrader\s*$') { throw 'Invalid skill name.' }
if ($text -notmatch '(?m)^description:\s*.+$') { throw 'Missing skill description.' }
if ($text -notmatch 'L1' -or $text -notmatch 'L2' -or $text -notmatch 'L3') { throw 'Missing tier routing.' }
if ($text -notmatch 'prompt-rewrite') { throw 'Missing prompt rewrite gate.' }
if ($text -notmatch 'external-review') { throw 'Missing external validation ladder.' }

$data = Get-Content -Raw -Encoding utf8 -LiteralPath $manifest | ConvertFrom-Json
if ($data.name -ne 'ambitious-task-upgrader') { throw 'manifest name does not match.' }
if ($data.version -notmatch '^\d+\.\d+\.\d+$') { throw 'manifest version must use SemVer.' }
foreach ($relative in $data.files) {
    if (-not (Test-Path -LiteralPath (Join-Path $Root $relative))) { throw "manifest file is missing: $relative" }
}

Write-Output "OK: ambitious-task-upgrader v$($data.version)"
