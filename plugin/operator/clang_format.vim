if exists('g:loaded_operator_clang_format')
  finish
endif

call operator#user#define('clang-format', 'operator#clang_format#do')

let g:loaded_operator_clang_format = 1
