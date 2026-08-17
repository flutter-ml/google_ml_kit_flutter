---
name: pr-preparer
description: Analyzes git branch diffs (added, modified, deleted files) against the default or target branch, and generates a conventional commit title, PR title, and formatted markdown PR description for copy-pasting to GitHub. Use when the user asks to prepare a PR, generate a PR description, generate a commit message, summarize branch changes, or create a PR template.
---

# PR Preparer Skill

This skill guides the AI assistant in comparing the current branch against the base/default branch (`develop`, `main`, `master`), analyzing all added, modified, and deleted files, and generating a conventional commit title, PR title, and a comprehensive, GitHub-ready markdown PR description.

---

## Workflow Steps

### Step 1: Determine the Base Branch & Diff Scope

1. **Identify the current branch and default target branch:**
   ```bash
   CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
   BASE_BRANCH=$(gh pr view --json baseRefName --jq '.baseRefName' 2>/dev/null || git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@refs/remotes/origin/@@' || echo "develop")
   ```
2. **Empty Diff & Branch Validation Check:**
   - Run a diff check against `$BASE_BRANCH` and working directory:
     ```bash
     BRANCH_DIFF=$(git diff --name-only "$BASE_BRANCH"...HEAD)
     WORKING_DIFF=$(git status -s)
     ```
   - **Case A: Zero changes anywhere (branch is identical to base & working tree is clean):**
     - Notify the user:
       ```markdown
       ℹ️ No changes detected on branch `<CURRENT_BRANCH>` compared to `<BASE_BRANCH>`.
       Please make code edits or switch to a branch with changes before running PR preparation.
       ```
     - Exit early without generating a PR description.

   - **Case B: Same branch or uncommitted-only changes:**
     - If `CURRENT_BRANCH == BASE_BRANCH` or `BRANCH_DIFF` is empty, but `WORKING_DIFF` has local edits, analyze uncommitted changes against `HEAD`:
       ```bash
       git diff HEAD
       git status -s
       ```

   - **Case C: Feature branch with committed changes (Standard Flow):**
     - Compare branch changes against `$BASE_BRANCH`:
       ```bash
       git diff --stat "$BASE_BRANCH"...HEAD
       git status -s
       ```

---

### Step 2: Analyze Code Changes

1. **Fetch detailed diffs** to understand the scope and intent of all changes:
   ```bash
   git diff "$BASE_BRANCH"...HEAD
   ```
2. **Categorize all changed files:**
   - 🟢 **Added (`[NEW]`)**: Newly created files, modules, scripts, or tests.
   - 🟡 **Modified (`[MODIFY]`)**: Updated configuration, refactored logic, schema edits, or updated docs.
   - 🔴 **Deleted (`[DELETE]`)**: Removed obsolete files, dead code, or redundant scripts.

3. **Identify key themes and impact:**
   - Architecture & logic changes.
   - Dependency or configuration updates.
   - CI/CD workflow modifications.
   - Database migrations or schema updates.
   - Documentation adjustments.

---

### Step 3: Format Conventional Commit & PR Details

Generate output with clear separation between titles and description, using formatted markdown blocks for easy one-click copy/pasting.

#### Format Template:

````markdown
### 📝 Conventional Commit Title

```text
<type>(<scope>): <short imperative summary in lower case, max 72 chars>
```

---

### 🔤 Pull Request Title

```text
<Type>: <Capitalized Concise Description of PR Goal>
```

---

### 📄 Pull Request Description

```markdown
## 📌 Overview

<Brief 2-3 sentence overview explaining the problem, context, and what this PR accomplishes.>

---

## 🛠 Key Changes

### [Component / Feature Area 1]

- 🟢 `path/to/new_file`: Brief description of what was added.
- 🟡 `path/to/modified_file`: Brief description of what changed.

### [Component / Feature Area 2]

- 🔴 `path/to/deleted_file`: Brief description of why this file was removed.

---

## 🧪 Verification & Testing

- [x] Ran unit tests: `uv run python manage.py test --settings=besties_backend.test_settings_sqlite`
- [x] Ran linters/pre-commit: `uv run pre-commit run --all-files`
- [x] Manual verification steps performed.

---

## ⚠️ Notes & Risk Assessment

- **Breaking Changes:** None / <List breaking changes if any>
- **Migration Required:** No / Yes (`python manage.py migrate`)
- **Environment Variables:** No new env vars required / <List new env vars>
```
````

---

## Guidelines & Best Practices

- **Conventional Commit Types**: Use `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `ci`, or `style`.
- **Imperative Mood**: Use imperative present tense in titles ("add feature" instead of "added feature").
- **Concise Summaries**: Group individual file changes by logical component (e.g., API, Database, CI/CD, Documentation) rather than listing random files.
- **Copy/Paste Friendly**: Always enclose output in markdown fenced code blocks (` ```text ` and ` ```markdown `).
