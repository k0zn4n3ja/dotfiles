-- C# / .NET via roslyn.nvim + the Nix-provided Roslyn language server.
-- This is the same engine VS Code's C# extension uses; it handles modern
-- SDK-style projects (.NET 10, Microsoft.Testing.Platform) that OmniSharp
-- struggles with. The server binary comes from the `roslyn-ls` Nix package
-- (Microsoft.CodeAnalysis.LanguageServer on PATH) -- no Mason needed.
return {
  {
    "seblyng/roslyn.nvim",
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
