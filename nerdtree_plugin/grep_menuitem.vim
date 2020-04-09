"shove this in ~/.vim/nerdtree_plugin/grep_menuitem.vim
"
" Add 'g' menu items to grep under selected directory.
" 'g' : prompts the user to type search pattern under selected dir.
"       use parent directory if file is selected.
"       This uses ':grep'.
"
" For ripgrep user,
"   NERDTreeRipGrepDirectory function is much, much faster. 
"   Requirements:
"   - Ripgrep: https://github.com/BurntSushi/ripgrep
"   - vim-ripgrep: https://github.com/jremmen/vim-ripgrep
"
" Originally written by scrooloose
" (http://gist.github.com/205807)

if exists("g:loaded_nerdtree_grep_menuitem")
    finish
endif
let g:loaded_nerdtree_grep_menuitem = 1

call NERDTreeAddMenuItem({
            \ 'text': '(g)rep directory',
            \ 'shortcut': 'g',
            \ 'callback': 'NERDTreeGrep' })

function! NERDTreeGrep()
    let dirnode = g:NERDTreeDirNode.GetSelected()

    let pattern = input("Enter the search pattern: ")
    if pattern == ''
        echo 'Aborted'
        return
    endif

    "use the previous window to jump to the first search result
    wincmd w

    "a hack for *nix to make sure the output of "grep" isnt echoed in vim
    let old_shellpipe = &shellpipe
    let &shellpipe='&>'

    try
        exec 'silent cd ' . dirnode.path.str()
        exec 'silent grep -rn ' . pattern . ' .'
        " exec 'silent grep -rn ' . pattern . ' ' . dirnode.path.str()
    finally
        let &shellpipe = old_shellpipe
    endtry

    let hits = len(getqflist())
    if hits == 0
        echo "No hits"
    elseif hits > 1
        copen
        " echo "Multiple hits. Jumping to first, use :copen to see them all."
    endif

endfunction

" FUNCTION: NERDTreeRipGrepDirectory() {{{1
" This is for ripgrep user.
function! NERDTreeRipGrepDirectory()
    let dirnode = g:NERDTreeDirNode.GetSelected()
    let pattern = input("Enter the search pattern/options: ")

    if pattern == ''
        call nedtree#echo("Grep directory aborted.")
        return
    "else
    "    if match(pattern, '"') >= 0
    "        let pattern = substitute(pattern, '"', '\\"', 'g')
    "    endif
    "    let pattern = join(['"', pattern, '"'], '')
    endif

    wincmd w
    let old_shellpipe = &shellpipe
    let &shellpipe='&>'

    try
        let s:current_dir = expand("%:p:h")
        exec 'silent cd ' . dirnode.path.str()
        exec 'silent Rg ' . pattern
    finally
        let &shellpipe = old_shellpipe
        exec 'silent cd '. s:current_dir
    endtry

    let hits = len(getqflist())
    if hits == 0
        echo "No hits"
    elseif hits > 1
        copen
    endif
endfunction
