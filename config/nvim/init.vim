set shell=/bin/bash
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'embear/vim-localvimrc'
Plugin 'fatih/vim-go'
Plugin 'godlygeek/tabular'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'mileszs/ack.vim'
Plugin 'othree/es.next.syntax.vim'
Plugin 'othree/yajs.vim'
Plugin 'plasticboy/vim-markdown'
" Plugin 'prettier/vim-prettier'
" Plugin 'styled-components/vim-styled-components'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-vinegar'
Plugin 'vim-airline/vim-airline'
Plugin 'w0rp/ale'
Plugin 'jparise/vim-graphql'

" themes
Plugin 'dracula/vim'
Plugin 'rakr/vim-one'

call vundle#end()            " required
filetype plugin indent on    " required

syntax on

" themes
color dracula
" color one
" set background=light

set softtabstop=2 shiftwidth=2 expandtab
autocmd Filetype go setlocal ts=2 sw=2 noexpandtab
autocmd Filetype markdown setlocal tw=100
set termguicolors
set cursorline
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

" let g:netrw_liststyle = 3
" let g:netrw_banner = 0
" let g:netrw_browse_split = 4
" let g:netrw_winsize = 25

let g:ackprg = 'ag --nogroup --nocolor --column'

noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
noremap <c-p> :GFiles<cr>
noremap <m-p> :Files<cr>

" This allows buffers to be hidden if you've modified a buffer.
" This is almost a must if you wish to use buffers in this way.
set hidden

" To open a new empty buffer
" This replaces :tabnew which I used to bind to this mapping
nmap <leader>T :enew<cr>

" Move to the next buffer
nmap <leader>l :bnext<CR>

" Move to the previous buffer
nmap <leader>h :bprevious<CR>

" Close the current buffer and move to the previous one
" This replicates the idea of closing a tab
nmap <leader>bq :bp <BAR> bd #<CR>

" Show all open buffers and their status
nmap <leader>bl :ls<CR>

set splitright " splits open to the right
set so=999     " force cursor to stay centred (lots of context)
set number     " show line numbers
set list       " show whitespace chars

let g:vim_markdown_folding_disabled = 1
let g:go_fmt_command = "goimports"
let g:flow#autoclose = 1
"
" replace currently selected text with default register
" without yanking it
vnoremap <leader>p "_dP

" airline
" let g:airline#extensions#tabline#enabled = 1 " Display Tabs

" ale
let g:airline#extensions#ale#enabled = 1
call airline#parts#define_function('ALE', 'ALEGetStatusLine')
call airline#parts#define_condition('ALE', 'exists("*ALEGetStatusLine")')
let g:airline_section_error = airline#section#create_right(['ALE'])
let g:ale_sign_column_always = 1
let g:ale_fix_on_save = 1
let g:ale_lint_delay = 500
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1
let g:airline#extensions#ale#enabled = 1
let g:ale_sign_error = '=>' 
let g:ale_sign_warning = '##'

nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

highlight clear SignColumn
highlight clear ALEErrorSign
highlight clear ALEWarningSign
highlight Cursor guifg=white guibg=black
highlight iCursor guifg=white guibg=steelblue
