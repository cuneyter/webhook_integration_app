# agents.md

---

## Project Overview

This repository, `webhook_integration_app`, is a Ruby on Rails application designed to handle inbound webhooks. It is configured to work with various services, including GitHub, and includes user authentication and session management. The application is built with Rails 8 and uses modern development practices.

---

## Dependencies and Setup

### Main Dependencies

- **Ruby:** The application requires a specific version of Ruby, as defined in the `.ruby-version` file.
- **Rails:** It uses Rails 8, a modern and robust framework for web development.
- **PostgreSQL:** The primary database for the application.
- **Puma:** The web server used to run the application.
- **RSpec:** The testing framework for writing and running tests.
- **RuboCop:** A code linter to enforce a consistent style.

### Setup Commands

To get the application up and running, follow these steps:

1.  **Install Dependencies:**
    ```bash
    bundle install
    ```
2.  **Prepare the Database:**
    ```bash
    bin/rails db:prepare
    ```
3.  **Run Migrations:**
    ```bash
    bin/rails db:migrate
    ```

---

## Linting and Code Style

### Linting

This project uses **RuboCop** to enforce a consistent code style. To check for linting errors, run the following command:

```bash
bin/rubocop
```

### Code Style

We follow the **Rails community code style guide**, which is enforced by RuboCop. Please ensure your contributions adhere to these standards to maintain code quality and readability.

---

## Testing

### Framework

We use **RSpec** for testing. All new features should be accompanied by corresponding tests to ensure they work as expected.

### Running Tests

To run the entire test suite, use the following command:

```bash
bin/rspec
```

---

## Conventions and Best Practices

### Code Implementation

- **Service Objects:** For complex business logic, use service objects to keep controllers and models clean.
- **API Responses:** When creating API responses, use the `ApiResponse` service to ensure consistency.
- **Authentication:** Follow the existing authentication pattern for all new features that require user authentication.

### Commits and Pull Requests

- **Conventional Commits:** We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification for our commit messages. This helps us maintain a clear and organized commit history.
- **Pull Requests:** All new features and bug fixes should be submitted as pull requests. Each pull request should include a clear description of the changes and reference any related issues.

---
