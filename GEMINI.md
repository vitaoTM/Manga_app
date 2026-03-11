# Gemini Project: Manga App

This document provides a summary of the Manga App project, its structure, and conventions to be used as a context for an AI assistant.

## Project Overview

This is a Ruby on Rails 8.1 application that appears to be a "Manga App". It utilizes a modern web development stack including:

*   **Backend:** Ruby on Rails 8.1
*   **Frontend:** Hotwire (Turbo and Stimulus), Tailwind CSS, and JavaScript via import maps.
*   **Database:** PostgreSQL (`pg` gem).
*   **Authentication:** Handled by the `devise` gem.
*   **Background Jobs:** `solid_queue` is configured.
*   **Caching:** `solid_cache` is configured.
*   **WebSockets:** `solid_cable` is configured.
*   **Deployment:** The project is set up for deployment with Kamal.

The application's entry point is the `home#index` route.

## Building and Running

### 1. Initial Setup

To set up the development environment, you'll need to install the dependencies and set up the database.

```bash
# Install Ruby gems
bundle install

# Create the database
bin/rails db:create

# Run database migrations
bin/rails db:migrate

# Seed the database with initial data (if seeds.rb is populated)
bin/rails db:seed
```

### 2. Running the Development Server

To run the application in a local development environment, use the following command. This will start the Rails web server and the Tailwind CSS watcher.

```bash
bin/dev
```

The application will be available at `http://localhost:3000`.

## Development Conventions

### Testing

The project uses the built-in Rails testing framework.

*   **Run all tests:**
    ```bash
    bin/rails test
    ```
*   **Run system tests:**
    ```bash
    bin/rails test:system
    ```
The CI configuration in `.github/workflows/ci.yml` also runs `bin/rails db:test:prepare` before running the tests.

### Linting and Code Style

The project uses RuboCop for Ruby code linting.

*   **Run the linter:**
    ```bash
    bin/rubocop
    ```

### Security Scans

The CI pipeline includes steps for security vulnerability scanning.

*   **Rails security:**
    ```bash
    bin/brakeman --no-pager
    ```
*   **Gem security:**
    ```bash
    bin/bundler-audit
    ```
*   **JavaScript dependency security:**
    ```bash
    bin/importmap audit
    ```
