[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
param([Parameter(Mandatory=$true)][string]$ServerDir, [Parameter(Mandatory=$true)][string]$BackupPath)
. "$PSScriptRoot\common.ps1"
$server = Get-ServerPath $ServerDir
$world = Get-WorldPath $server
$backup = Get-ServerPath $BackupPath
if ($backup.EndsWith('.partial')) { throw 'Incomplete backups cannot be restored.' }
if ($backup -eq $server -or $backup.StartsWith($server + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'BackupPath must be outside ServerDir.' }
$source = Join-Path $backup 'world'
if (-not (Test-Path -LiteralPath (Join-Path $source 'level.dat') -PathType Leaf)) { throw 'Backup world level.dat is missing.' }
$expected = Get-Content -LiteralPath (Join-Path $backup 'manifest.json') -Raw | ConvertFrom-Json
Assert-SameManifest $expected @(Get-Manifest $source)
if (-not $PSCmdlet.ShouldProcess($world, 'Restore verified backup and retain existing world in a rollback directory')) { return }
# Additional explicit confirmation cannot be bypassed with -Confirm:$false.
if ((Read-Host 'Type RESTORE to replace the world (the old world will be retained)') -cne 'RESTORE') { throw 'Restore cancelled.' }
$guard = Enter-Maintenance $server
try {
    Assert-NoJava
    Assert-WorldUnlocked $world
    $suffix = [guid]::NewGuid().ToString('N')
    $stage = Join-Path $server ('.restore-' + $suffix)
    $rollback = Join-Path $server ('.rollback-' + $suffix)
    Copy-World $source $stage
    Assert-SameManifest $expected @(Get-Manifest $stage)
    Assert-NoJava
    Assert-WorldUnlocked $world
    $hadWorld = Test-Path -LiteralPath $world
    if ($hadWorld) { Move-Item -LiteralPath $world -Destination $rollback }
    try { Move-Item -LiteralPath $stage -Destination $world }
    catch {
        if ($hadWorld -and -not (Test-Path -LiteralPath $world)) { Move-Item -LiteralPath $rollback -Destination $world }
        throw
    }
    Write-Output "Restored world. Previous world, if present, retained at: $rollback"
} finally { $guard.Dispose() }
