" Vim syntax file
" Language: LaMake configuration files
" Maintainer: Stefan Majewsky <majewsky@gmx.net>
" Latest Revision: 6 Sep 2011

if exists("b:current_syntax")
	finish
endif

syn keyword lamakeStatement use at set
syn keyword lamakeEntityDecl begin end
syn keyword lamakeEntityType target group
syn match lamakeComment "^\s*#\+.*$"

let b:current_syntax = "lamake"

hi def link lamakeStatement Operator
hi def link lamakeEntityDecl Type
hi def link lamakeEntityType Type
hi def link lamakeComment Comment
