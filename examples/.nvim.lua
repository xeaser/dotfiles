-- Project-local nvim config example
-- Place this file as .nvim.lua in your project root
-- Loaded via exrc when nvim opens from this directory
--
-- Features:
--   - Loads .env file for environment variables
--   - Configures DAP (Debug Adapter Protocol) launch targets
--   - Adds which-key keybindings under <leader>z group
--   - Handles symlink path mapping for delve

-- 1. dlv preflight check
if vim.fn.executable("dlv") ~= 1 then
  vim.notify("delve (dlv) not found in PATH. Go debugging will not work.", vim.log.levels.WARN)
end

-- 2. .env file loader
local function load_env(filepath)
  local vars = {}
  local f = io.open(filepath, "r")
  if not f then
    vim.notify("Env file not found: " .. filepath, vim.log.levels.WARN)
    return vars
  end
  for line in f:lines() do
    if line:match("^%s*$") or line:match("^%s*#") then
      goto continue
    end
    line = line:gsub("^export%s+", "")
    local key, value = line:match("^([^=]+)=(.*)")
    if key and value then
      key = vim.trim(key)
      value = value:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1")
      vars[key] = value
    end
    ::continue::
  end
  f:close()
  return vars
end

-- 3. Project DAP configurations
local project_root = vim.fn.getcwd()
local env_vars = load_env(project_root .. "/.env")

-- Symlink path mapping (adjust for your setup)
-- Delve compiles with real paths, nvim uses symlink paths
local substitute_path = {
  { from = "/Volumes/Work", to = "/Users/username/Work" },
}

local dap_configs = {
  ["My API"] = {
    type = "go",
    name = "My API",
    request = "launch",
    mode = "debug",
    program = "./cmd/api",
    cwd = project_root,
    outputMode = "remote",
    substitutePath = substitute_path,
    env = vim.tbl_extend("force", env_vars, {
      DB_NAME = "mydb",
      DB_PASSWORD = "localpassword",
      DB_PORT = "5432",
      DB_SSL_MODE = "disable",
      DB_USER = "dbuser",
      ENVIRONMENT = "dev",
      AWS_PROFILE = "my-profile",
    }),
  },
  ["My Worker"] = {
    type = "go",
    name = "My Worker",
    request = "launch",
    mode = "debug",
    program = "./cmd/worker",
    cwd = project_root,
    outputMode = "remote",
    substitutePath = substitute_path,
    env = vim.tbl_extend("force", env_vars, {
      ENVIRONMENT = "dev",
    }),
  },
  ["Integration Tests"] = {
    type = "go",
    name = "Integration Tests",
    request = "launch",
    mode = "test",
    program = "./...",
    cwd = project_root,
    outputMode = "remote",
    substitutePath = substitute_path,
    buildFlags = "-tags integration -v -race",
    env = vim.tbl_extend("force", env_vars, {
      ENVIRONMENT = "dev",
    }),
  },
}

-- 4. Launch a named config directly via dap.run
local function run_dap_config(name)
  local config = dap_configs[name]
  if config then
    require("dap").run(config)
  else
    vim.notify("DAP config not found: " .. name, vim.log.levels.ERROR)
  end
end

-- 5. which-key group + keybindings
vim.schedule(function()
  local ok, wk = pcall(require, "which-key")
  if ok then
    wk.add({
      { "<leader>z", group = "Launch (project)" },
      { "<leader>za", function() run_dap_config("My API") end, desc = "Debug API" },
      { "<leader>zw", function() run_dap_config("My Worker") end, desc = "Debug Worker" },
      {
        "<leader>zb",
        function()
          run_dap_config("My API")
          vim.defer_fn(function() run_dap_config("My Worker") end, 1000)
        end,
        desc = "Debug Both (API + Worker)",
      },
      { "<leader>zi", function() run_dap_config("Integration Tests") end, desc = "Debug Integration Tests" },
      {
        "<leader>zt",
        function()
          local dap_go_ok, dap_go = pcall(require, "dap-go")
          if dap_go_ok then
            dap_go.debug_test()
          else
            vim.notify("dap-go not available", vim.log.levels.ERROR)
          end
        end,
        desc = "Debug Test Under Cursor",
      },
    })
  end
end)
