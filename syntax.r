REBOL [
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
		tuple-syntax
	}
	License: {
		Copyright (c) 2012 The rebol-syntax contributors

		Permission is hereby granted, free of charge, to any person
		obtaining a copy of this software and associated documentation
		files (the "Software"), to deal in the Software without
		restriction, including without limitation the rights to use,
		copy, modify, merge, publish, distribute, sublicense, and/or
		sell copies of the Software, and to permit persons to whom the
		Software is furnished to do so, subject to the following
		conditions:

		The above copyright notice and this permission notice shall be
		included in all copies or substantial portions of the
		Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
		KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
		WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
		PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
		COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
		OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
		SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	}
]

alternative-syntax: func [
	{defines (or documents) an alternative syntax}
	'syntax-ids [word! block!] {the id/ids of syntaxes using the alternative}
	'syntax-element [set-word!]
	spec
][
	; don't do anything at present
	; this way it serves for documentation
]

value-syntax: [
	block-syntax
	| paren-syntax
	| integer-syntax
	| decimal-syntax
	| char-syntax
	| quoted-string
	| braced-string
	| binary-syntax
	| tuple-syntax
]

implicit-block: [
	any [
		whitespace
		| comment-syntax
		| value-syntax
		| end-load
	]
]

block-syntax: [#"[" implicit-block #"]"]
paren-syntax: [#"(" implicit-block #")"]

non-lf: complement charset [#"^/"]
comment-syntax: [#";" any non-lf #"^/"]

end-load: [#"^@" to end]

whitespace: charset [#"^A" - #" " #"^(7F)"]

sign: [#"+" | #"-"]
digit: charset [#"0" - #"9"]
thousand-separator: [#"'"]
termination-char: union whitespace charset "()[]^"{}/^@;"
termination: [end | and termination-char]
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

hex-digit: charset [#"0" - #"9" #"a" - #"f" #"A" - #"F"]
quoted-char: complement charset [#"^/" #"^"" #"^^"]
non-open: complement charset [#"("]
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
alternative-syntax R2 caret-notation: [
	#"^^" [
		non-open
		| #"(" [
			0 2 hex-digit
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

braced-char: complement charset [#"{" #"}" #"^^"]
braced-string: [
	#"{"
	any [braced-char | caret-notation | braced-string]
	#"}"
]

binary-2: ["2#{" any [8 [any whitespace [#"0" | #"1"]]] any whitespace #"}"]
binary-16: [opt "16" "#{" any [2 [any whitespace hex-digit]] any whitespace #"}"]
digit-64: charset [#"A" - #"Z" #"a" - #"y" #"0" - #"9" #"+" #"/"]
wsd-64: [any whitespace digit-64]
ws=: [any whitespace #"="]
binary-64: [
	"64#{"
	[
		2 wsd-64 any [4 wsd-64] 2 ws=
		| 3 wsd-64 any [4 wsd-64] ws=
		| any [4 wsd-64]
	]
	any whitespace #"}"
]
binary-syntax: [binary-2 | binary-16 | binary-64]

tuple-syntax: [
	[some digit 2 9 [#"." any digit] | #"." some digit 1 8 [#"." any digit]]
	termination
]

; words containing the slash character are exceptional:
; they can contain only slashes
; they do not have a lit-word syntax
; they do not have a set-word syntax
; they do not have a get-word syntax
; they do not have a refinement syntax
; they do not have a path syntax
slash-word: [some #"/"]

; words containing #"<" or #"> are exceptional:
; there are only a few words like this
; the words don't have a set-word syntax
; the words don't have a refinement syntax
more-less-word: [
	[
		#"<"
		| #">"
		| "<="
		| ">="
		| "<>"
		| ">>"
		| "<<"
	]
]

; the :x:y get-words don't have a word-syntax

; the //x refinements don't have a word-syntax

extra-word-char: union termination-char charset ":/#$%<>@\,"
word-char: complement extra-word-char

; words starting with #"." are exceptional:
; the second character cannot be a digit
; they do not have a refinement syntax

; words starting with #"+" or #"-" are exceptional:
; the second character cannot be a digit
; if the second character is #".", the third character cannot be a digit
; the second character cannot be the apostrophe
; they do not have a refinement syntax
word-syntax: [
	[
		slash-word
		| more-less-word
		| opt sign [#"." | not #"'"] not digit any word-char
	]
	termination 
]
