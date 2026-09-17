[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$issPath = Join-Path $root 'LuaForWindows.iss'
$iss = Get-Content -Raw -LiteralPath $issPath

function Assert-File([string] $relativePath) {
    $path = Join-Path $root $relativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required installer input is missing: $relativePath"
    }
}

Assert-File 'files/LICENSE.txt'
Assert-File 'files/lua5.1.exe'
Assert-File 'files/luac5.1.exe'
Assert-File 'files/wlua5.1.exe'
Assert-File 'files/lua5.1.dll'
Assert-File 'files/lua51.dll'
Assert-File 'support/SciTEGlobal.black.properties'
Assert-File 'vcredist_x86.exe'

# The installer must not depend on the retired, insecure HTTP endpoints.
$httpUrls = [regex]::Matches($iss, '(?i)https?://[^\s"'']+') |
    ForEach-Object { $_.Value } |
    Where-Object { $_ -like 'http://*' }
if ($httpUrls) {
    throw "Insecure HTTP URL(s) found in LuaForWindows.iss: $($httpUrls -join ', ')"
}

# Keep the output name and displayed version synchronized with the script.
$version = [regex]::Match($iss, '#define MyAppDisplayVer "([^"]+)"').Groups[1].Value
if ([string]::IsNullOrWhiteSpace($version)) {
    throw 'Could not find MyAppDisplayVer in LuaForWindows.iss'
}
$output = Join-Path $root "LuaForWindows_v$version.exe"
if (Test-Path -LiteralPath $output) {
    Remove-Item -LiteralPath $output -Force
}

Write-Host "Installer inputs are valid. Expected output: $output"
