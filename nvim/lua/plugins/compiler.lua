return {
  {
    "Zeioth/compiler.nvim",
    cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
    event = "VeryLazy",
    dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" },
    opts = {},
    config = function(_, opts)
      require("compiler").setup(opts)

      -- Windows fix for F6 (CompilerOpen) / Redo:
      -- compiler.nvim loads languages via utils.require_language() which uses
      -- dofile() (fresh table every call), so patching
      -- require("compiler.languages.java") does NOTHING for F6.
      -- We must wrap utils.require_language instead.
      -- Also stock java/cpp use `rm -f ... || true && mkdir -p ...` (POSIX-only,
      -- fails silently under cmd.exe -> SUCCESS + empty output + [Process exited 0]).
      local cpp_args = "-Wall -g -std=c++17 -Wno-unused-parameter"

      local function run_overseer(cmd, cwd, name)
        local overseer = require("overseer")
        local task = overseer.new_task({
          cmd = cmd,
          cwd = cwd,
          name = name,
          -- default_extended is registered by compiler.setup(): on_complete_dispose + default + open_output
          components = { "default_extended" },
        })
        task:start()
        vim.defer_fn(function()
          pcall(function()
            require("overseer").open({ enter = false })
          end)
        end, 100)
      end

      local function java_cmd_for(bufname, selected_option)
        -- Use cwd=filedir + RELATIVE names so "Dev Projects" space never
        -- appears inside the shell string (cmd.exe /s /c quoting safe).
        local filedir = vim.fn.fnamemodify(bufname, ":p:h")
        local filename = vim.fn.fnamemodify(bufname, ":t") -- Main.java
        local classname = vim.fn.fnamemodify(bufname, ":t:r") -- Main
        vim.fn.mkdir(filedir .. "/bin", "p")
        local javac = string.format('javac -d "bin" -Xlint:all "%s"', filename)
        local run = string.format('java -cp "bin" %s', classname)
        if selected_option == "option1" then
          return javac .. " && " .. run, filedir
        elseif selected_option == "option2" then
          return javac, filedir
        else
          return run, filedir
        end
      end

      local function cpp_cmd_for(bufname, selected_option)
        local filedir = vim.fn.fnamemodify(bufname, ":p:h")
        local filename = vim.fn.fnamemodify(bufname, ":t")
        local outname = vim.fn.fnamemodify(bufname, ":t:r")
        vim.fn.mkdir(filedir .. "/bin", "p")
        if selected_option == "option3" then
          return string.format('".\\bin\\%s.exe" || ".\\bin\\%s"', outname, outname), filedir
        end
        local build = string.format('g++ "%s" -o "bin/%s" %s', filename, outname, cpp_args)
        if selected_option == "option1" then
          return build .. string.format(' && echo --- Program output --- && ".\\bin\\%s.exe" || ".\\bin\\%s"', outname, outname), filedir
        else
          return build, filedir
        end
      end

      local utils_ok, utils = pcall(require, "compiler.utils")
      if not utils_ok or not utils or type(utils.require_language) ~= "function" then
        vim.notify("compiler.nvim: utils.require_language not found, Windows patch skipped", vim.log.levels.WARN)
      else
        local orig_require_language = utils.require_language
        utils.require_language = function(filetype)
          local lang = orig_require_language(filetype)
          if not lang or type(lang.action) ~= "function" then
            return lang
          end

          if filetype == "java" then
            local orig_action = lang.action
            lang.action = function(selected_option)
              if selected_option ~= "option1" and selected_option ~= "option2" and selected_option ~= "option3" then
                return orig_action(selected_option)
              end
              local bufname = vim.api.nvim_buf_get_name(0)
              if bufname == "" then
                vim.notify("Save file first (no buffer name)", vim.log.levels.ERROR)
                return
              end
              if vim.bo.modified then
                vim.cmd("silent write")
              end
              local cmd, cwd = java_cmd_for(bufname, selected_option)
              vim.notify("Java: " .. cmd, vim.log.levels.INFO, { title = "Compiler (F6)" })
              run_overseer(cmd, cwd, '- Java ("' .. bufname .. '")')
            end
          elseif filetype == "cpp" or filetype == "c" then
            local orig_action = lang.action
            lang.action = function(selected_option)
              if selected_option ~= "option1" and selected_option ~= "option2" and selected_option ~= "option3" and selected_option ~= "option4" then
                return orig_action(selected_option)
              end
              local bufname = vim.api.nvim_buf_get_name(0)
              if bufname == "" then
                vim.notify("Save file first (no buffer name)", vim.log.levels.ERROR)
                return
              end
              if vim.bo.modified then
                vim.cmd("silent write")
              end
              if selected_option == "option4" then
                selected_option = "option2" -- single-file build
              end
              local cmd, cwd = cpp_cmd_for(bufname, selected_option)
              run_overseer(cmd, cwd, '- Build program -> "' .. bufname .. '"')
            end
          end
          return lang
        end
      end

      -- F5: instant single-file build & run (no picker), filetype-aware.
      -- This path never used dofile(), so it always worked — now also relative-path safe.
      vim.keymap.set("n", "<F5>", function()
        local bufname = vim.api.nvim_buf_get_name(0)
        if bufname == "" then
          vim.notify("Save file first (no buffer name)", vim.log.levels.ERROR)
          return
        end
        if vim.bo.modified then
          vim.cmd("silent write")
        end
        local ext = vim.fn.fnamemodify(bufname, ":e"):lower()
        if ext == "java" then
          local cmd, cwd = java_cmd_for(bufname, "option1")
          run_overseer(cmd, cwd, '- Build & run -> "' .. bufname .. '"')
          return
        end
        local cmd, cwd = cpp_cmd_for(bufname, "option1")
        run_overseer(cmd, cwd, '- Build & run -> "' .. bufname .. '"')
      end, { desc = "Build & run current file (F5, single-file)" })
    end,
    keys = {
      { "<F5>", desc = "Build & run current file (single-file)" },
      { "<F6>", "<cmd>CompilerOpen<cr>", desc = "Open compiler" },
      { "<S-F6>", "<cmd>CompilerStop<cr><cmd>CompilerRedo<cr>", desc = "Redo last compiler task" },
      { "<S-F7>", "<cmd>CompilerToggleResults<cr>", desc = "Toggle compiler results" },
    },
  },
  {
    "stevearc/overseer.nvim",
    cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
    opts = {
      task_list = { direction = "bottom", min_height = 25, max_height = 25, default_detail = 2 },
    },
  },
}
