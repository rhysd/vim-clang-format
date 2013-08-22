" test with vim-vspec
" https://github.com/kana/vim-vspec

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

execute 'set' 'rtp +=./'.system('git rev-parse --show-cdup')

set rtp +=~/.vim/bundle/vim-operator-user
runtime! plugin/operator/clang_format.vim

describe 'default settings'

    it 'provide a default <Plug> mapping'
        Expect maparg('<Plug>(operator-clang-format)') !=# ''
    end

    it 'provide autoload functions'
        runtime! autoload/operator/clang_format.vim
        Expect exists('*operator#clang_format#do') to_be_true
    end

    it 'provide variables to customize this plugin'
        Expect exists('g:operator_clang_format_extra_args') to_be_true
        Expect exists('g:operator_clang_format_code_style') to_be_true
        Expect exists('g:operator_clang_format_style_options') to_be_true
        Expect exists('g:operator_clang_format_command') to_be_true
        Expect g:operator_clang_format_extra_args == ""
        Expect g:operator_clang_format_code_style ==# 'google'
        Expect g:operator_clang_format_style_options == {}
        Expect executable(g:operator_clang_format_command) to_be_true
    end
end
