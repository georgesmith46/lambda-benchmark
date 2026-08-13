import { DynamoDBClient, GetItemCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({ region: "us-east-1" });

export const handler = async () => {
  const input = {
    Key: {
      Artist: { S: "No One You Know" },
      SongTitle: { S: "Call Me Today" },
    },
    TableName: "Music",
  };
  const response = await client.send(new GetItemCommand(input));

  console.log(response);
  return 1;
};
