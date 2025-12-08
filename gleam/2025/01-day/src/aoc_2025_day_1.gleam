import argv
import file_streams/file_stream.{type FileStream as FS}
import file_streams/file_stream_error.{type FileStreamError as FSE}
import file_streams/text_encoding
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string

pub fn main() {
  case argv.load().arguments {
    [] -> io.println("File argument required")
    [file, ..] ->
      case read_0_rots_from(file) {
        Ok(r) ->
          io.println(
            "Number of rotations ending in 0: " <> r |> int.to_string(),
          )
        Error(e) ->
          io.println("Error reading file: " <> file_stream_error.describe(e))
      }
  }
}

/// Read file of dial rotations line-by-line and count how many times 
/// a rotation ends on the 0 position, starting from the 50 position
pub fn read_0_rots_from(path: String) -> Result(Int, FSE) {
  file_stream.open_read_text(path, text_encoding.Latin1)
  |> result.map(read_0_rots(_, 50, 0))
  |> result.flatten
}

fn read_0_rots(file: FS, sum: Int, rot0count: Int) -> Result(Int, FSE) {
  case file |> file_stream.read_line {
    Error(e) if e == file_stream_error.Eof -> Ok(rot0count)
    Error(e) -> Error(e)
    Ok(line) -> {
      let sum =
        sum + { line |> rot_to_int |> option.unwrap(0) } |> wrap_between_0_100

      read_0_rots(file, sum, case sum {
        0 -> rot0count + 1
        _ -> rot0count
      })
    }
  }
}

/// The dial moves between 0 and 100. Multiple whole rotations have to be
/// wrapped: R863 -> 63, L863 -> -863 -> -63 -> 37
fn wrap_between_0_100(i: Int) -> Int {
  case i {
    i if i % 100 == 0 -> 0
    i if i >= 100 -> i % 100
    i if i < 0 -> i % 100 + 100
    i -> i
  }
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

pub fn rots_to_ints(rots: List(String)) -> List(Int) {
  rots
  |> list.map(rot_to_int)
  |> option.values()
}

pub fn count_0_rots(rots: List(Int), sum, count) -> Int {
  case rots {
    [first, ..rest] ->
      case wrap_between_0_100(sum + first) {
        0 -> count_0_rots(rest, 0, count + 1)
        newsum -> count_0_rots(rest, newsum, count)
      }
    _ -> count
  }
}
