import boto3

client = boto3.client('dynamodb', region_name='us-east-1')
table_name = 'Music'

def handler(event, context):
    key = {
        'Artist': {'S': 'No One You Know'},
        'SongTitle': {'S': 'Call Me Today'}
    }

    response = client.get_item(TableName=table_name, Key=key)

    print(response)

    return 1

