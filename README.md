# BrettProjekt - Backend
[![Travis](https://img.shields.io/travis/dhbw-stginf16a/backend.svg)](https://travis-ci.org/dhbw-stginf16a/backend)

[Doc](https://dhbw-stginf16a.github.io/backend)

## Setup

### Install Elixir

Arch Linux:
`sudo pacman -S elixir`

Ubuntu/Debian Linux:
```bash
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb
sudo apt-get update
sudo apt-get install esl-erlang
sudo apt-get install elixir
```

Windows, MacOS, BSD:
*figure it out yourself :P*

Install Elixir's package manager: hex

`mix local.hex`

Install Phoenix

`mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez`


### Starting
To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix