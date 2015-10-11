defmodule LogHelper do
  def capture(fileName, regex) do
    fileName |> File.open!([:utf8]) |> IO.stream(:line) |> Stream.filter(&(Regex.match?(regex, &1))) |> Stream.flat_map(&(Regex.scan(regex, &1))) |> Enum.to_list
  end

  def read_tail(filename, tail_size_in_kb) when is_binary(filename) and is_integer(tail_size_in_kb) and tail_size_in_kb > 0 do
    {:ok, filehandle} = filename |> :file.open([:read])
    %File.Stat{size: size_in_bytes} = File.stat!(filename)
    size_in_Kb = size_in_bytes / 1024
    cond do
      tail_size_in_kb < size_in_Kb ->
        {:ok, _} = :file.position(filehandle, {:eof, tail_size_in_kb * 1024})
      true ->
        :ok
    end
    extname = filename |> Path.extname
    outfile_handle = filename |> Path.rootname(extname)
    |> out_file_name |> File.open!([:write])
    filehandle |> IO.stream(4096) |> Enum.each(&IO.write(outfile_handle, &1))
    outfile_handle |> File.close
    filehandle |> File.close
  end

  defp out_file_name(filename, suffix \\ "_trunc") do
    extname = filename |> Path.extname
    rootname = filename |> Path.rootname(extname)
    rootname <> suffix <> extname
  end

  def process_file_part(caller_pid, filename, _position, 0, _file_size, processor) do
    send(caller_pid, processor.(filename |> File.open!([:read, :utf8]) |> IO.read(:all)))
  end

  def process_file_part(caller_pid, filename, position, chunk_size, file_size, processor) do
    {:ok, filehandle} = filename |> :file.open([:read, {:encoding, :utf8}])
    {:ok, offset} = filehandle |> :file.position({:bof, position})
    case IO.read(filehandle, min(chunk_size, file_size - offset)) do
      {:error, reason} -> send caller_pid, {:error, reason}
      :eof -> send caller_pid, :eof
      data -> send caller_pid, processor.(data |> to_string)
    end
  end

  defp spawn_n_workers(filename, n, processor) when is_integer(n) and n > 0 and is_function(processor) do
    %File.Stat{size: size} = filename |> File.stat!
    chunk_size = div size, n
    cond do
      chunk_size > 0 ->
        for i <- 1..n do
          spawn_link(__MODULE__, :process_file_part, [self(), filename, (i-1) * chunk_size, chunk_size, size, processor])
        end
        n
      true ->
        spawn_link(__MODULE__, :process_file_part, [self(), filename, 0, size, size, processor])
        1
    end
  end

  defp reduce(0, acc) do
    acc
  end

  defp reduce(n, acc) when is_integer(n) and n > 0 do
    receive do
      {:error, reason} ->
        IO.puts "An error occured: #{reason}"
        reduce(n-1, acc)
      :eof ->
        IO.puts "EOF reached"
        reduce(n-1, acc)
      data ->
        reduce(n-1, [data|acc])
    end
  end

  def copy_chunk_calc_md5_hash(data) do
    hash = data |> :crypto.md5
    {:ok, sio} = StringIO.open(~s"Text:\r\n#{data}\r\n")
    sio |> IO.puts("Hash:")
    sio |> IO.inspect(hash, binaries: :as_binaries)
    result = sio |> StringIO.contents |> Tuple.to_list |> Enum.join
    sio |> StringIO.close
    {_a, _b, c} = :erlang.now()
    outfilehandle = Path.join([System.tmp_dir(),  "new" <> Integer.to_string(c) <> ".txt"])
    |> File.open!([:write, :utf8])
    outfilehandle |> IO.puts(result)
    #outfilehandle |> IO.inspect(hash, binaries: :as_binaries)
    #outfilehandle |> IO.puts("\n")
    outfilehandle |> File.close
    result
  end

  def process_text_file_in_chunks(filename, number_of_chunks, processor, acc_initial_value)
  when is_binary(filename) and is_function(processor) and is_integer(number_of_chunks) and number_of_chunks > 0 do
    start_time = :os.timestamp()
    number_of_workers = spawn_n_workers(filename, number_of_chunks, processor)
    IO.puts "#{number_of_workers} workers has been spawned"
    results = reduce(number_of_workers, acc_initial_value)
    reduce_finish = :os.timestamp()
    reduce_duration = :timer.now_diff(reduce_finish, start_time)
    IO.puts "Map/reduce took #{reduce_duration} microseconds"
    outfilehandle = filename |> out_file_name("_processed") |> File.open!([:write, :utf8])
    sum = results |> Enum.sum
    results |> Stream.map(&(to_string(&1) <> "\r\n")) |> Enum.each(&IO.puts(outfilehandle, &1))
    outfilehandle |> IO.puts "Sum == #{sum}"
    outfilehandle |> File.close
    finish_time = :os.timestamp()
    duration = :timer.now_diff(finish_time, start_time)
    IO.puts "Done, Sir!"
    IO.puts "Full task took #{duration} microseconds"
  end

  def word_count(text) do
    Regex.scan(~r/(\w+)/, text) |> Enum.count
  end
end
