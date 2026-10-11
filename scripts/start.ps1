[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$ServerDir,
    [ValidateRange(1,16)][int]$MinMemoryGB = 2,
    [ValidateRange(1,16)][int]$MaxMemoryGB = 4,
    [switch]$CheckOnly
)
. "$PSScriptRoot\common.ps1"
if ($MinMemoryGB -gt $MaxMemoryGB) { throw 'Minimum memory cannot exceed maximum memory.' }
if (-not $env:JAVA_HOME) { throw 'JAVA_HOME is not set. Install Temurin JDK 25 and reopen the terminal.' }
$java = Join-Path $env:JAVA_HOME 'bin\java.exe'
if (-not (Test-Path -LiteralPath $java -PathType Leaf)) { throw 'JAVA_HOME does not contain bin\java.exe.' }
$server = Get-ServerPath $ServerDir
$jar = Join-Path $server 'fabric-server.jar'
if (-not (Test-Path -LiteralPath $jar -PathType Leaf)) { throw 'fabric-server.jar is missing from ServerDir.' }
# Java writes its version to stderr; Process avoids PowerShell 5.1 native-stderr errors.
$info = New-Object Diagnostics.ProcessStartInfo
$info.FileName = $java
$info.Arguments = '-version'
$info.UseShellExecute = $false
$info.RedirectStandardError = $true
$info.CreateNoWindow = $true
$process = [Diagnostics.Process]::Start($info)
$version = $process.StandardError.ReadToEnd()
$process.WaitForExit()
if ($process.ExitCode -ne 0 -or $version -notmatch 'version "25[.\"]') { throw 'This project requires Java 25. Check JAVA_HOME.' }
$process.Dispose()
$world = Get-WorldPath $server
$properties = Get-Properties (Join-Path $server 'server.properties')
if ($properties['online-mode'] -ne 'true') { Write-Warning 'Authentication is disabled. Whitelist cannot prevent username impersonation. Read docs/security.md.' }
if ($CheckOnly) { Write-Output 'Startup prerequisites passed; server was not started.'; return }
$guard = Enter-Maintenance $server
try {
    Assert-NoJava
    Assert-WorldUnlocked $world
    Push-Location -LiteralPath $server
    try {
        & $java "-Xms$($MinMemoryGB)G" "-Xmx$($MaxMemoryGB)G" -jar $jar nogui
        if ($LASTEXITCODE -ne 0) { throw "Server exited with code $LASTEXITCODE. Review its private logs." }
    } finally { Pop-Location }
} finally { $guard.Dispose() }
