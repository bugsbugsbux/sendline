local M = {}

---@class Config
local defaults = {
    autoconnect = true,
    autodisconnect = true,
    allow_connect_to_self = false,
    confirm_send_from_terminal = true,
}

---Throws if invalid overrides are given.
local function validate(overrides)
    assert(type(overrides) == 'table')
    -- is valid key?
    local valid_keys = vim.tbl_keys(defaults)
    for _,key in ipairs(vim.tbl_keys(overrides)) do
        assert(vim.tbl_contains(valid_keys, key), 'Sendline: invalid config key: ', key)
    end
    -- is valid type?
    vim.validate{
        autoconnect = { overrides.autoconnect, 'boolean', true },
        autodisconnect = { overrides.autodisconnect, 'boolean', true },
        allow_connect_to_self = { overrides.allow_connect_to_self, 'boolean', true },
        confirm_send_from_terminal = {
            overrides.confirm_send_from_terminal, 'boolean', true
        },
    }
end

validate(defaults) -- make sure default config is valid

---Represents current config state. Not exposed to user.
local active = vim.deepcopy(defaults)

-- Reset config to defaults.
function M.reset()
    active = vim.deepcopy(defaults)
end

-- Return config or value of given key.
---@param key string?
function M.get(key)
    if key then
        return active[key]
    end
    return active
end

function M.set(overrides)
    overrides = overrides or {}
    validate(overrides)
    active = vim.tbl_deep_extend('force', M.get(), overrides)
end

-- Validates overrides before resetting and then overriding config with new values.
function M.setup(overrides)
    overrides = overrides or {}
    validate(overrides)
    M.reset()
    active = vim.tbl_deep_extend('force', M.get(), overrides)
end

return M
