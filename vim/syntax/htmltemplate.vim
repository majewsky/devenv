if exists("b:current_syntax")
	finish
endif
runtime syntax/html.vim
let b:current_syntax = "htmltemplate"

syn match templateMarker +###.\{-}###+
syn match templateMarker +###.\{-}###+ contained containedin=ALLBUT,templateMarker

syn region  templateProc    start=+^\s*\zs##\ze[^#]+ end=+##+ oneline contains=templateIf,templateFor containedin=ALLBUT,templateMarker
syn match   templateIf      +if [^#]\++   contained
syn keyword templateIf      else endif    contained
syn match   templateFor     +for [^#]\++  contained
syn keyword templateFor     endfor        contained

hi def link templateMarker  SpecialComment
hi def link templateMarkerC SpecialComment
hi def link templateProc    SpecialComment
hi def link templateIf      Conditional
hi def link templateFor     Repeat
