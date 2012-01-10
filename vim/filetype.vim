if exists("did_load_filetypes")
	finish
endif
augroup filetypedetect
	" setf = setfiletype
	autocmd! BufRead,BufNewFile *.tikz setf tex
	autocmd! BufRead,BufNewFile *.qml setf qml
	autocmd! BufRead,BufNewFile *.gp setf gnuplot
	autocmd! BufRead,BufNewFile Tupfile,*.tup setf tup
	autocmd! BufRead,BufNewFile scatttd.conf setf dosini
	autocmd! BufRead,BufNewFile *.es setf emegir
	autocmd! BufRead,BufNewFile lamake.conf setf lamake | set commentstring=#\ %s
augroup END
