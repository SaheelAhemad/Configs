-- ~/.config/nvim/lua/custom/configs/jdtls.lua

return {
  cmd = { "jdtls" },
  root_dir = function(fname)
    return require("lspconfig.util").root_pattern("pom.xml", "build.gradle", ".git")(fname)
      or vim.fn.getcwd()
  end,
}
