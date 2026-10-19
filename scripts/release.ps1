param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [string]$OutputDirectory = (Join-Path (Split-Path -Parent $PSScriptRoot) 'dist')
)

$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'validate_skill.ps1') -Root $Root

$manifest = Get-Content -Raw -LiteralPath (Join-Path $Root 'manifest.json') | ConvertFrom-Json
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$archive = Join-Path $OutputDirectory "$($manifest.name)-v$($manifest.version).zip"
if (Test-Path -LiteralPath $archive) { Remove-Item -LiteralPath $archive -Force }

$staging = Join-Path ([System.IO.Path]::GetTempPath()) "$($manifest.name)-$([guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory -Force -Path $staging | Out-Null
try {
    foreach ($relative in $manifest.files) {
        $source = Join-Path $Root $relative
        $destination = Join-Path $staging $relative
        $parent = Split-Path -Parent $destination
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
        Copy-Item -LiteralPath $source -Destination $destination
    }
    Compress-Archive -Path (Join-Path $staging '*') -DestinationPath $archive -CompressionLevel Optimal
}
finally {
    Remove-Item -LiteralPath $staging -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output "Created: $archive"
