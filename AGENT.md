# AGENT.md

This file guides AI agents to work effectively in the **Dreamkast** repository.

## Project Context
Dreamkast is an Online Conference System built with **Ruby on Rails** (Backend) and **Webpack/Bootstrap** (Frontend).
- **Ruby Version**: Managed via rbenv.
- **Language**: Use Japanese standard language for all documentation and comments.

## Workflows
- **Checklists**: Create task checklists under `docs/todo`.
    - Work iteratively according to the list.
    - specialized tasks should be checked off upon completion.

## Prerequisites
- **Docker Compose V2**: Required for backing services.
- **Node.js & Ruby**: Versions managed by `.node-version` and `.ruby-version`.

## Development Commands

### Setup
Install dependencies:
```bash
yarn install --check-files
bundle install
```

### Environment
Create `.env-local` from the template or ask the team for values.
```bash
export AUTH0_CLIENT_ID=...
# ... (see README.md for full list)
```

### Startup
1. Start backing services (DB, Redis, UI, etc.):
```bash
docker compose up -d fifo-worker db redis nginx localstack ui
```

2. Start the application (Rails + Webpack):
```bash
bundle exec foreman start -f Procfile.dev "$@" -e .env
```

### Testing
Run backend tests with RSpec:
```bash
bundle exec rspec
```
*Always ensure tests pass before requesting review.*

### Linting
Run and auto-correct Ruby linting errors:
```bash
bundle exec rubocop --autocorrect-all
```
*Always run linting before finishing a task.*
