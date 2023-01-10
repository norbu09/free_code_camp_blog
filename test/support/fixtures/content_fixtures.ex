defmodule Blog.ContentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Blog.Content` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        body: "some body",
        cover: "some cover",
        published: true,
        slug: "some slug",
        title: "some title",
        user_id: 42
      })
      |> Blog.Content.create_post()

    post
  end
end
