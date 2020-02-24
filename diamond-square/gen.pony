use "collections"
use "promises"
use "random"
use "debug"

type DSResult is Array[Array[F64] val] val

actor DiamondSquare
  let weights: Array[F64] val
  let multiplier: F64
  let width: USize
  let height: USize
  let _seed_x: U64
  let _seed_y: U64

  new create(width': USize, height': USize, weights': Array[F64] iso, seed: ((U64, U64) | U64 | None), multiplier': F64 = 1, aliasing': Bool = false) =>
    width = width'
    height = height'
    weights = consume weights'
    multiplier = multiplier'
    match seed
    | (let x: U64, let y: U64) => _seed_x = x; _seed_y = y
    | let x: U64 => _seed_x = x; _seed_y = 0
    else _seed_x = 0; _seed_y = 0
    end

  be apply(callback: Promise[DSResult]) =>
    try
      callback((recover val
        _DiamondSquareWorker(
          width,
          height,
          weights,
          XorOshiro128StarStar(_seed_x, _seed_y),
          multiplier
        )()?
      end))
    else None end // TODO

class _DiamondSquareWorker
  let tiles: Array[Array[F64] iso] iso
  let width: USize
  let height: USize
  let rng: Random ref
  let weights: Array[F64] val
  let multiplier: F64

  new ref create(width': USize, height': USize, weights': Array[F64] val, rng': Random ref, multiplier': F64) =>
    width = width'
    height = height'
    tiles = recover iso Array[Array[F64] iso](height) end
    for y in Range[USize](0, height) do
      tiles.push(recover iso Array[F64].init(0, width) end)
    end
    rng = rng'
    weights = weights'
    multiplier = multiplier'

  fun ref apply(): Array[Array[F64] val] ref? =>
    step(0, (0, 0), (width - 1, height - 1))?
    let res = Array[Array[F64] val](height)
    for n in Range[USize](0, height) do
      res.push(recover val tiles.pop()?.clone() end)
    end
    res

  fun ref step(
    depth: USize,
    from: (USize, USize),
    to: (USize, USize)
  )? =>
    let width' = to._1 - from._1
    let height' = to._2 - from._2
    let center_horizontal = (from._1 + to._1) / 2
    let center_vertical = (from._2 + to._2) / 2

    var top: F64 = _get(from._1, from._2)
    var bottom: F64 = _get(to._1, to._2)
    var left: F64 = top
    var right: F64 = bottom

    if width' > 1 then
      top = sample(
        width'.f64(),
        (center_horizontal, from._2),
        (_get(from._1, from._2) + _get(to._1, from._2)) / 2
      )?
      bottom = sample(
        width'.f64(),
        (center_horizontal, to._2),
        (_get(from._1, to._2) + _get(to._1, to._2)) / 2
      )?
    end
    if height' > 1 then
      left = sample(
        height'.f64(),
        (from._1, center_vertical),
        (_get(from._1, from._2) + _get(from._1, to._2)) / 2
      )?
      right = sample(
        height'.f64(),
        (to._1, center_vertical),
        (_get(to._1, from._2) + _get(to._1, to._2)) / 2
      )?
    end
    if ((width' > 1) and (height' > 1)) or (width' > 2) or (height' > 2) then
      // Debug("Hi!")
      sample(
        ((width' * width') + (height' * height')).f64().sqrt(),
        (center_horizontal, center_vertical),
        (top + bottom + left + right) / 4
      )?
      step(depth + 1, from, (center_horizontal, center_vertical))?
      step(depth + 1, (center_horizontal, from._2), (to._1, center_vertical))?
      step(depth + 1, (from._1, center_vertical), (center_horizontal, to._2))?
      step(depth + 1, (center_horizontal, center_vertical), to)?
    end

  fun ref sample(
    dist: F64,
    position: (USize, USize),
    mean: F64
  ): F64? =>
    let weight = try // assume(dist > 1)
        let int = dist.floor()
        let rem = dist - int
        if rem == 0 then
          weights(rem.usize())?
        else
          (weights(rem.usize())? * (1 - rem)) + (weights(rem.usize() + 1)? * rem)
        end
      else
        0
      end * multiplier
    let bias = ((rng.real() * 2) - 1) * weight // returns a number between [-weight; weight]
    // Debug(weight.string() + " " + bias.string())
    tiles(position._2)?(position._1)? = mean + bias
    mean + bias

  fun ref _get(x: USize, y: USize): F64 =>
    if \unlikely\ (x >= width) or (y >= height) then
      0
    else
      try
        tiles(y)?(x)?
      else 0 end
    end
