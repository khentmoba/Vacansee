# Quickstart: CI/CD Deployment

This guide explains how to manage and verify deployments for **VacanSee**.

## Prerequisites

1. **Vercel CLI**: Installed and linked to your project.
2. **GitHub Secrets**: Ensure the following secrets are configured in your repository:
   - `VERCEL_TOKEN`: Your Vercel Personal Access Token.
   - `VERCEL_ORG_ID`: Your Team/Org ID.
   - `VERCEL_PROJECT_ID`: The project ID for VacanSee.

## Deployment Workflow

### 1. Feature Previews
Every push to any branch (other than `main`) triggers a **Vercel Preview** deployment.
- **Where to find**: Check the PR comments or the GitHub Actions tab.
- **Purpose**: Verify feature stability in a live environment.

### 2. Production Deployment
Pushes or merges to the `main` branch trigger a **Vercel Production** deployment.
- **Where to find**: `vacansee.vercel.app`

## Troubleshooting

### Build Failures
- **Analysis Error**: If `flutter analyze` fails, the build will stop. Fix all lint/type errors.
- **Missing Secrets**: If you see "Vercel credentials not found", verify the GitHub Secrets match those in `.vercel/project.json`.
- **Regenerate Models**: If you see model errors, run `flutter pub run build_runner build` before pushing.
