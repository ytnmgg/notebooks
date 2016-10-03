set nocompatible

" for Vundle
filetype off 
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'easymotion/vim-easymotion'

call vundle#end()
filetype plugin indent on


set number
set tabstop=4
set expandtab
set softtabstop=4
set hlsearch
let mapleader=","
map <Leader> <Plug>(easymotion-prefix)
syntax enable
syntax on
