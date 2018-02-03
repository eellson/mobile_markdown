defmodule MobileMarkdown.CurrentTimeReal do
  @behaviour MobileMarkdown.CurrentTime

  def now, do: DateTime.utc_now()
end
