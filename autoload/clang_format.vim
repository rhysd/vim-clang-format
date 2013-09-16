" helper functions {{{
function! s:has_vimproc()
    if !exists('s:exists_vimproc')
        try
            silent call vimproc#version()
            let s:exists_vimproc = 1
        catch
            let s:exists_vimproc = 0
        endtry
    endif
    return s:exists_vimproc
endfunction

function! s:system(str, ...)
    let command = a:str
    let input = a:0 >= 1 ? a:1 : ''

    if a:0 == 0
        let output = s:has_vimproc() ?
                    \ vimproc#system(command) : system(command)
    elseif a:0 == 1
        let output = s:has_vimproc() ?
                    \ vimproc#system(command, input) : system(command, input)
    else
        " ignores 3rd argument unless you have vimproc.
        let output = s:has_vimproc() ?
                    \ vimproc#system(command, input, a:2) : system(command, input)
    endif

    return output
endfunction

function! s:make_style_options()
    let extra_options = ""
    for [key, value] in items(g:clang_format_style_options)
        let extra_options .= printf(", %s: %s", key, value)
    endfor
    return printf("'{BasedOnStyle: %s, IndentWidth: %d, UseTab: %s%s}'",
                        \ g:clang_format_code_style,
                        \ &l:shiftwidth,
                        \ &l:expandtab==1 ? "false" : "true",
                        \ extra_options)
endfunction

function! s:success(result)
    return (s:has_vimproc() ? vimproc#get_last_status() : v:shell_error) == 0
                \ && a:result !~# '^YAML:\d\+:\d\+: error: unknown key '
                \ && a:result !~# '^\n\?$'
endfunction

function! s:error_message(result)
    echoerr "clang-format has failed to format."
    if a:result =~# '^YAML:\d\+:\d\+: error: unknown key '
        echohl ErrorMsg
        for l in split(a:result, "\n")[0:1]
            echomsg l
        endfor
        echohl None
    endif
endfunction

function! clang_format#format(line1, line2)
    let args = printf(" -lines=%d:%d -style=%s %s",
                \     a:line1,
                \     a:line2,
                \     s:make_style_options(),
                \     g:clang_format_extra_args)

    let clang_format = printf("%s %s --", g:clang_format_command, args)
    return s:system(clang_format, join(getline(1, '$'), "\n"))
endfunction
" }}}

" main logic {{{
function! clang_format#replace(line1, line2)
    let sel_save = &l:selection
    let &l:selection = "inclusive"
    let [save_g_reg, save_g_regtype] = [getreg('g'), getregtype('g')]

    let formatted = clang_format#format(a:line1, a:line2)

    if s:success(formatted)
        call setreg('g', formatted)
        let pos = getpos('.')
        execute 'keepjumps' 'silent' 'normal!' 'ggVG"gp'
        call setpos('.', pos)
    else
        call s:error_message(formatted)
    endif

    call setreg('g', save_g_reg, save_g_regtype)
    let &l:selection = sel_save
endfunction
" }}}
