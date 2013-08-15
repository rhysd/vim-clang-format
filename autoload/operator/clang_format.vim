function! operator#clang_format#do(motion_wise)

    let sel_save = &l:selection
    let &l:selection = "inclusive"

    echo string(getpos("'[")[1:2]) . string(getpos("']")[1:2])

    let &l:selection = sel_save
endfunction
