return {
  "saghen/blink.cmp",
  opts = {
    -- カーソル直前の文字が日本語（マルチバイト）のときは補完を出さない。
    -- ASCII（英数字・記号）を書いているときだけ補完を有効にする。
    enabled = function()
      local col = vim.fn.col(".") - 1
      if col <= 0 then
        return true
      end
      local line = vim.api.nvim_get_current_line()
      -- カーソル直前のバイトを取得
      local byte = line:byte(col)
      -- 0x80 以上はマルチバイト文字（日本語など）の一部とみなして無効化
      if byte and byte >= 0x80 then
        return false
      end
      return true
    end,
  },
}
