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

function! operator#clang_format#do(motion_wise)

    let sel_save = &l:selection
    let &l:selection = "inclusive"
    let save_g_reg = getreg('g')
    let save_g_regtype = getregtype('g')

    let start = getpos("'[")[1:2]
    let last = getpos("']")[1:2]

    " FIXME check if the region is empty or not

    if a:motion_wise !=# 'line'
        " FIXME character wise and block wise
        throw "not implemented except for line wise text objects."
        return
    endif

    let style = printf("'{BasedOnStyle: %s, IndentWidth: %d, UseTab: %s}'",
                      \ g:operator_clang_format_code_style,
                      \ &l:shiftwidth,
                      \ &l:expandtab==1 ? "false" : "true")

    let args = printf(" -lines=%d:%d -style=%s %s", start[0], last[0], style, g:operator_clang_format_clang_args)
    echo args

    " FIXME a bug when the number of lines of the after is diffrent from the one
    " of the before
    let clang_format = printf("clang-format %s --", args)
    let formatted = s:system(clang_format, join(getbufline(bufnr('%'), 1, line('$')), "\n"))
    call setreg('g', formatted)

    let pos = getpos('.')
    execute 'normal!' 'ggVG"gp'
    call setpos('.', pos)

    call setreg('g', save_g_reg, save_g_regtype)
    let &l:selection = sel_save
endfunction


