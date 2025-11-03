-- 安装配置
--
return {
  "hiphish/rainbow-delimiters.nvim",
  event = "User AstroFile",
  config = function()
    local rainbow_delimiters = require "rainbow-delimiters"

    vim.g.rainbow_delimiters = {
      strategy = {
        [""] = rainbow_delimiters.strategy["global"],
      },
      query = {
        [""] = "rainbow-delimiters",
        latex = "rainbow-blocks",
      },
      highlight = {
        -- 高对比度颜色
        "RainbowDelimiterRed",
        "RainbowDelimiterGreen",
        "RainbowDelimiterBlue",
        "RainbowDelimiterYellow",
        "RainbowDelimiterMagenta",
        "RainbowDelimiterCyan",
        "RainbowDelimiterOrange",
      },
    }
  end,
}
