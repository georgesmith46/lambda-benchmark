use aws_sdk_dynamodb::types::AttributeValue;
use aws_sdk_dynamodb::Client;
use lambda_runtime::{
    run, service_fn,
    tracing::{self, info},
    Error, LambdaEvent,
};
use serde_json::Value;

async fn function_handler(client: &Client, _event: LambdaEvent<Value>) -> Result<(), Error> {
    let response = client
        .get_item()
        .table_name("Music")
        .key("Artist", AttributeValue::S("No One You Know".into()))
        .key("SongTitle", AttributeValue::S("Call Me Today".into()))
        .send()
        .await?;

    info!("{response:?}");

    Ok(())
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing::init_default_subscriber();

    let config = aws_config::load_from_env().await;
    let client = Client::new(&config);

    run(service_fn(|event: LambdaEvent<Value>| async {
        function_handler(&client, event).await
    }))
    .await
}
