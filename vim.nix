{ pkgs, ... }:
{
  programs.vim.enable = true;
  programs.vim.defaultEditor = true;
  environment.systemPackages = with pkgs; [
    ((vim_configurable.override { python3 = python3; }).customize {
      name = "vim";
      vimrcConfig.packages.myplugins = with pkgs.vimPlugins; {
        start = [ vim-nix vim-airline vim-airline-themes onedark-vim python-mode ];
        opt = [];
      };
      vimrcConfig.customRC = ''
        " *start* {{{
        if has('vim_starting')
          if &compatible
            set nocompatible    " do not maintatin compatibility with vi
          endif
        scriptencoding utf-8
        set encoding=utf-8      " encoding => utf-8 (cannot run after startup)
        set backspace=indent,eol,start
        endif
        " }}}
        " *colors and visual preferences* {{{
        syntax enable
        set background=dark                             " dark background!
        set t_Co=256
        colorscheme onedark
        let airline#extensions#tabline#enabled=1
        let airline#extensions#tabline#formatter='default'
        let airline_powerline_fonts=1
        let airline_theme='onedark'
        set cursorline                                  " horizontal line where cursor is
        set list                                        " show hidden characters
        set listchars=eol:¬,tab:»\ ,extends:»,trail:·   " configure what to show for hidden characters
        set number                                      " show line numbers
        set laststatus=2                                " always show the status bar at the bottom
        set noshowmode                                  " don't display --insert--, --visual--, --normal--, etc
        set wildmenu                                    " show a nice menu for completiong with colon-commands
        set novisualbell                                " no flashing
        set noerrorbells                                " no noise
        set vb t_vb=                                    " disable any beeps or flashes on error
        set nosplitbelow                                " horizontal splits open above (default)
        set splitright                                  " vertical splits open to the right"
        " }}}
        " *undo* {{{
        " don't change order
        set undodir=~/.vim/undo
        set undofile
        " }}}
        " *search* {{{
        set incsearch           " hilight in real time while searching
        set hlsearch            " highlight all matches
        " }}}
        " *indentation* {{{
        " Default
        set autoindent                  " automatically indent
        set cindent                     " c-style indentation
        set smartindent                 " c-like indentation on new line
        set shiftwidth=0                " number of spaces to auto-indent with cindent, <<, >>, etc
        set softtabstop=4               " make spaces feel like tabs (i.e. <BS> deletes to last tabstop)
        set tabstop=4                   " number of spaces tab inserts
        set expandtab                   " use spaces rather than tabs
        set indentkeys-=0#              " do not break indent on #
        set cinoptions=:s,ps,ts,cs      " how cindent re-indents a line
        set cinwords=if,else,while,do
        set cinwords+=for,switch,case   " words that cause indent on next line
        set formatoptions=cro           " continue comment on new line
        set pastetoggle=<F3>            " toggle paste mode with F3
        " Custom filetype settings
        autocmd Filetype yaml setlocal tabstop=2 softtabstop=2 expandtab " use 2 spaces on YAMLs
        autocmd Filetype nix setlocal tabstop=2 softtabstop=2 expandtab " use 2 spaces on nix configs
        " }}}
        " *aliases* {{{
        cnoreabbrev tree NERDTree
        " }}}
        " *general* {{{
        set foldmethod=marker
        set nocp
        set virtualedit=block   " doesn't constrain visual block
        set history=10000       " big history (max)
        set modeline            " check for modes (like vim: foldmethod=marker)
        set modelines=5         " check first 5 lines (default)
        set autowrite           " autowrite on make/shell commands
        set autoread            " autoread when file is changed
        set hidden              " current buffer can be hidden when not written to disk
        " Split command rewrite
        nnoremap <C-J> <C-W><C-J>
        nnoremap <C-H> <C-W><C-H>
        nnoremap <C-K> <C-W><C-K>
        nnoremap <C-L> <C-W><C-L>
        set splitbelow
        set splitright
        " Remap file creation in :Explorer
        map f %
        nnoremap <space> za     " let space toggle folds
        filetype plugin indent on
        set timeoutlen=550      " time to wait after esc (default 1000 ... way too long)
        set fo-=o               " don't automatically insert comment after newline on commented line
        " }}}
        " *leader configuration for visual preferences* {{{
        " toggle background from light to dark
        nnoremap <silent> <leader>bg :let &background=(&background == "light" ? "dark" : "light")<cr>:silent AirlineRefresh<cr>:<cr>
        " toggle showing invisibles
        nnoremap <silent> <leader>l :set list!<cr>
        " toggle relative numbers
        nnoremap <silent> <leader>r :set relativenumber!<cr>:<cr>
        " list buffers and pre-type ':buffer ' for you
        nnoremap <leader>bf :buffers<cr>:buffer<space>
        " fun colorschemes
        nnoremap <silent> <leader>[l :echo "backgrounds: gruvbox (g), jellybeans (j), monokai (m), solarized (s), xoria256 (x)"<cr>
        nnoremap <silent> <leader>[g :set background=dark<cr>:colorscheme gruvbox<cr>:AirlineRefresh<cr>
        nnoremap <silent> <leader>[j :set background=dark<cr>:colorscheme jellybeans<cr>:AirlineRefresh<cr>
        nnoremap <silent> <leader>[m :set background=dark<cr>:colorscheme monokai<cr>:AirlineRefresh<cr>
        nnoremap <silent> <leader>[s :set background=dark<cr>:colorscheme solarized<cr>::AirlineTheme badwolf<cr>:AirlineRefresh<cr>
        nnoremap <silent> <leader>[x :set background=dark<cr>:colorscheme xoria256<cr>:AirlineRefresh<cr>
        " }}}
        " *templates* {{{
        if has("autocmd")
            augroup templates
                autocmd BufNewFile *.sh 0r ~/.vim/templates/skeleton.sh
                autocmd BufNewFile *.c 0r ~/.vim/templates/skeleton.c
                autocmd BufNewFile *.html 0r ~/.vim/templates/skeleton.html
                autocmd BufNewFile *.py 0r ~/.vim/templates/skeleton.py
            augroup end
        endif
        " }}}
        " *keywordprg mappings* {{{
        if has("autocmd")
            augroup keywordprg
                autocmd FileType markdown,rst,tex,txt setlocal keywordprg=dict
                autocmd FileType python setlocal keywordprg=pydoc3
            augroup end
        endif
        " }}}
        " *plugins* {{{
        filetype off
        filetype plugin indent on
        syntax on
        " Pymode settings
        set textwidth=0
        setlocal textwidth=0
        let pymode_options_max_line_length=0
        let pymode_lint_ignore=["E501", "E127"]     " Ignore line length warnings and line split+length warnings
        " Bind \c to run linter
        nnoremap <leader>c :PymodeLint<CR>
        let pymode_run = 0
        " Bind \r to run python as a different process to avoid locks
        nnoremap <leader>r :!python3 %
        " }}}
      '';
    })
  ];
}
