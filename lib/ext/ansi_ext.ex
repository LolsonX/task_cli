defmodule ANSIExt do
  def store_cursor(), do: "\e[s"
  def restore_cursor(), do: "\e[u"
end
