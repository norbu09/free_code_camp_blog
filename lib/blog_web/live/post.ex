defmodule BlogWeb.PostLive do
  use BlogWeb, :live_view

  alias Blog.Content

  @impl true
  def mount(params, _session, socket) do
    {:ok, assign(socket, :post, get_post(params["id"]))}
  end

  defp get_post(id) do
    Content.get_post!(id)
  end

  @impl true
  def render(assigns) do
    ~H"""
      <h1>Blog</h1>
        <h2><%= @post.title %></h2>
        <p><%= @post.body %></p>
    """
  end
end


