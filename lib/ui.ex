defmodule Ucat.UI do
  def start_link(args, opts) do
    :avm_scene.start_link(__MODULE__, args, opts)
  end

  def init(opts) do
    :erlang.send_after(1, self(), :show_hello)
    {:ok, opts}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :error, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  def handle_info(:show_hello, state) do
    rendered = [
      {:text, 10, 20, :default16px, 0x000000, 0xFFFFFF, "Hello."},
      {:rect, 0, 0, state[:width], state[:height], 0xFFFFFF}
    ]

    {:noreply, state, [{:push, rendered}]}
  end

  def handle_info(msg, state) do
    :erlang.display({:handle_info, msg})
    {:noreply, state}
  end
end
