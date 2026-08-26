import gleam/float
import gleam/int
import gleam/list
import granny_life/square.{type Cell, type Quadrant, Alive, Dormant}
import lustre
import lustre/attribute.{type Attribute}
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

type CellDirection {
  North
  South
  East
  West
}

type Color {
  Red
  Orange
  Yellow
  Green
  Blue
  Indigo
  Violet
  Pink
}

type Message {
  UserClickedNextGen
  UserClickedNextRound
  UserClickedPreviousGen
  UserClickedPreviousRound
  UserClickedResetGen
  UserToggledFocusMode(Bool)
  UserRequestedInvalidGen
  UserRequestedNewGen(Int)
  UserSelectedColor(Color)
}

type Model {
  Model(
    color: Color,
    focus_mode: Bool,
    focus_round: Int,
    generation: Int,
    quadrant: Quadrant,
  )
}

fn init(_args) -> Model {
  Model(
    color: Indigo,
    focus_mode: False,
    focus_round: 0,
    generation: 0,
    quadrant: square.granny_life_gen_0,
  )
}

fn update(model: Model, message: Message) -> Model {
  case message {
    UserClickedNextGen -> next_generation(model)
    UserClickedNextRound -> next_round(model)
    UserClickedResetGen ->
      Model(
        ..model,
        focus_round: 0,
        generation: 0,
        quadrant: square.granny_life_gen_0,
      )
    UserClickedPreviousGen -> previous_generation(model)
    UserClickedPreviousRound -> previous_round(model)
    UserToggledFocusMode(focus) -> Model(..model, focus_mode: focus)
    UserRequestedInvalidGen -> model
    UserRequestedNewGen(generation) -> jump_to_generation(model, generation)
    UserSelectedColor(color) -> Model(..model, color: color)
  }
}

fn next_generation(model: Model) -> Model {
  let generation = model.generation + 1
  let quadrant = square.next_generation(model.quadrant)

  Model(..model, focus_round: 0, generation: generation, quadrant: quadrant)
}

fn previous_generation(model: Model) -> Model {
  case model.generation {
    gen if gen > 0 -> create_previous_generation(model)
    _ -> Model(..model, focus_round: 0)
  }
}

fn create_previous_generation(model: Model) -> Model {
  let generation = model.generation - 1
  let quadrant = square.nth_generation(square.granny_life_gen_0, generation)

  Model(..model, focus_round: 0, generation: generation, quadrant: quadrant)
}

fn jump_to_generation(model: Model, generation: Int) -> Model {
  let quadrant = case generation - model.generation {
    nth_gen if nth_gen >= 0 -> square.nth_generation(model.quadrant, nth_gen)
    _ -> square.nth_generation(square.granny_life_gen_0, generation)
  }

  Model(..model, focus_round: 0, generation: generation, quadrant: quadrant)
}

fn next_round(model: Model) -> Model {
  let max_round = list.length(model.quadrant) - 1

  case model.focus_round {
    focus if focus >= max_round -> model
    focus -> Model(..model, focus_round: focus + 1)
  }
}

fn previous_round(model: Model) -> Model {
  case model.focus_round {
    round if round < 1 -> model
    round -> Model(..model, focus_round: round - 1)
  }
}

fn handle_generation_form_submit(fields: List(#(String, String))) -> Message {
  case fields {
    [] -> UserRequestedInvalidGen
    [#("generation", generation), ..] ->
      case int.parse(generation) {
        Ok(gen) -> UserRequestedNewGen(gen)
        Error(Nil) -> UserRequestedInvalidGen
      }
    [_, ..rest] -> handle_generation_form_submit(rest)
  }
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

  html.main([], [
    html.h1([], [html.text("Granny Life Motif Generator")]),
    html.div([attribute.class("stats")], [
      stat_box("Generation", [
        html.div([attribute.class("content")], [html.text(generation)]),
      ]),
      stat_box("Percent alive", [
        html.div([attribute.class("content")], [
          html.text(alive_percent <> "%"),
        ]),
      ]),
      stat_box("Color changes", [
        html.div([attribute.class("content")], [
          html.text(color_changes),
        ]),
      ]),
    ]),
    html.div([], [granny_square(model)]),
    html.div([attribute.class("color-button-container")], [
      color_select_button(Red),
      color_select_button(Orange),
      color_select_button(Yellow),
      color_select_button(Green),
      color_select_button(Blue),
      color_select_button(Indigo),
      color_select_button(Violet),
      color_select_button(Pink),
    ]),
    case model.focus_mode {
      True -> focus_navigation(model.focus_round + 1)
      False -> generation_navigation()
    },
    html.div([attribute.class("focus-switch")], [focus_switch(model.focus_mode)]),
    html.footer([attribute.class("p-2 m-2 text-center text-slate-500")], [
      html.text("Carefully crafted by "),
      html.a([attribute.href("https://brainofdane.com")], [html.text("Dane")]),
    ]),
  ])
}

fn focus_switch(focus_mode: Bool) -> Element(Message) {
  html.button(
    [
      event.on_click(UserToggledFocusMode(!focus_mode)),
      attribute.class("switch"),
      attribute.attribute("type", "button"),
      attribute.role("switch"),
    ],
    [
      html.span([attribute.class("label")], [html.text("Focus")]),
      html.svg(
        [
          attribute.class("toggle"),
          attribute.attribute("viewBox", "0 0 64 32"),
        ],
        [
          svg.rect([
            attribute.class("outer-toggle"),
            attribute.attribute("x", "0"),
            attribute.attribute("y", "0"),
            attribute.attribute("rx", "16"),
            attribute.width(64),
            attribute.height(32),
          ]),
          case focus_mode {
            False ->
              svg.circle([
                attribute.class("inner-toggle off"),
                attribute.attribute("cx", "16"),
                attribute.attribute("cy", "16"),
                attribute.attribute("r", "12"),
                attribute.width(28),
                attribute.height(28),
              ])
            True ->
              svg.circle([
                attribute.class("inner-toggle on"),
                attribute.attribute("cx", "48"),
                attribute.attribute("cy", "16"),
                attribute.attribute("r", "12"),
                attribute.width(28),
                attribute.height(28),
              ])
          },
        ],
      ),
    ],
  )
}

fn focus_navigation(focus_round: Int) -> Element(Message) {
  let round = int.to_string(focus_round)
  html.div([], [
    html.div([attribute.class("focus-nav")], [
      button("Previous", UserClickedPreviousRound),
      stat_box("Crochet round", [
        html.div([attribute.class("content")], [
          html.text(round),
        ]),
      ]),
      button("Next", UserClickedNextRound),
    ]),
  ])
}

fn generation_navigation() -> Element(Message) {
  html.div([], [
    html.div([attribute.class("generation-nav")], [
      button("Previous", UserClickedPreviousGen),
      button("Reset", UserClickedResetGen),
      button("Next", UserClickedNextGen),
    ]),
    html.form(
      [
        event.on_submit(handle_generation_form_submit),
        attribute.class("generation-jump-form"),
        attribute.autocomplete("off"),
      ],
      [
        html.label([attribute.for("generation")], [
          html.text("Generation:"),
        ]),
        html.input([
          attribute.attribute("type", "number"),
          attribute.name("generation"),
          attribute.value(""),
        ]),
        html.button([], [html.text("Go")]),
      ],
    ),
  ])
}

fn stat_box(
  title: String,
  content: List(Element(Message)),
) -> Element(Message) {
  html.div([attribute.class("stat-box")], [
    html.div([attribute.class("title")], [html.text(title)]),
    ..content
  ])
}

fn button(text: String, message: Message) -> Element(Message) {
  html.button([event.on_click(message)], [html.text(text)])
}

fn color_select_button(color: Color) -> Element(Message) {
  html.button(
    [
      attribute.class("color-select-button"),
      event.on_click(UserSelectedColor(color)),
      color_class(color),
    ],
    [],
  )
}

fn granny_square(model: Model) -> Element(Message) {
  html.svg(
    [
      attribute.class("granny_square"),
      attribute.attribute("viewBox", "-140 -140 280 280"),
      color_class(model.color),
    ],
    list.index_map(model.quadrant, fn(row, row_index) {
      case model.focus_mode, row_index {
        True, i if i == model.focus_round ->
          svg.g(
            [
              attribute.class("focus"),
            ],
            list.index_fold(row, [], fn(acc, cell, cell_index) {
              prepend_cell_rects(cell, cell_index, row_index, acc)
            }),
          )
        False, _ ->
          svg.g(
            [
              attribute.class("focus"),
            ],
            list.index_fold(row, [], fn(acc, cell, cell_index) {
              prepend_cell_rects(cell, cell_index, row_index, acc)
            }),
          )
        True, _ ->
          svg.g(
            [
              attribute.class("dim"),
            ],
            list.index_fold(row, [], fn(acc, cell, cell_index) {
              prepend_cell_rects(cell, cell_index, row_index, acc)
            }),
          )
      }
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
  svg.g(
    [
      case direction {
        North -> attribute.attribute("transform", "rotate(180)")
        South -> attribute.attribute("transform", "")
        West -> attribute.attribute("transform", "rotate(90)")
        East -> attribute.attribute("transform", "rotate(270)")
      },
      case cell {
        Alive -> attribute.class("cell alive")
        Dormant -> attribute.class("cell dormant")
      },
    ],
    [
      svg.rect([
        attribute.attribute("x", int.to_string(x)),
        attribute.attribute("y", int.to_string(y)),
        attribute.attribute("rx", "4"),
        attribute.attribute("ry", "4"),
        attribute.width(cell_width),
        attribute.height(cell_height),
      ]),
      svg.line([
        attribute.attribute("x1", int.to_string(x - cell_width + 3)),
        attribute.attribute("y1", int.to_string(y + cell_height - 3)),
        attribute.attribute("x2", int.to_string(x + cell_width * 2 - 3)),
        attribute.attribute("y2", int.to_string(y + cell_height - 3)),
        attribute.attribute("stroke-width", "6"),
        attribute.attribute("stroke-linecap", "round"),
      ]),
    ],
  )
}

fn color_class(color: Color) -> Attribute(Message) {
  case color {
    Red -> attribute.class("red")
    Orange -> attribute.class("orange")
    Yellow -> attribute.class("yellow")
    Green -> attribute.class("green")
    Blue -> attribute.class("blue")
    Indigo -> attribute.class("indigo")
    Violet -> attribute.class("violet")
    Pink -> attribute.class("pink")
  }
}
