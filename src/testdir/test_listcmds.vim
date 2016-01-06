  " Test for :windo/:bufdo/:argdo/:cdo/:cfdo/:ldo/:lfdo commnads and the <restore>
  " argument

  func SetUp() "{{{1
    call writefile(['foobar1'], 'foobar1.txt')
    call writefile(['foobar2']+range(1,15), 'foobar2.txt')
    call writefile(['foobar3'], 'foobar3.txt')
  endfu

  func s:Arglist() "{{{1
    redir => arg | sil args | redir end
    return arg
  endfu

  func TestDown() "{{{1
    for i in range(1,3)
    call delete('foobar'.i.'.txt')
  endfu

  func Test_windo() "{{{1
    if !has("windows")
      return
    endif
    e foobar1.txt
    sp foobar2.txt | norm! 15zt$
    sp foobar3.txt
    1wincmd w
    windo sil echo 1
    " Cursor should be in last window: 3
    call assert_equal(3, winnr())
    1,2windo sil echo 1
    " Cursor should be in 2 window: 2
    call assert_equal(2,winnr())
    2wincmd w
    let a=winsaveview()
    windo <restore> sil echo 1
    " Cursor should be in 2 window: 2
    call assert_equal(2,winnr())
    call assert_equal(a, winsaveview())
    %bw!
  endfunc

  func Test_bufdo() "{{{1
    let startnr = bufnr('')
    e foobar1.txt
    e foobar2.txt
    e foobar3.txt
    let endnr = bufnr('$')
    " Cursor in last buffer
    call assert_equal(startnr+2, endnr)
    bufdo sil echo 1
    " Cursor in last buffer
    call assert_equal(endnr, bufnr(''))
    exe printf(":%d,%dbufdo sil echo 1", startnr+1, startnr+2)
    " Cursor in second last buffer
    call assert_equal(endnr, bufnr(''))
    exe startnr+2."b"
    set modified
    try
      bufdo sil echo 1
    catch /^Vim\%((\a\+)\)\=:E37/
    endtry
    set nomodified
    " cursor still in the same buffer
    call assert_equal(startnr+2, bufnr(''))
    bufdo! sil echo 1
    " aborted modified buffer, cursor in last buffer
    call assert_equal(endnr, bufnr(''))
    exe startnr+2."b"
    norm! 15zt$
    let a=winsaveview()
    bufdo <restore> sil echo 1
    call assert_equal(startnr+2, bufnr(''))
    call assert_equal(a, winsaveview())
    %bw!
  endfu

  func Test_argdo() "{{{1
    let startnr = bufnr('')
    argadd f*.txt
    let endnr = bufnr('$')
    first
    call assert_equal(startnr, bufnr(''))
    set modified
    try
      argdo :sil echo 1
    catch /^Vim\%((\a\+)\)\=:E37/
      set nomodified
    endtry
    let args=s:Arglist()
    call assert_equal(startnr, bufnr(''))
    argdo :sil echo 1
    call assert_equal(endnr, bufnr(''))
    call assert_true(args isnot# s:Arglist())
    first
    next
    let args=s:Arglist()
    let curbuf = bufnr('')
    let a=winsaveview()
    argdo <restore> sil echo 1
    call assert_equal(curbuf, bufnr(''))
    call assert_equal(a, winsaveview())
    call assert_equal(args, s:Arglist())
    set modified
    try
      argdo :sil echo 1
    catch /^Vim\%((\a\+)\)\=:E37/
      set nomodified
    endtry
    call assert_equal(curbuf, bufnr(''))
    call assert_equal(a, winsaveview())
    %bw!
  endfu

  func Test_qdo() "{{{1
    let startnr = bufnr('')
    vimgrep /foobar/j f*.txt
    let endnr = bufnr('$')
    copen
    wincmd w
    call assert_equal(startnr, bufnr(''))
    cnext
    call assert_equal(startnr+2, bufnr(''))
    cdo sil echo 1
    call assert_equal(endnr, bufnr(''))
    exe startnr+2.'b'
    norm! 15zt$
    let a=winsaveview()
    cdo <restore> sil echo 1
    call assert_equal(startnr+2, bufnr(''))
    call assert_equal(a, winsaveview())
    cclose
    %bw!
  endfu

" vim: tabstop=2 shiftwidth=0 expandtab
