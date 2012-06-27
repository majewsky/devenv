" Pandoc
au! Bufread,BufNewFile *.pdc call PdcSetup()

function! PdcSetup()
	set ft=pdc
	hi link pdcHeader PreCondit
endfunction
