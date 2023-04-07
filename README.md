# About
Send lines from your code buffer to a terminal buffer.

# Basic usage pattern

1. open a terminal buffer
2. set up the terminal such that you just have to start typing the lines
   you want to insert. This means if you use vi mode make sure you are
   in insert mode!
3. If you have several terminal buffers loaded: From your code buffer
   run `:SendlineConnect <term-bufnr>`
4. Send current line `:Sendline`, or multiple by visually selecting them
   and `:Sendline`

# UserCommands

## `:[range]Sendline [bufnr]`
Tries to send current line or all *lines* with visual selection
to the terminal with
  * bufnr (and sets it as the buffer's new connection)
  * or the connected terminal if no bufnr given to `:Sendline` (removes
    the connection if it is invalid)
  * or tries to autoconnect.

## `:[range]Sendline! [bufnr]`
Like :[range]Sendline but **does not**:
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

# Troubleshooting
## IPython complains about indentation
For now you need to either run ipython with `ipython --no-autoindent` or
unindent before you send your lines. See: Tips>Keymaps for a helpful map
