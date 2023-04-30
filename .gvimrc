set nobackup
set noswapfile

syntax on
colorscheme morning
set guifont=Hack\ Nerd\ Font:h16

autocmd ColorScheme * highlight Comment ctermfg=31 guifg=#008800
colorscheme solarized

set t_Co=256
set number
set ruler
"set autoindent
set expandtab
set tabstop=2
set fileencodings=iso-2022-jp,euc-jp,utf-8,sjis
set fileformats=unix,dos,mac
set noautoindent

set lines=60
set columns=150

NeoBundle 'nathanaelkane/vim-indent-guides'

