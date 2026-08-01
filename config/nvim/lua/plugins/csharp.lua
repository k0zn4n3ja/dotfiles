-- C# / .NET via roslyn.nvim + the Nix-provided Roslyn language server.
-- This is the same engine VS Code's C# extension uses; it handles modern
-- SDK-style projects (.NET 10, Microsoft.Testing.Platform) that OmniSharp
-- struggles with. The server binary comes from the `roslyn-ls` Nix package
-- (Microsoft.CodeAnalysis.LanguageServer on PATH) -- no Mason needed.
return {
  {
    "seblyng/roslyn.nvim",
    -- Pinned: main now requires Neovim >= 0.12 (commit dbd677f, "feat!: >=0.12").
    -- We're on 0.11.7 (Nix stable 25.11), so pin to the last 0.11-compatible commit.
    -- Remove this pin once nixpkgs ships Neovim 0.12+.
    commit = "f2ec6ee6384c3b611ddc817b9e78b20cd0334bbb",
    ft = { "cs", "razor" },
    config = function()
      -- point roslyn at the Nix-installed server on PATH
      vim.lsp.config("roslyn", {
        cmd = {
          "Microsoft.CodeAnalysis.LanguageServer",
          "--logLevel=Information",
          "--extensionLogDirectory=" .. vim.fs.joinpath(vim.fn.stdpath("log"), "roslyn"),
          "--stdio",
        },
      })
      -- older roslyn.nvim versions expose a setup(); newer ones don't. Harmless either way.
      pcall(function()
        require("roslyn").setup({})
      end)
    end,
  },
}
