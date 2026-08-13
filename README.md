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
| lambda_type    | min  | avg  | p50  | p99  | max  |
|----------------|------|------|------|------|------|
| go             | 385  | 479  | 482  | 574  | 574  |
| java           | 2008 | 2147 | 2163 | 2357 | 2357 |
| java-snapstart | 746  | 909  | 889  | 1170 | 1170 |
| llrt           | 275  | 361  | 336  | 687  | 687  |
| node           | 700  | 786  | 796  | 927  | 927  |
| node-bundled   | 501  | 580  | 582  | 679  | 679  |
| python         | 525  | 691  | 680  | 888  | 888  |
| rust           | 310  | 422  | 430  | 494  | 494  |

### Round-trip duration when warm
| lambda_type    | min | avg | p50 | p99 | max |
|----------------|-----|-----|-----|-----|-----|
| go             | 11  | 16  | 17  | 28  | 50  |
| java           | 16  | 24  | 24  | 46  | 53  |
| java-snapstart | 17  | 27  | 24  | 58  | 850 |
| llrt           | 12  | 17  | 18  | 31  | 40  |
| node           | 14  | 20  | 20  | 51  | 56  |
| node-bundled   | 14  | 21  | 21  | 38  | 52  |
| python         | 9   | 15  | 15  | 31  | 44  |
| rust           | 11  | 17  | 17  | 34  | 46  |
