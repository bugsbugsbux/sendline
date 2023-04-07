local M = {}

local utils = require('sendline.utils')
local levels = utils.levels

---@param buf? integer Terminal buffer number. If missing tries to autoconnect.
---@return boolean is_success
---@return integer? channel A valid channel_id.
function M.connect(buf, opts)
    opts = opts or {}
    vim.validate({
        buf = { buf, 'number', true },
        opts = { opts, 'table', true },
        ['opts.once'] = { opts.once, 'boolean', true },
    })

    local chan ---@type integer|nil
    local terminals = utils.get_terminals() ---@type integer[]
    if buf then
        -- given buffer needs to be terminal
        for _, term in ipairs(terminals) do
            if term.buf == buf then
                chan = term.chan
                break
            end
        end
    else
        -- buffer is connected:
        if vim.b.sendlineChannel then
            for _, term in ipairs(terminals) do
                if term.chan == vim.b.sendlineChannel then
                    chan = term.chan
                    break
                end
            end
            -- remove invalid connection:
            if not chan and not opts.once then
                vim.b.sendlineChannel = nil
                vim.notify('Sendline: Removed invalid connection!', levels.WARN)
                return false
            end
        elseif #terminals == 1 then
            -- buffer doesn't have a connection -> autoconnect to single terminal found
            chan = terminals[1].chan
            vim.notify('Sendline: Connected to terminal in buffer ' .. terminals[1].buf, levels.INFO)
        end
    end

    if not chan then
        vim.notify('Sendline: Could not connect...', levels.WARN)
        return false
    end

    -- persist connection
    if not opts.once then
        vim.b.sendlineChannel = chan
    end

    return true, chan
end

---@param buf? integer Buffer number. Current if missing
function M.disconnect(buf)
    vim.validate({ buf = { buf, 'number', true } })
    vim.b[buf or 0].sendlineChannel = nil
end


---@return boolean success
function M.send(opts)
    vim.validate({
        opts = { opts, 'table' },
        ['opts.text'] = { opts.text, 'string' },
        ['opts.buffer'] = { opts.buffer, 'number', true },
        ['opts.once'] = { opts.once, 'boolean', true },
    })

    local is_connected, chan = M.connect(opts.buffer, { once = opts.once })
    if not is_connected then
        return false
    end
    local ok = pcall(vim.api.nvim_chan_send, chan, opts.text)
    if not ok then
        vim.notify('Sendline Error: Failed to send lines for unknown reason', levels.ERROR)
        return false
    end
    return true
end

return M
