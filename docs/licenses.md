# Licenses

## Quick-compare

| License      | Type              | Patents       | Copyleft | Best for                         | Watch out                          |
|--------------|-------------------|---------------|----------|----------------------------------|------------------------------------|
| MIT          | Permissive        | No (explicit) | No       | General OSS default              | No explicit patent grant           |
| Apache-2.0   | Permissive        | **Yes**       | No       | Corp / patent-sensitive projects | NOTICE / more boilerplate          |
| BSD-2-Clause | Permissive        | No (explicit) | No       | "MIT-like" w/ BSD flavor         | No explicit patent grant           |
| BSD-3-Clause | Permissive        | No (explicit) | No       | BSD + non-endorsement            | Name endorsement restriction       |
| ISC          | Permissive        | No (explicit) | No       | Minimal permissive               | No explicit patent grant           |
| zlib         | Permissive        | No (explicit) | No       | Libraries, provenance-friendly   | Mark altered versions              |
| Unlicense    | Public domain-ish | No            | No       | Max freedom / do-anything        | Legal acceptance varies            |
| CC BY 4.0    | Content           | N/A           | No       | Docs / media / tutorials         | Not for code; attribution required |

## When to pick which

### MIT / ISC / BSD-2

Pick when you want maximum adoption and simplicity.

- *MIT* is the most recognized
- *ISC* is "MIT but shorter"
- *BSD-2* is "MIT-ish with BSD branding"

### BSD-3-Clause

Pick when you want the same freedom as BSD-2, but also want to prevent anyone from using your name to *endorse* derived products.

### Apache-2.0

Pick when you want permissive **plus an explicit patent license** (common in corporate environments and larger projects).

### zlib

Pick when you want permissive **and** you care about provenance (don’t misrepresent origin; mark modified source). Nice for libraries.

### Unlicense

Pick when you want "public domain vibes", but be aware it’s sometimes rejected by companies/legal teams due to jurisdiction quirks. If you want "almost public domain but more legally boring", many people choose **MIT** instead.

### CC BY 4.0 (docs/content)

Pick for **documentation and educational materials** where you want reuse allowed as long as attribution is given. Avoid using CC licenses for code.
