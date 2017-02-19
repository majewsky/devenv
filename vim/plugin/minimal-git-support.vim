command! -bang -nargs=0 Gw  write<bang> | call s:GitAdd()
command! -bang -nargs=0 Gwq write<bang> | call s:GitAdd() | quit

function! s:GitAdd() abort
  if expand("%:t") == "COMMIT_EDITMSG"
    quit
    return
  end
  silent let l:msg = systemlist("git add " . shellescape(expand("%")))
  if v:shell_error
    echohl ErrorMsg
    for l:line in l:msg
      echom l:line
    endfor
    echohl None
  endif
endfunction
