[CmdletBinding()]
param(
    [ValidateSet('DryRun', 'Apply', 'Verify')]
    [string]$Mode = 'DryRun',
    [ValidateRange(0, 5)]
    [int]$Batch = 0,
    [string]$Family = '',
    [string]$ProjectRoot = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
$scriptPath = $MyInvocation.MyCommand.Path
$manifestVersion = 'environment-relocation-v1'

function New-Move([string]$Source, [string]$Category, [int]$MoveBatch) {
    $filename = Split-Path -Leaf $Source
    return [pscustomobject]@{
        Source = $Source
        Destination = "assets/environment/$Category/$filename"
        Action = 'Move'
        Batch = $MoveBatch
        Family = [IO.Path]::GetFileNameWithoutExtension($filename)
    }
}

function New-Retirement([string]$Source, [string]$CanonicalSource, [string]$Destination, [int]$MoveBatch) {
    return [pscustomobject]@{
        Source = $Source
        Destination = $Destination
        Action = 'RetireDuplicate'
        Batch = $MoveBatch
        Family = [IO.Path]::GetFileNameWithoutExtension((Split-Path -Leaf $Source))
        CanonicalSource = $CanonicalSource
    }
}

$manifest = @(
    New-Move 'assets/building_blocks/SM_Caution_01_Decal.glb' 'dressing/decals' 2
    New-Move 'assets/building_blocks/SM_Certification_Decal.glb' 'dressing/decals' 2
    New-Move 'assets/building_blocks/SM_CinderBlocks_02.glb' 'dressing/debris' 2
    New-Move 'assets/building_blocks/SM_CinderBlocks_03.glb' 'dressing/debris' 2
    New-Move 'assets/building_blocks/SM_Debris_04.glb' 'dressing/debris' 2
    New-Move 'assets/building_blocks/SM_Hallway_Door_02b.glb' 'architecture/doors' 3
    New-Move 'assets/building_blocks/SM_IronPipe_straight_02.glb' 'infrastructure/pipes' 3
    New-Move 'assets/building_blocks/SM_IronPipe_turning_01.glb' 'infrastructure/pipes' 3
    New-Move 'assets/building_blocks/SM_L_Pipe_4m_02.glb' 'infrastructure/pipes' 4
    New-Move 'assets/building_blocks/SM_L_Pipe_4m_03.glb' 'infrastructure/pipes' 3
    New-Move 'assets/building_blocks/SM_L_Pipe_4m_Valved.glb' 'infrastructure/pipes' 4
    New-Move 'assets/building_blocks/SM_L_Pipe_Bend.glb' 'infrastructure/pipes' 4
    New-Move 'assets/building_blocks/SM_L_Pipe_Joint.glb' 'infrastructure/pipes' 4
    New-Move 'assets/building_blocks/SM_L_Pipe_Terminal.glb' 'infrastructure/pipes' 3
    New-Move 'assets/building_blocks/SM_Loose_Debris_03.glb' 'dressing/debris' 2
    New-Move 'assets/floors/SM_ConstructionFloor_01.glb' 'architecture/floors' 2
    New-Move 'assets/floors/SM_Floor_2x3.glb' 'architecture/floors' 2
    New-Move 'assets/floors/SM_Hangar_floor_8x8.glb' 'architecture/floors' 4
    New-Move 'assets/floors/SM_Modular_Floor_01a.glb' 'architecture/floors' 2
    New-Move 'assets/floors/SM_Sewer_Floor_01a.glb' 'architecture/floors' 2
    New-Move 'assets/floors/SM_Walkway.glb' 'architecture/floors' 2
    New-Move 'assets/from_kitbash/SM_KB3D_MTM_PropChair_A.glb' 'furniture/seating' 2
    New-Move 'assets/from_kitbash/SM_KB3D_MTM_PropCropTomatoes_A.glb' 'dressing/decoration' 2
    New-Move 'assets/from_kitbash/SM_KB3D_MTM_PropKiosk_A.glb' 'furniture/miscellaneous' 3
    New-Move 'assets/furniture/SM_Barrel_01.glb' 'dressing/containers' 2
    New-Move 'assets/furniture/SM_ClothesCabinet.glb' 'furniture/storage' 5
    New-Move 'assets/furniture/SM_Electrical_Cabinet_03a.glb' 'infrastructure/electrical' 4
    New-Move 'assets/furniture/SM_FuelCanister.glb' 'dressing/containers' 2
    New-Move 'assets/furniture/SM_Generator_01.glb' 'infrastructure/electrical' 4
    New-Retirement 'assets/furniture/SM_Hallway_Door_02b.glb' 'assets/building_blocks/SM_Hallway_Door_02b.glb' 'assets/environment/architecture/doors/SM_Hallway_Door_02b.glb' 3
    New-Move 'assets/furniture/SM_MetalShelves.glb' 'furniture/storage' 5
    New-Move 'assets/furniture/SM_MilitaryCrate_02_base.glb' 'dressing/containers' 2
    New-Move 'assets/furniture/SM_MilitaryRadio.glb' 'infrastructure/communications' 4
    New-Move 'assets/furniture/SM_pipe_02_b.glb' 'infrastructure/pipes' 3
    New-Move 'assets/furniture/SM_PortaCabinDoor.glb' 'architecture/doors' 3
    New-Move 'assets/furniture/SM_ShootingRange_lane_dividers_table.glb' 'furniture/work_surfaces' 3
    New-Move 'assets/furniture/SM_Table.glb' 'furniture/work_surfaces' 5
    New-Move 'assets/furniture/SM_Tool_Cabinet_01a.glb' 'furniture/storage' 3
    New-Move 'assets/furniture/SM_ventilated_locker.glb' 'furniture/storage' 5
    New-Move 'assets/lights/SM_AlarmLight.glb' 'infrastructure/lighting' 4
    New-Move 'assets/lights/SM_Fluoresent_Light_Tube_01b.glb' 'infrastructure/lighting' 4
    New-Move 'assets/lights/SM_Lamp_long.glb' 'infrastructure/lighting' 4
    New-Move 'assets/lights/SM_Sewer_Light_Wall_Fixture_On.glb' 'infrastructure/lighting' 4
    New-Move 'assets/walls/SM_Sewer_Wall_Arch_01a.glb' 'architecture/walls' 4
    New-Move 'assets/walls/SM_Sewer_Wall_Brick_01a.glb' 'architecture/walls' 4
    New-Move 'assets/walls/SM_Sewer_Wall_Brick_01c.glb' 'architecture/walls' 2
    New-Move 'assets/walls/SM_Sewer_Wall_Cinder_01a.glb' 'architecture/walls' 4
    New-Move 'assets/walls/SM_Sewer_Wall_Cinder_01b.glb' 'architecture/walls' 2
    New-Move 'assets/walls/SM_Sewer_Wall_Cinder_01c.glb' 'architecture/walls' 2
    New-Move 'assets/walls/SM_Wall_2M.glb' 'architecture/walls' 2
)

$holdPaths = @(
    'assets/characters/SKM_Quinn_Simple.glb',
    'assets/props/Food/SM_Dry_Goods_01h.glb',
    'assets/props/Food/SM_Dry_Goods_NN_01a.glb',
    'assets/props/Food/SM_Jar_01.glb',
    'assets/props/Fuel/SM_Firewood_02.glb',
    'assets/props/Fuel/SM_LargeFuelJug.glb',
    'assets/props/Fuel/SM_PropaneTank_01.glb',
    'assets/props/medical/SM_Pill_Bottle_01b.glb',
    'assets/props/morale/SM_RubikCube_01.glb',
    'assets/props/protection/SM_Balaclava_01.glb',
    'assets/props/protection/SM_ConstructionHelmet_1.glb',
    'assets/props/protection/SM_HardHat_02.glb',
    'assets/props/protection/SM_Jacket_01.glb',
    'assets/props/protection/SM_Pants_01.glb',
    'assets/props/protection/SM_Shoes_01.glb',
    'assets/props/protection/SM_Shoes_02.glb',
    'assets/props/protection/SM_Sweater_01.glb',
    'assets/props/Weapons/SM_BaseballBat_01.glb'
)

function To-Absolute([string]$RepoPath) {
    return Join-Path $ProjectRoot ($RepoPath.Replace('/', '\'))
}

function To-Res([string]$RepoPath) {
    return 'res://' + $RepoPath.Replace('\', '/')
}

function Get-PathHash([string]$ResourcePath) {
    $md5 = [Security.Cryptography.MD5]::Create()
    try {
        $bytes = [Text.Encoding]::UTF8.GetBytes($ResourcePath)
        return ([BitConverter]::ToString($md5.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant()
    } finally {
        $md5.Dispose()
    }
}

function Get-FamilyFiles([string]$PrimaryPath) {
    $absolute = To-Absolute $PrimaryPath
    $directory = Split-Path -Parent $absolute
    $family = [IO.Path]::GetFileNameWithoutExtension((Split-Path -Leaf $absolute))
    if (-not (Test-Path -LiteralPath $directory -PathType Container)) { return @() }
    return @(
        Get-ChildItem -LiteralPath $directory -File -Force |
            Where-Object { $_.Name.StartsWith($family, [StringComparison]::OrdinalIgnoreCase) } |
            Sort-Object Name
    )
}

function Get-LootPaths {
    $definitionDirectory = To-Absolute 'data/items/definitions'
    $paths = @()
    foreach ($file in Get-ChildItem -LiteralPath $definitionDirectory -Filter 'loot_*.tres' -File | Sort-Object Name) {
        $content = [IO.File]::ReadAllText($file.FullName)
        $match = [regex]::Match($content, '(?m)^\[ext_resource type="PackedScene" path="([^"]+)"')
        if (-not $match.Success) { throw "Missing PackedScene visual in $($file.FullName)" }
        $paths += $match.Groups[1].Value
    }
    return $paths
}

function Get-TrackedReferenceFiles([string]$OldResourcePath) {
    $extensions = @('.gd', '.tscn', '.tres', '.res', '.cfg', '.json', '.txt', '.md', '.shader', '.gdshader', '.godot')
    $files = @(& git -C $ProjectRoot ls-files)
    $hits = @()
    foreach ($repoPath in $files) {
        $absolute = To-Absolute $repoPath
        if ($absolute -eq $scriptPath -or -not (Test-Path -LiteralPath $absolute -PathType Leaf)) { continue }
        if ([IO.Path]::GetExtension($absolute).ToLowerInvariant() -notin $extensions) { continue }
        $content = [IO.File]::ReadAllText($absolute)
        if ($content.Contains($OldResourcePath)) { $hits += $repoPath.Replace('\', '/') }
    }
    return $hits
}

function Assert-SidecarPreservable([IO.FileInfo]$File) {
    if ($File.Extension -ieq '.import') { return }
    $sidecar = $File.FullName + '.import'
    if (-not (Test-Path -LiteralPath $sidecar -PathType Leaf)) {
        throw "Missing import sidecar: $sidecar"
    }
    $content = [IO.File]::ReadAllText($sidecar)
    if (-not $content.Contains('[params]') -or -not $content.Contains('source_file=')) {
        throw "Import metadata cannot be preserved: $sidecar"
    }
}

function Assert-DuplicateMatches([object]$Retirement, [object]$CanonicalMove) {
    $duplicateFiles = @(Get-FamilyFiles $Retirement.Source | Where-Object { $_.Extension -ine '.import' })
    $canonicalPrimary = if (Test-Path -LiteralPath (To-Absolute $CanonicalMove.Source)) { $CanonicalMove.Source } else { $CanonicalMove.Destination }
    $canonicalFiles = @(Get-FamilyFiles $canonicalPrimary | Where-Object { $_.Extension -ine '.import' })
    if ($duplicateFiles.Count -eq 0) { return }
    if ($duplicateFiles.Count -ne $canonicalFiles.Count) { throw 'Duplicate Hallway Door source-file counts differ.' }
    foreach ($duplicate in $duplicateFiles) {
        $canonical = $canonicalFiles | Where-Object Name -ceq $duplicate.Name
        if (@($canonical).Count -ne 1) { throw "Duplicate Hallway Door counterpart is missing or ambiguous: $($duplicate.Name)" }
        if ((Get-FileHash -LiteralPath $duplicate.FullName -Algorithm SHA256).Hash -ne (Get-FileHash -LiteralPath $canonical.FullName -Algorithm SHA256).Hash) {
            throw "Duplicate Hallway Door hash mismatch: $($duplicate.Name)"
        }
    }
}

function Invoke-Preflight {
    if (-not (Test-Path -LiteralPath (To-Absolute 'assets') -PathType Container)) { throw 'Authoritative local assets directory is missing.' }
    $branch = (& git -C $ProjectRoot branch --show-current).Trim()
    if ([string]::IsNullOrWhiteSpace($branch) -or $branch -in @('main', 'master')) { throw "Unsafe branch state: '$branch'" }
    if ($manifest.Count -ne 50) { throw "Unexpected primary manifest count: $($manifest.Count)" }
    if (@($manifest | Where-Object Action -eq 'Move').Count -ne 49) { throw 'Expected 49 move primaries.' }
    if (@($manifest | Where-Object Action -eq 'RetireDuplicate').Count -ne 1) { throw 'Expected one duplicate retirement.' }
    if ($holdPaths.Count -ne 18) { throw 'Expected 18 HOLD exclusions.' }

    $lootPaths = @(Get-LootPaths)
    if ($lootPaths.Count -ne 42 -or @($lootPaths | Sort-Object -Unique).Count -ne 42) { throw 'Catalogue does not contain 42 unique loot visuals.' }
    $manifestPaths = @($manifest.Source + $manifest.Destination | ForEach-Object { To-Res $_ })
    $overlap = @($lootPaths | Where-Object { $_ -in $manifestPaths })
    if ($overlap.Count -gt 0) { throw "Loot path entered environment manifest: $($overlap -join ', ')" }
    foreach ($hold in $holdPaths) {
        if ($hold -in $manifest.Source -or $hold -in $manifest.Destination) { throw "HOLD path entered environment manifest: $hold" }
    }

    $moves = @($manifest | Where-Object Action -eq 'Move')
    $destinationGroups = @($moves | Group-Object { $_.Destination.ToLowerInvariant() } | Where-Object Count -gt 1)
    if ($destinationGroups.Count -gt 0) { throw "Case-insensitive destination collision: $($destinationGroups.Name -join ', ')" }

    $states = @()
    foreach ($row in $manifest) {
        $sourceExists = Test-Path -LiteralPath (To-Absolute $row.Source) -PathType Leaf
        $destinationExists = Test-Path -LiteralPath (To-Absolute $row.Destination) -PathType Leaf
        if ($row.Action -eq 'Move') {
            if ($sourceExists -and $destinationExists) { throw "Source and destination both exist: $($row.Source)" }
            if (-not $sourceExists -and -not $destinationExists) { throw "Source and destination both missing: $($row.Source)" }
            $currentPrimary = if ($sourceExists) { $row.Source } else { $row.Destination }
            $familyFiles = @(Get-FamilyFiles $currentPrimary)
            if ($familyFiles.Count -lt 2) { throw "Incomplete asset family: $currentPrimary" }
            foreach ($file in $familyFiles | Where-Object Extension -ine '.import') { Assert-SidecarPreservable $file }
            $states += [pscustomobject]@{ Row = $row; State = $(if ($sourceExists) { 'Pending' } else { 'Complete' }); Files = $familyFiles }
        } else {
            $states += [pscustomobject]@{ Row = $row; State = $(if ($sourceExists) { 'Pending' } else { 'Complete' }); Files = @(Get-FamilyFiles $row.Source) }
        }
    }

    foreach ($directory in @('assets/building_blocks', 'assets/floors', 'assets/from_kitbash', 'assets/furniture', 'assets/lights', 'assets/walls')) {
        $pendingRows = @($states | Where-Object { $_.State -eq 'Pending' -and (Split-Path -Parent $_.Row.Source) -eq $directory })
        if ($pendingRows.Count -eq 0) { continue }
        foreach ($file in Get-ChildItem -LiteralPath (To-Absolute $directory) -File -Force) {
            $owners = @($pendingRows | Where-Object { $file.Name.StartsWith($_.Row.Family, [StringComparison]::OrdinalIgnoreCase) })
            if ($owners.Count -ne 1) { throw "Supporting-file ownership is ambiguous or missing: $($file.FullName)" }
        }
    }

    $retirement = $manifest | Where-Object Action -eq 'RetireDuplicate'
    $canonical = $manifest | Where-Object Source -eq $retirement.CanonicalSource
    Assert-DuplicateMatches $retirement $canonical

    foreach ($state in $states | Where-Object { $_.Row.Action -eq 'Move' -and $_.State -eq 'Pending' }) {
        $oldRes = To-Res $state.Row.Source
        $state | Add-Member -NotePropertyName TrackedReferences -NotePropertyValue @(Get-TrackedReferenceFiles $oldRes)
    }
    return $states
}

function Update-ImportMetadata([string]$SidecarPath, [string]$OldResourcePath, [string]$NewResourcePath) {
    $content = [IO.File]::ReadAllText($SidecarPath)
    $oldHash = Get-PathHash $OldResourcePath
    $newHash = Get-PathHash $NewResourcePath
    $updated = $content.Replace($OldResourcePath, $NewResourcePath).Replace($oldHash, $newHash)
    if ($updated -eq $content) { throw "Import metadata did not contain expected old path/hash: $SidecarPath" }
    [IO.File]::WriteAllText($SidecarPath, $updated, [Text.UTF8Encoding]::new($false))
}

function Update-TrackedReferences([object]$State) {
    $oldRes = To-Res $State.Row.Source
    $newRes = To-Res $State.Row.Destination
    foreach ($repoPath in @($State.TrackedReferences)) {
        $absolute = To-Absolute $repoPath
        $content = [IO.File]::ReadAllText($absolute)
        $updated = $content.Replace($oldRes, $newRes)
        [IO.File]::WriteAllText($absolute, $updated, [Text.UTF8Encoding]::new($false))
    }
}

function Invoke-Move([object]$State) {
    $row = $State.Row
    $sourceDirectory = Split-Path -Parent (To-Absolute $row.Source)
    $destinationDirectory = Split-Path -Parent (To-Absolute $row.Destination)
    [void](New-Item -ItemType Directory -Path $destinationDirectory -Force)
    $movedSources = 0
    $movedSidecars = 0
    foreach ($file in $State.Files) {
        $destination = Join-Path $destinationDirectory $file.Name
        Move-Item -LiteralPath $file.FullName -Destination $destination
        if ($file.Extension -ieq '.import') {
            $sourceName = $file.Name.Substring(0, $file.Name.Length - '.import'.Length)
            $oldResource = To-Res ((Split-Path -Parent $row.Source) + '/' + $sourceName)
            $newResource = To-Res ((Split-Path -Parent $row.Destination) + '/' + $sourceName)
            Update-ImportMetadata $destination $oldResource $newResource
            $movedSidecars++
        } else {
            $movedSources++
        }
    }
    Update-TrackedReferences $State
    return [pscustomobject]@{ Sources = $movedSources; Sidecars = $movedSidecars }
}

function Invoke-Retirement([object]$State) {
    $removedSources = 0
    $removedSidecars = 0
    foreach ($file in $State.Files) {
        Remove-Item -LiteralPath $file.FullName -Force
        if ($file.Extension -ieq '.import') { $removedSidecars++ } else { $removedSources++ }
    }
    return [pscustomobject]@{ Sources = $removedSources; Sidecars = $removedSidecars }
}

$states = @(Invoke-Preflight)
$selected = @($states | Where-Object {
    $_.State -eq 'Pending' -and
    ($Batch -eq 0 -or $_.Row.Batch -eq $Batch) -and
    ([string]::IsNullOrWhiteSpace($Family) -or $_.Row.Family -eq $Family)
})

Write-Output "MANIFEST_VERSION=$manifestVersion"
Write-Output "MANIFEST_PRIMARY=$($manifest.Count)"
Write-Output "MOVE_PRIMARY=$(@($manifest | Where-Object Action -eq 'Move').Count)"
Write-Output "RETIRE_PRIMARY=$(@($manifest | Where-Object Action -eq 'RetireDuplicate').Count)"
Write-Output 'LOOT_EXCLUDED=42'
Write-Output 'HOLD_EXCLUDED=18'
Write-Output "PENDING_PRIMARY=$(@($states | Where-Object State -eq 'Pending').Count)"
Write-Output "COMPLETE_PRIMARY=$(@($states | Where-Object State -eq 'Complete').Count)"
Write-Output "SELECTED_PRIMARY=$($selected.Count)"
Write-Output 'PREFLIGHT=PASS'

foreach ($state in $selected) {
    $references = if ($null -eq $state.TrackedReferences) { @() } else { @($state.TrackedReferences) }
    Write-Output "PLAN $($state.Row.Action) batch=$($state.Row.Batch) $($state.Row.Source) -> $($state.Row.Destination) files=$($state.Files.Count) refs=$($references -join ',')"
}

if ($Mode -eq 'DryRun') {
    Write-Output 'DRY_RUN=PASS'
    exit 0
}

if ($Mode -eq 'Verify') {
    if ($selected.Count -gt 0) { throw 'Verification found pending manifest entries.' }
    Write-Output 'VERIFY=PASS'
    exit 0
}

if ($selected.Count -eq 0) {
    Write-Output 'APPLY=NO_OP'
    exit 0
}

$selectedRetirement = @($selected | Where-Object { $_.Row.Action -eq 'RetireDuplicate' })
if ($selectedRetirement.Count -gt 0) {
    $retirement = $selectedRetirement[0].Row
    $canonical = $manifest | Where-Object Source -eq $retirement.CanonicalSource
    Assert-DuplicateMatches $retirement $canonical
    Write-Output 'DUPLICATE_HASH_RECHECK=PASS'
}

$movedSources = 0
$movedSidecars = 0
$retiredSources = 0
$retiredSidecars = 0
foreach ($state in $selected | Sort-Object { $_.Row.Action -eq 'RetireDuplicate' }, { $_.Row.Source }) {
    if ($state.Row.Action -eq 'Move') {
        $result = Invoke-Move $state
        $movedSources += $result.Sources
        $movedSidecars += $result.Sidecars
    } else {
        $result = Invoke-Retirement $state
        $retiredSources += $result.Sources
        $retiredSidecars += $result.Sidecars
    }
}

Write-Output "MOVED_SOURCE_FILES=$movedSources"
Write-Output "MOVED_SIDECARS=$movedSidecars"
Write-Output "RETIRED_SOURCE_FILES=$retiredSources"
Write-Output "RETIRED_SIDECARS=$retiredSidecars"
Write-Output 'APPLY=PASS'
