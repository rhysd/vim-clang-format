" test with vim-vspec
" https://github.com/kana/vim-vspec

" helpers "{{{
" clang-format detection
function! s:detect_clang_format()
    for candidate in ['clang-format-3.4', 'clang-format']
        if executable(candidate)
            return candidate
        endif
    endfor
    throw 'not ok bnecause detect clang-format could not be found in $PATH'
endfunction
let g:operator_clang_format_command = s:detect_clang_format()

function! s:chomp(s)
    return a:s =~# '\n$'
                \ ? a:s[0:len(a:s)-2]
                \ : a:s
endfunction
"}}}

" setup {{{
let s:root_dir = s:chomp(system('git rev-parse --show-cdup'))
execute 'set' 'rtp +=./'.s:root_dir

set rtp +=~/.vim/bundle/vim-operator-user
runtime! plugin/operator/clang_format.vim

call vspec#customize_matcher('to_be_empty', function('empty'))
"}}}

" test for default settings {{{
describe 'default settings'

    it 'provide a default <Plug> mapping'
        Expect maparg('<Plug>(operator-clang-format)') not to_be_empty
    end

    it 'provide autoload functions'
        runtime! autoload/operator/clang_format.vim
        Expect exists('*operator#clang_format#do') to_be_true
        Expect exists('*operator#clang_format#format') to_be_true
    end

    it 'provide variables to customize this plugin'
        Expect exists('g:operator_clang_format_extra_args') to_be_true
        Expect exists('g:operator_clang_format_code_style') to_be_true
        Expect exists('g:operator_clang_format_style_options') to_be_true
        Expect exists('g:operator_clang_format_command') to_be_true
        Expect g:operator_clang_format_extra_args to_be_empty
        Expect g:operator_clang_format_code_style ==# 'google'
        Expect g:operator_clang_format_style_options to_be_empty
        Expect executable(g:operator_clang_format_command) to_be_true
    end

end
"}}}

" test for <Plug>(operator-clang-format) {{{
describe '<Plug>(operator-clang-format)'

    before

    end

    after

    end

    it 'formats t/test.cpp'
        TODO
    end

end
" }}}
