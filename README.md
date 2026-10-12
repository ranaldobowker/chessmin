# Chessmin

## Installation

### Prerequisites

- Ruby `4.0.7` (see `.ruby-version`)
- Bundler
- SQLite 3.8.0 or newer

Install Ruby with a version manager such as `mise`, `asdf`, or `rbenv`, then
install Bundler if it is not already available:

```sh
gem install bundler
```

### Setup

Clone the repository and run the setup script:

```sh
git clone <repository-url>
cd chessmin
bin/setup --skip-server
```

`bin/setup` installs the Ruby dependencies and prepares the development and
test databases. Use `bin/setup --reset --skip-server` to recreate the local
databases from scratch.

## Running the application

Start the development server with:

```sh
bin/dev
```

The application is available at <http://localhost:3000>.

## Running tests

Run the RSpec suite with:

```sh
bundle exec rspec
```
