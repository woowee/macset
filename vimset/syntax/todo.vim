"$MYVIMRUNTIME/after/syntax/todo.vim"

syn match MkdCheckboxMark '\[\d\{8}\]:\s.\+' display containedin=ALL
hi MkdCheckboxMark guifg=#525252
syn match MkdCheckboxUnmark '\[\s\]:\s.\+' display containedin=ALL
hi MkdCheckboxUnmark guifg=lightred
" ref. http://pc-parts.chips.jp/vimMEMO/vimCNFHIGHLIGHT.html
" ref. http://qiita.com/omega999/items/15031eece4256eb500e7

" :syn region xmlFold start="<a>" end="</a>" fold transparent keepend extend
syn match MkdCheckboxMarkFolded '\[\d\{8}\]:\s.\+' fold containedin=ALL
hi MkdCheckboxMarkFolded guifg=red

" hi Folded           guifg=#a0a8b0     guibg=#384048     gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=NONE
hi Folded           guifg=NONE     guibg=NONE     gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=NONE

