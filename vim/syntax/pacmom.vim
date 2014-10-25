" Vim syntax file
" Language: Pacmom set file
" Maintainer: Stefan Majewsky <majewsky@gmx.net>

if exists("b:current_syntax")
    finish
endif

let b:current_syntax="pacmom"

syn match pacmomComment +#.*+ contains=@Spell,pacmomCommentKeyword
syn keyword pacmomCommentKeyword TODO FIXME BUG TDB XXX NOTE

syn match pacmomInclude +<\S\++
syn match pacmomGroup   +@\S\++

hi def link pacmomComment Comment
hi def link pacmomCommentKeyword Todo

hi def link pacmomInclude Include
hi def link pacmomGroup Type
