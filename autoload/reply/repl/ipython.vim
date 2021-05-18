let s:repl = reply#repl#base('ipython', {
   \   'prompt_start' : '',
   \ })
" let s:repl = reply#repl#base('ipython', {
"    \   'prompt_start' : '^In \[\d\+\]: ',
"    \   'prompt_continue' : '^[ ]+\.\.\.: ',
"    \ })

function! s:repl.send_string(str) abort
    if !self.running
        throw reply#error("REPL '%s' is no longer running", self.name)
    endif

    let str = "\e[200~" . a:str
    " if str[-1] !=# "\n"
    "     let str .= "\n"
    " endif
    let str .= "\e[201~\r"
    " Note: Zsh distinguishes <NL> and <CR> and regards <NL> as <C-j>.
    " We always use <CR> as newline character.
    let str = substitute(str, "\n", "\r", 'g')

    " Note: Need to enter Terminal-Job mode for updating the terminal window

    let prev_winnr = winnr()

    if has('nvim')
        " Don't need to enter terminal-job mode for sending keys to REPL on Neovim
        call self.into_terminal()
        call jobsend(getbufvar(self.term_bufnr, '&channel'), [str])
    else
        call self.into_terminal_job_mode()
        call term_sendkeys(self.term_bufnr, str)
    endif
    call reply#log('String was sent to', self.name, ':', str)

    if winnr() != prev_winnr
        execute prev_winnr . 'wincmd w'
    endif
endfunction


function! reply#repl#ipython#new() abort
    return deepcopy(s:repl)
endfunction


" local format = function(open, close, cr)
"   return function(lines)
"     if #lines == 1 then
"       return { lines[1] .. cr }
"     else
"       local new = { open .. lines[1] }
"       for line=2, #lines do
"         table.insert(new, lines[line])
"       end
"       return extend(new, close)
"     end
"   end
" end

" local def = function(cmd)
"   return {
"     command = cmd,
"     format = format("\27[200~", "\27[201~\13", "\13")
"   }
" end

