"$MYRUNTIMEPATH/after/check.vim

" タブ
setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2

" todoリストを簡単に入力する
abbreviate tl [ ]:

" 入れ子のリストを折りたたむ
setlocal foldmethod=expr foldexpr=MkdCheckboxFold(v:lnum) foldtext=MkdCheckboxFoldText()
function! MkdCheckboxFold(lnum)
    let line = getline(a:lnum)
    let next = getline(a:lnum + 1)
    if MkdIsNoIndentCheckboxLine(line) && MkdHasIndentLine(next)
        return 1
    elseif (MkdIsNoIndentCheckboxLine(next) || next =~ '^$') && !MkdHasIndentLine(next)
        return '<1'
    endif
    return '='
endfunction
function! MkdIsNoIndentCheckboxLine(line)
    return a:line =~ '^\[[ x]\]: '
endfunction
function! MkdHasIndentLine(line)
    return a:line =~ '^[[:blank:]]\+'
endfunction
function! MkdCheckboxFoldText()
    return getline(v:foldstart) . ' (' . (v:foldend - v:foldstart) . ' lines) '
endfunction

" todoリストのon/offを切り替える
nnoremap <buffer> <Leader><Leader> :call ToggleCheckbox()<CR>
vnoremap <buffer> <Leader><Leader> :call ToggleCheckbox()<CR>

" 選択行のチェックボックスを切り替える
function! ToggleCheckbox()
  let l:line = getline('.')
  if l:line =~ '\[\s\]'
    let l:result = substitute(l:line, '\[\s\]', '[x]', '')
    " let l:result = substitute(l:line, '\[\s\]', '[' . strftime("%Y%m%d") . ']', '')
    call setline('.', l:result)
  elseif l:line =~ '\[x\]'
    let l:result = substitute(l:line, '\[x\]', '[ ]', '')
    " let l:result = substitute(l:line, '\[\d\{8}\]', '[ ]', '')
    call setline('.', l:result)
  end
endfunction


