import aoc_2025_day_1
import gleeunit

const rots = [
  "L68",
  "L30",
  "R48",
  "L5",
  "R60",
  "L55",
  "L1",
  "L99",
  "R14",
  "L82",
]

pub fn main() -> Nil {
  gleeunit.main()
}

fn count_rots(rots: List(String)) -> Int {
  rots
  |> aoc_2025_day_1.rots_to_ints()
  |> aoc_2025_day_1.count_0_rots(0, 0)
}

pub fn l1_is_not_0_test() -> Nil {
  assert ["L1"] |> count_rots() == 0
}

pub fn l1_and_r1_equals_0() -> Nil {
  assert ["L1", "R1"] |> count_rots() == 1

  assert ["R1", "L1"] |> count_rots() == 1
}

pub fn repeated_direction_test() -> Nil {
  assert ["R50", "R50"] |> count_rots() == 1

  assert ["L50", "L50"] |> count_rots() == 1
}

pub fn wrap_around_simple_test() -> Nil {
  assert ["R102", "L2"] |> count_rots() == 1
}

pub fn wrap_around_advanced_test() -> Nil {
  assert ["L863", "L37"] |> count_rots() == 1
}

pub fn example_input_test() {
  assert [50, ..rots |> aoc_2025_day_1.rots_to_ints()]
    |> aoc_2025_day_1.count_0_rots(0, 0)
    == 3
}
