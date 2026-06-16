# 漫画 MangaApp

[![Rails Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)
[![Ruby Version](https://img.shields.io/badge/ruby-4.0.1-red.svg)](https://www.ruby-lang.org/)
[![Rails Version](https://img.shields.io/badge/rails-8.1.2-blue.svg)](https://rubyonrails.org/)

A modern, high-performance Manga reading platform built with **Ruby on Rails 8.1**, **Tailwind CSS 4**, and **Hotwire**. Features a sleek dark UI, responsive long-scroll reader, and a complete donation system powered by Stripe.

## ✨ Features

- **📖 Smooth Reading Experience:** Fast, long-scroll reader with Stimulus-powered chapter jumping.
- **📱 Fully Responsive:** Optimized for desktop, tablet, and mobile with zero horizontal overflow.
- **💎 Personal Library:** Bookmark your favorite manga and resume reading exactly where you left off.
- **⭐ Rating System:** Rate titles and see community averages.
- **🏷️ Advanced Tagging:** Discover new content through a robust tag management system.
- **💰 Stripe Donations:** Integrated Marketplace model allowing users to support us directly.
- **☁️ Cloud Storage:** High-speed image delivery via AWS S3 and Active Storage.
- **⚡ Modern Architecture:** Uses Rails 8 "Solid" adapters (Cache, Queue, Cable) for a simplified, database-backed infrastructure.

## 🛠️ Tech Stack

- **Framework:** Ruby on Rails 8.1.2 (Omakase)
- **Frontend:** Hotwire (Turbo & Stimulus), Tailwind CSS 4.0
- **Database:** SQLite (Production: replicated to Cloudflare R2 via Litestream)
- **Auth:** Devise
- **Media:** AWS S3 + Active Storage
- **Payments:** Stripe (Checkout + Connect)
- **Background Jobs:** Solid Queue / Async
- **Caching:** Solid Cache
- **Deployment:** Render (with persistent disk + Litestream for SQLite replication)

## 🚀 Getting Started

### Prerequisites
- Ruby 4.0.1
- SQLite3
- AWS S3 Bucket (for image uploads)
- Stripe Account (for donations)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/vitaoTM/Manga_app.git
   cd manga_app
   ```

2. **Install dependencies:**
   ```bash
   bundle install
   ```

3. **Database Setup:**
   ```bash
   bin/rails db:prepare
   ```

4. **Add Credentials:**
   You will need a `master.key` to decrypt the credentials or create a new one:
   ```bash
   EDITOR="code --wait" bin/rails credentials:edit
   ```
   *Required keys:* `aws: (access_key_id, secret_access_key, region, bucket)`, `stripe: (publishable_key, secret_key, webhook_secret)`.

5. **Run the development server:**
   ```bash
   bin/dev
   ```
   Visit `http://localhost:3000` to see the app.

## 🧪 Testing

The project uses **Minitest** (Rails default) with fixtures.

```bash
# Run all tests
bin/rails test

# Run a single model test
bin/rails test test/models/manga_test.rb

# Run full CI suite (rubocop + audits + tests + seed)
bin/ci
```

## 🚢 Deployment

The app is optimized for deployment on **Render**.

1. Connect your GitHub repo to Render.
2. Set Environment Variables:
   - `RAILS_MASTER_KEY`: The content of your `config/master.key`.
3. Build Command: `bundle install && bundle exec rails assets:precompile && bundle exec rails db:migrate`
4. Start Command: `bundle exec puma -C config/puma.rb`

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
