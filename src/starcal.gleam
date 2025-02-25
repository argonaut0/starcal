import gleam/io
import gleam/list
import gleam/regex
import gleam/string

pub fn main() {
  io.println("Hello from starcal!")
}

/// https://datatracker.ietf.org/doc/html/rfc5545#section-3.1
/// 75 octets including crlf
//const max_line_length = 75

pub fn to_content_lines(input: String) {
  input
  |> string.trim()
  |> string.split(on: "\r\n")
  |> unfold_lines()
  |> list.reverse()
}

fn unfold_lines(lines: List(String)) {
  do_unfold_lines([], lines)
}

fn do_unfold_lines(acc: List(String), lines: List(String)) {
  case lines {
    [] -> []
    [first] -> [first, ..acc]
    // At least 2 lines available, try to unfold
    [first, second, ..rest] ->
      case second {
        " " <> folded -> do_unfold_lines(acc, [first <> folded, ..rest])
        _ -> do_unfold_lines([first, ..acc], [second, ..rest])
      }
  }
}

//fn parse_lines(lines: List(String), acc: abc) {
//  case lines {
//    // If we can just process this
//    [] -> Empty
//    [l1] -> parse_line(l1, [])
//    // If there's at least 2 lines we need to try to unfold them first
//    [l1, l2, ..ls] ->
//      case l2 {
//        " " <> rest -> parse_lines([l1 <> rest, ..ls], acc)
//        _ -> parse_lines([l2, ..ls], parse_line(l1, acc))
//      }
//  }
//}

// Param represents an iCal Property Parameter
pub type Param {
  Param(name: String, values: List(String))
}

pub type Property {
  Property(name: String, params: List(Param), value: String)
}

pub fn generate_content_line(prop: Property) -> String {
  [
    prop.name,
    ";",
    ..prop.params
    |> list.map(generate_param_string)
    |> list.intersperse(";")
  ]
  |> string.concat
  |> string.append(":")
  |> string.append(prop.value)
}

/// len(param.values) must be >= 1
fn generate_param_string(param: Param) -> String {
  let s =
    param.values
    |> string.join("\",\"")
    |> string.append("\"")
  string.append("\"", s)
}

// split_content_line takes a content line and returns the #(name, params, value)
pub fn parse_content_line(line: String) -> Result(Property, Nil) {
  do_parse_content_line("", string.to_graphemes(line))
}

fn do_parse_content_line(acc: String, gs: List(String)) -> Result(Property, Nil) {
  case gs {
    // Params start
    [";", ..gs] if acc != "" -> parse_param(Property(acc, [], ""), gs)
    // Value starts
    [":", ..gs] if acc != "" ->
      case valid_name(acc) {
        True -> Ok(Property(acc, [], string.concat(gs)))
        False -> Error(Nil)
      }
    // Keep reading Name
    [g, ..gs] -> do_parse_content_line(string.append(acc, g), gs)
    _ -> Error(Nil)
  }
}

fn parse_param(prop: Property, gs: List(String)) {
  do_parse_params_name(prop, "", gs)
}

fn do_parse_params_name(
  prop: Property,
  name: String,
  gs: List(String),
) -> Result(Property, Nil) {
  case gs {
    ["=", ..gs] if name != "" ->
      case valid_name(name) {
        True -> parse_param_value(prop, Param(name, []), gs)
        False -> Error(Nil)
      }
    [g, ..gs] -> do_parse_params_name(prop, string.append(name, g), gs)
    _ -> Error(Nil)
  }
}

fn parse_param_value(prop: Property, param: Param, gs: List(String)) {
  case gs {
    ["\"", ..gs] ->
      parse_param_value_quoted(prop, Param(param.name, param.values), "", gs)
    _ -> parse_param_value_safe(prop, Param(param.name, param.values), "", gs)
  }
}

fn parse_param_value_quoted(
  prop: Property,
  param: Param,
  value: String,
  gs: List(String),
) {
  case gs {
    ["\"", ":", ..gs] ->
      Ok(Property(
        prop.name,
        [
          Param(param.name, [value, ..param.values] |> list.reverse),
          ..prop.params
        ]
          |> list.reverse,
        string.concat(gs),
      ))
    ["\"", ";", ..gs] ->
      parse_param(
        Property(
          prop.name,
          [
            Param(param.name, [value, ..param.values] |> list.reverse),
            ..prop.params
          ],
          "",
        ),
        gs,
      )
    ["\"", ",", ..gs] ->
      parse_param_value(prop, Param(param.name, [value, ..param.values]), gs)
    [g, ..gs] ->
      parse_param_value_quoted(prop, param, string.append(value, g), gs)
    _ -> Error(Nil)
  }
}

fn parse_param_value_safe(
  prop: Property,
  param: Param,
  value: String,
  gs: List(String),
) {
  case gs {
    [":", ..gs] ->
      Ok(Property(
        prop.name,
        [
          Param(param.name, [value, ..param.values] |> list.reverse),
          ..prop.params
        ]
          |> list.reverse,
        string.concat(gs),
      ))
    [";", ..gs] ->
      parse_param(
        Property(
          prop.name,
          [
            Param(param.name, [value, ..param.values] |> list.reverse),
            ..prop.params
          ],
          "",
        ),
        gs,
      )
    [",", ..gs] ->
      parse_param_value(prop, Param(param.name, [value, ..param.values]), gs)
    [g, ..gs] ->
      parse_param_value_safe(prop, param, string.append(value, g), gs)
    _ -> Error(Nil)
  }
}

fn valid_name(t: String) {
  let assert Ok(re) = regex.from_string("^[A-Z0-9]+$")
  regex.check(re, t)
}

pub fn index_off(s: String, g: String) {
  do_index_of(s, g, 0)
}

fn do_index_of(s: String, g: String, acc: Int) {
  case string.pop_grapheme(s) {
    Error(Nil) -> Error(Nil)
    Ok(#(first, _)) if first == g -> Ok(acc)
    Ok(#(_, rest)) -> do_index_of(rest, g, acc + 1)
  }
}
