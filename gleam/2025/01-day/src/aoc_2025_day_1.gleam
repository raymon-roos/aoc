import argv
import file_streamer
import file_streams/file_stream_error
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string

pub fn main() {
  case argv.load().arguments {
    [] -> io.println("File argument required")
    [file, ..] -> read_rots_from(file) |> io.println()
  }
}

pub fn read_rots_from(file: String) -> String {
  case file_streamer.read_from(file, 0, 50, process_rotation) {
    Ok(r) -> r |> int.to_string()
    Error(e) -> "Error reading file: " <> file_stream_error.describe(e)
  }
}

fn process_rotation(rot: String, count: Int, sum: Int) -> #(Int, Int) {
  let sum = sum + { rot |> rot_to_int |> option.unwrap(0) } |> modulo_100
  let count = case sum {
    0 -> count + 1
    _ -> count
  }
  #(count, sum)
}

/// Transform a rotation of the dial to an int.
/// Counter-clockwise is negative, clockwise is positive.
pub fn rot_to_int(rot: String) -> option.Option(Int) {
  case string.trim(rot) {
    "L" <> n -> int.parse(n) |> result.map(fn(n) { -n })
    "R" <> n -> int.parse(n)
    _ -> Error(Nil)
  }
  |> option.from_result
}

/// With `100` as a fixed divisor, this never errors
fn modulo_100(i: Int) -> Int {
  int.modulo(i, 100) |> result.unwrap(0)
}

pub fn rots_to_ints(rots: List(String)) -> List(Int) {
  rots
  |> list.map(rot_to_int)
  |> option.values()
}

pub fn count_0_rots(rots: List(Int), sum, count) -> Int {
  case rots {
    [first, ..rest] ->
      case modulo_100(sum + first) {
        0 -> count_0_rots(rest, 0, count + 1)
        newsum -> count_0_rots(rest, newsum, count)
      }
    _ -> count
  }
}
