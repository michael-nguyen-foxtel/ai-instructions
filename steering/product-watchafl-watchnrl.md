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

## Gotchas

- hawk-widgets uses legacy testing systems — be mindful of test patterns
- International deployment means latency-sensitive regions (US, Asia) — consider CDN/caching implications
- FISO serves specific versions — a widget deploy doesn't go live until FISO config is updated
