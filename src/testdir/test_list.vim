" Test for VimL List functionality
" that is not covered by other tests yet.
"
func! Test_list_empty()
  call assert_equal(0, len([]))
  call assert_equal(1, [] == [])
  call assert_equal(0, [1] == [])
endfunc

func! Test_list_idx_of_item()
  let l=[1,2]
  let l[0:-1] = [3, 4]
  call assert_equal(l, [3,4])
endfunc

func! Test_list_find_str()
  let a=copy(v:oldfiles)
  new
  let v:oldfiles=[]
  call add(v:oldfiles, 'README.txt')
  call add(v:oldfiles, 'README_does_not_exist.txt')
  call feedkeys(":browse :oldfiles\n0", 'tnix')
  call assert_equal('', bufname('%'))
  call feedkeys(":browse :oldfiles\n2", 'tnix')
  call assert_equal('README_does_not_exist.txt', bufname('%'))
  call feedkeys(":browse :oldfiles\n1", 'tnix')
  call assert_equal('README.txt', bufname('%'))
  try
    call feedkeys(":browse :oldfiles\n3\n", 'tnix')
    call assert_false(0, 1)
  catch /^Vim\%((\a\+)\)\=:E684/
  endtry
  let v:oldfiles=a
  bw!
endfunc

