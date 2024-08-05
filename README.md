# README

## About the Application
This is an experimental Ruby on Rails application to build robust, extendable and scalable webhook handling system. The application is designed to handle the webhook request in a background job so the request is not blocking the main thread.

### InboundWebhook Model
The InboundWebhook model is used to store the webhook data and monitor the status of the webhook. Also, it is used to save the error message if the webhook request fails.

### InboundWebhooks::ApplicationController
The InboundWebhooks::ApplicationController is used to handle the common methods for the InboundWebhooks controllers. This controller is inherited by all the InboundWebhooks controllers. 

### Integrations::HttpClient
The Integrations::HttpClient is used to make the HTTP request to the relevant API. This class is used to make the HTTP request in the background job. It is designed to handle the response and error while making the request.

## Requirements to Run the Application
You'll need the following installed

* Ruby version: 3.3.3
* bundler - `gem install bundler`
* PostgreSQL needs to be installed
  * PostgreSQL - `brew install postgresql` or `sudo apt-get install postgresql`

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
