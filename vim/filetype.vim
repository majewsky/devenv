if exists("did_load_filetypes")
	finish
endif
augroup filetypedetect
	autocmd! BufRead,BufNewFile *.tikz setfiletype tex
	autocmd! BufRead,BufNewFile *.qml setfiletype qml
augroup END
