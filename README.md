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

The API is now served at `ws://localhost:4000/socket`.

## Testing

`mix test`

## Deployment
To deploy this app using Apache you can start it as usual and set up a reverse proxy with Apache.

First set up a virtual host by creating a file in `/etc/apache2/sites-available/` with this content:
```apache config
<VirtualHost *:80>
    ProxyPass / ws://0.0.0.0:4000/
    ProxyPassReverse / ws://0.0.0.0:4000/

    ServerName example.org
</VirtualHost>
```

This routes all traffic to port 80 to the local port 4000 using the websockets protocol.

To enable this file run `sudo a2enmod yourfile.conf`

You also need to enable some Apache modules:
```
sudo a2enmod proxy_wstunnel
```

At least that module - if it doesn't work install the others mentioned [here](https://www.digitalocean.com/community/tutorials/how-to-use-apache-http-server-as-reverse-proxy-using-mod_proxy-extension) and add them to the list.

To make apache aware of all changes restart it: `sudo systemctl apache2 restart`

Now the API should be reachable at ws://example.org/socket

## Learn more about the tools

- Language: [Elixir](https://elixir-lang.org/)
- Web Framwork: [Phoenix](http://www.phoenixframework.org/)
- Code style checking: [Credo](https://github.com/rrrene/credo)
- JSON: [Poison](https://github.com/devinus/poison)
- Documentation: [ExDoc](https://github.com/elixir-lang/ex_doc)
- Unit Testing: [ExUnit](https://hexdocs.pm/ex_unit/ExUnit.html)
