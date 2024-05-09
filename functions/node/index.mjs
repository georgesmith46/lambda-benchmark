import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({ region: "us-east-1" });
const docClient = DynamoDBDocumentClient.from(client);

export const handler = async () => {
  const input = {
    Key: {
      Artist: "No One You Know",
      SongTitle: "Call Me Today",
    },
    TableName: "Music",
  };
  const response = await docClient.send(new GetCommand(input));

  console.log(response);
  return 1;
};
