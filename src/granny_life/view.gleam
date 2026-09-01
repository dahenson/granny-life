import gleam/int
import gleam/list
import granny_life/square.{type Cell, type Quadrant, Alive, Dormant}
import lustre/attribute
import lustre/element/html
import lustre/element/svg

const cell_height = 20

const cell_width = 10

const half_cell_width = 5

pub type Color {
  Red
  Orange
  Yellow
  Green
  Blue
  Indigo
  Violet
  Pink
}

type CellDirection {
  North
  South
  East
  West
}

pub fn granny_square(
  quadrant: Quadrant,
  focus_mode: Bool,
  focus_round: Int,
  color: Color,
) {
  html.svg(
    [
      attribute.class("granny_square"),
      attribute.attribute("viewBox", "-140 -140 280 280"),
      color_class(color),
    ],
    list.index_map(quadrant, fn(row, row_index) {
      case focus_mode, row_index {
        True, i if i == focus_round ->
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

fn prepend_cell_rects(cell: Cell, cell_index: Int, row_index: Int, acc) {
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

fn cell_rect(cell: Cell, x: Int, y: Int, direction: CellDirection) {
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

pub fn color_class(color: Color) {
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
