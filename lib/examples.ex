defmodule Examples do
  def flattern([]) do
    []
  end

  def flattern([h|t]) do
    flattern(h) ++ flattern(t)
  end

  def flattern(x) do
    [x]
  end

  defp tail_reverse([], r) do
    r
  end

  defp tail_reverse([h|t], r) do
    tail_reverse(t, [h|r])
  end

  def reverse(l) do
    tail_reverse(l, [])
  end

  def head([]) do
    :undefined
  end

  def head([h|_t]) do
    h
  end

  def tail([]) do
    :undefined
  end

  def tail([_h|t]) do
    t
  end

  defp zip_tail([h1|t1], [h2|t2], fun, res) when is_function(fun) and is_list(res) do
    zip_tail(t1, t2, fun, [fun.(h1, h2)|res])
  end

  defp zip_tail([], _, _, res) when is_list(res) do
    res |> reverse
  end

  defp zip_tail(_, [], _, res) when is_list(res) do
    res |> reverse
  end

  def zip(l1, l2, fun \\ &({&1, &2})) do
    zip_tail(l1, l2, fun, [])
  end

  defp gen_seq_tail(initial_value, gen_fun, counter, res) when is_function(gen_fun) and is_integer(counter) and counter > 0 and is_list(res) do
    gen_seq_tail(gen_fun.(initial_value), gen_fun, counter - 1, [initial_value|res])
  end

  defp gen_seq_tail(value, _, 0, res) when is_list(res) do
    [value|res] |> reverse
  end

  def gen_seq(initial_value, gen_fun, counter) when is_function(gen_fun) and is_integer(counter) and counter > 0 do
    gen_seq_tail(initial_value, gen_fun, counter, [])
  end

  def get_nth(_n, []) do
    []
  end

  def get_nth(1, [h|_t]) do
    h
  end

  def get_nth(n, [_h|t]) when n > 0 do
    get_nth(n-1, t)
  end

  def list_coalesce([], l) do
    l
  end

  def list_coalesce(l, _) do
    l
  end

  defp tail_list_length([], l) do
    l
  end

  defp tail_list_length([_h|t], l) do
    tail_list_length(t, l+1)
  end

  def list_length(l) when is_list(l) do
    tail_list_length(l, 0)
  end

  defp tail_list_product(_, _, [], [], _, _value, values) do
    reverse(values)
  end

  defp tail_list_product(pos, len, [h|t], rl, ol, value, values) when is_integer(pos) and is_integer(len) do
    tail_list_product(pos+1, len, get_nth(pos+1, ol), [t|rl], ol, [h|value], values)
  end

  defp tail_list_product(pos, len, [], [rlh|rlt], ol, value, values) when is_integer(pos) and is_integer(len) and is_list(rlh) and is_list(value) and is_list(values) do
    case len === pos - 1 do
      true -> tail_list_product(pos-1, len, rlh, rlt, ol, tail(value), [reverse(value)|values])
      false -> tail_list_product(pos-1, len, rlh, rlt, ol, tail(value), values)
    end
  end

  def list_product(l)do
    tail_list_product(1, list_length(l), head(l), [], l, [], [])
  end

  def fib(f1, f2) do
    f3 = f1 + f2
    {f2, f3}
  end

  def fib_n(f1, f2, n, action, action_value, action_idx) when is_integer(f1) and is_integer(f2) and is_integer(n) and is_function(action) and n > 2 do
    {a_v_1, a_v_i_1} = action.(1, f1, action_value, action_idx)
    {a_v_2, a_v_i_2} = action.(2, f2, a_v_1, a_v_i_1)
    # IO.puts "1: #{f1}"
    # IO.puts "2: #{f2}"
    fib_n_private(f1, f2, n - 2, 3, action, a_v_2, a_v_i_2)
  end

  defp fib_n_private(f1, f2, n, i, action, action_value, action_idx) when n > 0 do
    {^f2, f3} = fib(f1, f2)
    {new_action_value, new_action_idx} = action.(i, f3, action_value, action_idx)
    fib_n_private(f2, f3, n - 1, i + 1, action, new_action_value, new_action_idx)
  end

  defp fib_n_private(f1, f2, 0) do
    :done
  end

  def output_number(i, n, v, p_i) do
    n_str = Integer.to_string(n)
    n_str_len = String.length(n_str)
    #IO.puts "#{i}: #{n_str} : #{n_str_len}"
    if n_str_len != v do
      #IO.puts "------------------------------------"
      diff = i - p_i
      IO.puts "#{diff}"#" :: #{i} <---> #{n_str_len}"
      #IO.puts "------------------------------------"
      diff_idx = i
    else
      diff_idx = p_i
    end
    {n_str_len, diff_idx}
  end

  defp offset_fib_number do
    21
  end

  defp fib_recurring_seq do
    [5,5,5,4,5,5,5,5,4,5,5,5,5,4]
  end

  defp fib_initial_seq do
    [1,6,5,5,4]
  end

  defp sum_tail([h|t], sum) do
    sum_tail(t, h+sum)
  end

  defp sum_tail([], sum) do
    sum
  end

  def sum_list(l) do
    sum_tail(l,0)
  end

  def fib_num_with_length(len) do
    fib_num_with_length_tail(len, 0, fib_initial_seq())
  end

  defp fib_num_with_length_tail(len, res, [h|t]) when len > 0 do
    fib_num_with_length_tail(len - 1, res + h, t)
  end

  defp fib_num_with_length_tail(len, res, []) when len > 0 do
    fib_num_with_length_tail(len, res, fib_recurring_seq())
  end

  defp fib_num_with_length_tail(0, res, _) do
    res
  end

  def foldl([h|t], f) when is_function(f) do
    f.(h)
    foldl(t, f)
  end

  def foldl([], _) do
    :done
  end

  def foldl([h|t], f, acc) do
    foldl(t, f, f.(h, acc))
  end

  def foldl([], _, acc) do
    acc
  end

  def print_list(list) when is_list(list) do
    foldl(list, &IO.puts/1)
  end

  def humanize_sql(sql_text) when is_binary(sql_text) do
    sql_text
    |> String.split([" ", ","])
    |> print_list
  end

  defp fac_tail(n, res) when is_integer(n) and n > 0 do
    fac_tail(n-1, n*res)
  end

  defp fac_tail(0, res) do
    res
  end

  def fac(n) do
    fac_tail(n, 1)
  end

  # defp print_fac_and_sum_of_digits(n) when is_integer(n) do
  #   digits_sum = number_to_list_of_digits(n)
  #   IO.puts "#{String.rjust(left_door, max)}"
  # end

  def fac_info(n) do
    factorial = n |> fac
    sum_of_digits = factorial |> number_to_list_of_digits |> sum_list
    {n, factorial, sum_of_digits}
  end

  #def print_fac_info_list(fac_info_list) when is_list(fac_info_list)

  def print_fac_info_list_raw({max_diff_length, list}) when is_list(list) do
    print_fac_info_list(list, max_diff_length)
  end

  def print_fac_info_list([{n, factorial, _sum_of_digits, _difference}|_t] = list, max_diff_length) when is_list(list) do
    print_fac_info_list(list |> reverse, n |> Integer.to_string |> String.length, factorial |> Integer.to_string |> String.length, max_diff_length)
  end

  def print_fac_info_list([{n, factorial, sum_of_digits, difference}|t] = list, max_num_length, max_fac_length, max_diff_length) when is_list(list) and is_integer(max_num_length) and is_integer(max_fac_length) and is_integer(max_diff_length) do
    print_fac_info(n, factorial, sum_of_digits, difference, max_num_length, max_fac_length, max_diff_length)
    print_fac_info_list(t, max_num_length, max_fac_length, max_diff_length)
  end

  def print_fac_info_list([], _, _, _) do
    :done
  end

  defp print_fac_info(n, factorial, sum_of_digits, difference, max_num_lemgth, max_fac_length, max_diff_length) do
    n_string = n |> Integer.to_string |> String.rjust(max_num_lemgth)
    factorial_string = factorial |> Integer.to_string |> String.rjust(max_fac_length)
    #sum_of_digits = factorial |> number_to_list_of_digits |> sum_list
    difference_string = difference |> Integer.to_string |> String.rjust(max_diff_length)
    IO.puts "#{n_string}: #{factorial_string} #{sum_of_digits} #{difference_string} #{max_diff_length}"
  end

  defp digit_list_tail(0, l) do
    l
  end

  defp digit_list_tail(num, l) when is_integer(num) do
    digit = rem(num, 10)
    digit_list_tail(div(num, 10), [digit|l])
  end

  def number_to_list_of_digits(num) when is_integer(num) and num > 0 do
    digit_list_tail(num, [])
  end

  defp cycle_tail(fun, counter, times) when counter < times do
    fun.(counter)
    cycle_tail(fun, counter+1, times)
  end

  defp cycle_tail(fun, times, times) when is_integer(times) do
    fun.(times)
    :done
  end

  def cycle(fun, times) do
    cycle_tail(fun, 1, times)
  end

  defp generate_tail(counter, times, fun, acc) when counter < times and times > 0 and is_function(fun) do
    generate_tail(counter+1, times, fun, fun.(counter, acc))
  end

  defp generate_tail(times, times, fun, acc) when is_function(fun) do
    fun.(times, acc)
  end

  def generate(times, fun, initial_acc) do
    generate_tail(1, times, fun, initial_acc)
  end

  def accumulate(value, fun, acc) do
    fun.(value, acc)
  end

  def add_fac_info_to_list({n, factorial, sum_of_digits}, []) do
    {sum_of_digits |> Integer.to_string |> String.length, [{n, factorial, sum_of_digits, sum_of_digits}|[]]}
  end

  def add_fac_info_to_list({n, factorial, sum_of_digits}, {max_diff_length, [{_h_n, _h_factorial, h_sum_of_digits, _h_difference}|_t] = list}) do
    difference = sum_of_digits - h_sum_of_digits
    {max_of(difference |> Integer.to_string |> String.length, max_diff_length), [{n, factorial, sum_of_digits, difference}|list]}
  end

  def extract_fac_info_list({_, list}) when is_list(list) do
    list
  end

  def max_of(x, y) when is_integer(x) and is_integer(y) do
    if x > y do
      x
    else
      y
    end
  end

  defp add_offset(list, n) when is_list(list) and is_integer(n) and n > 0 do
    add_offset([0|list], n-1)
  end

  defp add_offset(list, 0) when is_list(list) do
    list
  end

  defp add_lcn_tail([h1|t1], [h2|t2], res) do
    val = h1 + h2
    add_lcn_tail(t1, t2, [val|res])
  end

  defp add_lcn_tail([], [h|t], res) do
    add_lcn_tail([], t, [h|res])
  end

  defp add_lcn_tail([h|t], [], res) do
    add_lcn_tail(t, [], [h|res])
  end

  defp add_lcn_tail([], [], res) do
    res |> reverse |> normalize_lcn |> reverse
  end

  def add_lcn(l1, l2) when is_list(l1) and is_list(l2) do
    add_lcn_tail(l1, l2, [])
  end

  defp sum_lcn_list_tail([hl|tl], []) do
    sum_lcn_list_tail(tl, hl)
  end

  defp sum_lcn_list_tail([hl|tl], res) when is_list(res) do
    sum_lcn_list_tail(tl, add_lcn(hl, res))
  end

  defp sum_lcn_list_tail([], res) when is_list(res) do
    res
  end

  def sum_lcn_list(lcn_list) when is_list(lcn_list) do
    sum_lcn_list_tail(lcn_list, [])
  end

  # defp mul_lcn_tail([hl|tl], [], offset, res) when is_list(hl) do
  #   mul_lcn_tail(tl, hl, offset, res)
  # end

  defp mul_lcn_tail([h|t], list, offset, res_list) when is_list(list) and is_integer(offset) do
    mul_lcn_tail(t, list, offset+1, multiply(h, list) |> add_offset(offset) |> add_lcn(res_list))
  end

  defp mul_lcn_tail([], _, _, res_list) when is_list(res_list) do
    res_list
  end

  def mul_lcn(l1, l2) when is_list(l1) and is_list(l2) do
    mul_lcn_tail(l1, l2, 0, [])
  end

  defp num_to_lcn_tail(num, lcn) when is_integer(num) and num > 0 and is_list(lcn) do
    num_to_lcn_tail(div(num, 10), [rem(num, 10)|lcn])
  end

  defp num_to_lcn_tail(0, lcn) when is_list(lcn) do
    lcn
  end

  def num_to_lcn(num) when is_integer(num) do
    num_to_lcn_tail(num, [])
  end

  def multiply(digit, list) when is_list(list) do
    multiply_tail(digit, list, [])
  end

  defp multiply_tail(digit, [h|t], res) do
    multiply_tail(digit, t, [digit*h|res])
  end

  defp multiply_tail(_, [], res) do
    res |> reverse |> normalize_lcn |> reverse
  end

  defp normalize_lcn_tail([h|t], transfer_digit, res) do
    new_val = h + transfer_digit
    normalize_lcn_tail(t, div(new_val, 10), [rem(new_val, 10)|res])
  end

  defp normalize_lcn_tail([], 0, res) do
    res
  end

  defp normalize_lcn_tail([], transfer_digit, res) when is_integer(transfer_digit) and transfer_digit > 0 do
    normalize_lcn_tail([], div(transfer_digit, 10), [rem(transfer_digit, 10)|res])
  end

  defp normalize_lcn(list) when is_list(list) do
    normalize_lcn_tail(list, 0, [])
  end

  def fac_lcn(n, fun \\ &(&1)) when is_integer(n) and n > 0 and is_function(fun) do
    fac_lcn_tail(n, [1|[]], fun)
  end

  defp fac_lcn_tail(n, lcn, fun) when is_integer(n) and n > 0 and is_list(lcn) do
    fun.(lcn)
    lcn_string = lcn |> reverse |> lcn_to_string
    IO.puts "#{n} <--> #{lcn_string}"
    fac_lcn_tail(n-1, n |> num_to_lcn |> reverse |> mul_lcn(lcn), fun)
  end

  defp fac_lcn_tail(0, lcn, fun) do
    fun.(lcn)
    lcn_string = lcn |> reverse |> lcn_to_string
    IO.puts "0 <--> #{lcn_string}"
    lcn
  end

  def lcn_to_string(lcn) when is_list(lcn) do
    lcn |> Enum.map(&(&1 |> Integer.to_string)) |> Enum.join
  end
end
