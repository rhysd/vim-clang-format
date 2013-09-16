if exists('g:loaded_operator_clang_format')
  finish
endif

function! s:getg(name, default)
    if exists('g:operator_'.a:name)
        echoerr 'g:operator_'.a:name.' is deprecated. Please use g:'.a:name
        return g:operator_{a:name}
    else
        return get(g:, a:name, a:default)
    endif
endfunction

" variable definitions {{{
let g:clang_format_command = s:getg('clang_format_command', 'clang-format')
if ! executable(g:clang_format_command)
    echoerr "clang-format is not found. check g:clang_format_command."
    finish
endif


let g:operator_clang_format_extra_args = get(g:, 'operator_clang_format_extra_args', "")
if type(g:operator_clang_format_extra_args) == type([])
    let g:operator_clang_format_extra_args = join(g:operator_clang_format_extra_args, " ")
endif

let g:operator_clang_format_code_style = get(g:, 'operator_clang_format_code_style', 'google')
let g:operator_clang_format_style_options = get(g:, 'operator_clang_format_style_options', {})
" }}}

try
    call operator#user#define('clang-format', 'operator#clang_format#do')
catch /^E117/
    echoerr "vim-operator-user is not found."
endtry

let g:loaded_operator_clang_format = 1
