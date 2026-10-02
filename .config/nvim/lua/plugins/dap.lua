-- Debug para C, C++, Rust (codelldb) e Go (delve).
--
-- <leader>d ja e o float de diagnostico, entao o grupo de debug fica em
-- <leader>D; as teclas do passo a passo estao nos F-keys, que e onde a memoria
-- muscular importa durante uma sessao.
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "jay-babu/mason-nvim-dap.nvim",
      "leoluz/nvim-dap-go",
    },
    keys = {
      { "<F5>",  function() require("dap").continue() end,          desc = "Debug: start/continue" },
      { "<F10>", function() require("dap").step_over() end,         desc = "Debug: step over" },
      { "<F11>", function() require("dap").step_into() end,         desc = "Debug: step into" },
      { "<S-F11>", function() require("dap").step_out() end,        desc = "Debug: step out" },
      { "<leader>Db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      {
        "<leader>DB",
        function()
          vim.ui.input({ prompt = "Condicao do breakpoint: " }, function(cond)
            if cond and cond ~= "" then
              require("dap").set_breakpoint(cond)
            end
          end)
        end,
        desc = "Conditional breakpoint",
      },
      { "<leader>Dc", function() require("dap").continue() end,     desc = "Start/continue" },
      { "<leader>Do", function() require("dap").step_over() end,    desc = "Step over" },
      { "<leader>Di", function() require("dap").step_into() end,    desc = "Step into" },
      { "<leader>DO", function() require("dap").step_out() end,     desc = "Step out" },
      { "<leader>Dl", function() require("dap").run_last() end,     desc = "Run last" },
      { "<leader>Dr", function() require("dap").repl.toggle() end,  desc = "Toggle REPL" },
      { "<leader>Dt", function() require("dap").terminate() end,    desc = "Terminate" },
      { "<leader>Du", function() require("dapui").toggle() end,     desc = "Toggle debug UI" },
      { "<leader>Dg", function() require("dap-go").debug_test() end, desc = "Debug nearest Go test", ft = "go" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Instala os adapters pelo mason e registra cada um com o handler padrao.
      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb", "delve" },
        automatic_installation = true,
        handlers = {
          function(config)
            require("mason-nvim-dap").default_setup(config)
          end,
        },
      })

      require("nvim-dap-virtual-text").setup({})
      dapui.setup()
      require("dap-go").setup()

      -- A UI abre e fecha junto com a sessao.
      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

      -- O codelldb nao tem "configuration" propria: precisa saber qual binario
      -- rodar. Nao ha como adivinhar, entao pergunta na primeira vez.
      local codelldb_launch = {
        name = "Launch file",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Executavel: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      }
      dap.configurations.c = { codelldb_launch }
      dap.configurations.cpp = { codelldb_launch }
      -- Rust tambem, como plano B: dentro de um cargo project o caminho bom e
      -- <leader>rD (RustLsp debuggables), que monta o alvo sozinho.
      dap.configurations.rust = { codelldb_launch }

      -- Kernel no QEMU: o alvo nao e um processo do SO, e um gdbstub numa porta
      -- TCP -- quem se conecta e o gdb com "target remote". O codelldb nao serve
      -- (o lldb nao tem backend de riscv32) e nem faz falta: o gdb >= 14 tem
      -- --interpreter=dap e fala DAP sozinho, sem adapter nenhum do mason.
      -- O -iex roda antes de carregar qualquer arquivo. Sem ele os paineis de
      -- Locals/Registers mostram tudo em decimal, e num kernel quase todo valor
      -- que interessa e endereco ou mascara de bits: mcause 2147483655 nao diz
      -- nada, 0x80000007 diz "interrupcao (bit 31), codigo 7 = timer".
      -- Para ver um valor em decimal pontualmente: p/d <expr> no console.
      dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = { "--interpreter=dap", "-iex", "set output-radix 16" },
      }

      -- O caminho bom e o <leader>kd (lua/kernel.lua): ele compila, sobe o QEMU
      -- congelado, espera a porta abrir e prende o GDB sozinho. Esta entrada e o
      -- plano B, para um QEMU que ja esta rodando e um ELF escolhido na mao.
      table.insert(dap.configurations.rust, {
        name = "QEMU: attach ao gdbstub (:1234)",
        type = "gdb",
        request = "attach",
        target = "localhost:1234",
        program = function()
          return vim.fn.input("ELF do kernel: ", vim.fn.getcwd() .. "/target/", "file")
        end,
      })

      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticSignError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticSignWarn" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticSignInfo" })
    end,
  },
}
