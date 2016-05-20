" タブ
setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2

" コメント
setlocal commentstring=<!--\ %s\ -->

" 自動形成について(特に、自動改行) (:h formatoptions, :h fo-table)
" 文字数制限/行は解除
setlocal textwidth=0
" 自動改行を抑制
setlocal formatoptions-=t
setlocal formatoptions-=c
" コメントスタイルの自動挿入を抑制
setlocal formatoptions-=r
setlocal formatoptions-=o



"
" :FormMarkdownEOL
"
function! s:FormMarkdownEOL() range
  let l:cur = line('.')

  exe 'silent %s/\s\+$//e'
  exe 'silent %s/^[^$].\+$/&  /e'

  exe 'silent %s/^[^$]\s*.\+\zs\s\{2}\ze$\n$//e'


  " -- headers
  exe 'silent g/^\(=\|-\)\+\s*$/s/\s\+$//e'
  exe 'silent g/^\(=\|-\)\+\s*$/-1s/\s\+$//e'
  exe 'silent g/^#\+[^#]/s/\s\+$//e'
  exe 'silent g/^#\+[^#]/-1s/\s\+$//e'

  " -- horizontal rules (This really doesn't have any meaning...)
  exe 'silent %s/\(^\(-\|*\|_\)\{3,}\)\s\+$/\1/e'
  exe 'silent %s/\(^-\+\(\s\+-\+\)\s\{-}-\+\)\s\+$/\1/e'
  exe 'silent %s/\(^\*\+\(\s\+\*\+\)\s\{-}\*\+\)\s\+$/\1/e'
  exe 'silent %s/\(^_\+\(\s\+_\+\)\s\{-}_\+\)\s\+$/\1/e'

  " -- table
  exe 'silent %s/\(^\s\+|.\+|\)\s\+$/\1/e'

  " --- html tag
  exe 'silent %s/^\s*<\a.\{-}>\zs\s\+$//e'
  exe 'silent %s/<\/\a\{-}>\zs\s\+//ge'
  exe 'silent %s/\zs\s\+\ze$\n^\s*<\/\a\{-}>//e'

  " -- Reference-style links
  exe 'silent %s/^\s*\[\(\a\|\d\)\{-}]:\s\+<*https*:.\+>*\s\+".*"\zs\s\+$//e'
  exe 'silent %s/^\s*\[\(\a\|\d\)\{-}]:\s\+<*https*:.\+>*\s\+''.*''\zs\s\+$//e'
  exe 'silent %s/^\s*\[\(\a\|\d\)\{-}]:\s\+<*https*:.\+>*\s\+(.*)\zs\s\+$//e'


  let l:iscodeblock = 0         " is NOT code block
  " for l:linenum in range(1, line('$'))
  echo 'first : ' . a:firstline
  echo 'last  : ' . a:lastline

  for l:linenum in range(a:firstline, a:lastline)
    let l:linestr = getline(l:linenum)
  " -- code blocks
    if match(l:linestr, '^\s*```') >= 0
      if l:iscodeblock == 0
        let l:iscodeblock = 1   " is code block (switch on)
      else
        let l:iscodeblock = 0   " is NOT code block (switch off)
      endif
    endif

    if l:iscodeblock == 1
      "erase the blanks on EOL
      exe 'silent ' . l:linenum . 's/\s\+$//e'
    else
  " -- lists
      " if match(l:linestr, '^\s*\(\*\|+\|-\|\d\+\.\)\s\+[^-*].') >= 0
      "   let l:linenum_prev = l:linenum - 1
      "   let l:linenum_next = l:linenum + 1
      "
      "   if len(getline(l:linenum_prev)) >= 0
      "       if match(getline(l:linenum_prev),  '^\s*\(\*\|+\|-\|\d\+\.\)\s\+[^-*].') < 0
      "         exe 'silent ' . l:linenum_prev . 's/\s\+$//e'
      "       endif
      "   endif
      "
      "   if len(getline(l:linenum_next)) >= 0
      "       if match(getline(l:linenum_next),  '^\s*\(\*\|+\|-\|\d\+\.\)\s\+[^-*].') >= 0
      "         exe 'silent ' . l:linenum . 's/\s\+$//e'
      "       endif
      "   else
      "       exe 'silent ' . l:linenum . 's/\s\+$//e'
      "   endif
      " endif
      let l:linenum_next = l:linenum + 1
      if len(getline(l:linenum_next)) >= 0
          if match(getline(l:linenum_next),  '^\s*\(\*\|+\|-\|\d\+\.\)\s\+[^-*].') >= 0
            exe 'silent ' . l:linenum . 's/\s\+$//e'
          endif
      else
          exe 'silent ' . l:linenum . 's/\s\+$//e'
      endif
    endif
  endfor

  exe l:cur
endfunction
command! -nargs=0 -range=% Mdown <line1>, <line2> call s:FormMarkdownEOL()
