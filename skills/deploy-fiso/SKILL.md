# Deploy to FISO

Deploy FISO widget packages to S3 and notify the FISO server via Pusher.

## Trigger

User says "deploy to fiso", "fiso deploy", "deploy staging", "deploy production", "bootstrap fiso", or "rollback fiso".

## Commands

This skill has three modes:

- **bootstrap** — Configure a repo for FISO deployment (run once per repo)
- **deploy** — Build and deploy to staging or production
- **rollback** — Re-deploy the previous version

---

## Bootstrap

Run when the user says "bootstrap fiso" or when `.fiso-deploy.json` is missing in the current directory.

### Process

1. **Detect build tool** by checking (in order):
   - `Gruntfile.js` / `Gruntfile.coffee` → `npx grunt --target=production --force`
   - `webpack.config.js` + npm script containing `build` → `cross-env NODE_ENV=production npm run build`
   - `package.json` scripts containing `build` → `npm run build`
   - If none found → ask the user

2. **Read `.nvmrc`** — extract the Node version. If missing, warn the user and ask them to specify one.

3. **Detect install command** by checking:
   - `package-lock.json` exists → `npm ci`
   - `yarn.lock` exists → `yarn install --frozen-lockfile`
   - Neither → `npm install`
   - Ask the user if `--legacy-peer-deps` or `--ignore-scripts` is needed (do NOT assume)

4. **Determine tarball prefix** — show the known prefix mapping table and ask the user to confirm or provide their prefix. Check S3 for existing tarballs to verify the prefix if possible.

5. **Determine dist directory** — ask the user: "Does the tarball package the entire repo root (minus excludes), or just a specific output directory like `dist/`?"

6. **Propose excludes** — suggest a default list and let the user confirm/edit:
   ```
   node_modules, .git, tmp, test, .github, .kiro, .fallow, storybook, .storybook, reports, .nyc_output
   ```

7. **Verify AWS CLI** — run `aws sts get-caller-identity --profile foxsports-web-powerdev-185314292360` to confirm access.

8. **Verify Pusher credentials** — check that `PUSHER_KEY` and `PUSHER_SECRET` environment variables are set. If not, tell the user to export them.

9. **Test Pusher signing** — run a dry-run of the signing logic to confirm `md5` and `openssl dgst` work on this machine (macOS uses `md5 -r`, Linux uses `md5sum`).

10. **Write `.fiso-deploy.json`** in the repo root:

```json
{
  "prefix": "<confirmed-prefix>",
  "buildCommand": "<detected-or-user-provided>",
  "installCommand": "<detected-or-user-provided>",
  "distDir": "<root-or-dist>",
  "nodeVersion": "<from-nvmrc>",
  "excludes": ["<confirmed-list>"],
  "awsProfile": "foxsports-web-powerdev-185314292360"
}
```

### Known Prefix Mapping

| Project | Tarball prefix |
|---------|---------------|
| iso-patterns | patterns |
| iso-article | article |
| iso-bracket | bracket |
| iso-explicitmodal | explicitmodal |
| iso-goalcentre | goalcentre |
| iso-magneton | magneton |
| iso-matchcentre | matchcentre |
| iso-mcafl | mcafl |
| iso-mcnrl | mcnrl |
| iso-mcfootball | mcfootball |
| iso-mediacentre | mediacentre |
| iso-misc | misc |
| iso-munchlax | munchlax |
| iso-navigation | navigation |
| iso-pikachu | pikachu |
| iso-scoreboard | scoreboard |
| iso-scorecentre | scorecentre |
| iso-thelab | thelab |
| iso-tvguide | tvguide |
| iso-vendor | vendor |
| iso-video | video |
| iso-videofswidgets | videofswidgets |
| iso-widgets | widgets |

---

## Deploy

### Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| environment | Yes | — | `staging` or `production` |
| suffix | No | — | Appended to version: `2.7.7-fix1` |
| dry-run | No | false | Build + tarball but skip upload and Pusher |
| skip-build | No | false | Skip install/build, use existing dist (for retries) |

### Process

1. **Read `.fiso-deploy.json`** — if missing, tell user to run bootstrap first.

2. **Read version** from `package.json`. If `suffix` is provided, append it: `{version}-{suffix}`.

3. **Validate Node version** — compare current `node --version` against `.nvmrc`. Warn (don't block) if mismatched.

4. **Build** (unless `--skip-build`):
   - Run the install command from config
   - Run the build command from config

5. **Create tarball**:
   ```bash
   FILENAME="{prefix}_{version}.tar.gz"
   tar czf "${FILENAME}" --exclude='node_modules' --exclude='.git' [... other excludes from config ...] -C {distDir} .
   ```
   If `distDir` is `.` (root), tar from the repo root. If it's `dist/`, tar from within `dist/`.

6. **Check S3 for existing tarball**:
   ```bash
   aws s3 ls "s3://{bucket}/{prefix}/{prefix}_{version}.tar.gz" --profile foxsports-web-powerdev-185314292360
   ```
   If it exists, ask the user: "Version {version} already exists in {environment}. Overwrite? (y/n)"

7. **Upload to S3** (unless dry-run):
   ```bash
   aws s3 cp "{prefix}_{version}.tar.gz" "s3://{bucket}/{prefix}/{prefix}_{version}.tar.gz" --profile foxsports-web-powerdev-185314292360
   ```

8. **Trigger Pusher** (unless dry-run):
   ```bash
   PUSHER_APP_ID="1065930"
   PUSHER_CLUSTER="ap4"
   PUSHER_CHANNEL="{channel}"  # fs-web-fiso-staging or fs-web-fiso-production
   TIMESTAMP=$(date +%s)
   BODY='{"name":"update","channel":"'"${PUSHER_CHANNEL}"'","data":"{}"}'
   BODY_MD5=$(printf '%s' "$BODY" | md5 -r | awk '{print $1}')
   PATH_STR="/apps/${PUSHER_APP_ID}/events"
   STRING_TO_SIGN="POST\n${PATH_STR}\nauth_key=${PUSHER_KEY}&auth_timestamp=${TIMESTAMP}&auth_version=1.0&body_md5=${BODY_MD5}"
   AUTH_SIG=$(printf '%b' "$STRING_TO_SIGN" | openssl dgst -sha256 -hmac "${PUSHER_SECRET}" | awk '{print $NF}')
   curl -sf -X POST \
     "https://api-${PUSHER_CLUSTER}.pusher.com${PATH_STR}?auth_key=${PUSHER_KEY}&auth_timestamp=${TIMESTAMP}&auth_version=1.0&body_md5=${BODY_MD5}&auth_signature=${AUTH_SIG}" \
     -H "Content-Type: application/json" \
     -d "$BODY"
   ```

9. **Update deploy history** — append to `.fiso-deploy-history.json`:
   ```json
   {
     "deployments": [
       {
         "version": "2.7.7",
         "environment": "staging",
         "timestamp": "2026-07-08T16:44:00+10:00",
         "tarball": "patterns_2.7.7.tar.gz"
       }
     ]
   }
   ```

10. **Post-deploy reminders**:
    - If production: display reminder:
      ```
      ⚠️  PRODUCTION DEPLOY — Manual step required:
      Update the widget version in WordPress admin dashboard.
      The version text field needs to be updated to: {version}
      ```
    - Print summary: tarball name, S3 path, environment, timestamp.

### Environment Config

| Environment | S3 Bucket | Pusher Channel |
|-------------|-----------|----------------|
| staging | `foxsports-fiso-data-staging` | `fs-web-fiso-staging` |
| production | `foxsports-fiso-data` | `fs-web-fiso-production` |

### Credential Sources

| Credential | Source |
|------------|--------|
| AWS | Profile `foxsports-web-powerdev-185314292360` via AWS CLI |
| Pusher Key | Environment variable `PUSHER_KEY` |
| Pusher Secret | Environment variable `PUSHER_SECRET` |

---

## Rollback

### Process

1. Read `.fiso-deploy-history.json` — find the last two deployments for the specified environment.
2. Show the user: "Current: {current_version}, Previous: {previous_version}. Roll back?"
3. If confirmed:
   - Verify the previous tarball still exists in S3
   - Trigger Pusher notification (the tarball is already in S3, FISO just needs to be told to serve it)
   - Note: rollback does NOT re-upload — it just re-notifies FISO to use the previous version
4. If production: remind user to update WordPress version config back to the previous version.
5. Log the rollback in `.fiso-deploy-history.json`.

**Important:** Rollback assumes the previous tarball is still in S3. If S3 has been cleaned, rollback won't work — fall back to a full redeploy of the previous version from git.

---

## Prerequisites Check

Before any deploy or rollback, validate:

- [ ] `.fiso-deploy.json` exists (otherwise: "Run bootstrap first")
- [ ] AWS CLI is installed (`which aws`)
- [ ] AWS profile is valid (`aws sts get-caller-identity --profile foxsports-web-powerdev-185314292360`)
- [ ] `PUSHER_KEY` environment variable is set
- [ ] `PUSHER_SECRET` environment variable is set
- [ ] Current directory contains a `package.json`

If any check fails, print the specific fix needed and stop.

---

## Dry Run

When `--dry-run` is specified:
- Run the full build + tarball creation
- Print the S3 path that WOULD be uploaded
- Print the Pusher payload that WOULD be sent
- Do NOT upload to S3
- Do NOT trigger Pusher
- Do NOT update `.fiso-deploy-history.json`

---

## Error Handling

| Error | Action |
|-------|--------|
| Build fails | Stop. Show the error output. Suggest checking Node version and dependencies. |
| S3 upload fails | Stop. Show the error. Suggest checking AWS profile/permissions. |
| Pusher notification fails | Warn but don't fail. Print: "Pusher notification failed — FISO may not pick up the new version automatically. Check FISO server logs." |
| Tarball already exists in S3 | Ask user to confirm overwrite before proceeding. |

---

## macOS Compatibility

The Pusher signing uses `md5`. On macOS, use:
```bash
md5 -r <<< "$BODY" | awk '{print $1}'
```

On Linux, use:
```bash
echo -n "$BODY" | md5sum | awk '{print $1}'
```

Detect the platform at runtime:
```bash
if command -v md5 &>/dev/null; then
  BODY_MD5=$(printf '%s' "$BODY" | md5 -r | awk '{print $1}')
else
  BODY_MD5=$(printf '%s' "$BODY" | md5sum | awk '{print $1}')
fi
```
