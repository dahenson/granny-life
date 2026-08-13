import gleam/float
import gleeunit
import granny_life/square.{Alive, Dormant}

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn alive_percentage_test() {
  let gen = square.granny_life_gen_0

  let alive_percent =
    gen
    |> square.nth_generation(10)
    |> square.alive_percentage()
    |> float.round()

  assert alive_percent == 32
}

pub fn zeroth_generation_test() {
  let gen_0 = [
    [Alive],
    [Dormant, Dormant],
    [Dormant, Dormant, Dormant],
    [Dormant, Dormant, Dormant, Dormant],
    [Alive, Alive, Alive, Alive, Alive],
  ]

  assert square.nth_generation(gen_0, 0)
    == [
      [Alive],
      [Dormant, Dormant],
      [Dormant, Dormant, Dormant],
      [Dormant, Dormant, Dormant, Dormant],
      [Alive, Alive, Alive, Alive, Alive],
    ]
}

pub fn first_generation_test() {
  let gen_0 = [
    [Alive],
    [Dormant, Dormant],
    [Dormant, Dormant, Dormant],
    [Dormant, Dormant, Dormant, Dormant],
    [Alive, Alive, Alive, Alive, Alive],
  ]

  assert square.nth_generation(gen_0, 1)
    == [
      [Dormant],
      [Alive, Alive],
      [Dormant, Dormant, Dormant],
      [Dormant, Dormant, Dormant, Dormant],
      [Alive, Alive, Alive, Alive, Alive],
    ]
}

pub fn third_generation_test() {
  let gen_0 = [
    [Alive],
    [Dormant, Dormant],
    [Dormant, Dormant, Dormant],
    [Dormant, Dormant, Dormant, Dormant],
    [Alive, Alive, Alive, Alive, Alive],
  ]

  assert square.nth_generation(gen_0, 3)
    == [
      [Dormant],
      [Alive, Alive],
      [Dormant, Dormant, Dormant],
      [Dormant, Dormant, Dormant, Dormant],
      [Alive, Alive, Alive, Alive, Alive],
    ]
}

pub fn next_generation_test() {
  let gen_0 = [
    [Alive],
    [Dormant, Dormant],
    [Dormant, Dormant, Dormant],
    [Dormant, Dormant, Dormant, Dormant],
    [Alive, Alive, Alive, Alive, Alive],
  ]

  let gen_1 = square.next_generation(gen_0)

  assert gen_1
    == [
      [Dormant],
      [Alive, Alive],
      [Dormant, Dormant, Dormant],
      [Dormant, Dormant, Dormant, Dormant],
      [Alive, Alive, Alive, Alive, Alive],
    ]

  let gen_2 = square.next_generation(gen_1)

  assert gen_2
    == [
      [Dormant],
      [Dormant, Dormant],
      [Alive, Dormant, Alive],
      [Dormant, Dormant, Dormant, Dormant],
      [Alive, Alive, Alive, Alive, Alive],
    ]

  let gen_3 = square.next_generation(gen_2)

  assert gen_3
    == [
      [Dormant],
      [Alive, Alive],
      [Dormant, Dormant, Dormant],
      [Dormant, Dormant, Dormant, Dormant],
      [Alive, Alive, Alive, Alive, Alive],
    ]
}
