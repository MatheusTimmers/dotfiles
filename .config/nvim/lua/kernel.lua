-- Ciclo curto de kernel bare-metal: compila, sobe o QEMU e prende o GDB nele.
--
-- O projeto ja tem o runner certo no .cargo/config.toml -- `cargo run` chama o
-- run.sh, e `cargo run -- -g` passa -s -S ao QEMU, que congela no reset com um
-- gdbstub escutando na 1234. O que faltava era o lado do editor: alguem que
-- espere essa porta abrir e ligue o nvim-dap nela, sem ter que sair para um
-- segundo terminal e digitar `target remote` na mao a cada boot.
--
-- O debug vai pelo gdb, nao pelo codelldb: o lldb nao tem backend de riscv32.
-- O gdb do Fedora ja vem com riscv:rv32 e com --interpreter=dap (gdb >= 14),
-- entao fala DAP nativamente e nao ha adapter nenhum para instalar pelo mason.
-- O adapter em si esta registrado em plugins/dap.lua, junto dos outros.

local M = {}

local GDB_PORT = 1234
local TERM_HEIGHT = 15

-- Onde parar quando o QEMU descongelar.
--
-- O -S para a maquina no vetor de reset -- 0x1000, que e a ROM do proprio QEMU,
-- nao o seu kernel. Nao ha fonte para mostrar ali, entao o attach cru te larga
-- num frame "???" sem nada para ler. Se voce nao marcou nenhum breakpoint, o
-- attach poe um aqui e solta a maquina ate chegar. Troque o nome se a entrada
-- do kernel mudar; se o simbolo nao existir, ele avisa e fica no reset mesmo.
local ENTRY = "kmain"

-- Um QEMU de cada vez. Dois nao coexistem: o segundo nao consegue fazer bind na
-- 1234, morre calado, e o GDB acaba conversando com o primeiro -- que ja tem
-- outro kernel carregado. O sintoma e "Ignoring packet error, continuing...".
local qemu = { job = nil, buf = nil }

local function root()
  local buf = vim.api.nvim_buf_get_name(0)
  local start = buf ~= "" and vim.fs.dirname(buf) or vim.uv.cwd()
  local manifest = vim.fs.find("Cargo.toml", { path = start, upward = true, type = "file" })[1]
  if not manifest then
    vim.notify("kernel: no Cargo.toml above " .. start, vim.log.levels.ERROR)
    return nil
  end
  return vim.fs.dirname(manifest)
end

--- Compila e entrega a on_ok o caminho do ELF que o proprio cargo reporta.
---
--- Montar o caminho na mao (target/<triple>/debug/<nome>) erraria toda vez que
--- o triple, o profile ou o nome do bin mudasse. O --message-format=json diz
--- qual e, e continua dizendo mesmo quando nao ha nada a recompilar ("fresh").
local function build(dir, on_ok)
  vim.notify("cargo build...", vim.log.levels.INFO)
  vim.system(
    { "cargo", "build", "--message-format=json-render-diagnostics" },
    { cwd = dir, text = true },
    function(res)
      if res.code ~= 0 then
        return vim.schedule(function()
          vim.notify("cargo build failed:\n" .. vim.trim(res.stderr or ""), vim.log.levels.ERROR)
        end)
      end
      -- Os diagnosticos ja sairam renderizados no stderr; no stdout so vem o
      -- JSON, uma mensagem por linha.
      -- type(...) == "string", e nao so `if msg.executable`: os artefatos que nao
      -- geram binario (as rlib do core, o build script) trazem "executable": null,
      -- e o vim.json.decode traduz null para vim.NIL -- um userdata, que em Lua e
      -- truthy. O teste ingenuo aceita todos eles.
      local elves = {}
      for line in vim.gsplit(res.stdout or "", "\n", { trimempty = true }) do
        local ok, msg = pcall(vim.json.decode, line)
        if ok and msg.reason == "compiler-artifact" and type(msg.executable) == "string" then
          table.insert(elves, msg.executable)
        end
      end
      vim.schedule(function()
        if #elves == 0 then
          vim.notify("kernel: cargo reported no executable", vim.log.levels.ERROR)
          return
        end
        if #elves == 1 then
          return on_ok(elves[1])
        end
        -- Mais de um binario (kernel + bootloader, ou um workspace): escolher o
        -- ultimo da lista seria escolher em silencio, e no dia que estivesse
        -- errado o sintoma seria um breakpoint que nunca bate, sem dizer porque.
        vim.ui.select(elves, {
          prompt = "Which binary?",
          format_item = function(item)
            return vim.fs.basename(item)
          end,
        }, function(choice)
          if choice then
            on_ok(choice)
          end
        end)
      end)
    end
  )
end

local function open_terminal(dir, cmd, focus)
  M.stop({ quiet = true })
  local prev = vim.api.nvim_get_current_win()
  vim.cmd("botright " .. TERM_HEIGHT .. "split | enew")
  qemu.buf = vim.api.nvim_get_current_buf()
  qemu.job = vim.fn.jobstart(cmd, {
    cwd = dir,
    term = true,
    on_exit = function()
      qemu.job, qemu.buf = nil, nil
    end,
  })
  if focus then
    vim.cmd.startinsert()
  elseif vim.api.nvim_win_is_valid(prev) then
    vim.api.nvim_set_current_win(prev)
  end
end

-- O /proc escreve as portas em hexadecimal maiusculo.
local PORT_HEX = ("%04X"):format(GDB_PORT)

--- O gdbstub ja esta escutando?
---
--- Le o /proc em vez de tentar conectar de proposito. O gdbstub do QEMU aceita
--- um cliente so: uma sonda que conecta e fecha e vista como esse cliente, e o
--- GDB de verdade chega depois num stub que ainda acha que esta ocupado --
--- "Remote replied unexpectedly to 'vMustReplyEmpty': timeout", intermitente e
--- dificil de ligar a causa. Olhar o socket em LISTEN (estado 0A) nao toca em
--- nada. Linux-only, que e onde o QEMU roda aqui.
local function gdbstub_listening()
  for _, path in ipairs({ "/proc/net/tcp", "/proc/net/tcp6" }) do
    local fh = io.open(path, "r")
    if fh then
      for line in fh:lines() do
        local addr, state = line:match("^%s*%d+:%s+(%S+)%s+%S+%s+(%x%x)")
        if state == "0A" and addr and addr:sub(-5) == ":" .. PORT_HEX then
          fh:close()
          return true
        end
      end
      fh:close()
    end
  end
  return false
end

local function wait_for_gdbstub(tries, on_ready)
  if gdbstub_listening() then
    return on_ready()
  end
  if tries <= 1 then
    vim.notify(("kernel: gdbstub never opened on port %d"):format(GDB_PORT), vim.log.levels.ERROR)
    return
  end
  vim.defer_fn(function()
    wait_for_gdbstub(tries - 1, on_ready)
  end, 100)
end

--- Quantos breakpoints de linha voce marcou (em qualquer buffer).
local function user_breakpoints()
  local n = 0
  for _, list in pairs(require("dap.breakpoints").get()) do
    n = n + #list
  end
  return n
end

--- Primeira parada depois do attach: e sempre o vetor de reset. Se voce ja disse
--- onde quer parar, so solta a maquina; senao, para na entrada do kernel.
local function skip_reset_vector(session, thread_id)
  local function resume()
    session:request("continue", { threadId = thread_id }, function() end)
  end

  if user_breakpoints() > 0 then
    return resume()
  end

  session:request("setFunctionBreakpoints", { breakpoints = { { name = ENTRY } } }, function(err, resp)
    local bp = resp and resp.breakpoints and resp.breakpoints[1]
    if err or not bp or bp.verified == false then
      vim.notify(
        ("kernel: symbol %s() not found; stopped at the reset vector"):format(ENTRY),
        vim.log.levels.WARN
      )
      return
    end
    resume()
  end)
end

local function attach(elf)
  local dap = require("dap")

  -- Uma vez so: a proxima parada ja e a que voce pediu.
  dap.listeners.after.event_stopped["kernel"] = function(session, body)
    dap.listeners.after.event_stopped["kernel"] = nil
    skip_reset_vector(session, body.threadId or 1)
  end

  dap.run({
    name = "QEMU gdbstub (:" .. GDB_PORT .. ")",
    type = "gdb",
    request = "attach",
    program = elf,
    target = "localhost:" .. GDB_PORT,
  })
end

--- Roda o kernel no QEMU. Foco vai para o terminal: e la que se le a UART e se
--- sai do QEMU (Ctrl+A, solta, X).
function M.run()
  local dir = root()
  if dir then
    open_terminal(dir, { "cargo", "run" }, true)
  end
end

--- Compila, sobe o QEMU congelado no reset e prende o GDB nele.
function M.debug()
  local dir = root()
  if not dir then
    return
  end
  build(dir, function(elf)
    open_terminal(dir, { "cargo", "run", "--", "-g" }, false)
    -- 100ms x 50 = 5s de paciencia; o QEMU costuma abrir a porta em menos de um.
    wait_for_gdbstub(50, function()
      attach(elf)
    end)
  end)
end

--- Prende o GDB num QEMU que ja esta rodando (subido a mao, noutro terminal).
--- Compila antes de proposito: garante que os simbolos batem com o binario.
function M.attach()
  local dir = root()
  if dir then
    build(dir, attach)
  end
end

function M.stop(opts)
  opts = opts or {}
  local dap = package.loaded["dap"]
  if dap and dap.session() then
    dap.terminate()
  end
  if qemu.job then
    vim.fn.jobstop(qemu.job)
  end
  if qemu.buf and vim.api.nvim_buf_is_valid(qemu.buf) then
    vim.api.nvim_buf_delete(qemu.buf, { force = true })
  end
  qemu.job, qemu.buf = nil, nil
  if not opts.quiet then
    vim.notify("kernel: QEMU stopped", vim.log.levels.INFO)
  end
end

local function scratch(name, ft, lines)
  vim.cmd("botright split | enew")
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modified = false
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = ft
  pcall(vim.api.nvim_buf_set_name, buf, name)
end

--- Le o binario com llvm-objdump, e nao com o objdump do sistema: o binutils do
--- Fedora e compilado so para o arch do host e nao conhece elf32-littleriscv.
--- O llvm-objdump ja vem multi-target (e vem junto do clang, que voce tem).
local function dump(tool, args, ft, filter)
  if vim.fn.executable(tool) ~= 1 then
    vim.notify(("kernel: %s is not on PATH (dnf install llvm)"):format(tool), vim.log.levels.ERROR)
    return
  end
  local dir = root()
  if not dir then
    return
  end
  build(dir, function(elf)
    local cmd = vim.list_extend({ tool }, args)
    table.insert(cmd, elf)
    vim.system(cmd, { cwd = dir, text = true }, function(res)
      vim.schedule(function()
        if res.code ~= 0 then
          vim.notify(("%s failed:\n%s"):format(tool, vim.trim(res.stderr or "")), vim.log.levels.ERROR)
          return
        end
        local lines = vim.split(res.stdout or "", "\n")
        if filter then
          lines = filter(lines)
        end
        scratch(tool .. " " .. vim.fs.basename(elf), ft, lines)
      end)
    end)
  end)
end

--- Disassembly com o fonte Rust intercalado -- da para ver o que o naked_asm!
--- e o codegen realmente emitiram, que e metade do trabalho num kernel.
function M.disasm()
  dump("llvm-objdump", { "--disassemble", "--source", "--demangle", "--no-show-raw-insn" }, "disassembly")
end

--- Simbolos por endereco: confere o layout que o kernel.ld pediu (.text em
--- 0x80000000, onde .bss comeca e acaba, onde o __stack_top caiu).
---
--- Sem filtro vem junto uma centena de rotulos internos (.Lline_table_start0,
--- .Lanon.*, os $d de mapeamento) que enterram o que voce quer conferir.
---
--- O --extern-only resolveria isso numa flag, mas joga fora demais: um
--- `static mut FOO` sem #[no_mangle] e um simbolo LOCAL (o 'b' minusculo do
--- nm), entao as pilhas das tarefas, o CONTEXTS e o USED sumiriam -- que sao
--- justamente os enderecos que se quer conferir num kernel. Filtrar pelo nome
--- mantem eles e tira o ruido.
function M.symbols()
  dump("llvm-nm", { "--numeric-sort", "--demangle", "--defined-only" }, "", function(lines)
    local kept = {}
    for _, line in ipairs(lines) do
      local name = line:match("^%x+%s+%a%s+(.+)$")
      if not name or not (name:match("^%$") or name:match("^%.L")) then
        table.insert(kept, line)
      end
    end
    return kept
  end)
end

function M.setup()
  local cmd = vim.api.nvim_create_user_command
  cmd("KernelRun", M.run, { desc = "QEMU: run the kernel" })
  cmd("KernelDebug", M.debug, { desc = "QEMU: run frozen and attach GDB" })
  cmd("KernelAttach", M.attach, { desc = "QEMU: attach GDB to a running QEMU" })
  cmd("KernelStop", M.stop, { desc = "QEMU: stop" })
  cmd("KernelDisasm", M.disasm, { desc = "Disassemble the ELF (llvm-objdump)" })
  cmd("KernelSymbols", M.symbols, { desc = "ELF symbols by address (llvm-nm)" })

  local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { desc = desc })
  end
  map("<leader>kr", M.run, "Run in QEMU")
  map("<leader>kd", M.debug, "Debug in QEMU (auto-attach)")
  map("<leader>ka", M.attach, "Attach to running QEMU")
  map("<leader>kx", M.stop, "Stop QEMU")
  map("<leader>ko", M.disasm, "Disassemble ELF")
  map("<leader>ks", M.symbols, "ELF symbols")
end

return M
