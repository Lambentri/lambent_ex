defmodule LambentEx.Utils.Network do
  def decimal_to_binary(str) when is_binary(str) do
    str
    |> String.to_integer()
    |> decimal_to_binary()
  end

  def decimal_to_binary(num) when is_integer(num),
    do: List.to_string(:io_lib.format("~8.2B", [num]))

  def get_netmask({a, b, c, d}) do
    # not great lmao, but hale
    (decimal_to_binary(a) <> decimal_to_binary(b) <> decimal_to_binary(c) <> decimal_to_binary(d))
    |> String.graphemes()
    |> Enum.reduce(0, fn char, acc ->
      if char == "1", do: acc + 1, else: acc
    end)
  end

  # ip is a tuple {10.8.0.4}
  # netmask is a /16
  def get_ip_range(ip, netmask) do
    cond do
      netmask >= 24 ->
        ip |> Kernel.put_elem(3, 0)

      netmask >= 16 ->
        ip |> Kernel.put_elem(3, 0) |> Kernel.put_elem(2, 0)

      netmask >= 8 ->
        ip |> Kernel.put_elem(3, 0) |> Kernel.put_elem(2, 0) |> Kernel.put_elem(1, 0)

      # idk lmao
      true ->
        ip
    end
    |> IP.Subnet.new(netmask)
  end
end
