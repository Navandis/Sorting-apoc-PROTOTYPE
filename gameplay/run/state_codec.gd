extends RefCounted

## Explicit value-only JSON codec. No object/resource decoding or executable data.
var error := ""

func encode(value: Variant, depth: int = 0) -> Variant:
	if depth > 64:
		error = "Snapshot nesting exceeds supported limit"
		return null
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_STRING: return value
		TYPE_INT: return {"@": "int", "v": str(value)}
		TYPE_FLOAT:
			if not is_finite(value): error = "Non-finite snapshot number"
			var bytes := PackedByteArray()
			bytes.resize(8)
			bytes.encode_double(0, value)
			return {"@": "float64", "v": bytes.hex_encode()}
		TYPE_STRING_NAME: return {"@": "name", "v": String(value)}
		TYPE_VECTOR2I: return {"@": "v2i", "v": [value.x, value.y]}
		TYPE_VECTOR3I: return {"@": "v3i", "v": [value.x, value.y, value.z]}
		TYPE_VECTOR2: return {"@": "v2", "v": [value.x, value.y]}
		TYPE_VECTOR3: return {"@": "v3", "v": [value.x, value.y, value.z]}
		TYPE_TRANSFORM3D: return {"@": "transform", "v": encode([value.basis.x, value.basis.y, value.basis.z, value.origin], depth + 1)}
		TYPE_AABB: return {"@": "bounds", "v": encode([value.position, value.size], depth + 1)}
		TYPE_PACKED_BYTE_ARRAY: return {"@": "bytes", "v": Marshalls.raw_to_base64(value)}
		TYPE_ARRAY, TYPE_PACKED_STRING_ARRAY:
			var array: Array = []
			for element: Variant in value:
				array.append(encode(element, depth + 1))
			return array
		TYPE_DICTIONARY:
			var dictionary: Dictionary = {}
			for key: Variant in value:
				if typeof(key) not in [TYPE_STRING, TYPE_STRING_NAME]:
					error = "Unsupported snapshot key"
					return null
				dictionary[String(key)] = encode(value[key], depth + 1)
			return dictionary
		_:
			error = "Unsupported snapshot value type: %d" % typeof(value)
			return null

func decode(value: Variant, depth: int = 0) -> Variant:
	if depth > 64:
		error = "Snapshot nesting exceeds supported limit"
		return null
	if value is Array:
		var array: Array = []
		for entry: Variant in value:
			array.append(decode(entry, depth + 1))
		return array
	if value is Dictionary:
		if value.has("@"):
			var payload: Variant = value.get("v")
			match value["@"]:
				"float64":
					if payload is String and payload.length() == 16 and payload.is_valid_hex_number(false):
						var number: float = payload.hex_decode().decode_double(0)
						if is_finite(number): return number
				"int":
					if payload is String and payload.is_valid_int(): return int(payload)
				"name":
					if payload is String: return StringName(payload)
				"bytes":
					if payload is String: return Marshalls.base64_to_raw(payload)
				"v2i", "v3i", "v2", "v3":
					var count := 2 if value["@"] in ["v2i", "v2"] else 3
					if payload is Array and payload.size() == count:
						for number: Variant in payload:
							if typeof(number) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(number)):
								error = "Invalid vector component"
								return null
						match value["@"]:
							"v2i": return Vector2i(int(payload[0]), int(payload[1]))
							"v3i": return Vector3i(int(payload[0]), int(payload[1]), int(payload[2]))
							"v2": return Vector2(payload[0], payload[1])
							"v3": return Vector3(payload[0], payload[1], payload[2])
				"transform", "bounds":
					var decoded: Variant = decode(payload, depth + 1)
					if decoded is Array and decoded.size() == (4 if value["@"] == "transform" else 2):
						for vector: Variant in decoded:
							if not vector is Vector3:
								error = "Invalid transform/bounds component"
								return null
						if value["@"] == "transform": return Transform3D(Basis(decoded[0], decoded[1], decoded[2]), decoded[3])
						return AABB(decoded[0], decoded[1])
			error = "Unsupported or malformed snapshot value"
			return null
		var dictionary: Dictionary = {}
		for key: String in value:
			dictionary[key] = decode(value[key], depth + 1)
		return dictionary
	if typeof(value) == TYPE_FLOAT and not is_finite(value):
		error = "Non-finite snapshot number"
	return value

func stringify(state: Dictionary) -> String:
	error = ""
	var encoded: Variant = encode(state)
	return JSON.stringify(encoded, "\t", true, true) if error.is_empty() else ""

func parse(source: String) -> Dictionary:
	error = ""
	var json := JSON.new()
	if json.parse(source) != OK:
		error = "Invalid JSON: " + json.get_error_message()
		return {}
	var decoded: Variant = decode(json.data)
	if not decoded is Dictionary or not error.is_empty():
		if error.is_empty(): error = "Snapshot root must be a dictionary"
		return {}
	return decoded
