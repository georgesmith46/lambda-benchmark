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
|go            |383 |502 |495 |703 |861 |
|java          |1924|2372|2355|2766|3292|
|java-snapstart|575 |873 |866 |1087|1129|
|llrt          |169 |374 |364 |661 |739 |
|node          |484 |620 |589 |832 |3468|
|node-bundled  |435 |551 |540 |741 |803 |
|python        |416 |550 |539 |820 |847 |
|rust          |234 |437 |432 |643 |726 |

### Round-trip duration when warm
|lambda_type   |min |avg |p50 |p99 |max |
|--------------|----|----|----|----|----|
|go            |11  |16  |15  |32  |59  |
|java          |14  |22  |20  |43  |1961|
|java-snapstart|15  |22  |21  |46  |65  |
|llrt          |12  |17  |17  |32  |233 |
|node          |12  |21  |19  |54  |498 |
|node-bundled  |13  |20  |19  |41  |324 |
|python        |8   |14  |13  |26  |74  |
|rust          |11  |16  |16  |34  |57  |
