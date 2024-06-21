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
|lambda_type   |min |avg |p50 |p90 |max |
|--------------|----|----|----|----|----|
|go            |314 |408 |369 |557 |609 |
|java          |2213|2496|2507|2658|3032|
|java-snapstart|842 |984 |944 |1083|1196|
|llrt          |227 |326 |304 |390 |617 |
|node          |454 |544 |542 |593 |700 |
|python        |451 |524 |514 |573 |642 |
|rust          |380 |498 |504 |577 |679 |

### Round-trip duration when warm
|lambda_type   |min |avg |p50 |p90 |max |
|--------------|----|----|----|----|----|
|go            |12  |15  |15  |18  |37  |
|java          |15  |20  |20  |25  |44  |
|java-snapstart|16  |21  |20  |26  |62  |
|llrt          |13  |16  |16  |20  |43  |
|node          |14  |19  |18  |23  |47  |
|python        |9   |13  |13  |16  |32  |
|rust          |12  |16  |15  |19  |59  |
