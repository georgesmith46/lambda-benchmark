account := "516028615317"

deploy-db:
    aws dynamodb create-table --table-name Music --attribute-definitions AttributeName=Artist,AttributeType=S AttributeName=SongTitle,AttributeType=S --key-schema AttributeName=Artist,KeyType=HASH AttributeName=SongTitle,KeyType=RANGE --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 --region us-east-1 --no-cli-pager

add-data:
    aws dynamodb put-item --table-name Music --item '{"Artist": {"S": "No One You Know"}, "SongTitle": {"S": "Call Me Today"}, "AlbumTitle": {"S": "Somewhat Famous"}}' --return-consumed-capacity TOTAL --region us-east-1 --no-cli-pager

deploy-iam:
    aws iam create-role --role-name lambda-ex --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}' --no-cli-pager
    aws iam attach-role-policy --role-name lambda-ex --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole --no-cli-pager
    aws iam attach-role-policy --role-name lambda-ex --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess --no-cli-pager
    
deploy-java:
    gradle buildZip -p functions/java
    cp functions/java/build/distributions/java.zip ./function.zip
    aws lambda create-function --function-name lambda-benchmark-java --zip-file fileb://function.zip --handler benchmark.Handler --runtime java17 --role arn:aws:iam::{{account}}:role/lambda-ex --region us-east-1 --memory-size 1024 --no-cli-pager
    rm function.zip

deploy-java-snapstart:
    gradle buildZip -p functions/java
    cp functions/java/build/distributions/java.zip ./function.zip
    aws lambda create-function --function-name lambda-benchmark-java-snapstart --zip-file fileb://function.zip --handler benchmark.Handler --runtime java17 --role arn:aws:iam::{{account}}:role/lambda-ex --region us-east-1 --memory-size 1024 --snap-start ApplyOn=PublishedVersions --no-cli-pager
    aws lambda publish-version --function-name lambda-benchmark-java-snapstart --region us-east-1 --no-cli-pager
    rm function.zip

deploy-node:
    zip -j function.zip functions/node/index.mjs
    aws lambda create-function --function-name lambda-benchmark-node --zip-file fileb://function.zip --handler index.handler --runtime nodejs20.x --role arn:aws:iam::{{account}}:role/lambda-ex --region us-east-1 --memory-size 1024 --no-cli-pager
    rm function.zip

cleanup-lambdas:
    aws lambda delete-function --function-name lambda-benchmark-node --region us-east-1 || true
    aws lambda delete-function --function-name lambda-benchmark-java --region us-east-1 || true
    aws lambda delete-function --function-name lambda-benchmark-java-snapstart --region us-east-1 || true
    
cleanup: cleanup-lambdas
    aws iam detach-role-policy --role-name lambda-ex --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole || true
    aws iam detach-role-policy --role-name lambda-ex --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess || true
    aws iam delete-role --role-name lambda-ex || true
    aws dynamodb delete-table --table-name Music --region us-east-1 --no-cli-pager || true
