# Lambda Runtime Benchmark

## Deploy to AWS
1. Update the account number in `justfile` to the account you'll be deploying to
1. Install [just](https://github.com/casey/just)
1. Run `just deploy-all`
1. The invoker function will invoke each lambda every 15 minutes and log the durations.


## Clean up
1. Run `just cleanup` to remove all the infrastructure

## Results

### node cold starts
Min: 468ms

Avg: 565ms

p50: 568ms

p90: 620ms

Max: 703ms


### java-snapstart cold starts
Min: 793ms

Avg: 1105ms

p50: 933ms

p90: 1712ms

Max: 2228ms


### rust cold starts
Min: 378ms

Avg: 524ms

p50: 494ms

p90: 689ms

Max: 767ms


### go cold starts
Min: 447ms

Avg: 615ms

p50: 606ms

p90: 735ms

Max: 971ms


### java cold starts
Min: 1743ms

Avg: 2294ms

p50: 2323ms

p90: 2498ms

Max: 2598ms



### go warm starts
Min: 16ms

Avg: 19ms

p50: 19ms

p90: 22ms

Max: 50ms


### rust warm starts
Min: 12ms

Avg: 16ms

p50: 16ms

p90: 19ms

Max: 56ms


### java-snapstart warm starts
Min: 17ms

Avg: 22ms

p50: 21ms

p90: 28ms

Max: 312ms


### java warm starts
Min: 16ms

Avg: 21ms

p50: 20ms

p90: 26ms

Max: 61ms


### node warm starts
Min: 15ms

Avg: 20ms

p50: 19ms

p90: 26ms

Max: 57ms
