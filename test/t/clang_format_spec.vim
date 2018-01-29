" test with vim-vspec
" https://github.com/kana/vim-vspec

" helpers "{{{
" clang-format detection
function! s:detect_clang_format() abort
    if $CLANG_FORMAT !=# '' && executable($CLANG_FORMAT)
        return $CLANG_FORMAT
    endif

    for suffix in ['-HEAD', '-5.0', '-4.0', '-3.8', '-3.7', '-3.6', '-3.5', '-3.4', '']
        let c = 'clang-format' . suffix
        if executable(c)
            return c
        endif
    endfor
    throw 'not ok because detect clang-format could not be found in $PATH'
endfunction
let g:clang_format#command = s:detect_clang_format()

function! Chomp(s) abort
    return a:s =~# '\n$'
                \ ? a:s[0:len(a:s)-2]
                \ : a:s
endfunction

function! ChompHead(s) abort
    return a:s =~# '^\n'
                \ ? a:s[1:len(a:s)-1]
                \ : a:s
endfunction

function! GetBuffer() abort
    return join(getline(1, '$'), "\n")
endfunction

function! ClangFormat(line1, line2, ...) abort
    let opt = printf("-lines=%d:%d '-style={BasedOnStyle: Google, IndentWidth: %d, UseTab: %s", a:line1, a:line2, &l:shiftwidth, &l:expandtab==1 ? "false" : "true")
    let file = 'test.cpp'

    for a in a:000
        if a =~# '^test\.\w\+$'
            let file = a
        else
            let opt .= a
        endif
    endfor
    let opt .= "}'"

    let cmd = printf('%s %s ./t/%s --', g:clang_format#command, opt, file)
    let result = Chomp(system(cmd))
    if v:shell_error
        throw "Error on system(): clang-format exited with non-zero.\nCommand: " . cmd . "\nOutput: " . result
    endif
    return Chomp(system(cmd))
endfunction
"}}}

" setup {{{
let s:root_dir = resolve(getcwd() . '/..')
execute 'set' 'rtp +=' . s:root_dir

runtime! plugin/clang_format.vim

call vspec#customize_matcher('to_be_empty', function('empty'))

function! RaisesException(cmd) abort
    try
        execute a:cmd
        return 0
    catch
        return 1
    endtry
endfunction

call vspec#customize_matcher('to_throw_exception', function('RaisesException'))

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
        Expect exists('g:clang_format#filetype_style_options') to_be_true
        Expect exists('g:clang_format#command') to_be_true
        Expect exists('g:clang_format#detect_style_file') to_be_true
        Expect exists('g:clang_format#auto_format') to_be_true
        Expect exists('g:clang_format#auto_format_on_insert_leave') to_be_true
        Expect g:clang_format#extra_args to_be_empty
        Expect g:clang_format#code_style ==# 'google'
        Expect g:clang_format#style_options to_be_empty
        Expect g:clang_format#filetype_style_options to_be_empty
        Expect executable(g:clang_format#command) to_be_true
        Expect g:clang_format#detect_style_file to_be_true
    end

    it 'provide commands'
        Expect exists(':ClangFormat') to_be_true
        Expect exists(':ClangFormatEchoFormattedCode') to_be_true
    end
end
"}}}

" test for clang_format#format() {{{
function! s:expect_the_same_output(line1, line2) abort
    Expect clang_format#format(a:line1, a:line2) ==# ClangFormat(a:line1, a:line2)
endfunction

describe 'clang_format#format()'

    before
        let g:clang_format#detect_style_file = 0
        new
        execute 'silent' 'edit!' './t/test.cpp'
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

    describe 'g:clang_format#style_options'
        before
            let g:clang_format#detect_style_file = 0
            new
            execute 'silent' 'edit!' './t/test.cpp'

            let s:saved_styles = [g:clang_format#style_options, &expandtab, &shiftwidth]
            set expandtab
            set shiftwidth=4
        end

        after
            close!
            let [g:clang_format#style_options, &expandtab, &shiftwidth] = s:saved_styles
        end

        it 'customizes code styles'
            let g:clang_format#style_options = {'UseTab' : 'false', 'IndentWidth' : 4}
            call s:expect_the_same_output(1, line('$'))
        end

        it 'can contain v:true/v:false'
            if exists('v:false')
                let g:clang_format#style_options = {'UseTab' : v:false, 'IndentWidth' : 4}
                call s:expect_the_same_output(1, line('$'))
            endif
        end
    end

    it 'ensures to fix issue #38'
        let saved = g:clang_format#style_options
        try
            let g:clang_format#style_options = {
                        \ "BraceWrapping" : {
                        \     "AfterControlStatement" : "true" ,
                        \     "AfterClass " : "true",
                        \   },
                        \ }
            try
                call clang_format#format(1, line('$'))
            catch /^YAML:\d\+:\d\+/
                " OK
            endtry
        finally
            let g:clang_format#style_options = saved
        endtry
    end
end

describe 'clang_format#replace()'
    before
        let g:clang_format#detect_style_file = 0
        new
        execute 'silent' 'edit!' './t/test.cpp'
        let s:cmd_tmp = g:clang_format#command
    end

    after
        bdelete!
        let g:clang_format#command = s:cmd_tmp
    end

    it 'throws an error when command is not found'
        let g:clang_format#command = "clang_format_not_exist"
        Expect "call clang_format#replace(1, line('$'))" to_throw_exception
    end

    it 'throws an error when command is not found'
        let g:clang_format#command = './t/clang-format-dummy.sh'
        Expect "call clang_format#replace(1, line('$'))" to_throw_exception
    end
end
" }}}

" test for <Plug>(operator-clang-format) {{{
describe '<Plug>(operator-clang-format)'

    before
        let g:clang_format#detect_style_file = 0
        new
        execute 'silent' 'edit!' './t/test.cpp'
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

    describe 'with filetype cpp'

        before
            let g:clang_format#detect_style_file = 0
            new
            execute 'silent' 'edit!' './t/test.cpp'
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

        it 'maintains screen position while formatting'
            execute 'normal!' "3\<C-e>"
            let prev = line('w0')
            ClangFormat
            let current = line('w0')
            Expect prev ==# current
        end
    end

    describe 'with filetype javascript'

        before
            let g:clang_format#detect_style_file = 0
            new
            execute 'silent' 'edit!' './t/test.js'
        end

        after
            bdelete!
        end

        it 'formats the whole code in normal mode'
            let by_clang_format_command = ClangFormat(1, line('$'), 'test.js')
            ClangFormat
            let buffer = GetBuffer()
            Expect by_clang_format_command ==# buffer
        end

    end

    describe 'hard tab'

        before
            let g:clang_format#detect_style_file = 0
            let s:saved_expandtab = &expandtab
            let s:saved_shiftwidth = &shiftwidth
            set noexpandtab shiftwidth=8
            new
            execute 'silent' 'edit!' './t/test.cpp'
        end

        after
            let &expandtab = s:saved_expandtab
            let &shiftwidth = s:saved_shiftwidth
        end

        it 'does not break formatting'
            let by_clang_format_command = ClangFormat(1, line('$'), 'test.cpp')
            ClangFormat
            let buffer = GetBuffer()
            Expect by_clang_format_command ==# buffer
        end

    end
end
" }}}

" test for auto formatting {{{
describe 'g:clang_format#auto_format'

    before
        let g:clang_format#auto_format = 1
        new
        execute 'silent' 'edit!' './t/test.cpp'
    end

    after
        bdelete!
    end

    it 'formats a current buffer on BufWritePre if the value is 1'
        SKIP 'because somehow BufWritePre event isn''t fired'
        let formatted = clang_format#format(1, line('$'))
        doautocmd BufWritePre
        let auto_formatted = join(getline(1, line('$')), "\n")
        Expect auto_formatted ==# formatted
    end
end
" }}}

" test for auto formatting on insert leave {{{
describe 'g:clang_format#auto_format_on_insert_leave'

    before
        let g:clang_format#auto_format_on_insert_leave = 1
        new
        execute 'silent' 'edit!' './t/test.cpp'
    end

    after
        bdelete!
    end

    it 'formats a inserted area on InsertLeave if the value is 1'
        SKIP 'because somehow InsertEnter and InsertLeave events aren''t fired'
        execute 10
        execute 'normal' "iif(1+2)return 4;\<Esc>"
        Expect getline('.') ==# '    if (1 + 2) return 4;'
    end
end

" }}}

" test for auto 'formatexpr' setting feature {{{
describe 'g:clang_format#auto_formatexpr'
    before
        let g:clang_format#auto_formatexpr = 1
        new
        execute 'silent' 'edit!' './t/test.cpp'
    end

    after
        bdelete!
    end

    it 'formats the text object using gq operator'
        SKIP 'because of unknown backslash on formatting too long macros'
        doautocmd Filetype cpp
        let expected = ClangFormat(1, line('$'))
        normal ggVGgq
        let actual = GetBuffer()
        Expect expected ==# actual
    end
end
" }}}

" test for undo {{{
describe 'undo formatting text'
    before
        let g:clang_format#detect_style_file = 0
        new
        execute 'silent' 'edit!' './t/test.cpp'
    end

    after
        bdelete!
    end

    it 'restores previous text as editing buffer normally'
        let prev = GetBuffer()
        ClangFormat
        undo
        let buf = GetBuffer()
        Expect prev ==# buf
    end
end
" }}}

" test for empty buffer {{{
describe 'empty buffer'
    before
        let g:clang_format#detect_style_file = 0
        new
    end

    after
        bdelete!
    end

    it 'can format empty buffer'
        ClangFormat
    end

    it 'can format a buffer containing only new lines'
        call setline('.', ['', ''])
        ClangFormat
        call setline('.', ['', '', ''])
        ClangFormat
    end
end
" }}}"
