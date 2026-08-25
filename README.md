# Lambda Runtime Benchmark

## Deploy to AWS
1. Update the account number in `justfile` to the account you'll be deploying to
1. Install [just](https://github.com/casey/just)
1. Run `just deploy-all`
1. The invoker function will invoke each lambda every 15 minutes and log the durations.

## Clean up
1. Run `just cleanup` to remove all the infrastructure

## Results

### Round-trip duration when cold starting
|lambda_type   |min |avg |p50 |p99 |max |
|--------------|----|----|----|----|----|
|go            |325 |447 |438 |684 |866 |
|java          |1576|2011|2033|2359|3513|
|java-snapstart|532 |771 |756 |1224|1549|
|llrt          |195 |316 |297 |582 |937 |
|node          |575 |718 |714 |925 |1091|
|node-bundled  |429 |522 |516 |671 |732 |
|python        |436 |601 |581 |987 |1267|
|rust          |234 |309 |296 |541 |659 |

### Round-trip duration when warm
|lambda_type   |min |avg |p50 |p99 |max |
|--------------|----|----|----|----|----|
|go            |11  |17  |17  |32  |269 |
|java          |15  |24  |22  |40  |1904|
|java-snapstart|16  |25  |24  |51  |672 |
|llrt          |11  |18  |18  |33  |400 |
|node          |12  |20  |20  |36  |469 |
|node-bundled  |13  |20  |20  |37  |337 |
|python        |8   |15  |15  |28  |415 |
|rust          |11  |17  |17  |34  |163 |

