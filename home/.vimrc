set number
set nocompatible
filetype plugin on
syntax on

au BufEnter /private/tmp/crontab.* setl backupcopy=yes
au FileType gitcommit setlocal spell spelllang=en_us
au FileType gitcommit setlocal tw=72

