local M = {
    levels = vim.log.levels ---@type table<'DEBUG'|'ERROR'|'INFO'|'TRACE'|'WARN'|'OFF', number>
}

---@return {chan: integer, buf: integer }[]
function M.get_terminals()
    local terminals = {}
    for _, channel in ipairs(vim.api.nvim_list_chans()) do
        if channel.mode == 'terminal' then
            table.insert(terminals, { chan = channel.id, buf = channel.buffer })
        end
    end
    return terminals
end

---@return boolean is_valid
---@return integer? buffer
function M.validate_fargs(cmd)
    vim.validate({ cmd = { cmd, 'table' } })
    -- check args
    local n = #cmd.fargs
    if n > 1 then
        vim.notify('Sendline: ArgumentError - Only 0 or 1 arguments allowed!', M.levels.ERROR)
        return false
    elseif n > 0 then
        local ok, buffer = pcall(tonumber, cmd.fargs[1])
        if not ok then
            vim.notify("Sendline: ArgumentError - '" .. cmd.fargs[1] .. "' is not convertible to number!", M.levels.ERROR)
            return false
        end
        return true, buffer
    end
    return true, nil
end

return M
