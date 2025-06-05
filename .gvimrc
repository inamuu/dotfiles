set nobackup
set noswapfile

syntax on
colorscheme morning
set guifont=UDEV\ Gothic\ 35:h16

autocmd ColorScheme * highlight Comment ctermfg=31 guifg=#008800
colorscheme dracula

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

" NeoBundle 'nathanaelkane/vim-indent-guides'

" Get current date in yyyymmdd format
let s:current_date = strftime("%Y%m%d")
let s:file_path = "~/Downloads/" . s:current_date . ".txt"

" Open the file if no other files are specified
if argc() == 0
    execute 'edit ' . s:file_path
endif

