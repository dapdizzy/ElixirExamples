defmodule Log.Processor do
  use GenServer

  # Server Callback definitions

  def handle_cast({:process, line, processor}, results) when is_binary(line) and is_function(processor) do
    case processor.(line) do
      {:ok, result} -> {:noreply, [result|results]}
      _ -> {:noreply, results}
    end
  end

  def handle_call(:get_results, _from, results) do
    results
  end

  # Client API
  def process_line(server, line, processor) do
    GenServer.cast(server, {:process, line, processor})
  end

  def get_results(server) do
    GenServer.call(server, :get_results)
  end

end
