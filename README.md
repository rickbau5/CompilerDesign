Compiler Design!


# Syntax Highlighting in Vim
1. Copy `./cmin.vim` to `$VIM/syntax/cmin.vim`
2. Create a file called `cmin.vim` in `$VIM/ftdetect/`
3. In the file from #2, add the following line: `au BufRead,BufNewFile *.c- set filetype=cmin`
4. ???
5. Profit!
