if exists('g:loaded_clang_format')
  finish
endif

try
    call operator#user#define('clang-format', 'operator#clang_format#do')
catch /^E117/
    echoerr "vim-operator-user is not found."
endtry

let g:loaded_clang_format = 1
