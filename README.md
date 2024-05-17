# Lambda Runtime Benchmark

## Deploy to AWS
1. Update the account number in `justfile` to the account you'll be deploying to
1. Install [just](https://github.com/casey/just)
1. Run `just deploy-all`
1. The invoker function will invoke each lambda every 15 minutes and log the durations.


## Clean up
1. Run `just cleanup` to remove all the infrastructure

## Results

### go cold starts
Min: 447ms

Max: 971ms

Avg: 618ms


### node cold starts
Min: 468ms

Max: 703ms

Avg: 563ms


### java-snapstart cold starts
Min: 793ms

Max: 2228ms

Avg: 1109ms


### rust cold starts
Min: 378ms

Max: 767ms

Avg: 526ms


### java cold starts
Min: 1743ms

Max: 2598ms

Avg: 2292ms



### go warm starts
Min: 16ms

Max: 27ms

Avg: 19ms


### node warm starts
Min: 15ms

Max: 29ms

Avg: 19ms


### rust warm starts
Min: 12ms

Max: 40ms

Avg: 16ms


### java warm starts
Min: 16ms

Max: 38ms

Avg: 21ms


### java-snapstart warm starts
Min: 17ms

Max: 43ms

Avg: 23ms
