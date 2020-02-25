# pony-diamond-square

Tiny library implementing the [diamond-square heightmap generation algorithm](https://en.wikipedia.org/wiki/Diamond-square_algorithm).

## Installation

Include this library in your project config:

```json
{
  "type": "github",
  "repo": "adri326/pony-diamond-square"
}
```

Or add it with `stable add github adri326/pony-diamond-square`

Then include it in your code:

```pony
use "diamond-square"
```

Run `stable fetch` and compile with `stable env ponyc`.

## Usage

This repository contains one (public) actor, `DiamondSquare` and a type, `DSResult`, which aliases `Array[Array[F64] val] val`.
You shall create it with the parameters you want to give it, then run its `apply` behavior with as argument a promise:

```pony
use "diamond-square"

// -- snip --

let promise = Promise[DSResult]
promise.next[None](recover iso FulfillClass end)
DiamondSquare(width, height, weight_array_as_f64, (noise_seed_a, noise_seed_b), multiplier)(promise)
```

