REBOL [
	Author: "Ladislav Mecir"
	Purpose: {
		REBOL syntax description:
		
		integer-syntax
		decimal-syntax
		char-syntax
		quoted-string
		braced-string
	}
]

whitespace: charset [#"^A" - #" " #"^(7F)" #"^(A0)"]

sign: [#"+" | #"-"]
digit: make bitset! [#"0" - #"9"]
thousand-separator: [#"'"]
termination: [
	end
	| and [whitespace | #"(" | #")" | #"[" | #"]" | #"^"" | #"{" | #"/"]
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
non-open: complement charset [#"("]
escaped-char: [
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
	[quoted-char | escaped-char]
	#"^""
]

quoted-string: [
	#"^""
	any [quoted-char | escaped-char]
	#"^""
]

braced-char: complement make bitset! [#"{" #"}" #"^^"]
braced-string: [
	#"{"
	any [braced-char | escaped-char]
	#"}"
]
