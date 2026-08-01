-- NixOS: all LSP servers, formatters and tools are installed via configuration.nix
-- and live on $PATH. Mason's prebuilt binaries generally don't run on NixOS, so we
-- disable it — LazyVim then configures every server directly from PATH. Nothing to
-- install inside nvim; just open a file and the LSP attaches.
return {
  -- disable Mason (both the old williamboman/* and new mason-org/* repo names)
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  { "williamboman/mason.nvim", enabled = false },
  { "williamboman/mason-lspconfig.nvim", enabled = false },
  { "jay-babu/mason-nvim-dap.nvim", enabled = false },
}
