import gleam/float
import gleam/int
import gleam/list
import granny_life/square.{type Cell, Alive, Dormant}
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/svg
import lustre/event

const cell_height = 20

const cell_width = 10

const half_cell_width = 5

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Model {
  Model(generation: Int, quadrant: List(List(Cell)), alive_percent: Float)
}

fn init(_args) -> Model {
  let quadrant = square.granny_life_gen_0

  Model(0, quadrant, square.alive_percentage(quadrant))
}

type Message {
  UserClickedNextGen
  UserClickedPreviousGen
  UserClickedResetGen
}

fn update(model: Model, message: Message) -> Model {
  case message {
    UserClickedNextGen -> next_generation(model)
    UserClickedResetGen -> init([])
    UserClickedPreviousGen -> previous_generation(model)
  }
}

fn next_generation(model: Model) -> Model {
  let generation = model.generation + 1
  let quadrant = square.next_generation(model.quadrant)

  Model(generation, quadrant, square.alive_percentage(quadrant))
}

fn previous_generation(model: Model) -> Model {
  case model.generation {
    gen if gen > 0 -> create_previous_generation(model)
    _ -> model
  }
}

fn create_previous_generation(model: Model) -> Model {
  let generation = model.generation - 1
  let quadrant = square.nth_generation(square.granny_life_gen_0, generation)

  Model(generation, quadrant, square.alive_percentage(quadrant))
}

fn view(model: Model) -> Element(Message) {
  let generation = int.to_string(model.generation)
  let alive_percent = model.alive_percent |> float.round() |> int.to_string()

  html.main([attribute.class("container")], [
    html.h1([], [
      html.text("Rule 6, Generation " <> generation),
    ]),
    html.div([], [granny_square(model)]),
    html.div([], [html.text(alive_percent <> "% alive")]),
    html.div([], [
      html.button([event.on_click(UserClickedPreviousGen)], [
        html.text("Previous"),
      ]),
      html.button([event.on_click(UserClickedResetGen)], [html.text("Reset")]),
      html.button([event.on_click(UserClickedNextGen)], [html.text("Next")]),
    ]),
  ])
}

fn granny_square(model: Model) -> Element(Message) {
  html.svg(
    [
      attribute.class("granny_square"),
      attribute.attribute("viewBox", "-145 -145 290 290"),
      attribute.width(550),
      attribute.height(550),
    ],
    model.quadrant |> list.index_map(full_square) |> list.flatten(),
  )
}

fn full_square(row: List(Cell), row_index: Int) -> List(Element(Message)) {
  list.index_fold(row, [], fn(acc, cell, cell_index) {
    prepend_cell_rects(cell, cell_index, row_index, acc)
  })
}

fn prepend_cell_rects(cell, cell_index, row_index, acc) {
  let row_position = row_index * cell_width
  let col_position = cell_index * cell_height

  let nsx = col_position - row_position - half_cell_width
  let nsy = row_position - half_cell_width
  let ewx = row_position - half_cell_width
  let ewy = row_position - col_position - half_cell_width

  [
    cell_rect(cell, nsx, nsy + 5, NorthSouth, cell_width),
    cell_rect(cell, ewx + 5, ewy, EastWest, cell_width),
    cell_rect(
      cell,
      -nsx - cell_width,
      -nsy - cell_height - 5,
      NorthSouth,
      cell_width,
    ),
    cell_rect(
      cell,
      -ewx - cell_height - 5,
      -ewy - cell_width,
      EastWest,
      cell_width,
    ),
    ..acc
  ]
}

type Direction {
  NorthSouth
  EastWest
}

fn cell_rect(
  cell: Cell,
  x: Int,
  y: Int,
  direction: Direction,
  dim: Int,
) -> Element(Message) {
  svg.rect([
    attribute.attribute("x", int.to_string(x)),
    attribute.attribute("y", int.to_string(y)),
    attribute.attribute("rx", "3"),
    attribute.attribute("ry", "3"),
    attribute.classes(cell_class(cell)),
    ..cell_attributes(dim, direction)
  ])
}

fn cell_attributes(
  dim: Int,
  direction: Direction,
) -> List(attribute.Attribute(Message)) {
  case direction {
    NorthSouth -> [
      attribute.width(dim),
      attribute.height(dim * 2),
    ]
    EastWest -> [
      attribute.width(dim * 2),
      attribute.height(dim),
    ]
  }
}

fn cell_class(cell: Cell) -> List(#(String, Bool)) {
  case cell {
    Alive -> [#("cell", True), #("alive", True)]
    Dormant -> [#("cell", True), #("dormant", True)]
  }
}
