10new
20vnew
call setline(1, repeat('aa_', 200))
setlocal breakindent breakindentopt=shift:4 linebreak showbreak=>> scrolloff=0
setlocal number
set cpo+=n
normal 12gj
redraw!
normal $
redraw!
