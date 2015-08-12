" My personal minimal golang support plugin.
"
" Syntastic does 99% of what I need. This plugin just adds commands for
" running `gofmt` and `goimports` on the current buffer, and a BufWritePre
" hook for `gofmt`.

" simplified version of https://github.com/fatih/vim-go/blob/master/autoload/go/fmt.vim
function! GoFmt(withGoImport)
    " save cursor position and many other things
    let l:curw = winsaveview()
    " write to a temporary file (gofmt might fail)
    let l:tmpname = tempname()
    call writefile(getline(1, '$'), l:tmpname)

    " run gofmt/goimports
    let command = "gofmt"
    if a:withGoImport == 1
        let command = "goimports"
    endif
    let out = system(command . " " . l:tmpname)

    " if there is no error on the temp file, gofmt again our original file
    if v:shell_error == 0
        " remove undo point caused by BufWritePre
        try | silent undojoin | catch | endtry

        " do not include stderr to the buffer, this is due to goimports/gofmt
        " that fails with a zero exit return value
        let default_srr = &srr
        set srr=>%s

        " execute gofmt on the current buffer
        silent execute "%!" . command

        " put back orignal srr
        let &srr = default_srr
    endif

    " cleanup and restore
    call delete(l:tmpname)
    call winrestview(l:curw)
endfunction

" setup commands and autocmd
command! -nargs=0 GoFmt     call GoFmt(-1)
command! -nargs=0 GoImports call GoFmt(+1)
autocmd BufWritePre *.go    call GoFmt(+1)
