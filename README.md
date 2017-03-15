# Messenger App

First Elixir app! Decided to create a chat app with an experimental snapchat feature that allows you to send messages, images, etc. "off the record".  It's never persisted and only lives in the browser for a short period of time. 

Notice:  I stopped working on this app a while ago... You can only work on a chat app by yourself for so long before it starts becoming sad. 

Example App: https://messengerr.herokuapp.com

## Screenshots

![Alt text](https://dl.dropboxusercontent.com/u/22919770/screen_1.png "Screen 1")

![Alt text](https://dl.dropboxusercontent.com/u/22919770/screen_2.png "Screen 2")


## Installing Dependencies

* Install Brew: `/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`
* Install Npm: `brew install npm`
* Install Node: `brew install node`
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
 * Then run `postgres -D /usr/local/var/postgres/`
 * Connect to postgres and create the secure_messenger_dev database.
 * `psql postgres` or Mac Users can Right Click on postgres folder Services > New Terminal at Folder --- if you have enabled this feature via System Prefs > Keyboard > Shortcuts > Services
 * `create database secure_messenger_dev;` then push ctrl-d to exit. 

## Starting the App

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate` -- If you get `FATAL (invalid_authorization_specification): role "postgres" does not exist` create superuser with command `createuser postgres --superuser`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


