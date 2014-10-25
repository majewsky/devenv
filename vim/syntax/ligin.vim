" Vim syntax file
" Language: Ligin shape specifications
" Maintainer: Stefan Majewsky <majewsky@gmx.net>

if exists("b:current_syntax")
	finish
endif

let b:current_syntax="ligin"

syn keyword liginCommand declare

syn match  liginContext       /%[A-Za-z_]\+/
syn match  liginPriority      /![0-9]\+/
syn match  liginAssociativity /!\(ltr\|rtl\)/

syn region liginDef start=/:/ end=/$/ oneline
\ contains=liginOperand,liginKeyword,liginNonPrintable,liginBranch,liginLookahead,liginLoop,liginReturn,liginContext,liginTokenRegexp

syn region liginTokenRegexp start=+/+ skip=+\\.+ end=+/+ contained

syn match  liginOperand /\$[>*=]\?[0-9]\+\(%[A-Za-z_]\+\)*/ contained
syn region liginKeyword start=+"+ end=+"+                contained oneline
syn match  liginNonPrintable />>\|<<\|@@/                contained

syn match  liginBranch /[()|]/         contained
syn match  liginLookahead /[?!][0-9]*/ contained
syn match  liginLoop /[][]/            contained
syn match  liginReturn /->\s*\%(\w\|[.-]\)\+/ contained

hi def link liginCommand PreProc
hi def link liginContext Type
hi def link liginPriority Number
hi def link liginAssociativity Boolean

hi def link liginTokenRegexp String

hi def link liginOperand Number
hi def link liginKeyword String
hi def link liginNonPrintable Operator
hi def link liginBranch Conditional
hi def link liginLookahead Boolean
hi def link liginLoop Repeat
hi def link liginReturn Function
