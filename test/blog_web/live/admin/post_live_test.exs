defmodule BlogWeb.Admin.PostLiveTest do
  use BlogWeb.ConnCase

  import Phoenix.LiveViewTest
  import Blog.ContentFixtures

  @create_attrs %{
    body: "some body",
    cover: "some cover",
    published: true,
    slug: "some slug",
    title: "some title",
    user_id: 42
  }
  @update_attrs %{
    body: "some updated body",
    cover: "some updated cover",
    published: false,
    slug: "some updated slug",
    title: "some updated title",
    user_id: 43
  }
  @invalid_attrs %{body: nil, cover: nil, published: false, slug: nil, title: nil, user_id: nil}

  defp create_post(_) do
    post = post_fixture()
    %{post: post}
  end

  describe "Index" do
    setup [:create_post]

    test "lists all posts", %{conn: conn, post: post} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/posts")

      assert html =~ "Listing Posts"
      assert html =~ post.body
    end

    test "saves new post", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/posts")

      assert index_live |> element("a", "New Post") |> render_click() =~
               "New Post"

      assert_patch(index_live, ~p"/admin/posts/new")

      assert index_live
             |> form("#post-form", post: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#post-form", post: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/admin/posts")

      assert html =~ "Post created successfully"
      assert html =~ "some body"
    end

    test "updates post in listing", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/posts")

      assert index_live |> element("#posts-#{post.id} a", "Edit") |> render_click() =~
               "Edit Post"

      assert_patch(index_live, ~p"/admin/posts/#{post}/edit")

      assert index_live
             |> form("#post-form", post: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#post-form", post: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/admin/posts")

      assert html =~ "Post updated successfully"
      assert html =~ "some updated body"
    end

    test "deletes post in listing", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/posts")

      assert index_live |> element("#posts-#{post.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#post-#{post.id}")
    end
  end

  describe "Show" do
    setup [:create_post]

    test "displays post", %{conn: conn, post: post} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/posts/#{post}")

      assert html =~ "Show Post"
      assert html =~ post.body
    end

    test "updates post within modal", %{conn: conn, post: post} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/posts/#{post}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Post"

      assert_patch(show_live, ~p"/admin/posts/#{post}/show/edit")

      assert show_live
             |> form("#post-form", post: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#post-form", post: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/admin/posts/#{post}")

      assert html =~ "Post updated successfully"
      assert html =~ "some updated body"
    end
  end
end
