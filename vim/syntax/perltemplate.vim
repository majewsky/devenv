set ft=perl

unlet b:current_syntax
syn include @HtmlTemplate syntax/htmltemplate.vim
syn region perlDATATemplate start=+__DATA__+ end=+\%$+ contained containedin=perlDATA contains=@HtmlTemplate
syn match perlDATAKeyword +__DATA__+ contained containedin=perlDATATemplate

let b:current_syntax = "perl"

hi def link perlDATAKeyword Comment
