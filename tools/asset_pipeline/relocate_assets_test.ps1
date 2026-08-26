param(
    [string]$ProjectRoot = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'
$moves = @(
    @{ Old = 'assets/props/SM_Gun_AssaultRifle.glb'; New = 'assets/props/Weapons/SM_Gun_AssaultRifle.glb' }
    @{ Old = 'assets/props/SM_Gun_Pistol.glb'; New = 'assets/props/Weapons/SM_Gun_Pistol.glb' }
    @{ Old = 'assets/props/SM_Gun_Shotgun.glb'; New = 'assets/props/Weapons/SM_Gun_Shotgun.glb' }
    @{ Old = 'assets/props/SM_Metal_Can_01a.glb'; New = 'assets/props/Hydration/SM_Metal_Can_01a.glb' }
    @{ Old = 'assets/props/SM_Pill_Bottle_01a.glb'; New = 'assets/props/medical/SM_Pill_Bottle_01a.glb' }
    @{ Old = 'assets/props/SM_Pill_Bottle_01b.glb'; New = 'assets/props/medical/SM_Pill_Bottle_01b.glb' }
    @{ Old = 'assets/props/tools/SM_Hammer_3.glb'; New = 'assets/props/Weapons/SM_Hammer_3.glb' }
    @{ Old = 'assets/props/from_blender/cereal_box.glb'; New = 'assets/props/Food/cereal_box.glb' }
    @{ Old = 'assets/props/from_blender/hammer.glb'; New = 'assets/props/Weapons/hammer.glb' }
    @{ Old = 'assets/props/from_blender/pill_bottle.glb'; New = 'assets/props/medical/pill_bottle.glb' }
    @{ Old = 'assets/props/from_blender/soda_can.glb'; New = 'assets/props/Hydration/soda_can.glb' }
    @{ Old = 'assets/props/from_blender/tennis_racket.glb'; New = 'assets/props/Weapons/tennis_racket.glb' }
)
function Assert-Condition([bool]$Condition, [string]$Message) { if (-not $Condition) { throw "ASSERTION FAILED: $Message" } }
$main = Get-Content -Raw -LiteralPath (Join-Path $ProjectRoot 'main.tscn')
$catalog = Get-Content -Raw -LiteralPath (Join-Path $ProjectRoot 'prototype_item_catalog.gd')
foreach ($move in $moves) {
    $oldAbsolute = Join-Path $ProjectRoot ($move.Old -replace '/', '\')
    $newAbsolute = Join-Path $ProjectRoot ($move.New -replace '/', '\')
    Assert-Condition (Test-Path -LiteralPath $newAbsolute -PathType Leaf) "new source missing: $($move.New)"
    Assert-Condition (-not (Test-Path -LiteralPath $oldAbsolute -PathType Leaf)) "old source remains: $($move.Old)"
    Assert-Condition (-not $main.Contains("res://$($move.Old)")) "old main reference remains: $($move.Old)"
    Assert-Condition (-not $catalog.Contains("res://$($move.Old)")) "old catalog reference remains: $($move.Old)"
    Assert-Condition ($main.Contains("res://$($move.New)") -or $catalog.Contains("res://$($move.New)")) "new authored reference missing: $($move.New)"
    Assert-Condition (-not (Test-Path -LiteralPath "$oldAbsolute.import" -PathType Leaf)) "old sidecar remains: $($move.Old).import"
    Assert-Condition (Test-Path -LiteralPath "$newAbsolute.import" -PathType Leaf) "new sidecar missing: $($move.New).import"
}
Write-Output "PASS: $($moves.Count) mapped GLB paths and sidecars verified."