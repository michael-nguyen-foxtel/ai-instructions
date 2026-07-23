# Release Email

Generate a formatted release notification email ready to paste into Outlook/Teams, pulling tickets from a Jira version.

## When to Use

- User says "release email", "generate release email", "write release notification"
- User provides a Jira version URL or version ID with a product name
- After a production deploy when the release email needs to go out

## Inputs (gather from user)

| Input | Required | Example |
|-------|----------|---------|
| Product | Yes (can be inferred from repo) | `watchafl` or `hubbl` |
| Jira version ID(s) or URL(s) | Yes | `80104` or multiple: `80104, 80105` |
| Released version name(s) | Yes | `Hawk Web Server v7.3.7` or multiple: `Hawk Web Server v7.3.7, Hawk Widgets v4.2.0` |
| Rollback version name(s) | Yes | `Hawk Web Server v7.3.5` or multiple: `Hawk Web Server v7.3.5, Hawk Widgets v4.1.8` |
| Date override | No | Defaults to today's date formatted as `DD Month YYYY` |

Multiple repos can be released together (e.g., Hawk Widgets + Hawk Web Server for a single WatchAFL/WatchNRL release, or Magneto Widgets + Magneto Web Server for Hubbl). In this case, all version IDs are queried and tickets are combined into a single email.

### Repo → Product auto-mapping

If the repo is known, infer the product automatically — don't ask:

| Repo | Product |
|------|---------|
| hawk-web-server | `watchafl` |
| hawk-widgets | `watchafl` |
| magneto-web-server | `hubbl` |
| magneto-widgets | `hubbl` |

## Product Configuration

| Field | WatchAFL/WatchNRL (`watchafl`) | Hubbl (`hubbl`) |
|-------|------|---------|
| Subject label | `WatchAFL/WatchNRL` | `HUBBL` |
| Target description | `WatchAFL and WatchNRL to production` | `hubbl.com.au` |
| Recipient (hint) | Streamotion All Staff | Streaming Aggregation All Staff |
| Recipient email | `Streamotion_All_Staff8396@foxtel.onmicrosoft.com` | `StreamingAggregationAllStaff@foxtel.com.au` |
| Jira project | WEB | WEB |

## Process

1. **Extract version ID(s)** — If user provides full URL(s), parse out the numeric version ID(s). The URL format is: `https://livesport.atlassian.net/projects/WEB/versions/{ID}/tab/release-report-all-issues`

2. **Fetch tickets from Jira** — For each version ID, use JQL to find issues:
   ```
   project = WEB AND fixVersion = {versionId}
   ```
   Use `searchJiraIssuesUsingJql` with cloudId `livesport.atlassian.net`. Combine results from all version IDs, deduplicating by issue key.

3. **Filter tickets** — Exclude tickets that are purely developer-facing:
   - Dependency updates / package bumps
   - Refactors with no user-visible change
   - CI/CD or build pipeline changes
   - Test-only changes
   - Infrastructure/DevOps work
   
   Only include tickets that result in a user-visible change (new feature, UX improvement, or bug fix that affected users).

4. **Categorise tickets by issue type** — Map Jira issue types to email categories:
   | Jira Issue Type | Email Category |
   |-----------------|----------------|
   | Bug | Bugfix |
   | Story, Task, Improvement | Feature |
   | Sub-task | Inherit parent type; if unavailable, treat as Feature |

5. **Rewrite ticket summaries for non-technical audience** — The Jira ticket summaries are often technical. Rewrite each into plain language that describes the user impact:
   - ❌ "Fix SSR hydration mismatch on highlights carousel component"
   - ✅ "Fixed an issue where highlights were not showing correctly"
   - ❌ "Add DAZN deep links to MyAccount widget for Kayo/Binge"
   - ✅ "Added links on the My Account page to lead users to DAZN's Kayo Sports and Binge web apps if users want to manage subscriptions"

   Keep the rewrite concise (one sentence) but clear about what changed for the user.

6. **Construct the release dashboard URL(s)**:
   ```
   https://livesport.atlassian.net/projects/WEB/versions/{versionId}/tab/release-report-all-issues
   ```
   If multiple versions, list each URL.

7. **Assemble the email** using the output format below.

## Output Format

Generate FOUR outputs:

### 1. Subject Line

```
RELEASE: Web - {subject_label} – {DD Month YYYY}
```

### 2. Recipient

Display as a note:
```
To: {recipient_email}
```

### 3. Email Body (Rich Text / HTML)

Output as an HTML snippet that the user can paste into Outlook or any rich text email client. This ensures bold headers render correctly without manual formatting.

```html
<p>Hi All,<br>Web has released to {target_description} and the details are as follows:</p>

<p><b>Feature:</b></p>
<ul>
  <li>{Rewritten summary}</li>
  <li>{Rewritten summary}</li>
</ul>

<p><b>Bugfix:</b></p>
<ul>
  <li>{Rewritten summary}</li>
</ul>

<p><b><u>Release Dashboard</u></b></p>
<ul>
  <li><a href="{release_dashboard_url}">{release_dashboard_url}</a></li>
</ul>

<p><b><u>Version/s Released</u></b></p>
<ul>
  <li>{released_version_name_1}</li>
  <li>{released_version_name_2}</li>
</ul>

<p><b><u>Rollback Version/s</u></b></p>
<ul>
  <li>{rollback_version_name_1}</li>
  <li>{rollback_version_name_2}</li>
</ul>

<p>On behalf of the Web App team</p>
```

### 4. Airtable Summary

Generate a separate entry for EACH repo version being released. This is for the "Software / Platform Releases" Airtable form.

For each repo version, output:

```
--- Airtable Entry: {repo_name} ---
Your name: Michael Nguyen
Product: {OTT | Hubbl}
Release Title and Version: {repo_name} v{version}
Environment: Production
Release Notes and Description:
* WEB-XXXX | {Jira summary as-is}
* WEB-YYYY | {Jira summary as-is}
Version: {version}
Platform / Service: (blank)
Team: Web
```

**Product mapping:**
- WatchAFL/WatchNRL → `OTT`
- Hubbl → `Hubbl`

**Important:** Include ALL tickets from the Jira version(s) in the Release Notes — including dev-related work (dependency bumps, refactors, CI changes, tests). Use the raw Jira summary, no rewriting needed. The same ticket list goes into each repo entry.

This is for the user to paste into the Airtable release form manually — one submission per repo.

## Formatting Rules

- **Bold** the category names (Feature:, Bugfix:) in the email
- **Bold + underline** the footer headers (Release Dashboard, Version/s Released, Rollback Version/s)
- Use bullet points — `<ul><li>` in HTML, `•` in plain text
- Date format: `DD Month YYYY` (e.g., `03 June 2026`)
- Release dashboard URLs should be clickable links in the HTML version
- Omit empty categories — only include categories that have tickets
- Category order: Feature first, then Bugfix
- No Jira keys in the email body — this is a non-technical audience email
- Keep each bullet to one clear sentence describing the user-facing change

## Clipboard Copy

After generating the email, automatically copy the HTML version to the user's clipboard as rich text using:

```bash
echo '<div style="font-family: Calibri, Arial, sans-serif; font-size: 11pt;">{html_content}</div>' | textutil -stdin -format html -convert rtf -stdout | pbcopy
```

This allows the user to immediately Cmd+V into Outlook/Teams with full formatting (bold, underline, links, bullets) preserved. No manual formatting needed.

**Important:** 
- Always wrap content in a `<div>` with `font-family: Calibri, Arial, sans-serif; font-size: 11pt;` to match Outlook's default font.
- Escape single quotes in the HTML content before passing to the shell command.

## Rules

- Always use today's date unless the user provides an override
- If the Jira version has no user-facing tickets (all filtered out), warn the user and suggest whether to still send or skip
- If a ticket has no clear type mapping, put it under "Feature"
- Don't include sub-tasks if the parent is already listed (avoid duplication)
- Don't include the email signature — the user has that configured in their email client
- When multiple versions are released together, list all version names under "Version/s Released" and all rollback versions under "Rollback Version/s"
- The HTML output should be a self-contained snippet (no `<html>`, `<head>`, or `<body>` wrapper) — just the content that goes in the email body
- If a ticket's description or summary isn't clear enough to rewrite for a non-technical audience, read the ticket's full description from Jira to understand the user impact before rewriting
