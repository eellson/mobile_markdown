ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(MobileMarkdown.Repo, :manual)

Mox.defmock(MobileMarkdown.CurrentTimeMock, for: MobileMarkdown.CurrentTime)
