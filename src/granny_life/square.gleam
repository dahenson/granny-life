//// A library for working with generating Granny Life squares. Credit for the
//// cellular automata rules and Granny Life Motif go to Laura Taalman and the
//// Granny Life community.
////
//// # The rules
//// Granny Life squares are generated based on a set of cellular automata
//// rules similar to Conway's Game of Life. These rules are:
//// 1. Alive cells will be alive in the next generation only if they have
////    NO alive neighbors.
//// 2. Dormant cells will be alive in the next generation only if they
////    have JUST ONE alive neighbor.
////
//// This library expects a list of a list of cells. The first list of cells
//// must only contain one cell. Each successive list of cells must contain
//// `n + 1` cells where `n` is the number of cells in the previous row.
//// The final row is implicitly all Dormant, but will be included in the
//// alive percentage if any cells are alive. This aligns with the Granny
//// Life generator.
////
//// example:
//// ```gleam
//// current_generation = [
////   [Alive],
////   [Dormant, Dormant],
////   [Dormant, Alive, Dormant],
////   ..
////   [Alive, Alive, Alive ..]
//// ]
//// ```

import gleam/float
import gleam/int
import gleam/list

/// The first generation of the square Granny Life motif
pub const granny_life_gen_0 = [
  [Alive],
  [Dormant, Dormant],
  [Dormant, Dormant, Dormant],
  [Dormant, Dormant, Dormant, Dormant],
  [Dormant, Dormant, Dormant, Dormant, Dormant],
  [Dormant, Dormant, Dormant, Dormant, Dormant, Dormant],
  [Dormant, Dormant, Dormant, Dormant, Dormant, Dormant, Dormant],
  [Dormant, Dormant, Dormant, Dormant, Dormant, Dormant, Dormant, Dormant],
  [
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
  ],
  [
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
  ],
  [
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
  ],
  [
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
    Dormant,
  ],
  [
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
  ],
]

pub type Cell {
  Alive
  Dormant
}

/// Returns the percentage of cells that are alive in the square. This
/// calculation runs on the quadrant rather than the entire square,
/// so calculations may be slightly different than the original
/// Granny Life generator.
///
/// example:
/// ```gleam
/// assert square.alive_percentage(square.granny_life_gen_0) |> float.round() == 16.0
/// ```
pub fn alive_percentage(generation: List(List(Cell))) -> Float {
  let flattened_rows = list.flatten(generation)
  let total_cells = list.length(flattened_rows)

  let percentage =
    flattened_rows
    |> list.count(fn(cell) { cell == Alive })
    |> int.to_float()
    |> float.divide(int.to_float(total_cells))

  case percentage {
    Ok(result) -> float.multiply(result, 100.0)
    Error(Nil) -> 0.0
  }
}

/// Returns the nth generation from the current generation
pub fn nth_generation(
  current_gen: List(List(Cell)),
  n: Int,
) -> List(List(Cell)) {
  case n {
    n if n <= 0 -> current_gen
    n -> current_gen |> next_generation() |> nth_generation(n - 1)
  }
}

/// Given a proper granny square, this returns the next generation
pub fn next_generation(current_gen: List(List(Cell))) -> List(List(Cell)) {
  create_next_gen(current_gen, [])
}

fn create_next_gen(
  current_gen: List(List(Cell)),
  next: List(List(Cell)),
) -> List(List(Cell)) {
  case current_gen {
    [] -> list.reverse(next)
    [_] -> list.reverse(next)
    [_first, _second] -> list.reverse(next)
    [first, second, last] ->
      create_next_gen([], [last, next_gen_row(first, second, last), ..next])
    [[_first] as first, second, third, ..rest] ->
      create_next_gen([second, third, ..rest], [
        next_gen_row(first, second, third),
        next_gen_row([], first, second),
        ..next
      ])
    [first, second, third, ..rest] ->
      create_next_gen([second, third, ..rest], [
        next_gen_row(first, second, third),
        ..next
      ])
  }
}

fn next_gen_row(
  first: List(Cell),
  second: List(Cell),
  third: List(Cell),
) -> List(Cell) {
  let first_row_neighbor_count =
    first
    |> expand_first_row(second)
    |> list.window_by_2()
    |> list.map(fn(x) { number_of_neighbors(x) })

  let third_row_neighbor_count =
    third
    |> list.window_by_2()
    |> list.map(fn(x) { number_of_neighbors(x) })

  first_row_neighbor_count
  |> list.map2(third_row_neighbor_count, fn(a, b) { a + b })
  |> list.map2(second, fn(cell, neighbors) {
    case cell, neighbors {
      0, Alive -> Alive
      1, Dormant -> Alive
      _, _ -> Dormant
    }
  })
}

fn number_of_neighbors(neighbors: #(Cell, Cell)) -> Int {
  case neighbors {
    #(Alive, Alive) -> 2
    #(Dormant, Dormant) -> 0
    _ -> 1
  }
}

fn expand_first_row(first: List(Cell), second: List(Cell)) -> List(Cell) {
  case second {
    [cell] -> [cell, cell]
    [cell, ..] ->
      first
      |> list.append([cell])
      |> list.prepend(cell)
    _ -> []
  }
}
