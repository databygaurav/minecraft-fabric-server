[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
. "$root\scripts\common.ps1"
foreach ($file in Get-ChildItem -LiteralPath $root -Filter *.ps1 -Recurse) {
    $tokens = $null; $errors = $null
    [void][Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors)
    if ($errors.Count) { throw "PowerShell parse error in $($file.Name): $errors" }
}
$p = Get-Properties "$root\config\server.properties.example"
$required = @{
    'online-mode'='true'; 'white-list'='true'; 'enforce-whitelist'='true'
    'enable-rcon'='false'; 'enable-query'='false'; 'server-ip'=''
    'difficulty'='hard'; 'server-port'='25565'; 'max-players'='2'
    'level-name'='world'; 'spawn-protection'='0'
}
foreach ($key in $required.Keys) {
    if (-not $p.ContainsKey($key) -or $p[$key] -cne $required[$key]) { throw "Unsafe/missing example setting: $key" }
}
foreach ($key in @('view-distance','simulation-distance')) {
    if ([int]$p[$key] -lt 2 -or [int]$p[$key] -gt 10) { throw "Unexpected distance: $key" }
}
Write-Output 'PASS: PowerShell syntax and safe example configuration.'
