---
name: deploy-coupler
description: Deploy foxsports-fedo-coupler to Elastic Beanstalk (staging or production). Use when the user says "deploy coupler" or "coupler deploy".
---
# Deploy Coupler

Deploy the foxsports-fedo-coupler Node.js API gateway to Elastic Beanstalk.

## Trigger

User says "deploy coupler", "coupler deploy", "deploy coupler to staging/production".

## Environment Map

| Environment | EB App | EB Environment | CNAME |
|-------------|--------|----------------|-------|
| Staging | Coupler | `coupler-staging-env` | `coupler-staging-foxsports.ap-southeast-2.elasticbeanstalk.com` |
| Production | Coupler | `coupler-production-env` | `coupler-production-foxsports.ap-southeast-2.elasticbeanstalk.com` |

## AWS Config

| Setting | Value |
|---------|-------|
| Account | foxsports-domestic-prod (`185314292360`) |
| Region | `ap-southeast-2` |
| Profile | `foxsports-web-powerdev-185314292360` |
| S3 Bucket | `elasticbeanstalk-ap-southeast-2-185314292360` |
| S3 Key Pattern | `coupler-versions/{branch}/{version-label}.zip` |
| Platform | 64bit Amazon Linux 2018.03 v4.14.1 running Node.js |

## Prerequisites

Before deploying, validate:

- [ ] AWS CLI installed (`which aws`)
- [ ] AWS profile valid (`aws sts get-caller-identity --profile foxsports-web-powerdev-185314292360`)
- [ ] Working directory is `foxsports-fedo-coupler` repo root
- [ ] On the correct branch (`develop` for staging, `master` for production)
- [ ] `node_modules/` exists (`yarn install --ignore-engines` if missing)

## Deploy Process

### Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| environment | Yes | — | `staging` or `production` |
| version-label | No | auto | Auto-generated from branch + increment |
| skip-build | No | false | Skip build, use existing `dist/` |

### Steps

1. **Validate AWS access**:
   ```bash
   aws sts get-caller-identity --profile foxsports-web-powerdev-185314292360
   ```

2. **Install dependencies** (if needed):
   ```bash
   yarn install --ignore-engines
   ```

3. **Build** (unless `--skip-build`):
   ```bash
   NODE_OPTIONS=--openssl-legacy-provider npx cross-env NODE_ENV=production webpack --config webpack.config.js
   ```
   Verify: `dist/js/coupler.min.js` exists.

4. **Determine version label**:
   - Query existing versions: `aws elasticbeanstalk describe-application-versions --application-name Coupler --profile foxsports-web-powerdev-185314292360 --region ap-southeast-2`
   - For staging: `develop-{N+1}` (increment from latest `develop-*` label)
   - For production: `master-{N+1}` (increment from latest `master-*` label)
   - Or use a custom label if the user provides one

5. **Create zip artifact**:
   ```bash
   zip -r /tmp/coupler-deploy.zip dist/ public/ .ebextensions/ package.json
   ```
   The artifact contains:
   - `dist/js/coupler.min.js` — webpack-built server bundle
   - `public/` — static files (service worker, AMP push pages, favicons)
   - `.ebextensions/` — EB platform config (nginx, logstash)
   - `package.json` — for EB to run `npm install` on the instance

   **Do NOT include**: `node_modules/`, `.git/`, `test/`, `src/`, `tmp/`

6. **Upload to S3**:
   ```bash
   aws s3 cp /tmp/coupler-deploy.zip \
     "s3://elasticbeanstalk-ap-southeast-2-185314292360/coupler-versions/{branch}/{version-label}.zip" \
     --profile foxsports-web-powerdev-185314292360 --region ap-southeast-2
   ```

7. **Create application version**:
   ```bash
   aws elasticbeanstalk create-application-version \
     --application-name Coupler \
     --version-label "{version-label}" \
     --source-bundle "S3Bucket=elasticbeanstalk-ap-southeast-2-185314292360,S3Key=coupler-versions/{branch}/{version-label}.zip" \
     --profile foxsports-web-powerdev-185314292360 --region ap-southeast-2
   ```

8. **Deploy to environment**:
   ```bash
   aws elasticbeanstalk update-environment \
     --environment-name {environment-name} \
     --version-label "{version-label}" \
     --profile foxsports-web-powerdev-185314292360 --region ap-southeast-2
   ```

9. **Wait for deployment to complete**:
   ```bash
   aws elasticbeanstalk wait environment-updated \
     --environment-name {environment-name} \
     --profile foxsports-web-powerdev-185314292360 --region ap-southeast-2
   ```
   This blocks until the environment health returns to Ready (or times out after 10 min).

10. **Verify health**:
    ```bash
    aws elasticbeanstalk describe-environment-health \
      --environment-name {environment-name} \
      --attribute-names All \
      --profile foxsports-web-powerdev-185314292360 --region ap-southeast-2
    ```
    Confirm `HealthStatus: Ok` and `Status: Ready`.

11. **Print summary**:
    - Version label deployed
    - Environment URL
    - Timestamp

## Rollback

If the deployment fails or causes issues:

```bash
# Find the previous version label
aws elasticbeanstalk describe-environments \
  --environment-names {environment-name} \
  --profile foxsports-web-powerdev-185314292360 --region ap-southeast-2

# Roll back to previous version
aws elasticbeanstalk update-environment \
  --environment-name {environment-name} \
  --version-label "{previous-version-label}" \
  --profile foxsports-web-powerdev-185314292360 --region ap-southeast-2
```

Production last known good: `master-48`
Staging last known good: `10`

## Error Handling

| Error | Action |
|-------|--------|
| SSO token expired | Run `aws sso login --profile foxsports-web-powerdev-185314292360` |
| Build fails (OpenSSL) | Ensure `NODE_OPTIONS=--openssl-legacy-provider` is set |
| S3 upload fails | Check profile permissions and bucket name |
| Environment update fails | Check EB events: `aws elasticbeanstalk describe-events --environment-name {env}` |
| Health degraded after deploy | Rollback immediately, check `/var/log/nodejs/nodejs.log` on the instance |

## Gotchas

- **Node version mismatch**: The EB platform runs Node 12.x. The local build uses Node 22 with `--openssl-legacy-provider`. The webpack output is compatible regardless — it's just a bundled JS file.
- **No `node_modules` in zip**: EB runs `npm install` on the instance from `package.json`. Dependencies must be installable from the public npm registry (no private `@fsa/*` packages).
- **Yarn locally, npm on EB**: We use `yarn install --ignore-engines` locally for the lockfile, but EB uses `npm install`. The `package.json` dependencies must work with both.
- **`.ebextensions` must be at zip root**: If the zip structure is wrong, EB ignores the config files silently.
- **Production deploys should go through staging first**: Always verify on `coupler-staging-env` before touching `coupler-production-env`.
