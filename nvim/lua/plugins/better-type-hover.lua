-- ~/.config/nvim/lua/plugins/better-type-hover.lua
return {
  "Sebastian-Nielsen/better-type-hover",
  ft = { "typescript", "typescriptreact" },
  config = function()
    -- better-type-hover 配置
    require("better-type-hover").setup {
      -- 主快捷键，光标在 interface/type 时触发展开
      openTypeDocKeymap = "K",

      -- 当光标不在 interface/type 时，fallback 到原生 hover
      fallback_to_old_on_anything_but_interface_and_type = true,

      -- 类型声明行数超过 20 行时折叠
      fold_lines_after_line = 20,

      -- 展开嵌套类型的快捷键顺序
      keys_that_open_nested_types = { "a", "s", "b", "i", "e", "u", "r", "x" },

      -- 避免显示无意义类型提示
      types_to_not_expand = { "string", "number", "boolean", "Date" },
    }

    -- 高亮配置
    vim.cmd "highlight key_hint_color guifg=#FFFFFF guibg=NONE" -- 白色
    vim.cmd "highlight selected_key_hint_color guifg=#BC0000 guibg=NONE" -- 红色

    -- 自定义 fallback hover 窗口，例如添加圆角边框
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
  end,
}
