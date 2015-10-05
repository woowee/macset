"$MYRUNTIMEPATH/filetype.vim

if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
  " au! commands to set the filetype go here
  autocmd! BufRead,BufNewFile *.tmp setfiletype tmp
  autocmd! BufRead,BufNewFile *.todo setfiletype todo
  autocmd! BufRead,BufNewFile *.check setfiletype check
augroup END





