use "../diamond-square"
use "promises"
use "random"
use "time"

actor Main
  let env: Env
  new create(env': Env) =>
    env = env'
    env.out.print("Ohi!")
    let promise = Promise[DSResult]
    promise.next[None](recover iso DSFulfill(env) end)
    let width = try env.args(1)?.usize()? else 15 end
    let height = try env.args(2)?.usize()? else 15 end
    DiamondSquare(
      width, height,
      recover iso [as F64: 0.05; 0.1; 0.3; 0.3; 0.7; 0.5; 0.2] end,
      (Time.nanos(), 64),
      2
    )(promise)

class DSFulfill is Fulfill[DSResult, None]
  let _env: Env

  new create(env: Env) =>
    _env = env

  fun apply(result: DSResult) =>
    for row in result.values() do
      for cell in row.values() do
        var n = (cell * 10).round() + 5
        if n < 0 then n = 0
        elseif n > 9 then n = 9
        end
        _env.out.write(try [as String: " "; "_"; "-"; "~"; "="; "^"; "ʌ"; "Λ"; "A"; "Å"](n.usize())? else "" end)
      end
      _env.out.write("\n")
    end
