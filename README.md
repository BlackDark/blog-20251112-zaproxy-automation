# ZAP Web Application Security Scanning

> Demo repository accompanying the blog post on [eduard-marbach.de](https://eduard-marbach.de/post)

Automation framework examples for OWASP ZAP (Zed Attack Proxy) security scanning. This repository demonstrates different approaches to running web application security scans using ZAP's automation framework.

## Prerequisites

- OWASP ZAP installed and accessible
- Environment variables configured:
  - `ClientID` - API client identifier
  - `ApiKey` - API authentication key

## Configuration Files

This repository includes three automation configuration variants:

### 1. `automation-test.yaml`
**Modern approach** - The recommended way forward using the new automation framework format.
- Based on current best practices
- Reference: [API Scan Example](https://github.com/zaproxy/community-scripts/blob/main/other/af-plans/ApiScanExample.yaml)

### 2. `automation.yaml`
**Legacy approach** - Uses policy-based configuration (policy name).
- ⚠️ **Status**: Broken with newer ZAP releases (ZAP has changed the policy configuration)
- Kept for reference and migration purposes

### 3. `automation-auth-check.yaml`
**Credential verification** - Pipeline-specific configuration.
- Used exclusively in CI/CD pipelines to verify credentials
- Fails the pipeline if authentication fails
- Not easily combined with other scanning tasks

## Quick Start

### Local Testing

Run a local security scan:

```bash
bash zap/localtest.sh
```

## Documentation & References

### ZAP Automation Framework
- [Environment Variables Configuration](https://www.zaproxy.org/docs/desktop/addons/automation-framework/environment/)
- [Authentication Helper - Session Header](https://www.zaproxy.org/docs/desktop/addons/authentication-helper/session-header/)
- [Replacer Plugin](https://www.zaproxy.org/docs/desktop/addons/replacer/)

### Example Plans
- [API Scan Example Plan](https://github.com/zaproxy/community-scripts/blob/main/other/af-plans/ApiScanExample.yaml)
