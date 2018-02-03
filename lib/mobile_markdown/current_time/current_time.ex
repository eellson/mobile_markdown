defmodule MobileMarkdown.CurrentTime do
  @callback now() :: DateTime.t
end
