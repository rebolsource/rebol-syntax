REBOL [
	Author: "Ladislav Mecir"
	Purpose: {
		REBOL syntax description:
		
		comment-syntax
		integer-syntax
		decimal-syntax
		char-syntax
		quoted-string
		braced-string
	}
]

non-lf: complement make bitset! [#"^/"]
comment-syntax: [#";" any non-lf #"^/"]

whitespace: make bitset! [#"^A" - #" " #"^(7F)" #"^(A0)"]

sign: [#"+" | #"-"]
digit: make bitset! [#"0" - #"9"]
thousand-separator: [#"'"]
termination: [
	end
	| and [whitespace | #"(" | #")" | #"[" | #"]" | #"^"" | #"{" | #"/" | #";"]
]
integer-syntax: [opt sign digit any [digit | thousand-separator] termination]

decimal-separator: [#"." | #","]
e-part: [[#"e" | #"E"] opt sign some digit]
decimal-syntax: [
	opt sign [
		digit any [digit | thousand-separator] [
			e-part | decimal-separator any [digit | thousand-separator]
		] | decimal-separator digit any [digit | thousand-separator] opt e-part
	] termination
]

hex-digit: make bitset! [#"0" - #"9" #"a" - #"f" #"A" - #"F"]
quoted-char: complement make bitset! [#"^/" #"^"" #"^^"]
non-open: complement make bitset! [#"("]
caret-notation: [
	#"^^" [
		non-open
		| #"(" [
			0 4 hex-digit
			| "line"
			| "tab"
			| "page"
			| "back"
			| "null"
			| "escape"
		] #")"
	]
]
char-syntax: [
	"#^""
	[quoted-char | caret-notation]
	#"^""
]

quoted-string: [
	#"^""
	any [quoted-char | caret-notation]
	#"^""
]

braced-char: complement make bitset! [#"{" #"}" #"^^"]
braced-string: [
	#"{"
	any [braced-char | caret-notation]
	#"}"
]

value-syntax: [
	integer-syntax
	| decimal-syntax
	| char-syntax
	| quoted-string
	| braced-string	
]