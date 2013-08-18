if exists('g:loaded_operator_clang_format')
  finish
endif

if ! executable('clang-format')
    finish
endif

let s:tmp = get(g:, 'operator_clang_format_clang_args', "")
if type(s:tmp) == type([])
    let s:tmp = join(s:tmp, " ")
endif
let g:operator_clang_format_clang_args = s:tmp
unlet s:tmp

let g:operator_clang_format_code_style = get(g:, 'operator_clang_format_code_style', 'google')
let g:operator_clang_format_style_options = get(g:, 'operator_clang_format_options', {})
let g:operator_clang_format_command = get(g:, 'operator_clang_format_command', 'clang-format')

call operator#user#define('clang-format', 'operator#clang_format#do')

let g:loaded_operator_clang_format = 1
