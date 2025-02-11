# README

## About the Application

This is a Ruby on Rails application to build a robust, extendable and scalable webhook handling system. The application is designed to handle the webhook request in a background job so the request is not blocking the main thread.

### InboundWebhook Model

The InboundWebhook model is used to store the webhook data and monitor the status of the webhook. Also, it is used to save the error message if the webhook request fails.

### Integrations::FaradayClient

The Integrations::FaradayClient is used to make the HTTP request to the relevant API. This class is used to make the HTTP request in the background job. It is designed to handle the response and error while making the request.

#### Integrations::HttpErrorHandling

This module is responsible for handling errors that are raised by the HTTP client. It defines custom error classes for different types of HTTP errors.

#### Integrations::ApiResponse

This module is a simple data object that represents an HTTP response. It provides methods to check if the response is successful or a failure based on the HTTP status code.

### InboundWebhooks::ApplicationController

The InboundWebhooks::ApplicationController is used to handle the common methods for the InboundWebhooks controllers. This controller is inherited by all the InboundWebhooks controllers.

### InboundWebhooks::GithubController

The InboundWebhooks::GithubController is used to handle the webhook request from the Github API. This controller is used to save the webhook data and call the background handler job to process the webhook request.

## Requirements to Run the Application

You'll need the following installed

- Ruby version: 3.4.1
- bundler - `gem install bundler`
- PostgreSQL needs to be installed
  - PostgreSQL - `brew install postgresql` or `sudo apt-get install postgresql`
- Redis needs to be installed
  - Redis - `brew install redis` or `sudo apt-get install redis`

## Setting Up

To setup the application, run `./bin/setup` after installing the requirements.

```bash
bin/setup
```

## Running the Application

To start the application, use the following command:

```bash
bin/dev
```

To run the tests, use the following command:

```bash
rspec
```
