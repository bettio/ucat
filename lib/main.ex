defmodule Main do
  _sharp_display_opts = [
    width: 400,
    height: 240,
    compat: "sharp_memory_lcd",
    cs: 5,
    en: 27
  ]

  _ili_display_opts = [
    width: 320,
    height: 240,
    compat: "ili934x",
    reset: 18,
    cs: 22,
    dc: 21,
    backlight: 5
  ]

  sdl_display_opts = [
    width: 320,
    height: 240
  ]

  @display_driver sdl_display_opts
  @spi_display_driver? false

  def start() do
    :erlang.display("Hello.")

    display_opts =
      if @spi_display_driver? do
        spi_opts = %{
          bus_config: %{sclk: 19, mosi: 23, miso: 25, peripheral: "spi2"},
          # bus_config: %{mosi: 25, sclk: 26, peripheral: "spi2"}, sharp
          device_config: %{}
        }

        [{:spi_host, :spi.open(spi_opts)} | @display_driver]
      else
        @display_driver
      end

    case :erlang.open_port({:spawn, "display"}, display_opts) do
      display when is_port(display) ->
        {:ok, _ui} = Ucat.UI.start_link(display_opts, display_server: {:port, display})

      _ ->
        :io.format("Failed to open display")
    end

    recv_loop()
  end

  defp recv_loop() do
    receive do
      any -> :erlang.display({:got, any})
    end

    recv_loop()
  end
end
