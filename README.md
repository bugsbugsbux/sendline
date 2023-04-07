**USE AT YOUR OWN RISK**

# About
Send lines from your code buffer to a terminal buffer.

# Basic usage pattern

1. Open a terminal buffer.
2. Set up the terminal such that you just have to start typing the lines
   you want to insert - this means if you use vi-mode make sure you are
   in insert-mode!
3. If you have several terminal buffers loaded: From your code buffer
   run `:SendlineConnect <term-bufnr>`.
4. Send current line - or multiple lines by visually selecting (at least
   parts of) them - with `:Sendline`. Actually you can send any range of
   lines by specifying it with the usual notation, however, motions or
   repeats do not work.

# UserCommands
## `:[range]Sendline [bufnr]`
Tries to send current line or all *lines* with visual selection
to the terminal with
  * bufnr (and sets it as the buffer's new connection)
  * or the connected terminal if no bufnr given to `:Sendline` (removes
    the connection if it is invalid)
  * or tries to autoconnect.

## `:[range]Sendline! [bufnr]`
Like `:[range]Sendline` but **does not**:

* save
* remove
* or override

the connection.

## `:SendlineConnect [bufnr]`
Assign a specific channel (for `vim.api.nvim_chan_send`) to the (code)
buffer, which will be used to send lines if no explicit target was
given.

## `:SendlineDisconnect [bufnr]`
Removes the given or current buffer's connection.

# Tips
## Keymaps

* Send current line and advance `:nnoremap <cr> <cmd>Sendline<cr>+`
* Send unindented selection `vnoremap <cr> 100<gv:Sendline<cr>u`

# FAQ, Troubleshooting
## My repl complains about indentation
Unindent the lines before you send them (see: Tips>Keymaps for a helpful
map to do so).

* Ipython: you can just use the `--no-autoindent` flag

## The plugin sends the whole line even tho I only selected part of it
This is intended. I understand that this might be useful sometimes, but
considering I'd have to handle all the different selection modes I
decided to not implement this and rely on the simple tools at hand
(user-commands and ranges).

## Sendline sends a newline even when my line doesn't end in one
Indeed, this is intended, because this plugin is made for executing
lines in a repl running in a neovim terminal.

## My repl needs n more newlines to run the code
Include n trailing, empty lines in the lines you send or, after sending
the code lines, send an empty line n times. If you use a mapping this
shouldn't be a big problem.
