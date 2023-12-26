defmodule Main do
  def start() do
    :erlang.display("Hello.")

    spi_opts = %{
      bus_config: %{mosi: 25, sclk: 26, peripheral: "spi2"},
      device_config: %{}
    }

    spi = :spi.open(spi_opts)

    display_opts = [
      width: 400,
      height: 240,
      compat: "sharp_memory_lcd",
      cs: 5,
      en: 27,
      spi_host: spi
    ]

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
