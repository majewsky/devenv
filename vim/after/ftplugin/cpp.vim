runtime syntax/doxygen.vim
" enable pair matching for angle brackets (e.g. C++ templates)
setlocal matchpairs+=<:> commentstring=//\ %s
" add :/// to comments, but make sure that it has a higher priority than ://
setlocal comments-=:// comments+=:///,://
