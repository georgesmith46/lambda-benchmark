package main

import (
	"context"
	"log"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
)

type MyEvent struct{}

func HandleRequest(ctx context.Context, event *MyEvent, svc *dynamodb.Client) (int, error) {
	tableName := "Music"
	artist := "No One You Know"
	songTitle := "Call Me Today"

	result, err := svc.GetItem(ctx, &dynamodb.GetItemInput{
		TableName: aws.String(tableName),
		Key: map[string]types.AttributeValue{
			"Artist": &types.AttributeValueMemberS{
				Value: artist,
			},
			"SongTitle": &types.AttributeValueMemberS{
				Value: songTitle,
			},
		},
	})

	if err != nil {
		return 0, err
	}

	log.Println(result)
	return 1, nil
}

func main() {
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion("us-east-1"))
	if err != nil {
		log.Fatalf("unable to load SDK config, %v", err)
	}
	svc := dynamodb.NewFromConfig(cfg)

	f := func(ctx context.Context, event *MyEvent) (int, error) {
		return HandleRequest(ctx, event, svc)
	}

	lambda.Start(f)
}
