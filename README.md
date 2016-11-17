Compiler Design!

# Syntax Highlighting in Vim
0. Create the directories `$VIM` (`~/.vim`), `$VIM/syntax` and `$VIM/ftdetect`
1. Copy `./cmin.vim` to `$VIM/syntax/cmin.vim`
2. Run the following command so Vim can autodetect the extension: `echo "au BufRead,BufNewFile *.c- set filetype=cmin" > $VIM/ftdetect/cmin.vim`
3. ???
4. Profit!
