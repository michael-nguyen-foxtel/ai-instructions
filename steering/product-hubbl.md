# Product: Hubbl

Hardware sales and account management product. Handles Hubbl hardware purchases and account creation to connect/register hardware to user accounts.

- URL: https://hubbl.com.au/

Note: Hubbl was previously an aggregator app (hardware sales + subscription aggregation). It no longer handles subscription aggregation.

## Repos

| Repo (short name) | Role | Depth |
|---|---|---|
| quicksilver | Component library for Hubbl UI | Shallow — consume components, only modify when building new shared UI |
| magneto-widgets | The web app: widgets, built components, endpoint usage, 2nd-level routing rules | Deep — primary application code lives here |
| magneto-web-server | Web server: main routing, template creation, middleware, query param handling | Deep — server logic and routing |
| streamotion-web-app | Monorepo containing shared utils (widgets-common), utility libraries. Not the app container itself | Shallow — consume its exports |
| fiso-server | Serves versioned widget packages (magneto-widgets, etc.) based on config or query param | Shallow — understand its versioning interface |

## Key Seams

- **magneto-web-server → magneto-widgets**: server renders templates that load magneto-widgets bundles
- **magneto-web-server → fiso-server**: requests specific widget versions via config/query param
- **fiso-server → magneto-widgets**: serves built widget packages to the browser
- **magneto-widgets → quicksilver**: imports UI components from the component library
- **magneto-widgets → streamotion-web-app**: imports shared utilities from widgets-common
- **magneto-web-server → Platform APIs**: proxy routes for auth, hardware registration, account management

## User Flows

- **Hardware Purchase**: browse products → select hardware → checkout → payment → order confirmation
- **Account Creation**: sign up → verify identity → register hardware to account → dashboard
- **Hardware Registration**: login → add device → enter hardware code → confirm pairing

## Environment Map

| Env | AWS Account | Region | EB App | URL |
|---|---|---|---|---|
| Staging | martian-foxsports-nonprod (856308764217) | ap-southeast-2 | Magneto Web / Magnetoweb-staging | http://magnetoweb-staging.ap-southeast-2.elasticbeanstalk.com/ |
| Production | martian-foxsports-prod (856380941954) | ap-southeast-2 | Magneto Web / Magnetoweb-production | http://magnetoweb-production.ap-southeast-2.elasticbeanstalk.com/ |
| FISO Staging | martian-foxsports-nonprod (856308764217) | ap-southeast-2 | FISO Web / Fisoweb-staging | http://fisoweb-staging.ap-southeast-2.elasticbeanstalk.com/ |
| FISO Production | martian-foxsports-prod (856380941954) | ap-southeast-2 | FISO Web / Fisoweb-production | http://fisoweb-production.ap-southeast-2.elasticbeanstalk.com/ |

## Gotchas

- FISO serves specific versions — a widget deploy doesn't go live until FISO config is updated
- Hubbl is NOT a streaming/content product — no video playback, no content browsing
- quicksilver is a component library (like a design system), not an app
