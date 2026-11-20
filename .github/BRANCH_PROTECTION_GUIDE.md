# Branch Protection Setup Guide

To complete the professional repository setup, protect your `main` branch from accidental force pushes.

## Steps to Enable Branch Protection:

1. Go to https://github.com/locvel/voite/settings/branches
2. Click **"Add rule"** or **"Add branch protection rule"**
3. In **"Branch name pattern"**, enter: `main`
4. Enable these settings:

### Recommended Protection Rules:

✅ **Require a pull request before merging**
- Require approvals: 0 (since you're solo, or set to 1 if you have team members)
- Dismiss stale pull request approvals when new commits are pushed

✅ **Require status checks to pass before merging**
- Require branches to be up to date before merging
- Add status checks: `analyze-and-test`, `Analyze (java)`, `Analyze (swift)` (from your CI workflows)

✅ **Require conversation resolution before merging**

✅ **Require signed commits** (optional, but recommended for security)

✅ **Include administrators** (applies rules to repo admins too)

❌ **Do not allow force pushes**

❌ **Do not allow deletions**

5. Click **"Create"** or **"Save changes"**

## Result:

After setup, the warning "Your main branch isn't protected" will disappear, and your repository will have professional-grade protection like major open-source projects!
