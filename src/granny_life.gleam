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

  html.main([attribute.class("container mx-auto max-w-xl")], [
    html.h1([attribute.class("m-2 text-3xl")], [
      html.text("Granny Life Motif")
    ]),
    html.div([attribute.class("flex flex-row text-lg")], [
      html.div([
        attribute.class("flex-auto p-2 m-2 rounded-md bg-slate-700")
      ], [html.text("Generation " <> generation)]),
      html.div([
        attribute.class("flex-auto p-2 m-2 rounded-md bg-slate-700")
      ], [html.text(alive_percent <> "% alive")]),
      html.div([
        attribute.class("flex-auto p-2 m-2 rounded-md bg-slate-700")
      ], [html.text("?? color changes")]),
    ]),
    html.div([], [granny_square(model)]),
    html.div([attribute.class("flex flex-row")], [
      button("Previous", UserClickedPreviousGen),
      button("Reset", UserClickedResetGen),
      button("Next", UserClickedNextGen),
    ]),
  ])
}

fn button(text: String, message: Message) -> Element(Message) {
      html.button(
        [
          attribute.class("flex-auto p-2 m-2 border-2 rounded-md bg-sky-500 border-sky-400"),
          event.on_click(message),
        ],
        [
          html.text(text),
        ],
      )
}

fn granny_square(model: Model) -> Element(Message) {
  html.svg(
    [
      attribute.class("granny_square w-full"),
      attribute.attribute("viewBox", "-145 -145 290 290"),
    ],
    list.index_map(model.quadrant, square),
  )
}

fn square(row: List(Cell), row_index: Int) -> Element(Message) {
  svg.g(
    [attribute.class("round-" <> int.to_string(row_index))],
    list.index_fold(row, [], fn(acc, cell, cell_index) {
      prepend_cell_rects(cell, cell_index, row_index, acc)
    }),
  )
}

type CellDirection {
  North
  South
  East
  West
}

fn prepend_cell_rects(cell, cell_index, row_index, acc) {
  let x =
    { cell_index * cell_height } - { row_index * cell_width } - half_cell_width
  let y = {
    row_index * cell_width
  }

  [
    cell_rect(cell, x, y, South),
    cell_rect(cell, x, y, West),
    cell_rect(cell, x, y, East),
    cell_rect(cell, x, y, North),
    ..acc
  ]
}

fn cell_rect(
  cell: Cell,
  x: Int,
  y: Int,
  direction: CellDirection,
) -> Element(Message) {
  svg.rect([
    attribute.attribute("x", int.to_string(x)),
    attribute.attribute("y", int.to_string(y)),
    attribute.attribute("rx", "3"),
    attribute.attribute("ry", "3"),
    attribute.width(cell_width),
    attribute.height(cell_height),
    case cell {
      Alive -> attribute.class("cell alive fill-slate-100 stroke-slate-400")
      Dormant ->
        attribute.class("cell dormant fill-purple-800 stroke-purple-900")
    },
    case direction {
      North -> attribute.attribute("transform", "rotate(180)")
      South -> attribute.attribute("transform", "")
      West -> attribute.attribute("transform", "rotate(90)")
      East -> attribute.attribute("transform", "rotate(270)")
    },
  ])
}
