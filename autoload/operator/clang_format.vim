" helper functions {{{
function! s:has_vimproc()
  if !exists('s:exists_vimproc')
    try
      call vimproc#version()
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
    for [key, value] in items(g:operator_clang_format_style_options)
        let extra_options .= printf(", %s: %s", key, value)
    endfor
    return printf("'{BasedOnStyle: %s, IndentWidth: %d, UseTab: %s%s}'",
                        \ g:operator_clang_format_code_style,
                        \ &l:shiftwidth,
                        \ &l:expandtab==1 ? "false" : "true",
                        \ extra_options)
endfunction

function! s:success(result)
    return (s:has_vimproc() ? vimproc#get_last_status() : v:shell_error) == 0
                \ && a:result !~# '^YAML:\d\+:\d\+: error: unknown key '
endfunction

function! s:error_message(result)
    echoerr "clang-format has failed to format."
    if a:result =~# '^YAML:\d\+:\d\+: error: unknown key '
        echohl Error
        for l in split(a:result, "\n")[0:1]
            echomsg l
        endfor
        echohl None
    endif
endfunction

function! s:is_empty_region(begin, end)
  return a:begin[1] == a:end[1] && a:end[2] < a:begin[2]
endfunction
" }}}

" main logic {{{
function! operator#clang_format#do(motion_wise)

    if s:is_empty_region(getpos("'["), getpos("']"))
        return
    endif

    let sel_save = &l:selection
    let &l:selection = "inclusive"
    let save_g_reg = getreg('g')
    let save_g_regtype = getregtype('g')

    " FIXME character wise
    " FIXME cursor position history is violated by ggVG"gp

    let args = printf(" -lines=%d:%d -style=%s %s",
                \     getpos("'[")[1],
                \     getpos("']")[1],
                \     s:make_style_options(),
                \     g:operator_clang_format_clang_args)

    let clang_format = printf("%s %s --", g:operator_clang_format_command, args)
    let formatted = s:system(clang_format, join(getline(1, '$'), "\n"))

    if s:success(formatted)
        call setreg('g', formatted)
        let pos = getpos('.')
        execute 'normal!' 'ggVG"gp'
        call setpos('.', pos)
    else
        call s:error_message(formatted)
    endif

    call setreg('g', save_g_reg, save_g_regtype)
    let &l:selection = sel_save
endfunction
" }}}
