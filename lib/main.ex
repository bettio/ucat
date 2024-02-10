defmodule Main do
  oled_display_opts = [
    width: 128,
    height: 64,
    compatible: "solomon-systech,ssd1306",
    reset: 16,
    invert: true
  ]

  _sharp_display_opts = [
    width: 400,
    height: 240,
    compatible: "sharp,memory-lcd",
    cs: 5,
    en: 27
  ]

  _acep_display_opts = [
    width: 320,
    height: 240,
    compatible: "waveshare,5in65-acep-7c",
    reset: 33,
    busy: 23,
    cs: 13,
    dc: 18
  ]

  _ili_display_opts = [
    width: 320,
    height: 240,
    compatible: "ilitek,ili9341",
    reset: 18,
    cs: 22,
    dc: 21,
    backlight: 5,
    backlight_active: :low,
    backlight_enabled: true,
    rotation: 1,
    enable_tft_invon: false
  ]

  sdl_display_opts = [
    width: 320,
    height: 240
  ]

  @display_driver oled_display_opts
  @spi_display_driver? false
  @i2c_display_driver? true

  def start() do
    :erlang.display("Hello.")

    display_opts =
      if @spi_display_driver? do
        spi_opts = %{
          bus_config: %{sclk: 19, mosi: 23, miso: 25, peripheral: "spi2"},
          # bus_config: %{mosi: 25, sclk: 26, peripheral: "spi2"}, # sharp
          # bus_config: %{mosi: 14, sclk: 32, peripheral: "spi2"}, # acep
          device_config: %{}
        }

        [{:spi_host, :spi.open(spi_opts)} | @display_driver]
      else
        if @i2c_display_driver? do
          i2c_opts = [
            sda: 4,
            scl: 15,
            clock_speed_hz: 1_000_000,
            peripheral: "i2c0"
          ]

          [{:i2c_host, :i2c.open(i2c_opts)} | @display_driver]
        else
          @display_driver
        end
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
