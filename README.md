# axios-supply-chain-scanner

A one-file bash scanner to detect the **March 2026 axios npm supply-chain compromise** on your machine.

## The attack (TL;DR)

On **March 31, 2026**, a compromised maintainer account published malicious versions of the `axios` npm package:

- `axios@1.14.1`
- `axios@0.30.4`

Both versions pulled in a fake dependency, **`plain-crypto-js@4.2.1`**, which executed a `postinstall` hook installing a cross-platform Remote Access Trojan (macOS, Windows, Linux). The malicious versions were tagged `latest`, so any `npm install` during the window could have been affected. The campaign has been attributed to the North Korean threat actor **Sapphire Sleet**.

References:

- [Microsoft Security Blog](https://www.microsoft.com/en-us/security/blog/2026/04/01/mitigating-the-axios-npm-supply-chain-compromise/)
- [Wiz](https://www.wiz.io/blog/axios-npm-compromised-in-supply-chain-attack)
- [Huntress](https://www.huntress.com/blog/supply-chain-compromise-axios-npm-package)
- [Google Cloud Threat Intelligence](https://cloud.google.com/blog/topics/threat-intelligence/north-korea-threat-actor-targets-axios-npm-package)
- [Socket](https://socket.dev/blog/axios-npm-package-compromised)

## Usage

**One-liner (quickest):**

```bash
curl -O https://raw.githubusercontent.com/yzzztech/axios-supply-chain-scanner/main/axios-scan.sh && chmod +x axios-scan.sh && ./axios-scan.sh
```

**Step by step:**

```bash
curl -O https://raw.githubusercontent.com/yzzztech/axios-supply-chain-scanner/main/axios-scan.sh
chmod +x axios-scan.sh
./axios-scan.sh             # scans $HOME
./axios-scan.sh ~/projects  # scans a specific path
```

Exit code is `0` if clean, `1` if a compromised artifact is found — so you can drop it into CI.

## What it checks

For every `package.json`, `package-lock.json`, `yarn.lock`, and `pnpm-lock.yaml` under the target path (skipping `node_modules`, `.git`, `.venv`, etc.), it flags:

- The exact strings `axios@1.14.1` or `axios@0.30.4`
- Any reference to `plain-crypto-js` (strongest signal — this package should not exist in your tree at all)

## If you're affected

1. **Pin axios to a safe version** (e.g. `1.13.6`) in `package.json`, or use an `overrides` block:
   ```json
   "overrides": { "axios": "1.13.6" }
   ```
2. **Delete `node_modules` and the lockfile**, then reinstall clean.
3. **Rotate secrets** that touched the affected machine or CI runner: npm tokens, SSH keys, cloud credentials, `.env` values, browser sessions.
4. **Treat the host as potentially compromised** — scan for unknown outbound connections and review `postinstall` logs since 2026-03-31. Ideally reimage dev/CI machines that ran the bad install.

## License

MIT. Share freely.
