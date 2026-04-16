# Quickstart: Restoring CI/CD Automation

Follow these steps to verify the fix and restore automation.

## Prerequisites
- Flutter SDK installed.
- Git installed.
- Access to the `khentmoba/Vacansee` repository.

## Verification Steps

### 1. Fix Git Structural Issue
Ensure the nested `.git` directory is removed:
```powershell
Remove-Item -Recurse -Force Vacansee/.git
```

### 2. Verify Local Analysis
Run the analyzer and ensure it passes:
```powershell
flutter analyze
```

### 3. Stage and Push
Stage all changes (including the previously "untracked" Vacansee folder) and push:
```powershell
git add .
git commit -m "Fix: CI/CD - Resolve analysis errors and git structure"
git push origin 003-fix-cicd-pipeline
```

### 4. Monitor Deployment
- Visit: [GitHub Actions](https://github.com/khentmoba/Vacansee/actions)
- Ensure the workflow `Deploy to Vercel` triggers and passes.
- Verify the Vercel Preview URL.
