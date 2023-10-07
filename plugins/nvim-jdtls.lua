return {
  "mfussenegger/nvim-jdtls", -- load jdtls on module
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "jdtls" },
    },
  },
}
