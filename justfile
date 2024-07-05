account := "516028615317"
memory := "1024"

deploy-db:
    aws dynamodb create-table --table-name Music --attribute-definitions AttributeName=Artist,AttributeType=S AttributeName=SongTitle,AttributeType=S --key-schema AttributeName=Artist,KeyType=HASH AttributeName=SongTitle,KeyType=RANGE --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 --region us-east-1 --no-cli-pager

add-data:
    aws dynamodb put-item --table-name Music --item '{"Artist": {"S": "No One You Know"}, "SongTitle": {"S": "Call Me Today"}, "AlbumTitle": {"S": "Somewhat Famous"}}' --return-consumed-capacity TOTAL --region us-east-1 --no-cli-pager

deploy-iam:
    aws iam create-role --role-name lambda-ex --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": [ "lambda.amazonaws.com", "scheduler.amazonaws.com" ]}, "Action": "sts:AssumeRole"}]}' --no-cli-pager
    aws iam attach-role-policy --role-name lambda-ex --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole --no-cli-pager
    aws iam attach-role-policy --role-name lambda-ex --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess --no-cli-pager
    aws iam attach-role-policy --role-name lambda-ex --policy-arn arn:aws:iam::aws:policy/AWSLambda_FullAccess --no-cli-pager
        
deploy-java:
    gradle buildZip -p functions/java
    aws lambda create-function --function-name lambda-benchmark-java --zip-file fileb://./functions/java/build/distributions/java.zip --handler benchmark.Handler --runtime java17 --role arn:aws:iam::{{account}}:role/lambda-ex --timeout 10 --region us-east-1 --memory-size {{memory}} --no-cli-pager

deploy-java-snapstart:
    gradle buildZip -p functions/java
    aws lambda create-function --function-name lambda-benchmark-java-snapstart --zip-file fileb://./functions/java/build/distributions/java.zip --handler benchmark.Handler --runtime java17 --role arn:aws:iam::{{account}}:role/lambda-ex --timeout 10 --region us-east-1 --memory-size {{memory}} --snap-start ApplyOn=PublishedVersions --no-cli-pager
    sleep 5
    VERSION=$(aws lambda publish-version --function-name lambda-benchmark-java-snapstart --region us-east-1 --query 'Version' --output text) && aws lambda create-alias --function-name lambda-benchmark-java-snapstart --name PROD --function-version $VERSION --region us-east-1 --no-cli-pager

deploy-node:
    zip -j function.zip functions/node/index.mjs
    aws lambda create-function --function-name lambda-benchmark-node --zip-file fileb://function.zip --handler index.handler --runtime nodejs20.x --role arn:aws:iam::{{account}}:role/lambda-ex --timeout 10 --region us-east-1 --memory-size {{memory}} --no-cli-pager
    rm function.zip

deploy-node-bundled:
    npm run build --prefix functions/node-bundled
    zip -j function.zip functions/node-bundled/index.js
    aws lambda create-function --function-name lambda-benchmark-node-bundled --zip-file fileb://function.zip --handler index.handler --runtime nodejs20.x --role arn:aws:iam::{{account}}:role/lambda-ex --timeout 10 --region us-east-1 --memory-size {{memory}} --no-cli-pager
    rm function.zip

deploy-python:
    zip -j function.zip functions/python/main.py
    aws lambda create-function --function-name lambda-benchmark-python --zip-file fileb://function.zip --handler main.handler --runtime python3.8 --role arn:aws:iam::{{account}}:role/lambda-ex --timeout 10 --region us-east-1 --memory-size {{memory}} --no-cli-pager
    rm function.zip

deploy-llrt:
    zip -j function.zip functions/llrt/*
    aws lambda create-function --function-name lambda-benchmark-llrt --handler index.handler --zip-file fileb://function.zip --runtime provided.al2023 --role arn:aws:iam::{{account}}:role/lambda-ex --architectures arm64 --timeout 10 --region us-east-1 --memory-size {{memory}} --no-cli-pager
    rm function.zip

deploy-rust:
    cargo lambda build --manifest-path functions/rust/Cargo.toml --release --arm64 --output-format zip
    aws lambda create-function --function-name lambda-benchmark-rust --handler bootstrap --zip-file fileb://./functions/rust/target/lambda/rust/bootstrap.zip --runtime provided.al2023 --role arn:aws:iam::{{account}}:role/lambda-ex --environment Variables={RUST_BACKTRACE=1} --tracing-config Mode=Active --architectures arm64 --timeout 10 --region us-east-1 --memory-size {{memory}} --no-cli-pager

deploy-go:
    GOOS=linux GOARCH=arm64 go build -C functions/go -tags lambda.norpc -o bootstrap main.go
    zip -j function.zip functions/go/bootstrap
    aws lambda create-function --function-name lambda-benchmark-go --runtime provided.al2023 --handler bootstrap --architectures arm64 --role arn:aws:iam::{{account}}:role/lambda-ex --zip-file fileb://function.zip --timeout 10 --memory-size {{memory}} --region us-east-1 --no-cli-pager
    rm function.zip

deploy-invoker:
    ACCOUNT={{account}} cargo lambda build --manifest-path invoker/Cargo.toml --release --arm64 --output-format zip
    aws lambda create-function --function-name lambda-benchmark-invoker --handler bootstrap --zip-file fileb://./invoker/target/lambda/invoker/bootstrap.zip --runtime provided.al2023 --role arn:aws:iam::{{account}}:role/lambda-ex --environment Variables={RUST_BACKTRACE=1} --tracing-config Mode=Active --architectures arm64 --timeout 100 --region us-east-1 --memory-size {{memory}} --no-cli-pager
    aws scheduler create-schedule --name lambda-benchmark-schedule --schedule-expression 'cron(0,15,30,45 * * * ? *)' --target '{"RoleArn": "arn:aws:iam::{{account}}:role/lambda-ex", "Arn": "arn:aws:lambda:us-east-1:{{account}}:function:lambda-benchmark-invoker", "Input": "{}" }' --flexible-time-window '{ "Mode": "OFF"}' --region us-east-1 --no-cli-pager

deploy-all:
    just deploy-iam
    just deploy-db
    just deploy-java
    just deploy-java-snapstart
    just deploy-node
    just deploy-node-bundled
    just deploy-llrt
    just deploy-python
    just deploy-rust
    just deploy-go
    just deploy-invoker
    just add-data

cleanup-node:
    aws lambda delete-function --function-name lambda-benchmark-node --region us-east-1 || true

cleanup-node-bundled:
    aws lambda delete-function --function-name lambda-benchmark-node-bundled --region us-east-1 || true

cleanup-llrt:
    aws lambda delete-function --function-name lambda-benchmark-llrt --region us-east-1 || true

cleanup-python:
    aws lambda delete-function --function-name lambda-benchmark-python --region us-east-1 || true

cleanup-java:
    aws lambda delete-function --function-name lambda-benchmark-java --region us-east-1 || true

cleanup-java-snapstart:
    aws lambda delete-function --function-name lambda-benchmark-java-snapstart --region us-east-1 || true

cleanup-rust:
    aws lambda delete-function --function-name lambda-benchmark-rust --region us-east-1 || true

cleanup-go:
    aws lambda delete-function --function-name lambda-benchmark-go --region us-east-1 || true

cleanup-lambdas:
    just cleanup-java
    just cleanup-java-snapstart
    just cleanup-node
    just cleanup-node-bundled
    just cleanup-llrt
    just cleanup-python
    just cleanup-rust
    just cleanup-go

cleanup-invoker:
    aws lambda delete-function --function-name lambda-benchmark-invoker --region us-east-1 || true
    aws scheduler delete-schedule --name lambda-benchmark-schedule --region us-east-1 --no-cli-pager || true

cleanup: cleanup-lambdas && cleanup-invoker
    aws iam detach-role-policy --role-name lambda-ex --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole || true
    aws iam detach-role-policy --role-name lambda-ex --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess || true
    aws iam detach-role-policy --role-name lambda-ex --policy-arn arn:aws:iam::aws:policy/AWSLambda_FullAccess || true
    aws iam delete-role --role-name lambda-ex || true
    aws dynamodb delete-table --table-name Music --region us-east-1 --no-cli-pager || true
