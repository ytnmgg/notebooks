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
set ruler                   " 打开状态栏标尺                        
set shiftwidth=4            " 设定 << 和 >> 命令移动时的宽度为 4         
set smartindent             " 开启新行时使用智能自动缩进                  
set hlsearch                                                 
let mapleader=","                                            
map <Leader> <Plug>(easymotion-prefix)                       
syntax enable                                                
syntax on                                                    
