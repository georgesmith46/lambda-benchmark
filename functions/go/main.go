package main

import (
	"context"
	"log"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
)

type MyEvent struct{}

func HandleRequest(ctx context.Context, event *MyEvent, svc *dynamodb.DynamoDB) (int, error) {
	tableName := "Music"
	artist := "No One You Know"
	songTitle := "Call Me Today"

	result, err := svc.GetItem(&dynamodb.GetItemInput{
		TableName: aws.String(tableName),
		Key: map[string]*dynamodb.AttributeValue{
			"Artist": {
				S: aws.String(artist),
			},
			"SongTitle": {
				S: aws.String(songTitle),
			},
		},
	})

	if err == nil {
		return 0, err
	}

	log.Println(result)
	return 1, nil
}

func main() {
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))
	svc := dynamodb.New(sess)

	f := func(ctx context.Context, event *MyEvent) (int, error) {
		return HandleRequest(ctx, event, svc)
	}

	lambda.Start(f)
}
