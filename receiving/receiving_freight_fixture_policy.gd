extends RefCounted
class_name ReceivingFreightFixturePolicy

const MAX_CRATES := 3
const MAX_PALLETS := 2

const CRATE_BLACKLIST: Array[StringName] = [
	&"loot_000001", # SM_ComputerMouse_01
	&"loot_000025", # SM_Antibiotics_01
	&"loot_000030", # SM_Book_01
]

enum SizeBand {
	SMALL,
	MEDIUM,
	LARGE,
}


static func size_band(definition: ItemDefinition) -> SizeBand:
	if definition == null:
		return SizeBand.LARGE
	var width := definition.storage_footprint.x
	var depth := definition.storage_footprint.y
	var maximum := maxi(width, depth)
	if maximum <= 2:
		return SizeBand.SMALL
	if maximum == 3:
		return SizeBand.MEDIUM
	return SizeBand.LARGE


static func footprint_area(definition: ItemDefinition) -> int:
	if definition == null:
		return 0
	return definition.storage_footprint.x * definition.storage_footprint.y


static func is_crate_eligible(definition: ItemDefinition) -> bool:
	return (
		definition != null
		and size_band(definition) == SizeBand.SMALL
		and definition.item_id not in CRATE_BLACKLIST
	)
