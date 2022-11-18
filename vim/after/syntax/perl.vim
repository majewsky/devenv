syn keyword perlStatementList uniq natatime
syn region perlStatementIndirObjWrap matchgroup=perlStatementIndirObj start="\<\%(\%(continue\|uireturn\|return\|bless\|else\|eval\|sub\|die\|q[qrw]\|\w\)\>\)\@![a-z_]\+\>\s*{" end="}" contains=@perlTop,perlGenericBlock
syn match perlStatementException "\<\%(die\|croak\|carp\|confess\|cluck\|ui\%(die\|return\)\)\>"
syn keyword perlNew new create
syn keyword perlSubNameNew new create containedin=perlSubName
hi link perlNew perlOperator
hi link perlSubNameNew perlNew
hi link perlStatement PreCondit
hi link perlStatementException ErrorMsg
