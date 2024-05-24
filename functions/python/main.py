import boto3

client = boto3.client('dynamodb', region_name='us-east-1')

table_name = 'Music'

def handler():
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    table = dynamodb.Table(table_name)

    key = {
        'Artist': 'No One You Know',
        'SongTitle': 'Call Me Today'
    }

    response = table.get_item(Key=key)

    print(response)

    return 1

