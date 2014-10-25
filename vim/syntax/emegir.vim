" Vim syntax file
" Language: Emegir language framework
" Maintainer: Stefan Majewsky <majewsky@gmx.net>

if exists("b:current_syntax")
    finish
endif

" first embed Ligin
syn include @Ligin syntax/ligin.vim
syn match eLiginOpener /^ligin\>/ nextgroup=eLiginStatement
syn match eLiginStatement /.*$/ contained contains=@Ligin
hi def link eLiginOpener PreProc

unlet b:current_syntax
let b:current_syntax="emegir"

" now continue with Emegir
syn match emegirComment "#.*" contains=@Spell,emegirCommentKeyword
syn keyword emegirCommentKeyword TODO FIXME BUG TDB XXX NOTE

syn keyword emegirDeclClass class nextgroup=emegirDeclName
syn keyword emegirDeclFunc func nextgroup=emegirDeclName
syn match emegirDeclName +\s*\w*+ contained nextgroup=emegirTemplateDecl
syn match emegirTemplateDecl +!(.\{-1,})+ contained
syn keyword emegirVarDecl var nextgroup=emegirDeclIdentifier

syn keyword emegirType type int float bool and or
syn match emegirIdentifier +[a-zA-Z_][a-zA-Z0-9_]*\s*:+
syn match emegirDeclIdentifier +\s*[a-zA-Z_][a-zA-Z0-9_]*\s*\%(:\|\ze=\)+ contained

syn keyword emegirBoolean true false

syn keyword emegirConditional if then else
syn keyword emegirRepeat while until for in
syn keyword emegirStatement do return continue break call

hi def link emegirComment Comment
hi def link emegirCommentKeyword Todo

hi def link emegirDeclClass Structure
hi def link emegirDeclFunc Keyword
hi def link emegirDeclName Function
hi def link emegirTemplateDecl PreCondit
hi def link emegirVarDecl Keyword

hi def link emegirType Type
hi def link emegirIdentifier Identifier
hi def link emegirDeclIdentifier Identifier

hi def link emegirBoolean Boolean

hi def link emegirConditional Conditional
hi def link emegirRepeat Repeat
hi def link emegirStatement Statement
