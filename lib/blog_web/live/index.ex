defmodule BlogWeb.IndexLive do
  use BlogWeb, :live_view

  alias Blog.Content

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :posts, list_posts())}
  end

  defp list_posts do
    Content.list_posts()
  end

  @impl true
  def render(assigns) do
    ~H"""
      <h1>Welcome</h1>
      <h2>recent posts</h2>
      <%= for post <- @posts do %>
        <h3><a href={~p"/blog/#{post.id}"}><%= post.title %></a></h3>
        <p><%= post.body %></p>
      <% end %>
    """
  end
end

