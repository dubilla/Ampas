# Ampas

A Rails 4.2.8 web application for managing award pools and entries. Users can create and participate in pools, submit entries, and track award ceremonies. The application features a modern frontend with Bourbon, Neat, and Bitters for a clean, responsive design.

## Features

- Ruby on Rails 4.2.8
- PostgreSQL database
- Devise for authentication
- Pundit for authorization
- Modern frontend with Bourbon, Neat, and Bitters
- RSpec for testing
- Code quality tools (Rubocop, Rails Best Practices)

## Prerequisites

- Ruby 2.2.2 or higher
- PostgreSQL
- Bundler
- Node.js (for asset compilation)

## Setup

1. Clone the repository:
```bash
git clone [your-repository-url]
cd ampas
```

2. Install dependencies:
```bash
bundle install
```

3. Set up the database:
```bash
rails db:create db:migrate
```

4. Start the Rails server:
```bash
rails server
```

The application will be available at `http://localhost:3000`

## Development

- Run tests: `bundle exec rspec`
- Run code quality checks: `bundle exec rubocop`
- Run Rails best practices check: `bundle exec rails_best_practices`

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 