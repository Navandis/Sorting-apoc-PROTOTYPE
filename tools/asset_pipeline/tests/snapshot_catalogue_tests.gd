extends SceneTree

const Snapshot = preload("res://gameplay/run/run_snapshot.gd")
const Catalog = preload("res://prototype_item_catalog.gd")
var checks := 0
var failures := 0

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)

func _init() -> void:
	run.call_deferred()

func run() -> void:
	# A fresh process must exercise fingerprinting before any facade lookup.
	check(not ResourceLoader.has_cached(Catalog.CATALOGUE_PATH), "Fresh fingerprint starts without a retained catalogue")
	var snapshot := Snapshot.new()
	var original: String = snapshot.content_fingerprint()
	print("SNAPSHOT_FINGERPRINT ", original)
	check(ResourceLoader.has_cached(Catalog.CATALOGUE_PATH), "Fingerprint retains the catalogue for later validation lookups")
	var catalogue := Catalog._catalogue() as ItemCatalog
	check(catalogue != null and not catalogue.definitions.is_empty(), "Facade supplies the physical catalogue")
	var definition: ItemDefinition = catalogue.definitions[0]
	var original_bulk := definition.bulk
	definition.bulk += 1
	check(snapshot.content_fingerprint() != original, "Fingerprint recomputes changed physical content in the retained catalogue")
	definition.bulk = original_bulk
	check(snapshot.content_fingerprint() == original, "Restoring content restores the exact fingerprint")
	check(Snapshot.new().content_fingerprint() == original, "Separate snapshot instances compute the same fingerprint")
	print("SNAPSHOT_CATALOGUE_COMPLETE checks=", checks, " failures=", failures)
	quit(1 if failures else 0)
