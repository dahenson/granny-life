import gleam/float
import gleam/int
import gleam/list
import granny_life/square.{type Cell, type Quadrant, Alive, Dormant}
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
  Model(generation: Int, quadrant: Quadrant, color: Color)
}

type Message {
  UserClickedNextGen
  UserClickedPreviousGen
  UserClickedResetGen
  UserRequestedInvalidGen
  UserRequestedNewGen(Int)
  UserSelectedColor(Color)
}

type Color {
  Red
  Orange
  Yellow
  Green
  Blue
  Indigo
  Violet
}

type CellDirection {
  North
  South
  East
  West
}

fn init(_args) -> Model {
  let quadrant = square.granny_life_gen_0

  Model(0, quadrant, Blue)
}

fn update(model: Model, message: Message) -> Model {
  case message {
    UserClickedNextGen -> next_generation(model)
    UserClickedResetGen -> init([])
    UserClickedPreviousGen -> previous_generation(model)
    UserRequestedInvalidGen -> model
    UserRequestedNewGen(generation) -> jump_to_generation(model, generation)
    UserSelectedColor(color) -> Model(..model, color: color)
  }
}

fn next_generation(model: Model) -> Model {
  let generation = model.generation + 1
  let quadrant = square.next_generation(model.quadrant)

  Model(..model, generation: generation, quadrant: quadrant)
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

  Model(..model, generation: generation, quadrant: quadrant)
}

fn jump_to_generation(model: Model, generation: Int) -> Model {
  let quadrant = square.nth_generation(square.granny_life_gen_0, generation)

  Model(..model, generation: generation, quadrant: quadrant)
}

fn view(model: Model) -> Element(Message) {
  let generation = int.to_string(model.generation)
  let alive_percent =
    model.quadrant
    |> square.alive_percentage()
    |> float.round()
    |> int.to_string()

  let color_changes =
    model.quadrant |> square.color_changes() |> int.to_string()

  html.main([attribute.class("container mx-auto max-w-lg")], [
    html.h1([attribute.class("m-2 text-3xl")], [html.text("Granny Life Motif")]),
    html.div([], [granny_square(model)]),
    html.div([attribute.class("my-4 flex flex-row gap-2 justify-around")], [
      color_select_button(Red, "bg-red-800"),
      color_select_button(Orange, "bg-orange-800"),
      color_select_button(Yellow, "bg-yellow-800"),
      color_select_button(Green, "bg-green-800"),
      color_select_button(Blue, "bg-blue-800"),
      color_select_button(Indigo, "bg-indigo-800"),
      color_select_button(Violet, "bg-violet-800"),
    ]),
    html.div([attribute.class("flex flex-row text-lg")], [
      stat_box("Generation", [
        html.div([attribute.class("text-center")], [html.text(generation)]),
      ]),
      stat_box("Percent alive", [
        html.div([attribute.class("text-center")], [
          html.text(alive_percent <> "%"),
        ]),
      ]),
      stat_box("Color changes", [
        html.div([attribute.class("text-center")], [
          html.text(color_changes),
        ]),
      ]),
    ]),
    html.div([attribute.class("flex flex-row")], [
      button("Previous", UserClickedPreviousGen),
      button("Reset", UserClickedResetGen),
      button("Next", UserClickedNextGen),
    ]),
    stat_box("Jump to generation", [
      html.form(
        [
          event.on_submit(process_generation_form),
          attribute.class("flex flex-row"),
          attribute.autocomplete("off"),
        ],
        [
          html.input([
            attribute.class("p-2 m-2 w-full rounded-sm border-1"),
            attribute.name("generation"),
          ]),
          html.button(
            [attribute.class("p-2 m-2 rounded-sm bg-sky-500 border-sky-400")],
            [html.text("Go")],
          ),
        ],
      ),
    ]),
    html.footer([attribute.class("p-2 m-2 text-center text-slate-500")], [
      html.text("Carefully crafted by "),
      html.a([attribute.href("https://brainofdane.com")], [html.text("Dane")]),
    ]),
  ])
}

fn stat_box(
  title: String,
  content: List(Element(Message)),
) -> Element(Message) {
  html.div([attribute.class("flex-1 p-2 m-2 rounded-sm bg-slate-700")], [
    html.div([attribute.class("text-xs text-slate-400")], [html.text(title)]),
    ..content
  ])
}

fn button(text: String, message: Message) -> Element(Message) {
  html.button(
    [
      attribute.class(
        "flex-1 p-2 m-2 border-2 rounded-sm bg-sky-500 border-sky-400",
      ),
      event.on_click(message),
    ],
    [
      html.text(text),
    ],
  )
}

fn color_select_button(color: Color, class: String) -> Element(Message) {
  html.button(
    [
      attribute.class("w-8 h-8 rounded-2xl"),
      attribute.class(class),
      event.on_click(UserSelectedColor(color)),
    ],
    [],
  )
}

fn granny_square(model: Model) -> Element(Message) {
  html.svg(
    [
      attribute.class("granny_square"),
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

fn prepend_cell_rects(
  cell: Cell,
  cell_index: Int,
  row_index: Int,
  acc: List(Element(Message)),
) -> List(Element(Message)) {
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
  svg.g([
      case direction {
        North -> attribute.attribute("transform", "rotate(180)")
        South -> attribute.attribute("transform", "")
        West -> attribute.attribute("transform", "rotate(90)")
        East -> attribute.attribute("transform", "rotate(270)")
      },
  ], [
    svg.rect([
      attribute.attribute("x", int.to_string(x)),
      attribute.attribute("y", int.to_string(y)),
      attribute.attribute("rx", "4"),
      attribute.attribute("ry", "4"),
      attribute.width(cell_width),
      attribute.height(cell_height),
      case cell {
        Alive -> attribute.class("cell alive fill-slate-200")
        Dormant -> attribute.class("cell dormant fill-red-900")
      },
    ]),
    svg.line([
      attribute.attribute("x1", int.to_string(x - cell_width + 3)),
      attribute.attribute("y1", int.to_string(y + cell_height - 3)),
      attribute.attribute("x2", int.to_string(x + cell_width * 2 - 3)),
      attribute.attribute("y2", int.to_string(y + cell_height - 3)),
      attribute.attribute("stroke-width", "6"),
      attribute.attribute("stroke-linecap", "round"),
      case cell {
        Alive -> attribute.class("cell alive stroke-slate-100")
        Dormant -> attribute.class("cell dormant stroke-red-800")
      },
    ]),
  ])
}

fn process_generation_form(fields: List(#(String, String))) -> Message {
  case fields {
    [] -> UserRequestedInvalidGen
    [#("generation", generation), ..rest] ->
      case int.parse(generation) {
        Ok(gen) -> UserRequestedNewGen(gen)
        Error(Nil) -> UserRequestedInvalidGen
      }
    [_, ..rest] -> process_generation_form(rest)
  }
}
