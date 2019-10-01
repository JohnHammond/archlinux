:call plug#begin("~/.vim/plugged")

Plug 'erichdongubler/vim-sublime-monokai'


call plug#end()

set number
syntax on
colorscheme sublimemonokai

let &t_8f="\<Esc>[38;2;%lu;%lu:lum"
let &t_8b="\<Esc>[48;2;%lu;%lu:lum"
