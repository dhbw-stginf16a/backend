# BrettProjekt - Backend
[![Travis](https://img.shields.io/travis/dhbw-stginf16a/backend.svg)](https://travis-ci.org/dhbw-stginf16a/backend)

[Documentation](https://dhbw-stginf16a.github.io/backend)

## Installation

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

Take a look at the [official instructions](https://elixir-lang.org/install.html)

### Install Elixir's package manager: hex

`mix local.hex`

### Install dependencies:

`mix deps.get`

`mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez`


## Running
Start your Phoenix server:

`iex -S mix phx.server`

The API is now served at [`localhost:4000`](http://localhost:4000).

## Testing

`mix test`

## Learn more about the tools

- Language: [Elixir](https://elixir-lang.org/)
- Web Framwork: [Phoenix](http://www.phoenixframework.org/)
- Code style checking: [Credo](https://github.com/rrrene/credo)
- JSON: [Poison](https://github.com/devinus/poison)
- Documentation: [ExDoc](https://github.com/elixir-lang/ex_doc)
- Unit Testing: [ExUnit](https://hexdocs.pm/ex_unit/ExUnit.html)
