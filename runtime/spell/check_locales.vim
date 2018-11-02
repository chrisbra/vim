" Script to check if all the locales used in spell files are available.

let _grepprg=&grepprg
set grepprg&vim
grep /sys */main.aap
let not_supported = []
for item in getqflist()
  let lang = substitute(item.text, '.*LANG=\(\S\+\).*', '\1', '')
  try
    exe 'lang ' . lang
  catch /E197/
    call add(not_supported, lang)
  endtry
endfor

if len(not_supported) > 0
  echo "Unsupported languages:"
  for l in not_supported
    echo l
  endfor
else
  echo "Everything appears to be OK"
endif
let &grepprg=_grepprg
