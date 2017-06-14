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

Install dependencies:

`mix deps.get`

`mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez`


### Starting
Start your Phoenix server:

`iex -S mix phx.server`

The API is now served at [`localhost:4000`](http://localhost:4000).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Source: https://github.com/phoenixframework/phoenix
