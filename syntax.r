REBOL [
	Author: "Ladislav Mecir"
	Purpose: {
		REBOL syntax description:
		
		value-syntax ; update when adding a new syntax type
		implicit-block
		block-syntax
		paren-syntax
		comment-syntax
		integer-syntax
		decimal-syntax
		char-syntax
		quoted-string
		braced-string
		binary-syntax
	}
]

value-syntax: [
	integer-syntax
	| decimal-syntax
	| char-syntax
	| quoted-string
	| braced-string
	| block-syntax
	| paren-syntax
	| tuple-syntax
	| binary-syntax
]

implicit-block: [
	any [
		whitespace
		| comment-syntax
		| value-syntax
	]
]

block-syntax: [#"[" implicit-block #"]"]
paren-syntax: [#"(" implicit-block #")"]

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
	any [braced-char | caret-notation | braced-string]
	#"}"
]

binary-2: ["2#{" any [8 [#"0" | #"1"]] #"}"]
binary-16: ["#{" any [2 hex-digit] #"}"]
digit-64: make bitset! [#"A" - #"Z" #"a" - #"y" #"0" - #"9" #"+" #"/"]
binary-64: [
	"64#{"
	[
		2 digit-64 any [4 digit-64] "=="
		| 3 digit-64 any [4 digit-64] "="
		| any [4 digit-64]
	]
	#"}"
]
binary-syntax: [binary-2 | binary-16 | binary-64]