if exists("did_load_filetypes")
	finish
endif
augroup filetypedetect
	autocmd! BufRead,BufNewFile *.tikz setfiletype tex
	autocmd! BufRead,BufNewFile *.qml setfiletype qml
	autocmd! BufRead,BufNewFile scatttd.conf setfiletype dosini
	autocmd! BufRead,BufNewFile lamake.conf setfiletype lamake
augroup END
