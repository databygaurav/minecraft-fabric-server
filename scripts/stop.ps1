[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$ServerDir, [ValidateRange(1,3600)][int]$TimeoutSeconds = 120)
. "$PSScriptRoot\common.ps1"
$server = Get-ServerPath $ServerDir
$world = Get-WorldPath $server
Write-Host 'In the Minecraft server console, type: stop'
Write-Host 'Wait for saving and shutdown to finish. Close any Java client too. This helper never kills a process or sends RCON commands.'
$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
do {
    try {
        Assert-NoJava
        Assert-WorldUnlocked $world
        Write-Output 'No Java processes remain and the world lock is available.'
        return
    } catch {
        if ((Get-Date) -ge $deadline) { throw 'Timed out waiting for a clean shutdown. No process was killed.' }
        Start-Sleep -Seconds 2
    }
} while ($true)
