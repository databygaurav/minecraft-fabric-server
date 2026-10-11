[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$scripts = Join-Path $root 'scripts'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('fabric-tests-' + [guid]::NewGuid().ToString('N'))
$server = Join-Path $fixture 'server'
$backups = Join-Path $fixture 'backups'
New-Item -ItemType Directory -Path "$server\world\playerdata",$backups | Out-Null
Set-Content -LiteralPath "$server\server.properties" -Value "level-name=world`nonline-mode=true"
Set-Content -LiteralPath "$server\world\level.dat" -Value 'synthetic-level'
Set-Content -LiteralPath "$server\world\playerdata\fixture.dat" -Value 'synthetic-inventory'
Set-Content -LiteralPath "$server\world\session.lock" -Value 'synthetic-lock'
. "$scripts\common.ps1"
$script:Count = 0
function Assert-True($Condition, [string]$Message) {
    if (-not $Condition) { throw "FAIL: $Message" }
    $script:Count++
    Write-Host "PASS: $Message"
}
function Assert-Throws([scriptblock]$Action, [string]$Pattern, [string]$Message) {
    $caught = $false
    try { & $Action | Out-Null } catch {
        if ($_.Exception.Message -notmatch $Pattern) { throw }
        $caught = $true
    }
    Assert-True $caught $Message
}
# Process and confirmation fakes are scoped to this test run. All mutations use
# the randomly created synthetic directory above. No Java server is launched.
$global:FabricTestFakeJava = $false
$global:FabricTestReply = 'RESTORE'
function Get-Process { [CmdletBinding()]param(); if ($global:FabricTestFakeJava) { [pscustomobject]@{ ProcessName='java' } } }
function Read-Host { param([string]$Prompt); return $global:FabricTestReply }
try {
    $global:FabricTestFakeJava = $true
    Assert-Throws { & "$scripts\backup.ps1" -ServerDir $server -BackupRoot $backups } 'Java is running' 'backup blocks active Java'
    Assert-Throws { & "$scripts\stop.ps1" -ServerDir $server -TimeoutSeconds 1 } 'Timed out' 'stop timeout never kills processes'
    $global:FabricTestFakeJava = $false
    & "$scripts\stop.ps1" -ServerDir $server | Out-Null
    Assert-True $true 'stop succeeds after clean shutdown'
    $guard = Enter-Maintenance $server
    try { Assert-Throws { & "$scripts\backup.ps1" -ServerDir $server -BackupRoot $backups } 'management operation' 'concurrent maintenance is blocked' }
    finally { $guard.Dispose() }
    $lock = [IO.File]::Open("$server\world\session.lock", 'Open', 'ReadWrite', 'None')
    try { Assert-Throws { & "$scripts\backup.ps1" -ServerDir $server -BackupRoot $backups } 'session.lock' 'locked world is blocked' }
    finally { $lock.Dispose() }
    Assert-Throws { & "$scripts\backup.ps1" -ServerDir $server -BackupRoot $server } 'outside' 'backup inside runtime is rejected'
    $snapshot = & "$scripts\backup.ps1" -ServerDir $server -BackupRoot $backups
    Assert-True (Test-Path -LiteralPath "$snapshot\manifest.json") 'completed backup has manifest'
    Assert-True (-not (Test-Path -LiteralPath "$snapshot\world\session.lock")) 'ephemeral session lock excluded'
    Assert-True ((Get-Content -LiteralPath "$snapshot\world\playerdata\fixture.dat") -eq 'synthetic-inventory') 'player data preserved'
    Set-Content -LiteralPath "$server\world\level.dat" -Value 'newer-world'
    & "$scripts\restore.ps1" -ServerDir $server -BackupPath $snapshot -WhatIf
    Assert-True ((Get-Content -LiteralPath "$server\world\level.dat") -eq 'newer-world') 'WhatIf leaves world unchanged'
    $global:FabricTestReply = 'NO'
    Assert-Throws { & "$scripts\restore.ps1" -ServerDir $server -BackupPath $snapshot -Confirm:$false } 'cancelled' 'explicit restore refusal is honored'
    $global:FabricTestReply = 'RESTORE'
    & "$scripts\restore.ps1" -ServerDir $server -BackupPath $snapshot -Confirm:$false | Out-Null
    Assert-True ((Get-Content -LiteralPath "$server\world\level.dat") -eq 'synthetic-level') 'restore round trip succeeds'
    $rollback = @(Get-ChildItem -LiteralPath $server -Directory -Force | Where-Object { $_.Name -like '.rollback-*' })
    Assert-True ($rollback.Count -eq 1 -and (Get-Content -LiteralPath (Join-Path $rollback[0].FullName 'level.dat')) -eq 'newer-world') 'previous world retained intact'
    Set-Content -LiteralPath "$snapshot\world\level.dat" -Value 'corrupted'
    Assert-Throws { & "$scripts\restore.ps1" -ServerDir $server -BackupPath $snapshot -WhatIf } 'integrity' 'corrupt backup rejected'
    Set-Content -LiteralPath "$server\server.properties" -Value 'level-name=..\escape'
    Assert-Throws { & "$scripts\backup.ps1" -ServerDir $server -BackupRoot $backups } 'simple directory' 'world path traversal rejected'
    Assert-Throws { & "$scripts\start.ps1" -ServerDir $server -MinMemoryGB 4 -MaxMemoryGB 2 -CheckOnly } 'Minimum memory' 'invalid heap range rejected'
    $savedHome = $env:JAVA_HOME
    try {
        $env:JAVA_HOME = $fixture
        Assert-Throws { & "$scripts\start.ps1" -ServerDir $server -CheckOnly } 'bin\\java.exe' 'missing Java rejected'
    } finally { $env:JAVA_HOME = $savedHome }
    Write-Host "All $script:Count assertions passed. Synthetic test directory: $fixture"
} finally {
    Remove-Variable -Name FabricTestFakeJava,FabricTestReply -Scope Global -ErrorAction SilentlyContinue
    # Remove only the exact temporary fixture created by this test invocation.
    $resolved = [IO.Path]::GetFullPath($fixture)
    $tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\') + '\'
    if (-not $resolved.StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase) -or (Split-Path $resolved -Leaf) -notmatch '^fabric-tests-[a-f0-9]{32}$') { throw 'Unsafe test cleanup path.' }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}
