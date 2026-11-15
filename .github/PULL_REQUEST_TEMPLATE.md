# Summary

What does this change?

## Type

- [ ] Bug fix
- [ ] Feature
- [ ] Documentation
- [ ] Data or fixtures
- [ ] CI or build

## Evidence

For a Compose or contract change, include the commands and observed result.

```text
command:
result:
```

For a fixture change, include the source PBF and `testdata/SHA256SUMS` update.

## Checklist

- [ ] `bash -n scripts/*.sh` passes.
- [ ] `docker compose config` is valid.
- [ ] `scripts/e2e.sh` passes with fixtures.
- [ ] No `.env`, graph, index, or archive is included.
- [ ] Documentation is updated when behavior changes.
- [ ] Commits carry `Signed-off-by` (DCO).
