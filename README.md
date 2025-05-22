# Robust Webhook Handler

This Ruby on Rails application provides a resilient and scalable solution for managing inbound webhooks. It ensures reliable webhook processing using background jobs and offers a structured approach for integration with various third-party services.

## Core Components

### `InboundWebhook` Model

The `InboundWebhook` model is central to the system. It stores incoming webhook data, tracks the processing status (e.g., `pending`, `success`, `failed`), and records any error messages encountered during processing.

### Webhook Processing Flow

1.  **Reception**: Incoming webhooks are received by dedicated controllers (e.g., `InboundWebhooks::GithubController`).
2.  **Storage**: The raw webhook data is immediately stored in an `InboundWebhook` record with a `pending` status.
3.  **Asynchronous Processing**: A background job is enqueued (e.g., using Sidekiq) to process the webhook data. This ensures the initial HTTP request completes quickly, preventing client timeouts and offloading potentially long-running tasks.
4.  **Status Update**: The background job updates the `InboundWebhook` record's status to `success` or `failed` and logs any errors.

### `InboundWebhooks::ApplicationController`

This controller provides common functionalities and shared methods for all webhook-specific controllers (like `InboundWebhooks::GithubController`). It serves as a base class to ensure consistent behavior.

### `InboundWebhooks::GithubController`

An example controller demonstrating how to handle webhooks from a specific service (GitHub in this case). It's responsible for receiving the webhook, creating an `InboundWebhook` record, and enqueuing the corresponding background job for processing.

## HTTP Client and Error Handling

### `Integrations::FaradayClient`

This class acts as a wrapper around an HTTP client library (Faraday) to make requests to external APIs as part of webhook processing. It is designed to be used within background jobs and includes built-in error handling and response parsing.

### `Integrations::HttpErrorHandling`

A module that provides standardized error handling for HTTP requests made by `Integrations::FaradayClient`. It defines custom error classes for various HTTP error scenarios (e.g., 4xx client errors, 5xx server errors), allowing for consistent error management.

### `Integrations::ApiResponse`

A simple data object (struct or class) representing a standardized HTTP response. It typically includes attributes like status code, body, and headers, along with helper methods to easily check for success or failure.

## Contributing

We welcome contributions to improve and expand this webhook handling system. If you have new features, bug fixes, or improvements, please follow these steps:

1.  **Fork the repository.**
2.  **Create a new branch** for your feature or bug fix:
    ```bash
    git checkout -b your-branch-name
    ```
3.  **Make your changes.** Ensure that your code follows the existing style and includes tests where applicable.
4.  **Commit your changes** with a clear and descriptive commit message.
5.  **Push your branch** to your forked repository:
    ```bash
    git push origin your-branch-name
    ```
6.  **Submit a pull request** to the main repository for review.

Please ensure your pull request describes the problem and solution and references any relevant issues.

## Requirements to Run the Application

You'll need the following installed:

- Ruby version: `3.4.1`
- `bundler`: Run `gem install bundler`
- `PostgreSQL`:
  - macOS: `brew install postgresql`
  - Ubuntu/Debian: `sudo apt-get install postgresql`
- `Redis`:
  - macOS: `brew install redis`
  - Ubuntu/Debian: `sudo apt-get install redis`

## Setting Up

After installing the requirements, run the setup script:

```bash
./bin/setup
```

This script will typically install gems, create the database, and run migrations.

## Running the Application

To start the application, use the following command:

```bash
./bin/dev
```

This usually starts the Rails server, Sidekiq (for background jobs), and any other necessary processes.

To run the test suite:

```bash
rspec
```

## License

This project is released under the [MIT License](LICENSE.txt).
