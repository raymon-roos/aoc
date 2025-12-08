use std/bench 

let loop = {
    mut sum = 50;
    mut count = 0;

    for $rot in (open input.txt | parse -r '(?P<dir>[RL])(?P<num>[0-9]+)') {
        $sum = ($sum + (match $rot.dir {
            "R"  => ($rot.num | into int), 
            "L" => (-1 * ($rot.num | into int))
        })) mod 100

        if $sum == 0 {
            $count += 1
        }
    }
    print $count
}

let reduce = {
    open input.txt
    | parse -r '(?P<dir>[RL])(?P<num>[0-9]+)' 
    | reduce --fold {sum: 50, count: 0} {|rot, acc|
        let $sum = ($acc.sum + (match $rot.dir {
            "R"  => ($rot.num | into int), 
            "L" => (-1 * ($rot.num | into int))
        })) mod 100

        match $sum {
            0 => {sum: 0, count: ($acc.count + 1)}
            _ => {sum: $sum, count: $acc.count}
        }
    }
    | print
}

bench -n 20 $loop $reduce | rotate --ccw keys loop reduce
