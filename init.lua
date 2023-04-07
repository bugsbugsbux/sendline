local M = {
    send = require('sendline.core').send,
    connect = require('sendline.core').connect,
    disconnect = require('sendline.core').disconnect,
}

local cmd_send = require('sendline.cmds').send
local cmd_connect = require('sendline.cmds').connect
local cmd_disconnect = require('sendline.cmds').disconnect
local complete_term_buffers = require('sendline.completion').complete_term_buffers
local complete_sendline_buffers = require('sendline.completion').complete_sendline_buffers

vim.api.nvim_create_user_command('Sendline', function(cmd)
    cmd_send(cmd)
end, {
    nargs = '*', -- '?' would accept everything as 1 arg. '*' splits on \s*
    complete = complete_term_buffers,
    range = true, -- to be able to send multiple lines
    bang = true, -- I want to use it to allow sending once without persisting a connection
})

vim.api.nvim_create_user_command('SendlineConnect', function(cmd)
    cmd_connect(cmd)
end, {
    nargs = '*', -- '?' would accept everything as 1 arg. '*' splits on \s*
    complete = complete_term_buffers,
})

vim.api.nvim_create_user_command('SendlineDisconnect', function(cmd)
    cmd_disconnect(cmd)
end, {
    nargs = '*', -- '?' would accept everything as 1 arg. '*' splits on \s*
    complete = complete_sendline_buffers,
})

return M
