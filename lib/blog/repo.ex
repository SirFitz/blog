defmodule Blog.Repo do
  use Ecto.Repo, otp_app: :blog
  use Kerosene, per_page: 20
end
