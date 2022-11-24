defmodule LambentEx.Utils.Color do
  # floating point modulo 🌀💍💍💍
  @spec _fmod(float, float) :: float
  defp _fmod(mod, b) when mod >= b do
    mod = mod - b
    _fmod(mod, b)
  end

  defp _fmod(mod, _b) do
    mod
  end

  @spec fmod(float, float) :: float
  defp fmod(a, b) do
    a = abs(a)
    b = abs(b)
    _fmod(a, b) |> abs
  end

  @spec sys_255_to_1([number]) :: [float]
  defp sys_255_to_1(values), do: values |> Enum.map(&(&1 / 255.0))
  @spec sys_1_to_255([number]) :: [number]
  defp sys_1_to_255(values), do: values |> Enum.map(&(&1 * 255))

  @spec _rgb_to_hsv([float]) :: [float]
  defp _rgb_to_hsv([r, g, b]) do
    maxc = Enum.max([r, g, b])
    minc = Enum.min([r, g, b])

    v = maxc

    if minc == maxc do
      [0.0, 0.0, v]
    else
      mami = maxc - minc
      s = mami / maxc
      rc = (maxc - r) / mami
      gc = (maxc - g) / mami
      bc = (maxc - b) / maxc - minc

      h =
        cond do
          r == maxc -> bc - gc
          g == maxc -> 2.0 + rc - bc
          true -> 4.0 + gc - rc
        end

      h = (h / 6.0) |> fmod(1.0)
      [h, s, v]
    end
  end

  @spec _hsv_to_rgb([float]) :: [float]
  defp _hsv_to_rgb([_h, s, v]) when s == 0.0, do: [v, v, v]

  defp _hsv_to_rgb([h, s, v]) do
    i = (h * 6.0) |> trunc
    f = h * 6.0 - i
    p = v * (1.0 - s)
    q = v * (1.0 - s * f)
    t = v * (1.0 - s * (1.0 - f))
    i = i |> fmod(6.0)

    case i do
      0 -> [v, t, p]
      1 -> [q, v, p]
      2 -> [p, v, t]
      3 -> [p, q, v]
      4 -> [t, p, v]
      5 -> [v, p, q]
    end
  end

  @spec rgb2hsv([float]) :: [float]
  def rgb2hsv(rgb) do
    rgb
    |> sys_255_to_1
    |> _rgb_to_hsv
    |> sys_1_to_255
  end

  @spec hsv2rgb([float]) :: [float]
  def hsv2rgb(hsv) do
    hsv
    |> sys_255_to_1
    |> _hsv_to_rgb
    |> sys_1_to_255
  end
end
