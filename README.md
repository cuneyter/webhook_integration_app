# README

## About the Application
This is an experimental Ruby on Rails application to build robust, extendable and scalable webhook handling system. The application is designed to handle the webhook request in a background job so the request is not blocking the main thread.

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
