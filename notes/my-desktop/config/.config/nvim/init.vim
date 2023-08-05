:set number
:set relativenumber
:set autoindent
:set tabstop=4
:set shiftwidth=4
:set smarttab
:set softtabstop=4
:set mouse=a
:set clipboard=unnamedplus

call plug#begin()

Plug 'preservim/nerdtree' " NerdTree
Plug 'ap/vim-css-color' " CSS Color Preview
Plug 'lunarvim/horizon.nvim' " Horizon Theme
Plug 'francoiscabrol/ranger.vim' " Ranger
Plug 'rbgrouleff/bclose.vim' " Ranger + nvim


:set encoding=UTF-8

call plug#end()

autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif


:colorscheme horizon
