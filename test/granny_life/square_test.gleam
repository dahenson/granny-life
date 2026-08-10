import gleeunit
import granny_life/square.{Alive, Dormant}

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn zeroth_generation_test() {
  let gen_0 = [
    [Alive],
    [Dormant, Dormant],
    [Dormant, Dormant, Dormant],
    [Dormant, Dormant, Dormant, Dormant],
  ]

  assert square.nth_generation(gen_0, 0)
    == [
      [Alive],
      [Dormant, Dormant],
      [Dormant, Dormant, Dormant],
      [Dormant, Dormant, Dormant, Dormant],
    ]
}

pub fn first_generation_test() {
  let gen_0 = [
    [Alive],
    [Dormant, Dormant],
    [Dormant, Dormant, Dormant],
    [Dormant, Dormant, Dormant, Dormant],
  ]

  assert square.nth_generation(gen_0, 1)
    == [
      [Dormant],
      [Alive, Alive],
      [Dormant, Dormant, Dormant],
      [Dormant, Dormant, Dormant, Dormant],
    ]
}

pub fn third_generation_test() {
  let gen_0 = [
    [Alive],
    [Dormant, Dormant],
    [Dormant, Dormant, Dormant],
    [Dormant, Dormant, Dormant, Dormant],
  ]

  assert square.nth_generation(gen_0, 3)
    == [
      [Dormant],
      [Alive, Alive],
      [Dormant, Dormant, Dormant],
      [Alive, Alive, Alive, Alive],
    ]
}

pub fn next_generation_test() {
  let gen_0 = [
    [Alive],
    [Dormant, Dormant],
    [Dormant, Dormant, Dormant],
    [Dormant, Dormant, Dormant, Dormant],
  ]

  let gen_1 = square.next_generation(gen_0)

  assert gen_1
    == [
      [Dormant],
      [Alive, Alive],
      [Dormant, Dormant, Dormant],
      [Dormant, Dormant, Dormant, Dormant],
    ]

  let gen_2 = square.next_generation(gen_1)

  assert gen_2
    == [
      [Dormant],
      [Dormant, Dormant],
      [Alive, Dormant, Alive],
      [Dormant, Dormant, Dormant, Dormant],
    ]

  let gen_3 = square.next_generation(gen_2)

  assert gen_3
    == [
      [Dormant],
      [Alive, Alive],
      [Dormant, Dormant, Dormant],
      [Alive, Alive, Alive, Alive],
    ]
}
