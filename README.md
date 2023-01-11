# FreeCodeCamp meetup Loule - elixir intro


To get started we need to have elixir and erlang installed. Erlang often
installs as a dependency of elixir so it normally needs no separate step to get
it. For details on how to install elixir see the fantastic docs here: https://elixir-lang.org/install.html

For the `helo world` example to get everyone playing with elixir i thought a
super simple bare bones blog might be a good starting point. The de-facto
standard web framework for elixir is called _phoenix_ and is a super robust
framework that has taken inspiration from all the major frameworks in other
languages. Phoenix is currently going through a pretty major change on how the
directory structure is set up so much of the current docs out there need to be
adapted. I have used the new version for quite a while now and find it a
cleaner start but if you see docs that don't match what you have it is due to
the fact that we use 1.7.0-rc and most docs are for 1.6 or below.

To get the new version run the following command in a terminal:

    mix archive.install hex phx_new 1.7.0-rc.2 

With that in place we can start generating the scaffold of the new project.
Elixir has a very flexible build system called `mix`. We used it in the command
above already and it can easily be extended with plugins. Phoenix comes with a
whole range of mix plugins and we will make extensive use of them. To get an
overview of what plugins your `mix` currently knows about run `mix help`

To generate a new Phoenix project we use the `mix phx.new` command and to get
an overview of the possible parameters we can run 

    mix help phx.new

We want to build a thing called `blog` and it should use a `sqlite3` backend so
we don't have to muck around with database servers just yet. The default in
Phoenix land is actually Postgres.

    mix phx.new blog --database sqlite3
    ...
    Fetch and install dependencies? [Yn] y
    ...

When we get asked if we want to fetch and install dependencies then answer with
a friendly `y` then change into your new `blog` directory and open up your
editor.

I normally try to keep my root directory relatively clean so i update the
config for the database path in the dev environment in `config/dev.exs`

```diff
-  database: Path.expand("../blog_dev.db", Path.dirname(__ENV__.file)),
+  database: Path.expand("../db/blog_dev.db", Path.dirname(__ENV__.file)),
```

in case you run in some sort of virtualised or containerised environment you
may also want to update the listen host like this:

```diff
-  http: [ip: {127, 0, 0, 1}, port: 4000],
+  http: [ip: {0, 0, 0, 0}, port: 4000],
```

After that we can run the database migrations with a friendly

    mix ecto.create

and finally start our new site with:

    iex -S mix phx.server

This starts the development server at http://localhost:4000 and it also drops
us into a repl so we can start playing with the code base. Now is good time to
have a bit of a look at the directory structure and explore what we have done
so far. Good docs about the directory structure here here:
https://hexdocs.pm/phoenix/1.7.0-rc.1/directory_structure.html

Next we need some sort of authentication so we can build a blog that has a
(very basic) admin interface and a public facing part that displays the posts.
So let's get started with authentication. Phoenix ships with many code
generators out of the box and there is a good starting point for building
authentication into an phoenix app with the provided `phx.gen.auth`.
Docs as always are excellent and can be found here:
https://hexdocs.pm/phoenix/1.7.0-rc.1/mix_phx_gen_auth.html

The generator that we use is straight out of the docs and provides everything
we need for today. Just run the following in your project directory:

    mix phx.gen.auth Accounts User users

This generates all the components, templates and so on for us, all we have to
do is fetch the missing dependencies for the new code, we can do that with a

    mix deps.get

and we need to apply the database migrations so we can start using the new
code. Database migrations are always run with:

    mix ecto.migrate


And with that in place we have a working application with authentication. We
have used the database abstraction layer called ecto, we have generated live
view components and so on. We'll look into what all that means next.

To generate the blog admin pages we can make use of another generator. this
time we use `phx.gen.live` which generates a live view, model, database
migration and all the bits that glue it all together in one go. Check out the
options to that generator with `mix help phx.gen.live` and follow the
references in that help to start to get a feel for how this generator builds on
top of several others. To generate the blog admin all we have to do is:

    mix phx.gen.live Content Post posts title:string body:text published:boolean cover:string slug:string --web Admin

We now have to add the new routes to our router so that the new code is mapped
onto route paths. Open up the `lib/blog_web/router.ex` and add the following
lines in the section that has the `pipe_through [:browser,
:require_authenticated_user]` pipeline:

```diff
+      live "/admin/posts", Admin.PostLive.Index, :index
+      live "/admin/posts/new", Admin.PostLive.Index, :new
+      live "/admin/posts/:id/edit", Admin.PostLive.Index, :edit
+
+      live "/admin/posts/:id", Admin.PostLive.Show, :show
+      live "/admin/posts/:id/show/edit", Admin.PostLive.Show, :edit
```

Then we need to run database migrations again...

    mix ecto.migrate

and now we can fire up our dev server again

    iex -S mix phx.server

and go to http://localhost:4000/admin/posts and play with the new pages a bit.
We have now a (very) basic admin UI for generating new blog posts. it is not
very sophisticated but came pretty much for free. Next we need a way to show
all this to the world, so let's look at an index page. I think we used enough
generators for now and do the next few steps my hand.

Let's add a home page, we have one auto-generated but want to replace it with a
live_view one that shows a list of blog posts. To do that we add a new file
called `lib/blog_web/live/index.ex` and add the following code:

```elixir
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
```
and we need to update our router with the following:

```diff
-    get "/", PageController, :home
+    live "/", IndexLive, :index
```

To then also display the posts we need a nearly identical view:

```elixir
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
```

and we need to wire that one up in the router as well. With those changes in
place we can check the homepage again and should see our test posts.

The next step before we spend all the time making things pretty is pushing it
out into the world, so let's have a quick look at deployment next. There are
plenty of options to get a phoenix project up and running but one of the
quickest i have seen in https://fly.io. So let's quickly add that, it is free
for the basic app we have so let's dive in.

First we need the `flyctl` installed, so let's head over to fly.io and check
their docs on it: https://fly.io/docs/hands-on/install-flyctl/

Phoenix has it's own docs around deploying to fly.io here:
https://hexdocs.pm/phoenix/1.7.0-rc.1/fly.html

The commands we need to run once we have a working `flyctl` are:

    fly auth signup

or if you already have a fly.io account then a `flyctl auth login`  should be
enough. Next we need to generate an elixir release, configure docker, configure
fly.io and prepare the code base for the deploy, so let's do that:

    fly launch

but don't deploy just yet. stop at:

    ? Would you like to deploy now? No
    
Although fly.io feels like magic it does have some issues with running sqlite
out of the box. I did run into a few fun errors but to shorten things, here is
a fantastic summary of what goes wrong:
https://gist.github.com/mcrumm/98059439c673be7e0484589162a54a01

Let's fix our setup, first edit `fly.toml`:

```diff
-[deploy]
-  release_command = "/app/bin/migrate"

[env]
+ DATABASE_PATH = "./blog.db"
```
and then we need to edit our `lib/blog/application.ex`

```diff
  def start(_type, _args) do
+    # Run migrations
+    Blog.Release.migrate()
```

With that in place we should be able to run the deploy with

    fly deploy

after that you should be able to find the URL to your page in the debug output
of `flyctl` and you can watch the logs with `flyctl logs`.

Congrats, you have the bare bones of a new blog online, i hope you hack around
on it and maybe we can build on top of it in a future meetup :)

