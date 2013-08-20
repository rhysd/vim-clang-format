" test with vim-vspec
" https://github.com/kana/vim-vspec

" clang-format detection
if executable('clang-format-3.4')
    let g:operator_clang_format_command = 'clang-format-3.4'
elseif executable('clang-format')
else
    echoerr '!!!could not detect clang-format in $PATH!!!'
endif

set rtp +=..
set rtp +=~/.vim/bundle/vim-operator-user
runtime! plugin/operator/clang_format.vim

describe 'default mapping and autoload functions and variables.'

    it 'provides default <Plug> mapping'
        Expect maparg('<Plug>(operator-clang-format)') !=# ''
    end

    it 'provides autoload functions'
        runtime! autoload/operator/clang_format.vim
        Expect exists('*operator#clang_format#do') to_be_true
    end

    it 'provides variables for settings'
        Expect exists('g:operator_clang_format_clang_args') to_be_true
        Expect exists('g:operator_clang_format_code_style') to_be_true
        Expect exists('g:operator_clang_format_style_options') to_be_true
        Expect exists('g:operator_clang_format_command') to_be_true
        Expect g:operator_clang_format_clang_args == ""
        Expect g:operator_clang_format_code_style ==# 'google'
        Expect g:operator_clang_format_style_options == {}
        Expect executable(g:operator_clang_format_command) to_be_true
    end
end
