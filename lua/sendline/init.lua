local config = require('sendline.config')
local cmds = require('sendline.cmds')
local auto = require('sendline.auto')

local M = {
    get_connection = require('sendline.core').get_connection,
    disconnect = require('sendline.core').disconnect,
    send = require('sendline.core').send,
    show_config = function() vim.print(require('sendline.config').get()) end
}

function M.setup(overrides)
    config.setup(overrides)
    cmds.enable()
    if config.get('autodisconnect') then
        auto.enable()
    end
end

function M.disable()
    cmds.disable()
    auto.disable()
end

return M
