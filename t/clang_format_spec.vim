" test with vim-vspec
" https://github.com/kana/vim-vspec

" helpers "{{{
" clang-format detection
function! s:detect_clang_format()
    for candidate in ['clang-format-3.4', 'clang-format', 'clang-format-HEAD']
        if executable(candidate)
            return candidate
        endif
    endfor
    throw 'not ok because detect clang-format could not be found in $PATH'
endfunction
let g:clang_format#command = s:detect_clang_format()

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
    let cmd = g:clang_format#command.opt.'./'.s:root_dir.'t/test.cpp --'
    return Chomp(system(cmd))
endfunction
"}}}

" setup {{{
let s:root_dir = ChompHead(Chomp(system('git rev-parse --show-cdup')))
execute 'set' 'rtp +=./'.s:root_dir

set rtp +=~/.vim/bundle/vim-operator-user
runtime! plugin/clang_format.vim

call vspec#customize_matcher('to_be_empty', function('empty'))
"}}}

" test for default settings {{{
describe 'default settings'
    it 'provide a default <Plug> mapping'
        Expect maparg('<Plug>(operator-clang-format)') not to_be_empty
    end

    it 'provide autoload functions'
        " load autload script
        silent! call clang_format#get_version()
        silent! call operator#clang_format#do()
        Expect exists('*operator#clang_format#do') to_be_true
        Expect exists('*clang_format#format') to_be_true
        Expect exists('*clang_format#get_version') to_be_true
    end

    it 'provide variables to customize this plugin'
        Expect exists('g:clang_format#extra_args') to_be_true
        Expect exists('g:clang_format#code_style') to_be_true
        Expect exists('g:clang_format#style_options') to_be_true
        Expect exists('g:clang_format#command') to_be_true
        Expect g:clang_format#extra_args to_be_empty
        Expect g:clang_format#code_style ==# 'google'
        Expect g:clang_format#style_options to_be_empty
        Expect executable(g:clang_format#command) to_be_true
    end

    it 'provide commands'
        Expect exists(':ClangFormat') to_be_true
        Expect exists(':ClangFormatEchoFormattedCode') to_be_true
    end
end
"}}}

" test for clang_format#format() {{{
function! s:expect_the_same_output(line1, line2)
    Expect clang_format#format(a:line1, a:line2) ==# ClangFormat(a:line1, a:line2)
endfunction

describe 'clang_format#format()'

    before
        new
        execute 'silent' 'edit!' './'.s:root_dir.'t/test.cpp'
    end

    after
        bdelete!
    end

    it 'formats whole t/test.cpp'
        call s:expect_the_same_output(1, line('$'))
    end

    it 'formats too long macro definitions'
        call s:expect_the_same_output(3, 3)
    end

    it 'formats one line functions'
        call s:expect_the_same_output(5, 5)
    end

    it 'formats initilizer list definition'
        call s:expect_the_same_output(9, 9)
    end

    it 'formats for statement'
        call s:expect_the_same_output(11, 13)
    end

    it 'formats too long string to multiple lines'
        call s:expect_the_same_output(17, 17)
    end

    it 'doesn''t move cursor'
        execute 'normal!' (1+line('$')).'gg'
        let pos = getpos('.')
        call s:expect_the_same_output(1, line('$'))
        Expect pos == getpos('.')
    end
end
" }}}

" test for <Plug>(operator-clang-format) {{{
describe '<Plug>(operator-clang-format)'

    before
        new
        execute 'silent' 'edit!' './'.s:root_dir.'t/test.cpp'
        map x <Plug>(operator-clang-format)
    end

    after
        bdelete!
    end

    it 'formats in visual mode'
        let by_clang_format_command = ClangFormat(1, line('$'))
        normal ggVGx
        let buffer = GetBuffer()
        Expect by_clang_format_command ==# buffer
    end

    it 'formats a text object'
        " format for statement
        let by_clang_format_command = ClangFormat(11, 13)
        " move to for statement block
        execute 12
        " do format a text object {}
        normal xa{
        let buffer = GetBuffer()
        Expect by_clang_format_command ==# buffer
    end

    it 'doesn''t move cursor'
        execute 12
        let pos = getpos('.')
        normal xa{
        Expect pos == getpos('.')
    end
end
" }}}

" test for :ClangFormat {{{
describe ':ClangFormat'

    before
        new
        execute 'silent' 'edit!' './'.s:root_dir.'t/test.cpp'
    end

    after
        bdelete!
    end

    it 'formats the whole code in normal mode'
        let by_clang_format_command = ClangFormat(1, line('$'))
        ClangFormat
        let buffer = GetBuffer()
        Expect by_clang_format_command ==# buffer
    end

    it 'formats selected code in visual mode'
        " format for statement
        let by_clang_format_command = ClangFormat(11, 13)
        " move to for statement block
        execute 11
        normal! VjjV
        '<,'>ClangFormat
        let buffer = GetBuffer()
        Expect by_clang_format_command ==# buffer
    end

    it 'doesn''t move cursor'
        execute 'normal!' (1+line('$')).'gg'
        let pos = getpos('.')
        ClangFormat
        Expect pos == getpos('.')
    end

end
" }}}
