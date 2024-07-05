use aws_sdk_lambda::{primitives::Blob, Client, Error as LambdaError};
use lambda_runtime::{
    run, service_fn,
    tracing::{self, info},
    Error, LambdaEvent,
};
use serde::Serialize;
use serde_json::Value;
use std::time::Instant;

const LAMBDA_TYPES: [&str; 8] = [
    "rust",
    "go",
    "node",
    "node-bundled",
    "java",
    "java-snapstart",
    "llrt",
    "python",
];

#[derive(Default, Debug, Serialize)]
struct Report {
    cold_starts: Vec<ColdStartResult>,
    warm_starts: Vec<WarmStartResult>,
}

#[derive(Default, Debug, Serialize)]
struct ColdStartResult {
    lambda_type: &'static str,
    duration: u128,
}

#[derive(Default, Debug, Serialize)]
struct WarmStartResult {
    lambda_type: &'static str,
    durations: Vec<u128>,
}

async fn invoke_lambda(client: &Client, lambda_type: &str) -> Result<u128, Error> {
    let now = Instant::now();

    let suffix = if lambda_type == "java-snapstart" {
        ":PROD"
    } else {
        ""
    };

    client
        .invoke()
        .function_name(format!(
            "arn:aws:lambda:us-east-1:{}:function:lambda-benchmark-{lambda_type}{suffix}",
            std::option_env!("ACCOUNT").expect("account env var should be set")
        ))
        .payload(Blob::new(b"{}"))
        .send()
        .await
        .map_err(LambdaError::from)?;

    Ok(now.elapsed().as_millis())
}

async fn function_handler(client: &Client, _event: LambdaEvent<Value>) -> Result<(), Error> {
    let mut report = Report::default();

    // Cold Starts
    for lambda_type in LAMBDA_TYPES {
        let duration = invoke_lambda(client, lambda_type).await?;
        report.cold_starts.push(ColdStartResult {
            lambda_type,
            duration,
        });
    }

    // Warm starts
    for lambda_type in LAMBDA_TYPES {
        let mut warm_start_result = WarmStartResult {
            lambda_type,
            ..Default::default()
        };
        for _ in 0..25 {
            let duration = invoke_lambda(client, lambda_type).await?;
            warm_start_result.durations.push(duration);
        }
        report.warm_starts.push(warm_start_result);
    }

    info!("{}", serde_json::to_string(&report).unwrap());

    Ok(())
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing::init_default_subscriber();

    let config = aws_config::load_from_env().await;
    let client = aws_sdk_lambda::Client::new(&config);

    run(service_fn(|event: LambdaEvent<Value>| async {
        function_handler(&client, event).await
    }))
    .await
}
