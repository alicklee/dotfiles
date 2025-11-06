-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- vim.cmd "colorscheme catppuccin-mocha"

-- Add Tab key buffer navigation without modifying astrocore

-- ~/.config/nvim/lua/user/polish.lua

vim.keymap.set("n", "<Tab>", function()
  local bufs = vim.tbl_filter(
    function(buf) return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted end,
    vim.api.nvim_list_bufs()
  )

  if #bufs <= 1 then
    vim.notify("Only one buffer, nothing to navigate", vim.log.levels.INFO)
    return
  end

  local current_buf = vim.api.nvim_get_current_buf()
  local current_index = nil

  for i, buf in ipairs(bufs) do
    if buf == current_buf then
      current_index = i
      break
    end
  end

  if current_index then
    local next_index = current_index + 1
    if next_index > #bufs then next_index = 1 end
    vim.api.nvim_set_current_buf(bufs[next_index])
  end
end, { desc = "Next buffer (wrap around)" })
