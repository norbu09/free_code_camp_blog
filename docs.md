mix archive.install hex phx_new 1.7.0-rc.2 

mix help phx.new

mix phx.new blog --database sqlite3

...
Fetch and install dependencies? [Yn] y
...

cd blog
mix ecto.create
iex -S mix phx.server
