defmodule Ucat.UI do
  @fg_color 0x000000
  @bg_color 0xFFFFFF

  @anim %{
    idle: {0, 4},
    idle2: {1, 4},
    clean: {2, 4},
    clean2: {3, 4},
    movement: {4, 8},
    movement2: {5, 8},
    sleep: {6, 4},
    paw: {7, 6},
    jump: {8, 7},
    scared: {9, 8}
  }

  def start_link(args, opts) do
    :avm_scene.start_link(__MODULE__, args, opts)
  end

  def init(opts) do
    :erlang.send_after(1, self(), :show_hello)
    {:ok, %{width: opts[:width], height: opts[:height], cat_state: %{action: :idle}}}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :error, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  def handle_info(:show_hello, %{width: width, height: height} = state) do
    :erlang.send_after(5000, self(), {:show_cat, 0})

    rendered = [
      {:text, 10, 20, :default16px, @fg_color, @bg_color, "Hello."},
      {:rect, 0, 0, width, height, @bg_color}
    ]

    {:noreply, state, [{:push, rendered}]}
  end

  def handle_info({:show_cat, n}, state) do
    %{width: width, height: height, cat_state: cat_state} = state

    {source_x, source_y, next} = get_frame(cat_state.action, n)

    next_cat_state =
      if next == 0 do
        next_state(cat_state)
      else
        cat_state
      end

    new_state =
      %{state | cat_state: next_cat_state}
      |> IO.inspect()

    :erlang.send_after(200, self(), {:show_cat, next})

    {:ok, cat} = get_cat_image("cat.rgba")

    rendered = [
      {:scaled_cropped_image, 0, height - 256, 256, 256, @bg_color, source_x, source_y, 8, 8, [],
       cat},
      {:rect, 0, 0, width, height, @bg_color}
    ]

    {:noreply, new_state, [{:push, rendered}]}
  end

  def handle_info(msg, state) do
    :erlang.display({:handle_info, msg})
    {:noreply, state}
  end

  defp next_state(state) do
    case state do
      %{awakeness: awakeness} = state when awakeness < 10 ->
        %{
          state
          | action: :sleep,
            awakeness: awakeness + 1
        }

      %{action: :sleep, awakeness: awakeness} when awakeness > 90 ->
        %{
          state
          | action: :idle
        }

      %{action: :sleep, awakeness: awakeness, cleanliness: cleanliness} ->
        %{
          state
          | action: :sleep,
            cleanliness: cleanliness - 1,
            awakeness: awakeness + 1
        }

      %{action: :idle, cleanliness: cleanliness, awakeness: awakeness} when cleanliness < 10 ->
        %{
          action: :clean,
          cleanliness: cleanliness,
          awakeness: awakeness - 1
        }

      %{action: :idle, cleanliness: cleanliness, awakeness: awakeness} ->
        %{
          action: :idle,
          cleanliness: cleanliness - 10,
          awakeness: awakeness - 1
        }

      %{action: :clean, cleanliness: cleanliness, awakeness: awakeness} when cleanliness > 90 ->
        %{
          action: :idle,
          cleanliness: cleanliness,
          awakeness: awakeness - 1
        }

      %{action: :clean, cleanliness: cleanliness, awakeness: awakeness} ->
        %{
          action: :clean,
          cleanliness: cleanliness + 10,
          awakeness: awakeness - 2
        }

      _ ->
        %{
          action: :idle,
          cleanliness: 100,
          awakeness: 100
        }
    end
  end

  defp get_frame(action, current) do
    {index, frames} = Map.fetch!(@anim, action)
    {current * 32, index * 32, rem(current + 1, frames)}
  end

  defp get_cat_image(icon_name) do
    case :atomvm.read_priv(:ucat, icon_name) do
      bin when is_binary(bin) -> {:ok, {:rgba8888, 256, 320, bin}}
      :undefined -> {:error, :no_icon}
    end
  end
end
