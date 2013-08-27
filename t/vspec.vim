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

function! Chomp(s)
    return a:s =~# '\n$'
                \ ? a:s[0:len(a:s)-2]
                \ : a:s
endfunction

function! ChompHead(s)
    return a:s =~# '^\n'
                \ ? a:s[1:len(a:s)-1]
                \ : a:s
endfunction

function! GetBuffer()
    return join(getline(1, '$'), "\n")
endfunction

function! ClangFormat(line1, line2)
    let opt = printf(" -lines=%d:%d -style='{BasedOnStyle: Google, IndentWidth: %d, UseTab: %s}' ", a:line1, a:line2, &l:shiftwidth, &l:expandtab==1 ? "false" : "true")
    let cmd = g:operator_clang_format_command.opt.'./'.s:root_dir.'t/test.cpp --'
    return Chomp(system(cmd))
endfunction
"}}}

" setup {{{
let s:root_dir = ChompHead(Chomp(system('git rev-parse --show-cdup')))
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

" test for operator#clang_format#format() {{{
function! CheckForSameOutput(line1, line2)
    return operator#clang_format#format(a:line1, a:line2) ==# ClangFormat(a:line1, a:line2)
endfunction

describe 'operator#clang_format#format()'

    before
        new
        execute 'silent' 'edit!' './'.s:root_dir.'t/test.cpp'
    end

    after
        bdelete!
    end

    it 'formats whole t/test.cpp'
        Expect CheckForSameOutput(1, line('$')) to_be_true
    end

    it 'formats too long macro definitions'
        Expect CheckForSameOutput(3, 3) to_be_true
    end

    it 'formats one line functions'
        Expect CheckForSameOutput(5, 5) to_be_true
    end

    it 'formats initilizer list definition'
        Expect CheckForSameOutput(9, 9) to_be_true
    end

    it 'formats for statement'
        Expect CheckForSameOutput(11, 13) to_be_true
    end

    it 'formats too long string to multiple lines'
        Expect CheckForSameOutput(17, 17) to_be_true
    end

end
" }}}

" test for <Plug>(operator-clang-format) {{{
describe '<Plug>(operator-clang-format)'

    before
        new
        map x <Plug>(operator-clang-format)
        execute 'edit' './'.s:root_dir.'t/test.cpp'
    end

    after
        close!
    end

    it 'formats t/test.cpp'
        let by_operator_clang_format = operator#clang_format#format(1, line('$'))

        let opt = printf("-style='{BasedOnStyle: Google, IndentWidth: %d, UseTab: %s}'", &l:shiftwidth, &l:expandtab==1 ? "false" : "true")
        let cmd = g:operator_clang_format_command.' '.opt.' ./'.s:root_dir.'t/test.cpp --'
        let by_command = system(cmd)
        Expect Chomp(by_operator_clang_format) == Chomp(by_command)
    end

end
" }}}
