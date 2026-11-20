## Evaluates compiled condition trees from story.json.
##
## A condition is null (always true), a literal, or a Dictionary node:
## {"var": name}, {"not": node}, {"and": [nodes]}, {"or": [nodes]},
## {"cmp": op, "a": node, "b": node}. See docs/script-format.md, sections 6.1 and 10.1.
class_name StoryCondition
extends RefCounted


## Returns whether a condition holds. A null condition always holds.
static func evaluate(node: Variant, flags: Object) -> bool:
	if node == null:
		return true
	return truthy(value_of(node, flags))


## 0, false, null and the empty string are false; everything else is true.
static func truthy(value: Variant) -> bool:
	match typeof(value):
		TYPE_NIL:
			return false
		TYPE_BOOL:
			return value
		TYPE_INT, TYPE_FLOAT:
			return value != 0
		TYPE_STRING, TYPE_STRING_NAME:
			return not String(value).is_empty()
	return true


static func value_of(node: Variant, flags: Object) -> Variant:
	if typeof(node) != TYPE_DICTIONARY:
		return node
	var d: Dictionary = node
	if d.has("var"):
		return flags.get_flag(String(d["var"]))
	if d.has("not"):
		return not truthy(value_of(d["not"], flags))
	if d.has("and"):
		for item in d["and"]:
			if not truthy(value_of(item, flags)):
				return false
		return true
	if d.has("or"):
		for item in d["or"]:
			if truthy(value_of(item, flags)):
				return true
		return false
	if d.has("cmp"):
		return compare(String(d["cmp"]), value_of(d["a"], flags), value_of(d["b"], flags))
	push_error("StoryCondition: unknown condition node %s" % [d])
	return false


## Compares two values. If either side is a number, unset flags (null) count as 0
## and booleans as 0/1. Otherwise only == and != are meaningful, and null equals false.
static func compare(op: String, a: Variant, b: Variant) -> bool:
	if _is_number(a) or _is_number(b):
		if not (_numeric_like(a) and _numeric_like(b)):
			return op == "!="
		var x := _to_number(a)
		var y := _to_number(b)
		match op:
			"==":
				return is_equal_approx(x, y)
			"!=":
				return not is_equal_approx(x, y)
			"<":
				return x < y
			"<=":
				return x <= y or is_equal_approx(x, y)
			">":
				return x > y
			">=":
				return x >= y or is_equal_approx(x, y)
		push_error("StoryCondition: unknown operator '%s'" % op)
		return false
	var left: Variant = false if a == null else a
	var right: Variant = false if b == null else b
	var same: bool = typeof(left) == typeof(right) and left == right
	match op:
		"==":
			return same
		"!=":
			return not same
	return false


static func _is_number(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT


static func _numeric_like(value: Variant) -> bool:
	return _is_number(value) or typeof(value) == TYPE_BOOL or value == null


static func _to_number(value: Variant) -> float:
	if value == null:
		return 0.0
	if typeof(value) == TYPE_BOOL:
		return 1.0 if value else 0.0
	return float(value)
