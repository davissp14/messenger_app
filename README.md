# SecureMessenger


## Installing Dependencies

* Install Brew: `/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`
* Install Npm: `brew install npm`
* Install Node: `brea install node`
* Install Elixir: ` brew update && brew install elixir`
* Install Hex:  `mix local.hex`
* Install Phoenix: `$ mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez`
* Install Redis: `brew install redis`
* Install Postgresql: `brew install postgresql`


## Pull Down Repository
 `git clone https://github.com/davissp14/messenger_app.git`

## Starting Redis / Postgresql
Open up two new tabs.
 * In one tab run:  `redis-server` 
 * In the other run: `initdb /usr/local/var/postgres/`  # You only need to run this the first time you set this up.
 * Then run `posgres -D /usr/local/var/postgres/`
 * Connect to postgres and create the secure_messenger_dev database.
 * `psql postgres`
 * `create database secure_messenger_dev;` then push ctrl-d to exit. 

## Starting the App

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
