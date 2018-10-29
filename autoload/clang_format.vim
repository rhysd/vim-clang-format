let s:save_cpo = &cpo
set cpo&vim

let s:on_windows = has('win32') || has('win64')
let s:dict_t = type({})
if exists('v:true')
    let s:bool_t = type(v:true)
else
    let s:bool_t = -1
endif

" helper functions {{{
function! s:has_vimproc() abort
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

function! s:system(str, ...) abort
    let command = a:str
    let input = a:0 >= 1 ? a:1 : ''

    if a:0 == 0 || a:1 ==# ''
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

function! s:create_keyvals(key, val) abort
    if type(a:val) == s:dict_t
        return a:key . ': {' . s:stringize_options(a:val) . '}'
    else
        if type(a:val) == s:bool_t
            return a:key . (a:val == v:true ? ': true' : ': false')
        else
            return a:key . ': ' . a:val
        endif
    endif
endfunction

function! s:stringize_options(opts) abort
    let keyvals = map(items(a:opts), 's:create_keyvals(v:val[0], v:val[1])')
    return join(keyvals, ',')
endfunction

function! s:build_extra_options() abort
    let opts = copy(g:clang_format#style_options)
    if has_key(g:clang_format#filetype_style_options, &ft)
        call extend(opts, g:clang_format#filetype_style_options[&ft])
    endif

    let extra_options = s:stringize_options(opts)
    if !empty(extra_options)
        let extra_options = ', ' . extra_options
    endif

    return extra_options
endfunction

function! s:make_style_options() abort
    let extra_options = s:build_extra_options()
    return printf("{BasedOnStyle: %s, IndentWidth: %d, UseTab: %s%s}",
                        \ g:clang_format#code_style,
                        \ (exists('*shiftwidth') ? shiftwidth() : &l:shiftwidth),
                        \ &l:expandtab==1 ? 'false' : 'true',
                        \ extra_options)
endfunction

function! s:success(result) abort
    let exit_success = (s:has_vimproc() ? vimproc#get_last_status() : v:shell_error) == 0
    return exit_success && a:result !~# '^YAML:\d\+:\d\+: error: unknown key '
endfunction

function! s:error_message(result) abort
    echoerr 'clang-format has failed to format.'
    if a:result =~# '^YAML:\d\+:\d\+: error: unknown key '
        echohl ErrorMsg
        for l in split(a:result, "\n")[0:1]
            echomsg l
        endfor
        echohl None
    endif
endfunction

function! clang_format#get_version() abort
    if &shell =~# 'csh$' && executable('/bin/bash')
        let shell_save = &shell
        set shell=/bin/bash
    endif
    try
        let version_output = s:system(s:shellescape(g:clang_format#command).' --version 2>&1')
        if stridx(version_output, 'NPM') != -1
            " Note:
            " When clang-format is installed with npm, version string is changed (#39).
            return matchlist(version_output, 'NPM version \d\+\.\d\+\.\(\d\)\(\d\+\)')[1:2]
        else
            return matchlist(version_output, '\(\d\+\)\.\(\d\+\)')[1:2]
        endif
    finally
        if exists('l:shell_save')
            let &shell = shell_save
        endif
    endtry
endfunction

function! clang_format#is_invalid() abort
    if !exists('s:command_available')
        if !executable(g:clang_format#command)
            return 1
        endif
        let s:command_available = 1
    endif

    if !exists('s:version')
        let v = clang_format#get_version()
        if len(v) < 2
            " XXX: Give up checking version
            return 0
        endif
        if v[0] < 3 || (v[0] == 3 && v[1] < 4)
            return 2
        endif
        let s:version = v
    endif

    return 0
endfunction

function! s:verify_command() abort
    let invalidity = clang_format#is_invalid()
    if invalidity == 1
        echoerr "clang-format is not found. check g:clang_format#command."
    elseif invalidity == 2
        echoerr 'clang-format 3.3 or earlier is not supported for the lack of aruguments'
    endif
endfunction

function! s:shellescape(str) abort
    if s:on_windows && (&shell =~? 'cmd\.exe')
        " shellescape() surrounds input with single quote when 'shellslash' is on. But cmd.exe
        " requires double quotes. Temporarily set it to 0.
        let shellslash = &shellslash
        set noshellslash
        try
            return shellescape(a:str)
        finally
            let &shellslash = shellslash
        endtry
    endif
    return shellescape(a:str)
endfunction

" }}}

" variable definitions {{{
function! s:getg(name, default) abort
    " backward compatibility
    if exists('g:operator_'.substitute(a:name, '#', '_', ''))
        echoerr 'g:operator_'.substitute(a:name, '#', '_', '').' is deprecated. Please use g:'.a:name
        return g:operator_{substitute(a:name, '#', '_', '')}
    else
        return get(g:, a:name, a:default)
    endif
endfunction

let g:clang_format#command = s:getg('clang_format#command', 'clang-format')
let g:clang_format#extra_args = s:getg('clang_format#extra_args', "")
if type(g:clang_format#extra_args) == type([])
    let g:clang_format#extra_args = join(g:clang_format#extra_args, " ")
endif

let g:clang_format#code_style = s:getg('clang_format#code_style', 'google')
let g:clang_format#style_options = s:getg('clang_format#style_options', {})
let g:clang_format#filetype_style_options = s:getg('clang_format#filetype_style_options', {})

let g:clang_format#detect_style_file = s:getg('clang_format#detect_style_file', 1)
let g:clang_format#enable_fallback_style = s:getg('clang_format#enable_fallback_style', 1)

let g:clang_format#auto_format = s:getg('clang_format#auto_format', 0)
let g:clang_format#auto_format_on_insert_leave = s:getg('clang_format#auto_format_on_insert_leave', 0)
let g:clang_format#auto_formatexpr = s:getg('clang_format#auto_formatexpr', 0)
" }}}

" format codes {{{
function! s:detect_style_file() abort
    let dirname = fnameescape(expand('%:p:h'))
    return findfile('.clang-format', dirname.';') != '' || findfile('_clang-format', dirname.';') != ''
endfunction

function! clang_format#format(line1, line2) abort
    let args = printf(' -lines=%d:%d', a:line1, a:line2)
    if ! (g:clang_format#detect_style_file && s:detect_style_file())
        if g:clang_format#enable_fallback_style
            let args .= ' ' . s:shellescape(printf('-style=%s', s:make_style_options())) . ' '
        else
            let args .= ' -fallback-style=none '
        endif
    else
        let args .= ' -style=file '
    endif
    let filename = expand('%')
    if filename !=# ''
        let args .= printf('-assume-filename=%s ', s:shellescape(escape(filename, " \t")))
    endif
    let args .= g:clang_format#extra_args
    let clang_format = printf('%s %s --', s:shellescape(g:clang_format#command), args)
    let source = join(getline(1, '$'), "\n")
    return s:system(clang_format, source)
endfunction
" }}}

" replace buffer {{{
function! clang_format#replace(line1, line2, ...) abort
    call s:verify_command()

    let pos_save = a:0 >= 1 ? a:1 : getpos('.')
    let formatted = clang_format#format(a:line1, a:line2)
    if !s:success(formatted)
        call s:error_message(formatted)
        return
    endif

    let winview = winsaveview()
    let splitted = split(formatted, '\n', 1)

    silent! undojoin
    if line('$') > len(splitted)
        execute len(splitted) .',$delete' '_'
    endif
    call setline(1, splitted)
    call winrestview(winview)
    call setpos('.', pos_save)
endfunction
" }}}

" auto formatting on insert leave {{{
let s:pos_on_insertenter = []

function! s:format_inserted_area() abort
    let pos = getpos('.')
    " When in the same buffer
    if &modified && ! empty(s:pos_on_insertenter) && s:pos_on_insertenter[0] == pos[0]
        call clang_format#replace(s:pos_on_insertenter[1], line('.'))
        let s:pos_on_insertenter = []
    endif
endfunction

function! clang_format#enable_format_on_insert() abort
    augroup plugin-clang-format-auto-format-insert
        autocmd!
        autocmd InsertEnter <buffer> let s:pos_on_insertenter = getpos('.')
        autocmd InsertLeave <buffer> call s:format_inserted_area()
    augroup END
endfunction
" }}}

" toggle auto formatting {{{
function! clang_format#toggle_auto_format() abort
    let g:clang_format#auto_format = !g:clang_format#auto_format
    if g:clang_format#auto_format
        echo 'Auto clang-format: enabled'
    else
        echo 'Auto clang-format: disabled'
    endif
endfunction
" }}}

" enable auto formatting {{{
function! clang_format#enable_auto_format() abort
    let g:clang_format#auto_format = 1
endfunction
" }}}

" disable auto formatting {{{
function! clang_format#disable_auto_format() abort
    let g:clang_format#auto_format = 0
endfunction
" }}}
let &cpo = s:save_cpo
unlet s:save_cpo
