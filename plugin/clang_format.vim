if exists('g:loaded_clang_format')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

try
    call operator#user#define('clang-format', 'operator#clang_format#do')
catch /^E117/
    " vim-operator-user is not installed
endtry

command! -range -nargs=0 ClangFormat if <line1> == <line2> |
            \                           call clang_format#replace(1, line('$')) |
            \                        else |
            \                           call clang_format#replace(<line1>, <line2>) |
            \                        endif

command! -range -nargs=0 ClangFormatEchoFormattedCode
            \ if <line1> == <line2> |
            \    echo clang_format#format(1, line('$')) |
            \ else |
            \    echo clang_format#format(<line1>, <line2>) |
            \ endif

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_clang_format = 1
