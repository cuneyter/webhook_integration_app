# Notes for Google Jules

## Setup v1

```bash
#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- 1. Install System-level Dependencies ---
# These are required to compile Ruby and the gems in your project.
echo "Updating package lists and installing build dependencies..."
sudo apt-get update
sudo apt-get install --no-install-recommends -y \
  git curl autoconf bison build-essential libssl-dev \
  libyaml-dev libreadline-dev zlib1g-dev libncurses5-dev \
  libffi-dev libgdbm-dev libpq-dev

# --- 2. Install rbenv and ruby-build ---
# This is a best-practice way to manage Ruby versions.
echo "Installing rbenv..."
if [ ! -d "$HOME/.rbenv" ]; then
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  # Add rbenv to the shell's path
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc
  # Apply the changes to the current session
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi

echo "Installing ruby-build..."
if [ ! -d "$(rbenv root)"/plugins/ruby-build ]; then
  git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
fi

# --- 3. Install Ruby ---
RUBY_VERSION="3.4.1"
echo "Installing Ruby ${RUBY_VERSION}..."
if ! rbenv versions | grep -q "$RUBY_VERSION"; then
  rbenv install "$RUBY_VERSION"
fi
rbenv global "$RUBY_VERSION"

# --- 4. Install Bundler ---
echo "Installing Bundler..."
gem install bundler

echo "---"
echo "✅ Ruby ${RUBY_VERSION} is now installed."
echo "You can now run 'bundle install' in your project directory."
```

## Setup v2

```bash
#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- 1. Install System-level Dependencies ---
# These are required to compile Ruby and the gems in your project.
echo "Updating package lists and installing build dependencies..."
sudo apt-get update
sudo apt-get install --no-install-recommends -y \
  git curl autoconf bison build-essential libssl-dev \
  libyaml-dev libreadline-dev zlib1g-dev libncurses5-dev \
  libffi-dev libgdbm-dev libpq-dev postgresql postgresql-contrib

# --- 2. Install rbenv and ruby-build ---
# This is a best-practice way to manage Ruby versions.
echo "Installing rbenv..."
if [ ! -d "$HOME/.rbenv" ]; then
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  # Add rbenv to the shell's path
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc
  # Apply the changes to the current session
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi

echo "Installing ruby-build..."
if [ ! -d "$(rbenv root)"/plugins/ruby-build ]; then
  git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
fi

# --- This is the key change to prevent freezing ---
# Force the 'make' command to use only a single core (-j 2).
export MAKEOPTS="-j 2"

# --- 3. Install Ruby ---
RUBY_VERSION="3.4.1"
echo "Installing Ruby ${RUBY_VERSION}..."
if ! rbenv versions | grep -q "$RUBY_VERSION"; then
  rbenv install "$RUBY_VERSION"
fi
rbenv global "$RUBY_VERSION"

# --- 4. Install Bundler ---
echo "Installing Bundler..."
gem install bundler

echo "---"
echo "✅ Ruby ${RUBY_VERSION} is now installed."
echo "You can now run 'bundle install' in your project directory."

echo "Installing application gems..."
bundle install

# --- 5. Configure and Start PostgreSQL ---
echo "Starting and configuring PostgreSQL..."
sudo service postgresql start

sleep 5 # Wait for the service to initialize
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
echo "--- PostgreSQL is running and configured. ---"

# --- 6. Prepare the Rails Application Database ---
echo "--- Creating and migrating the database... ---"
bundle exec rails db:prepare

echo ""
echo "✅✅✅ Setup Complete! Your Rails application and database are ready. ✅✅✅"
```
