# Rails 8 Authentication Implementation

## Overview

Rails 8 introduces a built-in authentication system that brings together all the authentication components that have been developed over the years. This implementation provides a secure, session-based authentication system with minimal setup.

## Key Components

Rails 8 authentication leverages several key features:

- `has_secure_password` (Rails 5)
- `normalizes` (Rails 7.1)
- `generates_token_for` (Rails 7.1)
- `authenticate_by` (Rails 7.1)

## Setup

The authentication system can be generated with a single command:

```bash
bin/rails generate authentication
```

This command creates all the essential files for a complete authentication system.

## Generated Files

### Models

- `app/models/current.rb` - Current attributes for session management
- `app/models/user.rb` - User model with secure password
- `app/models/session.rb` - Session model for database-backed sessions

### Controllers

- `app/controllers/sessions_controller.rb` - Login/logout functionality
- `app/controllers/passwords_controller.rb` - Password reset functionality
- `app/controllers/concerns/authentication.rb` - Authentication concern

### Mailers

- `app/mailers/passwords_mailer.rb` - Password reset email functionality

### Views

- `app/views/sessions/new.html.erb` - Login form
- `app/views/passwords/new.html.erb` - Password reset request form
- `app/views/passwords/edit.html.erb` - Password reset form
- `app/views/passwords_mailer/` - Email templates

### Database Migrations

- User table with email_address and password_digest
- Session table for database-backed sessions

## Implementation Details

### User Model

```ruby
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
```

Features:

- Secure password hashing using bcrypt
- Email normalization (strip whitespace, lowercase)
- Association with sessions for multi-device support

### Session Model

```ruby
class Session < ApplicationRecord
  belongs_to :user
end
```

Tracks:

- User association
- IP address
- User agent
- Creation timestamp

### Authentication Concern

The `Authentication` concern provides:

#### Core Methods

- `authenticated?` - Check if user is authenticated
- `require_authentication` - Before action to ensure authentication
- `start_new_session_for(user)` - Create new session
- `terminate_session` - End current session

#### Session Management

- Secure HTTP-only cookies
- SameSite: Lax for CSRF protection
- Permanent cookies for "remember me" functionality
- Database-backed sessions for security

#### Access Control

- `allow_unauthenticated_access` class method for public endpoints
- Redirect to intended page after authentication

### Current Model

```ruby
class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :user, to: :session, allow_nil: true
end
```

Provides thread-safe access to current session and user throughout the request lifecycle.

## Adding User Registration

The base Rails 8 authentication generator doesn't include user registration. Here's how to add it:

### Route Configuration

```ruby
# config/routes.rb
Rails.application.routes.draw do
  resource :session
  resource :registration, only: %i[new create]  # Singular resource
  resources :passwords, param: :token
end
```

### Registration Controller

```ruby
class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      start_new_session_for @user
      redirect_to root_path, notice: "Successfully signed up!"
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
```

Key features:

- `allow_unauthenticated_access` for public registration
- Automatic sign-in after successful registration using `start_new_session_for`
- Standard Rails form handling with validation

### Security Features

1. **Rate Limiting**: Built-in rate limiting on login attempts
2. **Secure Cookies**: HTTP-only, SameSite cookies
3. **Database Sessions**: Sessions stored in database, not just cookies
4. **Password Security**: bcrypt hashing via `has_secure_password`
5. **CSRF Protection**: Rails' built-in CSRF protection
6. **Session Tracking**: IP address and user agent tracking

### Route Naming Convention

Using `resource :registration` (singular) follows Rails conventions for singleton resources:

- One registration per user context
- URLs: `/registration/new`, `/registration` (POST)
- No ID parameters in URLs
- Matches the conceptual model of user registration

## Benefits

1. **Production Ready**: Secure defaults and best practices
2. **Database Sessions**: More secure than cookie-only sessions
3. **Multi-Device Support**: Each session tracked separately
4. **Email Normalization**: Consistent email handling
5. **Rate Limiting**: Built-in protection against brute force
6. **Extensible**: Easy to customize and extend

This implementation provides a solid foundation for authentication that can be extended with additional features like OAuth, two-factor authentication, or more complex user management as needed.
