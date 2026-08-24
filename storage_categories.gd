extends RefCounted
class_name StorageCategories

## High-level storage-policy categories.
## These are intentionally broader than individual item types. Auto-placement
## will eventually use an ItemDefinition's primary Storage Category to search
## matching zones.

const NONE: String = ""
const GENERAL: String = "General"
const FOOD: String = "Food"
const HYDRATION: String = "Hydration"
const MEDICAL: String = "Medical"
const WEAPONS: String = "Weapons"
const PROTECTION: String = "Protection"
const FUEL: String = "Fuel"
const MORALE: String = "Morale"
const ELECTRONICS: String = "Electronics"

const EDITOR_CATEGORIES: Array[String] = [
	GENERAL,
	FOOD,
	HYDRATION,
	MEDICAL,
	WEAPONS,
	PROTECTION,
	FUEL,
	MORALE,
	ELECTRONICS
]


static func color_for(category: String) -> Color:
	match category:
		GENERAL:
			return Color(0.52, 0.56, 0.58, 0.62)
		FOOD:
			return Color(0.92, 0.62, 0.20, 0.66)
		HYDRATION:
			return Color(0.18, 0.68, 0.92, 0.66)
		MEDICAL:
			return Color(0.90, 0.24, 0.28, 0.66)
		WEAPONS:
			return Color(0.86, 0.38, 0.16, 0.66)
		PROTECTION:
			return Color(0.58, 0.38, 0.86, 0.66)
		FUEL:
			return Color(0.80, 0.67, 0.16, 0.66)
		MORALE:
			return Color(0.88, 0.32, 0.70, 0.66)
		ELECTRONICS:
			return Color(0.24, 0.48, 0.94, 0.66)
		_:
			return Color(0.18, 0.20, 0.22, 0.0)


static func short_name(category: String) -> String:
	match category:
		HYDRATION:
			return "HYDR."
		PROTECTION:
			return "PROTECT."
		ELECTRONICS:
			return "ELECT."
		_:
			return category.to_upper()
