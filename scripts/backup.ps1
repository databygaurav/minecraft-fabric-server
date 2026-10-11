[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$ServerDir, [Parameter(Mandatory=$true)][string]$BackupRoot)
. "$PSScriptRoot\common.ps1"
$server = Get-ServerPath $ServerDir
$world = Get-WorldPath $server
if (-not (Test-Path -LiteralPath (Join-Path $world 'level.dat') -PathType Leaf)) { throw 'World level.dat is missing.' }
# Destination must already exist, and be outside the server and this repository.
$root = Get-ServerPath $BackupRoot
$repo = (Resolve-Path -LiteralPath "$PSScriptRoot\..").ProviderPath.TrimEnd('\')
foreach ($excluded in @($server,$repo)) {
    if ($root -eq $excluded -or $root.StartsWith($excluded + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'BackupRoot must be outside the server directory and repository.' }
}
$guard = Enter-Maintenance $server
try {
    Assert-NoJava
    Assert-WorldUnlocked $world
    $id = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssfffZ') + '-' + [guid]::NewGuid().ToString('N').Substring(0,8)
    $stage = Join-Path $root ($id + '.partial')
    New-Item -ItemType Directory -Path $stage | Out-Null
    $before = @(Get-Manifest $world)
    Copy-World $world (Join-Path $stage 'world')
    Assert-NoJava
    Assert-WorldUnlocked $world
    Assert-SameManifest $before @(Get-Manifest $world)
    Assert-SameManifest $before @(Get-Manifest (Join-Path $stage 'world'))
    ConvertTo-Json -InputObject $before -Depth 3 | Set-Content -LiteralPath (Join-Path $stage 'manifest.json') -Encoding UTF8
    Move-Item -LiteralPath $stage -Destination (Join-Path $root $id)
    Write-Output (Join-Path $root $id)
} finally { $guard.Dispose() }
