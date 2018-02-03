use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mobile_markdown, MobileMarkdownWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :mobile_markdown, MobileMarkdown.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "mobile_markdown_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :mobile_markdown, :s3_post_config,
  bucket: "my-bucket",
  region: "us-east-1",
  ttl: 30,
  public_key: "AKIAIEUX27GZFAKECODE",
  private_key: "M1jAHjgpZ6FnXCErcY8/ANOTHERFAKECODEEEEEEEE"

config :mobile_markdown, :current_time_interface,
  MobileMarkdown.CurrentTimeMock
