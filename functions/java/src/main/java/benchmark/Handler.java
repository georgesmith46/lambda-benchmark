package benchmark;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.dynamodb.model.DynamoDbException;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.AttributeValue;
import software.amazon.awssdk.services.dynamodb.model.GetItemRequest;
import java.util.HashMap;
import java.util.Map;

public class Handler implements RequestHandler<IncomingEvent, Integer> {
  private static final DynamoDbClient ddb = DynamoDbClient.builder()
      .region(Region.US_EAST_1)
      .build();

  @Override
  public Integer handleRequest(IncomingEvent event, Context context) {
    LambdaLogger logger = context.getLogger();

    HashMap<String, AttributeValue> keyToGet = new HashMap<>();
    keyToGet.put("Artist", AttributeValue.builder().s("No One You Know").build());
    keyToGet.put("SongTitle", AttributeValue.builder().s("Call Me Today").build());

    GetItemRequest request = GetItemRequest.builder()
        .key(keyToGet)
        .tableName("Music")
        .build();

    Map<String, AttributeValue> returnedItem = ddb.getItem(request).item();
    logger.log(returnedItem.toString());

    return 1;
  }
}

record IncomingEvent() {
}
