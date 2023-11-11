local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
-- local root_dir = require("jdtls.setup").find_root(root_markers)
-- vim.notify("root_dir " .. root_dir)

-- calculate workspace dir
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath "data" .. "/site/java/workspace-root/" .. project_name
os.execute("mkdir " .. workspace_dir)

-- get the mason install path
local install_path = require("mason-registry").get_package("jdtls"):get_install_path()

-- get the current OS
local os
if vim.fn.has "macunix" then
  os = "mac"
elseif vim.fn.has "win32" then
  os = "win"
else
  os = "linux"
end

local jdb_path = require("mason-registry").get_package("java-debug-adapter"):get_install_path()

-- java-debug installation)
local bundles = {
  vim.fn.glob(jdb_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", 1),
}
-- local jtest_path = "/Users/guo/.local/share/nvim/mason/packages/java-test/extension/server/*.jar"
local jtest_path = "/Users/guo/opt/vscode-java-test/server/*.jar"

-- java-test installation
vim.list_extend(bundles, vim.split(vim.fn.glob(jtest_path, 1), "\n"))

-- return the server config
return {
  cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-javaagent:" .. install_path .. "/lombok.jar",
    "-Xms1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "-jar",
    vim.fn.glob(install_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
    "-configuration",
    install_path .. "/config_" .. os,
    "-data",
    workspace_dir,
  },
  -- root_dir = root_dir,
  root_dir = function(fname)
    return require("jdtls.setup").find_root(root_markers)
  end,
  -- capabilities = capabilities,
  settings = {
    java = {
      configuration = {
        -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
        -- And search for `interface RuntimeOption`
        -- The `name` is NOT arbitrary, but must match one of the elements from `enum ExecutionEnvironment` in the link above
        -- TODO modify path
        runtimes = {
          -- {
          --   name = "JavaSE-21",
          --   path = "/opt/homebrew/Cellar/openjdk/21/"
          -- },
          {
            name = "JavaSE-19",
            path = "/Library/Java/JavaVirtualMachines/jdk-19.jdk/Contents/Home",
          },
          -- {
          --   name = "JavaSE-8",
          --   path = "/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home/",
          -- },
        },
      },
    },
  },
  init_options = {
    bundles = bundles,
  },
  on_attach = function(client, bufnr)
    if client.name == "jdtls" then
      -- catch exceptions
      if pcall(function() require("jdtls").setup_dap { hotcodereplace = "auto" } end) then
        vim.notify "jdtls setup dap"
      else
        vim.notify "jdtls setup dap failed"
      end
      -- launch.json style in VSCode
      if pcall(function() require("dap.ext.vscode").load_launchjs() end) then
        vim.notify "dap.ext.vscode load launchjs"
      else
        vim.notify "dap.ext.vscode load launchjs failed"
      end
      if pcall(function() require("jdtls.dap").setup_dap_main_class_configs() end) then
        vim.notify "jdtls.dap setup dap main class configs"
      else
        vim.notify "jdtls.dap setup dap main class configs failed"
      end
      vim.lsp.codelens.refresh()
    end
  end,
}
