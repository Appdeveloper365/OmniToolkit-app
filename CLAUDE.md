# OmniToolkit Project Guidelines

## Git Automation Workflow
To ensure the remote repository is always in sync and to avoid merge conflicts, the following workflow is strictly followed for every task:

1. **Sync**: Always start by running `git pull origin main` to ensure the local environment is up to date.
2. **Implement**: Perform the requested changes, fixes, or new features.
3. **Verify**: Run relevant tests or verify the UI changes.
4. **Commit**: 
   - Stage all changes: `git add .`
   - Create a professional commit message using conventional commits (e.g., `feat:`, `fix:`, `refactor:`, `chore:`).
5. **Deploy**: Run `git push origin main` to upload changes to GitHub immediately.

## Project Context
- **App Name**: OmniToolkit
- **Core Modules**: 
  - Scientific Calculator (Portrait mobile layout)
  - Calendar with Local Notes (Privacy-focused local SQLite storage)
  - World Radio Explorer
  - ZIP/Area Code Lookup
  - Password Generator
- **Tech Stack**: Flutter, Riverpod, SQLite (via sqflite)
- **Deployment**: GitHub Actions for Web PWA build and deploy.

## Coding Standards
- Use `PremiumCalculatorButton` for all calculator keys.
- Maintain a portrait-first design for mobile compatibility.
- Ensure all local storage is handled via `AppDatabase` to prevent cloud leaks.
