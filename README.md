**USE AT YOUR OWN RISK**

# About
Send lines from your code buffer to a terminal buffer.
![sendline-demo](https://github.com/herrvonvoid/sendline/assets/46503017/332fad70-aa2c-4ecc-abf6-b394e433eccc)

IMPORTANT: you are now required to call `setup()`!

# Basic usage pattern

1. Open a terminal buffer.
2. Set up the terminal such that you just have to start typing the lines
   you want to insert - this means if you use vi-mode make sure you are
   in insert-mode!
3. If you have several terminal buffers loaded: From your code buffer
   run `:SendlineConnect <term-bufnr>` to set the intended target.
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
Like `:[range]Sendline` but **does not** save new / override old
connection.

## `:SendlineConnect [bufnr]`
Set the target terminal for the current buffer. It will be used when
`:Sendline` is called without an explicit target.

## `:SendlineDisconnect [bufnr]`
Removes the given or current buffer's connection.

# Config
To activate the plugin call the setup function with your desired
overrides. Here this is shown with the default settings:
```lua
require('sendline').setup({
    ---When set, calling :Sendline or :SendlineConnect without a target
    ---buffer automatically connects to a terminal if there is no
    ---saved connection and there is exactly 1 valid target terminal.
    autoconnect = true,

    ---If this is not set a terminal may not connect to itself, thus
    ---2 terminals can autoconnect to each other.
    allow_connect_to_self = false,

    ---If this is set, closing a terminal removes all saved connections
    ---to this terminal.
    autodisconnect = true,

    ---If this is set you are asked for confirmation when sending from a
    ---terminal. This is supposed to prevent accidentally sending
    ---potentially very destructive commands to a terminal.
    confirm_send_from_terminal = true,
})
```

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
shouldn't be a big deal.

## I selected multiple lines but Sendline only sends the current line
This could have happened because you used a mapping which uses
`<cmd>Sendline`. Use `:` instead of `<cmd>` to capture your selected
range.

## It doesn't scroll when more lines than fit on the screen are printed
The neovim cursor position of the terminal window has to be at the last
line of the terminal buffer. Navigate there with `G` in normal mode.

## Issues with the confirmation dialog
The confirmation dialog receives all characters after the <CR> in your
mapping (for example this `:Sendline<CR>+` would send "+" to the
confirmation dialog). To avoid this use a different mapping in terminal
buffers.
