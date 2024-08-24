
syntax on
""" 以下のコマンドは :colorscheme の前に設定します
""" コメントを濃い緑にする
autocmd ColorScheme * highlight Comment ctermfg=31 guifg=#008800
colorscheme molokai

set guifont=UDEV\ Gothic\ 35:h14
set t_Co=256
set laststatus=2
set number
set ruler
set noautoindent
set expandtab
set tabstop=2
set shiftwidth=2
"set fileencodings=iso-2022-jp,euc-jp,utf-8,sjis
set fileformats=unix,dos,mac
autocmd FileType * setlocal formatoptions-=r
autocmd FileType * setlocal formatoptions-=o
set nobackup
set noswapfile
set noundofile

""" Visual Mode
highlight Visual ctermbg=81 guibg=#272c11


""" Clipboard連携
set clipboard+=unnamed

""" Indent
let g:indent_guides_enable_on_vim_startup=0
let g:indent_guides_start_level=2
let g:indent_guides_auto_colors=0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=#262626 ctermbg=gray
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=#3c3c3c ctermbg=darkgray
let g:indent_guides_color_change_percent = 30
let g:indent_guides_guide_size = 0

""" bug fix
set nocompatible
set whichwrap=b,s,h,l,<,>,[,]
set backspace=indent,eol,start

