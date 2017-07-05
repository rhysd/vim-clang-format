function! s:is_empty_region(begin, end) abort
    return a:begin[1] > a:end[1] || (a:begin[1] == a:end[1] && a:end[2] < a:begin[2])
endfunction

function! operator#clang_format#do(motion_wise) abort
    if s:is_empty_region(getpos("'["), getpos("']"))
        return
    endif

    " Do not move cursor and screen
    if exists('g:operator#clang_format#save_pos') && exists('g:operator#clang_format#save_screen_pos')
        call clang_format#replace(getpos("'[")[1], getpos("']")[1], g:operator#clang_format#save_pos, g:operator#clang_format#save_screen_pos)
        unlet g:operator#clang_format#save_pos
        unlet g:operator#clang_format#save_screen_pos
    else
        call clang_format#replace(getpos("'[")[1], getpos("']")[1])
    endif
endfunction
