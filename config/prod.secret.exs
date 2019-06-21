use Mix.Config

# Configure your database
config :blog, Blog.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "blogger",
  password: "bloggerific%$001",
  database: "blog",
  hostname: "serve.rfitzy.net",
  pool_size: 10
