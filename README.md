# Scoop bucket for ContextVerse

Own Scoop bucket — not submitted to the main Scoop extras. Parallel to [`homebrew-tap`](https://github.com/abyssmemes/homebrew-tap).

```powershell
scoop bucket add contextverse https://github.com/abyssmemes/scoop-bucket
scoop install contextd
```

When a GitHub organization exists, this repo can move there (e.g. `contextverse/scoop-bucket`).

## Updating the manifest after a release

1. Publish a `v*` tag on [`contextverse`](https://github.com/abyssmemes/contextverse) (GoReleaser builds Windows `.zip` + `checksums.txt`).
2. Refresh `contextd.json` version, URLs, and hashes:

```bash
./scripts/bump-manifest.sh vX.Y.Z
```

3. Commit and push.

## License

Manifest / bucket files: Apache-2.0. The `contextd` binary itself remains BUSL-1.1 — see the main repo.
