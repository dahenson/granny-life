import gleam/int
import gleam/list
import granny_life/square.{type Cell, Alive, Dormant}
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/svg
import lustre/event

const cell_width = 10
const half_cell_width = 5
const cell_height = 20

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Model {
  Model(generation: Int, quadrant: List(List(Cell)))
}

fn init(_args) -> Model {
  Model(0, square.granny_life_gen_0)
}

type Message {
  UserClickedNextGen
  UserClickedPreviousGen
  UserClickedResetGen
}

fn update(model: Model, message: Message) -> Model {
  case message {
    UserClickedNextGen -> Model(model.generation + 1, square.next_generation(model.quadrant))
    UserClickedResetGen -> Model(0, square.granny_life_gen_0)
    UserClickedPreviousGen -> previous_generation(model)
  }
}

fn previous_generation(model: Model) -> Model {
  case model.generation {
    gen if gen > 0 -> Model(gen - 1, square.nth_generation(square.granny_life_gen_0, gen - 1))
    _ -> model
  }
}

fn view(model: Model) -> Element(Message) {
  html.main([], [
    html.h1([], [html.text("Rule 6, Generation " <> int.to_string(model.generation))]),
    html.div([], [granny_square(model)]),
    html.button([event.on_click(UserClickedPreviousGen)], [html.text("Previous")]),
    html.button([event.on_click(UserClickedResetGen)], [html.text("Reset")]),
    html.button([event.on_click(UserClickedNextGen)], [html.text("Next")])
  ])
}

fn granny_square(model: Model) -> Element(Message) {
  html.svg([
    attribute.style("background-color", "darkblue"),
    attribute.attribute("viewBox", "-140 -140 280 280"),
    attribute.width(550),
    attribute.height(550),
  ], list.flatten(list.index_map(model.quadrant, quadrant_row)))
}

fn quadrant_row(row: List(Cell), row_index: Int) -> List(Element(Message)) {
  list.index_fold(row, [], fn(acc, cell, cell_index) { prepend_cell_rects(cell, cell_index, row_index, acc) })
}

fn prepend_cell_rects(cell, cell_index, row_index, acc) {
  let row_position = row_index * cell_width
  let col_position = cell_index * cell_height

  let nsx = col_position - row_position - half_cell_width
  let nsy = row_position - half_cell_width
  let ewx = row_position - half_cell_width
  let ewy = row_position - col_position - half_cell_width

  [
    cell_rect(cell, nsx, nsy, NorthSouth, cell_width),
    cell_rect(cell, ewx, ewy, EastWest, cell_width),
    cell_rect(cell, -nsx - cell_width, -nsy - cell_height, NorthSouth, cell_width),
    cell_rect(cell, -ewx - cell_height, -ewy - cell_width, EastWest, cell_width),
    ..acc
  ]
}

type Direction {
  NorthSouth
  EastWest
}

fn cell_rect(cell: Cell, x: Int, y: Int, direction: Direction, dim: Int) -> Element(Message) {
  svg.rect([
    attribute.attribute("x", int.to_string(x)),
    attribute.attribute("y", int.to_string(y)),
    attribute.attribute("rx", "3"),
    attribute.attribute("ry", "3"),
    attribute.attribute("stroke", "darkblue"),
    attribute.attribute("fill", cell_color(cell)),
    attribute.class(cell_class(cell)),
    ..cell_attributes(cell, dim, direction)])
}

fn cell_attributes(cell: Cell, dim: Int, direction: Direction) -> List(attribute.Attribute(Message)) {
  case direction {
    NorthSouth ->
      [
        attribute.width(dim),
        attribute.height(dim * 2),
      ]
    EastWest ->
      [
        attribute.width(dim * 2),
        attribute.height(dim),
      ]
  }
}

fn cell_color(cell: Cell) -> String {
  case cell {
    Alive -> "white"
    Dormant -> "blue"
  }
}

fn cell_class(cell: Cell) -> String {
  case cell {
    Alive -> "alive"
    Dormant -> "dormant"
  }
}
