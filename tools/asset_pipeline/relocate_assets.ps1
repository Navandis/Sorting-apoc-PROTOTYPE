[CmdletBinding()]
param(
    [switch]$Apply,
    [string]$ProjectRoot = (Get-Location).Path,
    [string]$GodotPath = 'D:\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe'
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
$scriptPath = $MyInvocation.MyCommand.Path

$moveSpecs = @(
    @{ From = 'assets/props'; To = 'assets/props/Weapons'; Names = @('SM_Gun_AssaultRifle', 'SM_Gun_Pistol', 'SM_Gun_Shotgun') }
    @{ From = 'assets/props'; To = 'assets/props/Hydration'; Names = @('SM_Metal_Can_01a') }
    @{ From = 'assets/props'; To = 'assets/props/medical'; Names = @('SM_Pill_Bottle_01a', 'SM_Pill_Bottle_01b') }
    @{ From = 'assets/props/tools'; To = 'assets/props/Weapons'; Names = @('SM_Hammer_3') }
    @{ From = 'assets/props/from_blender'; To = 'assets/props/Food'; Names = @('cereal_box') }
    @{ From = 'assets/props/from_blender'; To = 'assets/props/Weapons'; Names = @('hammer', 'tennis_racket') }
    @{ From = 'assets/props/from_blender'; To = 'assets/props/medical'; Names = @('pill_bottle') }
    @{ From = 'assets/props/from_blender'; To = 'assets/props/Hydration'; Names = @('soda_can') }
)

$textExtensions = @('.gd', '.tscn', '.tres', '.res', '.cfg', '.json', '.txt', '.md', '.shader', '.gdshader', '.godot')

function To-RepoPath([string]$Path) {
    return $Path.Substring($ProjectRoot.Length + 1).Replace('\', '/')
}

function To-AbsolutePath([string]$RepoPath) {
    return Join-Path $ProjectRoot ($RepoPath.Replace('/', '\'))
}

function Get-Manifest {
    $rows = @()
    foreach ($spec in $moveSpecs) {
        $fromAbsolute = To-AbsolutePath $spec.From
        $toAbsolute = To-AbsolutePath $spec.To
        foreach ($name in $spec.Names) {
            $files = @(Get-ChildItem -LiteralPath $fromAbsolute -File -Force | Where-Object {
                $_.Name -like "$name*"
            })
            foreach ($file in $files) {
                $destination = Join-Path $toAbsolute $file.Name
                $rows += [pscustomobject]@{
                    Source = To-RepoPath $file.FullName
                    Destination = To-RepoPath $destination
                    Type = $file.Extension.ToLowerInvariant()
                    Size = $file.Length
                    IsSidecar = ($file.Extension -ieq '.import')
                    DestinationExists = (Test-Path -LiteralPath $destination -PathType Leaf)
                }
            }
        }
    }
    return $rows
}

function Get-AuthoredTextFiles {
    $excluded = @(
        (Join-Path $ProjectRoot '.git'),
        (Join-Path $ProjectRoot '.godot'),
        (Join-Path $ProjectRoot 'assets')
    )
    return @(Get-ChildItem -LiteralPath $ProjectRoot -Recurse -File -Force | Where-Object {
        $path = $_.FullName
        $extension = $_.Extension.ToLowerInvariant()
        $extension -in $textExtensions -and
        $path -ne $scriptPath -and
        ($excluded | Where-Object { $path.StartsWith($_ + '\', [System.StringComparison]::OrdinalIgnoreCase) }).Count -eq 0
    })
}

function Get-AuthoredReferences($manifest) {
    $references = @()
    $files = Get-AuthoredTextFiles
    foreach ($file in $files) {
        $content = [System.Text.Encoding]::UTF8.GetString([System.IO.File]::ReadAllBytes($file.FullName))
        foreach ($row in @($manifest | Where-Object { -not $_.IsSidecar })) {
            $oldRes = 'res://' + $row.Source
            if ($content.Contains($oldRes)) {
                $references += [pscustomobject]@{ File = To-RepoPath $file.FullName; Old = $oldRes; New = 'res://' + $row.Destination }
            }
        }
    }
    return $references
}

function Replace-Bytes([string]$FilePath, [string]$OldText, [string]$NewText) {
    $encoding = [System.Text.UTF8Encoding]::new($false)
    $content = $encoding.GetString([System.IO.File]::ReadAllBytes($FilePath))
    if (-not $content.Contains($OldText)) { return $false }
    $updated = $content.Replace($OldText, $NewText)
    [System.IO.File]::WriteAllBytes($FilePath, $encoding.GetBytes($updated))
    return $true
}

function Update-AuthoredResourceUids($manifest) {
    foreach ($row in @($manifest | Where-Object { -not $_.IsSidecar })) {
        $sidecarPath = To-AbsolutePath ($row.Destination + '.import')
        if (-not (Test-Path -LiteralPath $sidecarPath -PathType Leaf)) { throw "Missing regenerated sidecar: $($row.Destination).import" }
        $sidecar = [System.Text.Encoding]::UTF8.GetString([System.IO.File]::ReadAllBytes($sidecarPath))
        $uidMatch = [regex]::Match($sidecar, '(?m)^uid="([^"]+)"')
        if (-not $uidMatch.Success) { throw "Regenerated sidecar has no UID: $($row.Destination).import" }
        $newResource = 'res://' + $row.Destination
        $pattern = '(?m)(uid=")[^"]+(" path="' + [regex]::Escape($newResource) + '")'
        foreach ($file in Get-AuthoredTextFiles) {
            $filePath = $file.FullName
            $content = [System.Text.Encoding]::UTF8.GetString([System.IO.File]::ReadAllBytes($filePath))
            $updated = [regex]::Replace($content, $pattern, '${1}' + $uidMatch.Groups[1].Value + '${2}')
            if ($updated -ne $content) {
                [System.IO.File]::WriteAllBytes($filePath, [System.Text.UTF8Encoding]::new($false).GetBytes($updated))
            }
        }
    }
}
function Invoke-GodotImport {
    if (-not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) { throw "Godot console executable not found: $GodotPath" }
    & $GodotPath --headless --editor --path $ProjectRoot --quit
    if ($LASTEXITCODE -ne 0) { throw "Godot import/rescan failed with exit code $LASTEXITCODE" }
}

$manifest = @(Get-Manifest)
if ($manifest.Count -ne 78) { throw "Unexpected manifest size: $($manifest.Count); expected 78." }
$collisions = @($manifest | Where-Object DestinationExists)
if ($collisions.Count -gt 0) {
    $collisions | ForEach-Object { Write-Error "Destination collision: $($_.Destination)" }
    throw 'Preflight aborted before writing.'
}
$references = @(Get-AuthoredReferences $manifest)
Write-Output "Manifest: $($manifest.Count) files; source files: $(@($manifest | Where-Object { -not $_.IsSidecar }).Count); sidecars: $(@($manifest | Where-Object IsSidecar).Count); collisions: 0"
Write-Output "Authored files with old references: $(@($references | Select-Object -ExpandProperty File -Unique) -join ', ')"
$references | ForEach-Object { Write-Output "  $($_.File): $($_.Old) -> $($_.New)" }
if (-not $Apply) {
    Write-Output 'Preflight only. Re-run with -Apply to perform the relocation.'
    exit 0
}

foreach ($directory in @($manifest | ForEach-Object { Split-Path -Parent (To-AbsolutePath $_.Destination) } | Select-Object -Unique)) {
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
}

foreach ($row in $manifest) {
    Move-Item -LiteralPath (To-AbsolutePath $row.Source) -Destination (To-AbsolutePath $row.Destination)
}

foreach ($reference in $references) {
    $filePath = To-AbsolutePath $reference.File
    [void](Replace-Bytes $filePath $reference.Old $reference.New)
}

Invoke-GodotImport

$staleSidecars = @()
foreach ($row in @($manifest | Where-Object IsSidecar)) {
    $sidecarPath = To-AbsolutePath $row.Destination
    if (-not (Test-Path -LiteralPath $sidecarPath -PathType Leaf)) { continue }
    $sidecar = [System.Text.Encoding]::UTF8.GetString([System.IO.File]::ReadAllBytes($sidecarPath))
    $oldSource = 'res://' + ($row.Source -replace '\.import$', '')
    if ($sidecar.Contains($oldSource)) { $staleSidecars += $sidecarPath }
}
if ($staleSidecars.Count -gt 0) {
    Write-Output "Godot left $($staleSidecars.Count) stale sidecars; removing only those sidecars and re-running import."
    $staleSidecars | ForEach-Object { Remove-Item -LiteralPath $_ -Force }
    Invoke-GodotImport
}

Update-AuthoredResourceUids $manifest
$remainingOld = @(Get-AuthoredReferences $manifest)
if ($remainingOld.Count -gt 0) { throw 'Old authored references remain after replacement.' }
$missingNew = @($manifest | Where-Object { -not (Test-Path -LiteralPath (To-AbsolutePath $_.Destination) -PathType Leaf) })
if ($missingNew.Count -gt 0) { throw 'One or more relocated files are missing after import.' }
$oldFiles = @($manifest | Where-Object { Test-Path -LiteralPath (To-AbsolutePath $_.Source) -PathType Leaf })
if ($oldFiles.Count -gt 0) { throw 'One or more old source paths remain after relocation.' }
Write-Output 'Relocation and static verification completed.'