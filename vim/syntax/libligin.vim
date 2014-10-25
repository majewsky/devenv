" Vim syntax file
" Language: libligin shape specifications
" Maintainer: Stefan Majewsky <majewsky@gmx.net>

if exists("b:current_syntax")
	finish
endif

syn match liginLoop /"[][]/
syn match liginBranch /"[()|]/
syn match liginMarker /#\w\+/
syn match liginPriority /#![0-9]\+/
syn match liginRand /\(#[>*]\)\?[0-9]\+/

hi def link liginLoop Repeat
hi def link liginBranch Conditional
hi def link liginMarker Type
hi def link liginPriority Define
hi def link liginRand Number
