defmodule LambentEx.Machines.Library do
  def machines do
    [
      solid: %{
        red: %{machine: LambentEx.Machine.Steps.Solid, args: %{h: 0}, mach_opts: [single: true]},
        blue: %{
          machine: LambentEx.Machine.Steps.Solid,
          args: %{h: 168},
          mach_opts: [single: true]
        },
        green: %{
          machine: LambentEx.Machine.Steps.Solid,
          args: %{h: 84},
          mach_opts: [single: true]
        }
      },
      solidrgb: %{
        wwhite: %{
          machine: LambentEx.Machine.Steps.SolidRGB,
          args: %{r: 255, g: 255, b: 190},
          mach_opts: [single: true]
        },
        sapphire: %{
          desc: "gem",
          machine: LambentEx.Machine.Steps.SolidRGB,
          args: %{r: 0, g: 102, b: 202},
          mach_opts: [single: true]
        },
        ruby: %{
          desc: "gem",
          machine: LambentEx.Machine.Steps.SolidRGB,
          args: %{r: 155, g: 17, b: 30},
          mach_opts: [single: true]
        },
        emerald: %{
          desc: "gem",
          machine: LambentEx.Machine.Steps.SolidRGB,
          args: %{r: 4, g: 93, b: 28},
          mach_opts: [single: true]
        },
        gold: %{
          desc: "gem",
          machine: LambentEx.Machine.Steps.SolidRGB,
          args: %{r: 255, g: 215, b: 0},
          mach_opts: [single: true]
        },
        cafe: %{
          desc: "gem",
          machine: LambentEx.Machine.Steps.SolidRGB,
          args: %{r: 117, g: 86, b: 56},
          mach_opts: [single: true]
        },
        orange: %{
          desc: "lemon",
          machine: LambentEx.Machine.Steps.SolidRGB,
          args: %{r: 255, g: 204, b: 16},
          mach_opts: [single: true]
        },
        plum: %{
          desc: "lemon",
          machine: LambentEx.Machine.Steps.SolidRGB,
          args: %{r: 122, g: 14, b: 190},
          mach_opts: [single: true]
        },
        guava: %{
          desc: "lemon",
          machine: LambentEx.Machine.Steps.SolidRGB,
          args: %{r: 240, g: 122, b: 190},
          mach_opts: [single: true]
        },
        lime: %{
          desc: "lemon",
          machine: LambentEx.Machine.Steps.SolidRGB,
          args: %{r: 8, g: 255, b: 107},
          mach_opts: [single: true]
        },
        lemon: %{
          desc: "lemon",
          machine: LambentEx.Machine.Steps.SolidRGB,
          args: %{r: 243, g: 255, b: 7},
          mach_opts: [single: true]
        }
      },
      chase: %{
        red: %{desc: "flag", machine: LambentEx.Machine.Steps.Chase, args: %{h: 0}},
        blue: %{desc: "flag", machine: LambentEx.Machine.Steps.Chase, args: %{h: 128}},
        green: %{desc: "flag", machine: LambentEx.Machine.Steps.Chase, args: %{h: 84}},
        yellow: %{desc: "flag", machine: LambentEx.Machine.Steps.Chase, args: %{h: 42}},
        pink: %{desc: "flag", machine: LambentEx.Machine.Steps.Chase, args: %{h: 212}},
        purple: %{desc: "flag", machine: LambentEx.Machine.Steps.Chase, args: %{h: 170}}
      },
      # todo the flags
      chasem: %{},
      scape: %{
        vista: %{desc: "map", machine: LambentEx.Machine.Steps.Scape, args: %{h_l: 240, h_h: 120}},
        love: %{desc: "map", machine: LambentEx.Machine.Steps.Scape, args: %{h_l: 230, h_h: 20}},
        ocean: %{desc: "map", machine: LambentEx.Machine.Steps.Scape, args: %{h_l: 90, h_h: 160}},
        forest: %{desc: "map", machine: LambentEx.Machine.Steps.Scape, args: %{h_l: 60, h_h: 90}},
        royal: %{desc: "map", machine: LambentEx.Machine.Steps.Scape, args: %{h_l: 34, h_h: 43}},
        sunny: %{desc: "map", machine: LambentEx.Machine.Steps.Scape, args: %{h_l: 245, h_h: 10}},
        night: %{desc: "map", machine: LambentEx.Machine.Steps.Scape, args: %{h_l: 250, h_h: 20}},
        fire: %{
          desc: "map",
          machine: LambentEx.Machine.Steps.Scape,
          args: %{h_l: 240, h_h: 120, v: 128}
        },
        vapor: %{desc: "map", machine: LambentEx.Machine.Steps.Scape, args: %{h_l: 150, h_h: 220}}
      },
      rocker: %{
        vapor: %{desc: "star", machine: LambentEx.Machine.Steps.Rocker, args: %{h: [136, 245]}},
        halloween: %{desc: "star", machine: LambentEx.Machine.Steps.Rocker, args: %{h: [13, 187]}},
        halloween_2: %{
          desc: "star",
          machine: LambentEx.Machine.Steps.Rocker,
          args: %{h: [13, 187, 85]}
        },
        xmas: %{desc: "star", machine: LambentEx.Machine.Steps.Rocker, args: %{h: [0, 85]}},
        rgb: %{desc: "star", machine: LambentEx.Machine.Steps.Rocker, args: %{h: [0, 85, 171]}},
        cmy: %{desc: "star", machine: LambentEx.Machine.Steps.Rocker, args: %{h: [42, 127, 212]}},
        cmyrgb: %{
          desc: "star",
          machine: LambentEx.Machine.Steps.Rocker,
          args: %{h: [0, 42, 85, 127, 171, 212]}
        }
      },
      # todo port this from LA3
      twinkle: %{},
      rainbow: %{
        regular: %{desc: "futbol", machine: LambentEx.Machine.Steps.Rainbow, args: %{modulo: 255}},
        regular64: %{
          desc: "futbol",
          machine: LambentEx.Machine.Steps.Rainbow,
          args: %{modulo: 64}
        },
        solid: %{
          desc: "futbol",
          machine: LambentEx.Machine.Steps.Rainbow,
          args: %{modulo: 255},
          mach_opts: [single: true]
        },
        solid64: %{
          desc: "futbol",
          machine: LambentEx.Machine.Steps.Rainbow,
          args: %{modulo: 64},
          mach_opts: [single: true]
        }
      },
      firefly: %{
        default: %{desc: "lightbulb", machine: LambentEx.Machine.Steps.Firefly, args: %{h: [52]}},
        others: %{
          desc: "lightbulb",
          machine: LambentEx.Machine.Steps.Firefly,
          args: %{h: [52, 15, 140]}
        }
      },
      growth: %{
        leaves: %{
          desc: "hourglass",
          machine: LambentEx.Machine.Steps.Growth,
          args: %{
            h_g: [90, 98, 94, 95, 90],
            h_d: [
              90,
              95,
              85,
              90,
              80,
              85,
              75,
              80,
              70,
              75,
              65,
              70,
              60,
              65,
              55,
              60,
              50,
              55,
              45,
              50,
              40,
              45,
              35,
              40,
              30,
              35,
              25,
              30,
              20,
              25,
              15,
              20,
              10,
              15,
              5,
              10,
              0
            ]
          }
        }
      }
    ]
  end
end
