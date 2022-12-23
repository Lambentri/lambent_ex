# LambentEx

A Reimplementation of Lambent Aether 4, in Elixir

## Information

### New Features

- Device implementation is 100x more robust in device discovery on-net
- ~Devices can be virtually grouped~
- Individual Machine Brightness Controls
- ~Links can target groups~ 

### Device Support

- ESP8266-WS2812-I2S
- ##### TODO
- Home-Assistant Singles/Strips

### Built-in Machines

- Solid (RGB/HSV)
- Rainbow (Cycling/Solid)
- Chaser (Single, Multi)
- ##### TODO
- Growth
- Rocker
- Scapes
- Twinkles
- GSI Receiver
- FFT Receiver
- Hyperion Receiver
- Apollo Receiver


## Running
```
docker pull lambentri/lambentex
docker run --net=host -d --restart always --mount type=bind,source"$(pwd)"/lex_metadata,target=/opt/app/lex_metadata lambentri/lambentex 
```

Then load host:4000 in your web browser

## Development

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
