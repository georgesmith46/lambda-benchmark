use anyhow::Result;
use aws_sdk_cloudwatchlogs as cloudwatchlogs;
use chrono::{DateTime, Utc};
use cloudwatchlogs::types::QueryStatus;
use serde::Deserialize;
use std::collections::BTreeMap;
use std::time::Duration;
use tokio::time::sleep;

#[derive(Debug, Deserialize, Clone)]
struct Day {
    cold_starts: Vec<ColdStartResult>,
    warm_starts: Vec<WarmStartResult>,
}

#[derive(Debug, Deserialize, Clone)]
struct ColdStartResult {
    lambda_type: String,
    duration: u128,
}

#[derive(Debug, Deserialize, Clone)]
struct WarmStartResult {
    lambda_type: String,
    durations: Vec<u128>,
}

#[derive(Debug, Default)]
struct LambdaReport {
    durations: Vec<u128>,
}

async fn collect_logs() -> Result<Vec<Day>> {
    let config = aws_config::from_env().region("us-east-1").load().await;
    let client = aws_sdk_cloudwatchlogs::Client::new(&config);
    let start_time = DateTime::parse_from_rfc3339("2024-07-05T15:00:00Z").unwrap();

    let response = client
        .start_query()
        .log_group_name("/aws/lambda/lambda-benchmark-invoker")
        .start_time(start_time.timestamp())
        .end_time(Utc::now().timestamp())
        .query_string("fields @message | filter @message like /cold_starts/")
        .send()
        .await?;

    let query_id = response.query_id.unwrap();

    let results_response = loop {
        let results_response = client
            .get_query_results()
            .query_id(query_id.clone())
            .send()
            .await?;

        if let Some(QueryStatus::Complete) = results_response.status {
            break results_response;
        } else {
            sleep(Duration::from_millis(500)).await;
        }
    };

    Ok(results_response
        .results
        .unwrap()
        .iter()
        .flatten()
        .filter(|x| x.field == Some(String::from("@message")))
        .map(|field| {
            serde_json::from_str::<Day>(field.value.as_ref().unwrap().split_once(": ").unwrap().1)
                .unwrap()
        })
        .collect())
}

fn print_report(lambda_type: &str, report: &LambdaReport) {
    let mut ranked = report.durations.clone();
    ranked.sort();

    let min = report.durations.iter().min().unwrap();
    let avg = report.durations.iter().sum::<u128>() / report.durations.len() as u128;
    let p50 = ranked[(0.5 * ranked.len() as f32) as usize];
    let p90 = ranked[(0.99 * ranked.len() as f32) as usize];
    let max = report.durations.iter().max().unwrap();

    println!("{lambda_type},{min},{avg},{p50},{p90},{max}");
}

#[tokio::main]
async fn main() -> Result<()> {
    let logs = collect_logs().await?;

    let mut cold_start_report: BTreeMap<String, LambdaReport> = BTreeMap::new();

    for day in logs.clone() {
        for cold_start in day.cold_starts {
            let ColdStartResult {
                lambda_type,
                duration,
            } = cold_start;
            let report = cold_start_report.entry(lambda_type).or_default();
            report.durations.push(duration);
        }
    }

    let mut warm_start_report: BTreeMap<String, LambdaReport> = BTreeMap::new();

    for day in logs {
        for warm_start in day.warm_starts {
            let WarmStartResult {
                lambda_type,
                durations,
            } = warm_start;
            let report = warm_start_report.entry(lambda_type).or_default();
            report.durations.append(&mut durations.clone());
        }
    }

    const COLUMNS: &str = "lambda_type,min,avg,p50,p99,max";

    println!("Cold Starts:");
    println!("{COLUMNS}");
    for (lambda_type, report) in cold_start_report {
        print_report(&lambda_type, &report);
    }
    println!();

    println!("Warm Starts:");
    println!("{COLUMNS}");
    for (lambda_type, report) in warm_start_report {
        print_report(&lambda_type, &report);
    }

    Ok(())
}
