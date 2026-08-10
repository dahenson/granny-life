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
////
//// example:
//// ```gleam
//// current_generation = [
////   [Alive],
////   [Dormant, Dormant],
////   [Dormant, Alive, Dormant],
////   ..rest
//// ]
//// ```

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
    Dormant,
  ],
]

pub type Cell {
  Alive
  Dormant
}

/// Returns the nth generation from the current generation
pub fn nth_generation(current_gen: List(List(Cell)), n: Int) {
  case n {
    n if n <= 0 -> current_gen
    n -> current_gen |> next_generation() |> nth_generation(n - 1)
  }
}

/// Returns the next generation from the current generation
pub fn next_generation(current_gen: List(List(Cell))) -> List(List(Cell)) {
  create_next_gen(current_gen, [])
}

fn create_next_gen(
  current_gen: List(List(Cell)),
  next: List(List(Cell)),
) -> List(List(Cell)) {
  case current_gen {
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
    [first, second] ->
      create_next_gen([], [
        next_gen_row(first, second, create_final_row(second)),
        ..next
      ])
    _ -> list.reverse(next)
  }
}

fn next_gen_row(
  first: List(Cell),
  second: List(Cell),
  third: List(Cell),
) -> List(Cell) {
  let lower_neighbor_count =
    first
    |> expand_first_row(second)
    |> list.window_by_2()
    |> list.map(fn(x) { number_of_neighbors(x) })

  let upper_neighbor_count =
    third
    |> list.window_by_2()
    |> list.map(fn(x) { number_of_neighbors(x) })

  let total_neighbor_list =
    list.map2(lower_neighbor_count, upper_neighbor_count, fn(a, b) { a + b })

  list.map2(second, total_neighbor_list, fn(cell, neighbors) {
    case cell, neighbors {
      Alive, 0 -> Alive
      Dormant, 1 -> Alive
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

fn create_final_row(current_row: List(Cell)) {
  let length = list.length(current_row) + 2
  list.repeat(Dormant, times: length)
}
