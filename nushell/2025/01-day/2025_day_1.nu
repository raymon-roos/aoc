#!/usr/bin/env nu

use std/bench 

def main [file: path] {
    match ($file | path type) {
        'file' => (read_rots_from $file),
        _ => (print "file not found"),
    }
}

def read_rots_from [file: path] {
    open $file
    | parse -r '(?P<dir>[RL])(?P<num>\d+)' 
    | count_rots 
    | get count
}

def count_rots []: table -> record {
    reduce --fold {sum: 50, count: 0} {|rot, acc|
        let num = match $rot.dir {
            "R"  => ($rot.num | into int), 
            "L" => (-1 * ($rot.num | into int))
        }

        match (($acc.sum + $num) mod 100) {
            0 => {sum: 0, count: ($acc.count + 1)}
            $sum => {sum: $sum, count: $acc.count}
        }
    }
}
