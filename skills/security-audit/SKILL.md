# Security Audit

Use when checking code or dependencies for security vulnerabilities.

## Trigger

User asks to "check security", "audit", "scan for vulnerabilities", or mentions security concerns.

## Checks to Perform

### 1. Dependency Vulnerabilities
- Run `npm audit` or `yarn audit` and summarise findings
- Flag any critical/high severity issues with remediation steps
- Check for outdated dependencies with known CVEs

### 2. Secrets & Credentials
- Scan for hardcoded API keys, tokens, passwords, connection strings
- Check `.env` files aren't committed (verify `.gitignore`)
- Look for secrets in webpack configs, docker-compose files, or build scripts
- Flag any credentials passed via URL query params

### 3. Input Handling (OWASP Top 10)
- **XSS**: Look for `dangerouslySetInnerHTML`, `innerHTML`, unescaped user input in templates
- **Injection**: Check for string concatenation in queries, unsanitised URL params
- **CSRF**: Verify tokens on state-changing requests
- **Open Redirect**: Check URL redirects validate against allowlist

### 4. Authentication & Authorization
- Session tokens stored securely (httpOnly cookies preferred over localStorage)
- Auth checks on protected routes (both client and server)
- Token expiry and refresh handling
- No sensitive data in JWTs visible client-side

### 5. Client-Side Security
- `target="_blank"` has `rel="noopener noreferrer"` (eslint covers this)
- No `eval()` or `Function()` constructor (eslint covers this)
- Content Security Policy headers where applicable
- Subresource integrity on external scripts

### 6. Data Exposure
- API responses don't leak sensitive fields
- Error messages don't expose stack traces or internal details to users
- No sensitive data in console.log statements in production code
- Check `window.postMessage` usage validates origin

### 7. Transport Security
- All API calls over HTTPS
- No mixed content
- Secure cookie flags (Secure, SameSite)

## Output Format

| Severity | Category | Finding | Location | Remediation |
|----------|----------|---------|----------|-------------|
| 🔴 Critical | ... | ... | ... | ... |
| 🟠 High | ... | ... | ... | ... |
| 🟡 Medium | ... | ... | ... | ... |
| 🔵 Low | ... | ... | ... | ... |

End with:
- **Overall risk level**: Critical / High / Medium / Low
- **Immediate actions**: What to fix now
- **Recommended improvements**: What to address in the next sprint
