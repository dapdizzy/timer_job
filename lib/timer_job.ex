defmodule TimerJob do
  use GenServer

  defstruct [:module, :function, :args, :interval, :period, :is_running, :remaining_period, :is_active, :timer_ref, :spawn_on_call]

  # API
  def start_link(module, function, args, interval, period \\ :infinity, spawn_on_call \\ false) do
    TimerJob |> GenServer.start_link(
      %TimerJob
      {
        module: module,
        function: function,
        args: args,
        interval: interval,
        period: period,
        spawn_on_call: spawn_on_call
      })
  end

  def state(server) do
    server |> GenServer.call(:state)
  end

  def update_state(pid, %TimerJob{} = new_state) do
    pid |> GenServer.cast({:update_state, new_state})
  end

  def run(pid) do
    pid |> GenServer.cast(:run)
  end

  def stop(pid) do
    pid |> GenServer.cast(:stop)
  end

  def function_name do

  end

  # Callbacks
  def init() do

  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:update_state, %TimerJob{} = new_state}, old_state) do
    {:noreply, old_state |> Map.merge(new_state, fn _k, v1, v2 -> v2 || v1 end)}
  end

  def handle_cast(:run, %TimerJob{is_running: true} = state) do
    {:noreply, state}
  end

  def handle_cast(:run, %TimerJob{interval: interval, period: period} = state) do
    new_timer_ref =
      if interval |> is_integer and interval > 0 do
        self |> Process.send_after(:activate, interval)
      end
    {:noreply, %{state | is_running: true, timer_ref: new_timer_ref, remaining_period: period}}
  end

  def handle_cast(:stop, state) do
    {:noreply, %{state | is_running: false}}
  end

  def handle_info(:activate, %TimerJob{is_running: false} = state) do
    {:noreply, state}
  end

  # def handle_cast(:activate, %TimerJob{is_active: true, timer_ref: timer_ref} = state) do
  #   new_timer_ref =
  #     case timer_ref |> Process.read_timer do
  #       false ->
  #     end
  # end

  def handle_info(:activate, %TimerJob{
    module: module,
    function: function,
    args: args,
    interval: interval,
    period: period,
    remaining_period: remaining_period,
    is_running: true,
    timer_ref: timer_ref,
    spawn_on_call: spawn_on_call
    } = state) do
    new_timer_ref =
      case timer_ref |> Process.read_timer do
        false ->
          if spawn_on_call do
            spawn module, function, args
          else
            apply module, function, args # treat the called function as a procedure (any return value is ignored)
          end
          if (remaining_period |> is_integer and interval |> is_integer and remaining_period >= interval) or (period == :infinity) do
            self |> Process.send_after(:activate, interval)
          end
        remaining when remaining |> is_integer and remaining > 0 ->
          timer_ref
      end
    {:noreply, %{state | remaining_period: (if new_timer_ref != timer_ref, do: (if period == :infinity, do: :infinity, else: remaining_period - interval), else: remaining_period), is_running: new_timer_ref != nil, is_active: new_timer_ref != nil, timer_ref: new_timer_ref}}
    # apply module, function, args # treat the called function as a procedure (any return value is ignored)
    # if (period |> is_integer and interval |> is_integer and period >= interval) or (period == :infinity) do
    #   self |> Process.send_after(:activate, interval)
    # end
    # {:noreply, %{state | period: (if period == :infinity, do: :infinity, else: period - interval)}}
  end
end
