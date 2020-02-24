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
    DiamondSquare(
      30, 11,
      recover iso [as F64: 1; 0.5; 0.1; 0] end,
      (Time.nanos(), 64),
      1
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
        _env.out.write(n.string().trim(0, 1))
      end
      _env.out.write("\n")
    end
