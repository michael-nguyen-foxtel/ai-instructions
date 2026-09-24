# Product: WatchAFL / WatchNRL

International streaming products for AFL and NRL content. Same codebase — AFL and NRL differ only in theming and data source configuration.

- WatchAFL: https://www.watchafl.com.au
- WatchNRL: https://www.watchnrl.com

## Repos

| Repo (short name) | Role | Depth |
|---|---|---|
| hawk-widgets | Widgets/components with endpoints and basic routing | Deep — primary UI code lives here |
| hawk-web-server | Web server: main routing, template creation, middleware (rate limiting), proxy routes, query param handling | Deep — server logic and routing |
| streamotion-web-app | Monorepo containing shared utils (widgets-common), utility libraries. Not the app container itself | Shallow — consume its exports, don't modify internals unless the task is explicitly there |
| fiso-server | Serves versioned widget packages (hawk-widgets, etc.) based on config or query param | Shallow — understand its versioning interface, rarely modify |

## Key Seams

- **hawk-web-server → hawk-widgets**: server renders templates that load hawk-widgets bundles
- **hawk-web-server → fiso-server**: requests specific widget versions via config/query param
- **fiso-server → hawk-widgets**: serves the built widget packages to the browser
- **hawk-widgets → streamotion-web-app**: imports shared utilities from widgets-common and other libs
- **hawk-web-server → Platform APIs**: proxy routes for auth, entitlements, content

## Theming

AFL and NRL share all code. Differentiation is via:
- Theme tokens (colours, logos, branding)
- Data source configuration (which sport/league content to fetch)
- Deploy target may differ but codebase is identical

## Environment Map

| Env | AWS Account | Region | EB App | URL |
|---|---|---|---|---|
| FISO Staging | international-ott-prod (618381512399) | ap-southeast-1 | FISO Web / Fisoweb-staging | http://fisoweb-staging.eba-42c3p3b2.ap-southeast-1.elasticbeanstalk.com/ |
| FISO Production | international-ott-prod (618381512399) | us-east-1 | FISO Web / Fisoweb-production | http://fiso-hawk-production-foxsports.us-east-1.elasticbeanstalk.com/ |
| Hawk Staging | international-ott-prod (618381512399) | ap-southeast-1 | WatchAFL Web / Watchaflweb-staging | http://watchaflweb-staging.eba-dvtd4dmt.ap-southeast-1.elasticbeanstalk.com/ |
| Hawk Production | international-ott-prod (618381512399) | us-east-1 | WatchAFL Web / Watchaflweb-production | http://watchaflweb-production.eba-fmmwkpbf.us-east-1.elasticbeanstalk.com/ |

## Releasing

Two independent release types — know which one you're doing.

### 1. hawk-web-server on its own

Same as magneto-web-server: bump `package.json` (from `node-app/`), open a version
PR, merge, then deploy to Elastic Beanstalk. No widget coupling. Use the `version-bump`
skill.

### 2. hawk-widgets (coupled — production only)

hawk-widgets does **not** go live in production on its own. hawk-web-server hardcodes
the served widget version in `node-app/src/js/utils/constants.js`
(`FISO_VERSIONS.production.hawkwidgets`), so a widget release must be followed by a
web-server change + redeploy. Staging needs none of this — `FISO_VERSIONS.staging.hawkwidgets`
is `'main'`, so staging always serves the latest.

Sequence (do them in order — never pin the server to a version that isn't published):

1. **Release hawk-widgets** — version PR → merge → GitHub Release → publish workflow.
   **Gate:** confirm the release run is green AND its `Publish to FISO` job succeeded
   (produces `hawkwidgets_<version>.tar.gz`) before continuing. A red release run's
   publish steps are skipped — do not proceed. (The Mocha/testem job flakes; a retry
   that goes green is fine.)
2. **hawk-web-server PR #1 — pin the version.** Edit
   `FISO_VERSIONS.production.hawkwidgets` in `node-app/src/js/utils/constants.js`
   (leave `staging` as `'main'`). Branch `fix/WEB-XXXX-bump-hawkwidgets-<version>`;
   commit `fix(fiso): WEB-XXXX | pin production hawkwidgets to <version>`.
3. **hawk-web-server PR #2 — version bump.** A SEPARATE PR (blocked by #1), standard
   `version-bump` flow from `node-app/`.
4. **Manual EB deploy** of hawk-web-server → this is what makes the new widgets live in
   production.

Cross-link the widget PRs in each server PR's **Related PRs** section so the coupling is
traceable from either repo.

### Release tracking (both types)

A coupled hawk-widgets release is **one** release entry, not two. Track it as the
widgets release (Jira version + WRT ticket for the widgets version). The web-server
version bump is the *deploy mechanism*, not a release in its own right — record it only
in the release email's multi-repo "Version/s Released" / "Rollback Version/s" slots (the
`release-email` skill already supports multiple repos in one email) for rollback/audit.
Do not create a second Jira release version or WRT ticket for the web-server bump.

### Why Hawk is different from Magneto

magneto-web-server reads its widget versions from a **runtime config file**
(`FISO_VERSIONS_URL` → `.../common/web-server/fiso-versions.json` on the resources host),
so a magneto-widgets version change is a config edit — live without a server redeploy.
hawk-web-server bakes the version into **source** (`constants.js`), so Hawk needs the
coupled code-PR + bump + redeploy dance above. Moving Hawk to the same runtime-config
approach as Magneto would remove the coupling — a worthwhile future improvement, not done
yet.

## Gotchas

- hawk-widgets uses legacy testing systems — be mindful of test patterns
- International deployment means latency-sensitive regions (US, Asia) — consider CDN/caching implications
- A hawk-widgets deploy does **not** reach production until hawk-web-server is repinned and
  redeployed — see **Releasing → hawk-widgets (coupled)**. (Staging tracks `main`, so it
  updates on its own.)
