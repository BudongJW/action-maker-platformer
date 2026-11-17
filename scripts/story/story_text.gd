## Text helpers for compiled story strings (docs/script-format.md, sections 5.2 and 10.2).
class_name StoryText
extends RefCounted

static var _wait_re: RegEx
static var _bbcode_re: RegEx


## Replaces {flag} and {@token} placeholders using `resolve` (Callable taking the inner
## text and returning a String), and turns the escapes \{ and \\ into { and \.
static func interpolate(text: String, resolve: Callable) -> String:
	var out := PackedStringArray()
	var i := 0
	var n := text.length()
	while i < n:
		var c := text[i]
		if c == "\\" and i + 1 < n and (text[i + 1] == "{" or text[i + 1] == "\\"):
			out.append(text[i + 1])
			i += 2
			continue
		if c == "{":
			var close := text.find("}", i + 1)
			if close != -1:
				out.append(str(resolve.call(text.substr(i + 1, close - i - 1).strip_edges())))
				i = close + 1
				continue
		out.append(c)
		i += 1
	return "".join(out)


## Removes [wait=<seconds>] markers. Returns {"text": String, "waits": Array} where each
## wait is {"at": <visible character index>, "seconds": float}; the index ignores BBCode tags,
## so it matches RichTextLabel.visible_characters.
static func split_waits(text: String) -> Dictionary:
	if _wait_re == null:
		_wait_re = RegEx.create_from_string("\\[wait=([0-9]+(?:\\.[0-9]+)?)\\]")
	var waits: Array = []
	var out := ""
	var last := 0
	for m in _wait_re.search_all(text):
		out += text.substr(last, m.get_start() - last)
		waits.append({"at": visible_length(out), "seconds": float(m.get_string(1))})
		last = m.get_end()
	out += text.substr(last)
	return {"text": out, "waits": waits}


## Number of characters a RichTextLabel shows for this BBCode text.
static func visible_length(bbcode: String) -> int:
	if _bbcode_re == null:
		_bbcode_re = RegEx.create_from_string("\\[/?[a-z_]+(?:=[^\\]]*)?\\]")
	return _bbcode_re.sub(bbcode, "", true).length()


## Formats a flag value for display: whole numbers without ".0", null as "".
static func format_value(value: Variant) -> String:
	match typeof(value):
		TYPE_NIL:
			return ""
		TYPE_FLOAT:
			if is_finite(value) and value == floorf(value):
				return str(int(value))
	return str(value)
