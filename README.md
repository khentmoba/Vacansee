# VacanSee

[![Deploy to Vercel](https://github.com/khentmoba/Vacansee/actions/workflows/deploy.yml/badge.svg)](https://github.com/khentmoba/Vacansee/actions/workflows/deploy.yml)

A real-time boarding house vacancy tracker for university students in Cagayan de Oro City. Students can filter verified listings by budget, location, and gender orientation while property owners update room availability in real-time.

## Live Deployment

The application is automatically synchronized with GitHub and deployed to Vercel:

- **Production**: [vacansee.vercel.app](https://vacansee.vercel.app)
- **Status**: Every push to `main` triggers a production build. Feature branches generate unique preview URLs.

## Tech Stack

- **Frontend**: Flutter Web (Stable channel)
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **CI/CD**: GitHub Actions + Vercel CLI

## Development

### Prerequisites

- Flutter SDK (Stable)
- Supabase Project
- Vercel Account (for deployment)

### Setup

1. Clone the repository.
2. Run `flutter pub get`.
3. Configure your Supabase environment variables (`SUPABASE_URL`, `SUPABASE_ANON_KEY`).
4. Run locally: `flutter run -d chrome`.

### CI/CD Configuration

The deployment pipeline is defined in `.github/workflows/deploy.yml`. It ensures that all code passes `flutter analyze` and `flutter test` before being built for the web and deployed to Vercel.
