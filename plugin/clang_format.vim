if exists('g:loaded_clang_format')
  finish
endif

try
    call operator#user#define('clang-format', 'operator#clang_format#do', 'let g:operator#clang_format#save_pos = getpos(".") \| let g:operator#clang_format#save_screen_pos = line("w0")')
catch /^Vim\%((\a\+)\)\=:E117/
    " vim-operator-user is not installed
endtry

command! -range=% -nargs=0 ClangFormat call clang_format#replace(<line1>, <line2>)

command! -range=% -nargs=0 ClangFormatEchoFormattedCode echo clang_format#format(<line1>, <line2>)

augroup plugin-clang-format-auto-format
    autocmd!
    autocmd BufWritePre * if &ft ==# 'cpp' && get(g:, 'clang_format#auto_format', 0) | call clang_format#replace(1, line('$')) | endif
augroup END

let g:loaded_clang_format = 1
