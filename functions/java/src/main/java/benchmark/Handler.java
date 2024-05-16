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
  private static final DynamoDbClient ddb;

  static {
    ddb = DynamoDbClient.builder()
        .region(Region.US_EAST_1)
        .build();

    // Perform a "warm up" read to initialize the connection
    HashMap<String, AttributeValue> warmUpKey = new HashMap<>();
    warmUpKey.put("Artist", AttributeValue.builder().s("WarmUpArtist").build());
    warmUpKey.put("SongTitle", AttributeValue.builder().s("WarmUpSong").build());

    GetItemRequest warmUpRequest = GetItemRequest.builder()
        .key(warmUpKey)
        .tableName("Music")
        .build();

    try {
      ddb.getItem(warmUpRequest);
    } catch (DynamoDbException e) {
      // Log or handle the exception as necessary
      System.err.println("Warm up read failed: " + e.getMessage());
    }
  }

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
