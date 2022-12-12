defmodule LambentEx.Utils.Color do

  # Int-ify
  defp iiy(v) when is_float(v), do: trunc(v)
  defp iiy(v) when is_binary(v), do: Integer.parse(v)
  defp iiy(v), do: v

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
    i = i |> fmod(6.0) |> trunc

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

  # color generation and expansion functions
  def wrgb([r,g,b], coef \\ 2) do
    Enum.min([r,g,b]) / coef |> iiy
  end

  def wwrgb([r,g,b]) do

  end

  def argb([r,g,b]) do
    w = wrgb([r,g,b])
    a = r - w
    a = if (a > (g - w) * 2) do
      a = (g - w) * 2
    else
      a
    end

    a |> iiy
  end

  def cr, do: [255, 0,0]
  def cg, do: [0, 255, 0]
  def cb, do: [0,0, 255]
  def cc, do: [0, 192, 192]
  def cm, do: [192, 0, 192]
  def cy, do: [192, 192, 0]
  def ck, do: [0,0,0]

  def cre, do: cr |> Stream.cycle |> Enum.take(900)
  def cge, do: cg |> Stream.cycle |> Enum.take(900)
  def cbe, do: cb |> Stream.cycle |> Enum.take(900)
  def cce, do: cc |> Stream.cycle |> Enum.take(900)
  def cme, do: cm |> Stream.cycle |> Enum.take(900)
  def cye, do: cy |> Stream.cycle |> Enum.take(900)
  def cke, do: ck |> Stream.cycle |> Enum.take(900)
end
