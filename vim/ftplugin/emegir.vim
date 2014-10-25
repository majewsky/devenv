" Vim filetype emegir file
" Language: emegir
" Maintainer: Stefan Majewsky <majewsky@gmx.net>

if exists("b:did_ftplugin") | finish | endif
let b:did_ftplugin = 1

let b:undo_ftplugin = "setl cin< cms< com< fo< sua<"

" set formatoptions to break comment lines but not other lines,
" and insert the comment leader when starting a new line.
setl fo-=t fo+=croq

setl nocindent
setl suffixesadd=.es
setl comments=b:#
setl commentstring=#%s
