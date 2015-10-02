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

  defp out_file_name(filename) do
    extname = filename |> Path.extname
    rootname = filename |> Path.rootname(extname)
    rootname ++ "_trunc" ++ extname
  end
end
