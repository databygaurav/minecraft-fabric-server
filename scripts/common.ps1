# Shared safety checks. Compatible with Windows PowerShell 5.1 and PowerShell 7.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-PlainTree([string]$Path) {
    $item = Get-Item -LiteralPath $Path -Force
    $cursor = $item
    while ($null -ne $cursor) {
        if ($cursor.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Junctions and symbolic links are not supported.' }
        $cursor = $cursor.Parent
    }
    foreach ($child in Get-ChildItem -LiteralPath $Path -Force -Recurse) {
        if ($child.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Junctions and symbolic links are not supported.' }
    }
}
function Get-ServerPath([string]$Path) {
    $resolved = (Resolve-Path -LiteralPath $Path).ProviderPath
    if (-not (Test-Path -LiteralPath $resolved -PathType Container)) { throw 'ServerDir must be a directory.' }
    Assert-PlainTree $resolved
    return $resolved.TrimEnd('\')
}
function Get-Properties([string]$Path) {
    $properties = @{}
    foreach ($line in Get-Content -LiteralPath $Path) {
        if ($line -match '^\s*[#!]' -or [string]::IsNullOrWhiteSpace($line)) { continue }
        if ($line -notmatch '^([^=]+)=(.*)$') { throw "Unsupported property syntax: expected key=value." }
        $key = $Matches[1].Trim()
        if ($properties.ContainsKey($key)) { throw "Duplicate property: $key" }
        $properties[$key] = $Matches[2].Trim()
    }
    return $properties
}
function Get-WorldPath([string]$Server) {
    $p = Get-Properties (Join-Path $Server 'server.properties')
    $name = $p['level-name']
    if ($name -notmatch '^[A-Za-z0-9_-]+$') { throw 'level-name must be a simple directory name (letters, digits, underscore, hyphen).' }
    return Join-Path $Server $name
}
function Assert-NoJava {
    # Conservative by design: also blocks a running Java Minecraft client.
    $running = @(Get-Process -ErrorAction Stop | Where-Object { $_.ProcessName -in @('java','javaw') })
    if ($running.Count -gt 0) { throw 'Java is running. Gracefully stop the server and close Java clients before this operation.' }
}
function Enter-Maintenance([string]$Server) {
    try { return [IO.File]::Open((Join-Path $Server '.management.lock'), 'OpenOrCreate', 'ReadWrite', 'None') }
    catch { throw 'Another management operation is active, or the server directory is not writable.' }
}
function Assert-WorldUnlocked([string]$World) {
    $lock = Join-Path $World 'session.lock'
    if (Test-Path -LiteralPath $lock) {
        try { $stream = [IO.File]::Open($lock, 'Open', 'ReadWrite', 'None'); $stream.Dispose() }
        catch { throw 'World session.lock is held or inaccessible. Stop the server first.' }
    }
}
function Get-Manifest([string]$Root) {
    @(Get-ChildItem -LiteralPath $Root -File -Recurse -Force | Where-Object { $_.Name -ne 'session.lock' } | ForEach-Object {
        [pscustomobject]@{ Path = $_.FullName.Substring($Root.Length + 1); SHA256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash }
    } | Sort-Object Path)
}
function Assert-SameManifest($Expected, $Actual) {
    $a = @($Expected | ForEach-Object { "$($_.Path)|$($_.SHA256)" } | Sort-Object)
    $b = @($Actual | ForEach-Object { "$($_.Path)|$($_.SHA256)" } | Sort-Object)
    if ($a.Count -ne $b.Count -or @(Compare-Object $a $b).Count -ne 0) { throw 'Backup integrity verification failed.' }
}
function Copy-World([string]$Source, [string]$Destination) {
    New-Item -ItemType Directory -Path $Destination -ErrorAction Stop | Out-Null
    foreach ($item in Get-ChildItem -LiteralPath $Source -Force) {
        if ($item.Name -ne 'session.lock') { Copy-Item -LiteralPath $item.FullName -Destination $Destination -Recurse -Force }
    }
}
