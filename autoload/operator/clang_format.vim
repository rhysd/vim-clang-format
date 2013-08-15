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

    if a:motion_wise ==# 'line'
        let args = " -lines=".start[0].":".last[0]." "
    else
        " FIXME character wise and block wise
        throw "not implemented"
        return
    endif

    " FIXME a bug when the number of lines of the after is diffrent from the one
    " of the before
    let clang_format = printf("clang-format %s %s --", args, expand('%:p'))
    let formatted = join(split(s:system(clang_format), "\n")[start[0]-1:last[0]-1], "\n")
    call setreg('g', formatted)
    execute 'normal!' 'gv"gp'

    call setreg('g', save_g_reg, save_g_regtype)
    let &l:selection = sel_save
endfunction


