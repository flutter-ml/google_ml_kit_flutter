---
name: pr-comment-handler
description: Fetches unresolved pull request comments using the GitHub CLI (gh), addresses feedback in the codebase, and formats markdown replies for easy copy-pasting to GitHub PRs. Use when the user asks to address PR comments, review PR feedback, or resolve PR review threads.
---

# PR Comment Handler Skill

This skill guides the AI assistant in using the GitHub CLI (`gh`) to retrieve unresolved review comments from a GitHub Pull Request, address code feedback directly in the codebase, verify changes with tests, and format markdown-ready replies for the user to copy/paste onto GitHub.

---

## Workflow Steps

### Step 1: Identify the Pull Request

1. Check if the user specified a PR number, URL, or branch.
2. If no PR identifier is provided, query the current branch's PR using:
   ```bash
   gh pr view --json number,url,headRefName,baseRefName
   ```
3. Extract `OWNER`, `REPO`, and `PR_NUMBER`.

---

### Step 2: Fetch Unresolved Comments & Review Threads

Run a GraphQL query via `gh api graphql` to retrieve recent review threads (up to 50 threads and 20 comments per thread; paginate if `hasNextPage` is true) and filter for unresolved threads (`isResolved: false`):

```bash
gh api graphql -f query='
query($owner: String!, $repo: String!, $pr: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      number
      title
      url
      reviewThreads(first: 50) {
        nodes {
          id
          isResolved
          isOutdated
          path
          line
          originalLine
          comments(first: 20) {
            nodes {
              id
              author { login }
              body
              createdAt
            }
          }
        }
      }
      comments(first: 50) {
        nodes {
          id
          author { login }
          body
          createdAt
        }
      }
    }
  }
}' -f owner="<OWNER>" -f repo="<REPO>" -F pr=<PR_NUMBER>
```

Filter the results:

- **Review Threads:** Keep threads where `isResolved == false`.
- **Issue Comments:** Extract top-level PR conversation comments requiring action.

---

### Step 2.1: Early Exit Check

- If there are **no unresolved review threads** (`isResolved == false` is empty) and **no unaddressed comments**:
  1. Immediately inform the user:
     ```markdown
     🎉 All comments on PR #<PR_NUMBER> have already been addressed and resolved!
     ```
  2. Exit the workflow immediately without making code changes or running tests.

---

### Step 3: Inspect Code & Address Feedback

For each unresolved comment/thread:

1. Locate the file (`path`) and target line range (`line` or `originalLine`).
2. Read the source code using `view_file` (or `view`).
3. Carefully analyze the reviewer's request and any explicit code suggestions provided.
4. Evaluate any reviewer-provided code suggestions against the overall system architecture, safety, and design intent.
5. If the suggestion is valid and aligns with the codebase design, implement the code changes using text replacement tools.
6. If no changes are needed or the suggestion conflicts with design requirements, prepare a clear technical explanation justifying the current approach.

---

### Step 4: Run Verification Tests & Linters

Before outputting replies, verify all code edits locally:

1. Run pre-commit checks:
   ```bash
   uv run pre-commit run --all-files
   ```
2. Run unit tests:
   ```bash
   uv run python manage.py test --settings=besties_backend.test_settings_sqlite
   ```

---

### Step 5: Generate Markdown Replies

Present a structured, easy-to-read summary for the user containing markdown blocks ready for copy/pasting onto GitHub.

For each unresolved thread, format the output as follows:

````markdown
### 💬 Comment Thread on `[file_path:line]`

> **Reviewer (@username):** _"Comment body text here"_

**Status:** ✅ Addressed / ℹ️ Answered

#### Action Taken:

- Description of code changes made or technical explanation provided.

#### Copy/Paste Reply for GitHub:

```markdown
Thanks @username!

[Detailed response explaining the code changes made, or providing the requested clarification].

Commit/Fix applied in `file_path`.
```
````
