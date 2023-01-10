defmodule Blog.Content.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :cover, :string
    field :published, :boolean, default: false
    field :slug, :string
    field :title, :string
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body, :published, :cover, :user_id, :slug])
    |> validate_required([:title, :body, :published, :cover, :user_id, :slug])
  end
end
