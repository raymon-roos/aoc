import file_streams/file_stream.{type FileStream as FS}
import file_streams/file_stream_error.{type FileStreamError as FSE}
import gleam/result

/// Generic signature of a function that does some calculation on a line in a 
/// file. First argument is the line, second is some co-value, third is some
/// accumulator value. Returns a tuple of the resulting co-value and
/// accumulator after processing the line.
pub type LineProcessor(t) =
  fn(String, t, t) -> #(t, t)

/// Read file, and execute given line_processor for each line.
/// Conceptually, this is like "folding" the lines of a file
/// into a starting value, while maintaining some state in carry.
pub fn read_from(
  path: String,
  value: t,
  carry: t,
  line_processor: LineProcessor(t),
) -> Result(t, FSE) {
  let fs = path |> file_stream.open_read
  let res =
    fs
    |> result.map(file_processor(_, value, carry, line_processor))
    |> result.flatten

  case fs |> result.try(file_stream.close) {
    Ok(_) -> res
    Error(e) -> Error(e)
  }
}

fn file_processor(
  file: FS,
  value: t,
  carry: t,
  line_processor: LineProcessor(t),
) -> Result(t, FSE) {
  case file |> file_stream.read_line {
    Error(e) if e == file_stream_error.Eof -> Ok(value)
    Error(e) -> Error(e)
    Ok(line) -> {
      let #(v, c) = line_processor(line, value, carry)
      file_processor(file, v, c, line_processor)
    }
  }
}
