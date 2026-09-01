import gleam/float
import gleam/int
import gleam/list
import granny_life/square.{type Quadrant}
import granny_life/view.{type Color}
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/svg
import lustre/event

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

pub type Message {
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
    color: view.Blue,
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
  Model(
    ..model,
    focus_round: 0,
    generation: model.generation + 1,
    quadrant: square.next_generation(model.quadrant),
  )
}

fn previous_generation(model: Model) -> Model {
  case model.generation {
    gen if gen > 0 -> jump_to_generation(model, model.generation - 1)
    _ -> Model(..model, focus_round: 0)
  }
}

fn jump_to_generation(model: Model, generation: Int) -> Model {
  case generation {
    nth_gen if nth_gen >= 0 -> {
      let quadrant = square.nth_generation_fast(nth_gen)
      Model(..model, focus_round: 0, generation: generation, quadrant: quadrant)
    }
    _ ->
      Model(
        ..model,
        focus_round: 0,
        generation: 0,
        quadrant: square.granny_life_gen_0,
      )
  }
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
    html.div([], [
      html.p([], [
        html.text(
          "If you would like to crochet one of these granny squares, use the ",
        ),
        html.a(
          [
            attribute.href(
              "https://www.ravelry.com/patterns/library/pixie-square",
            ),
          ],
          [html.text("Pixie Square pattern (ravelry)")],
        ),
        html.text(". "),
        html.text(
          "Focus mode can help you keep track of the round you are working.",
        ),
      ]),
    ]),
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
    html.div([], [
      view.granny_square(
        model.quadrant,
        model.focus_mode,
        model.focus_round,
        model.color,
      ),
    ]),
    html.div([attribute.class("color-button-container")], [
      color_select_button(view.Red),
      color_select_button(view.Orange),
      color_select_button(view.Yellow),
      color_select_button(view.Green),
      color_select_button(view.Blue),
      color_select_button(view.Indigo),
      color_select_button(view.Violet),
      color_select_button(view.Pink),
    ]),
    case model.focus_mode {
      True -> focus_navigation(model.focus_round + 1)
      False -> generation_navigation()
    },
    html.div([attribute.class("focus-switch")], [focus_switch(model.focus_mode)]),
    html.div([], [
      html.p([], [
        html.text("This granny square generator is inspired by the work of "),
        html.a([attribute.href("https://mathgrrl.com")], [html.text("mathgrrl")]),
        html.text(" and the "),
        html.a([attribute.href("https://www.grannylifecrochet.com")], [
          html.text("Granny Life Project"),
        ]),
        html.text("."),
      ]),
    ]),
    html.footer([], [
      html.text("Carefully crafted by "),
      html.a([attribute.href("https://brainofdane.com")], [html.text("Dane")]),
      html.text("."),
      html.div([], [
        html.a([attribute.href("https://github.com/dahenson/granny_life")], [
          html.text("source"),
        ]),
      ]),
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
      view.color_class(color),
    ],
    [],
  )
}
