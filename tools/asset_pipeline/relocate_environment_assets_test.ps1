param(
    [string]$ProjectRoot = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
$toolPath = Join-Path $ProjectRoot 'tools/asset_pipeline/relocate_environment_assets.ps1'

function Assert-Condition([bool]$Condition, [string]$Message) {
    if (-not $Condition) {
        throw "ASSERTION FAILED: $Message"
    }
}

Assert-Condition (Test-Path -LiteralPath $toolPath -PathType Leaf) 'environment relocation tool exists'

$before = @(
    Get-ChildItem -LiteralPath (Join-Path $ProjectRoot 'assets') -Recurse -File -Force |
        ForEach-Object FullName |
        Sort-Object
)
$output = @(& $toolPath -ProjectRoot $ProjectRoot -Mode DryRun 2>&1)
$exitCode = $LASTEXITCODE
$after = @(
    Get-ChildItem -LiteralPath (Join-Path $ProjectRoot 'assets') -Recurse -File -Force |
        ForEach-Object FullName |
        Sort-Object
)

Assert-Condition ($exitCode -eq 0) 'dry run exits zero'
Assert-Condition (($output -join "`n").Contains('MANIFEST_PRIMARY=50')) 'manifest covers 50 approved primaries'
Assert-Condition (($output -join "`n").Contains('MOVE_PRIMARY=49')) 'manifest relocates 49 canonical primaries'
Assert-Condition (($output -join "`n").Contains('RETIRE_PRIMARY=1')) 'manifest retires exactly one duplicate primary'
Assert-Condition (($output -join "`n").Contains('LOOT_EXCLUDED=42')) 'all catalogue loot visuals are excluded'
Assert-Condition (($output -join "`n").Contains('HOLD_EXCLUDED=18')) 'all approved HOLD primaries are excluded'
Assert-Condition (($output -join "`n").Contains('PREFLIGHT=PASS')) 'complete preflight passes'
Assert-Condition (($before.Count -eq $after.Count)) 'dry run preserves asset file count'
Assert-Condition (-not (Compare-Object $before $after)) 'dry run preserves every asset path'

Write-Output 'PASS: environment relocation manifest and dry-run contract verified.'
