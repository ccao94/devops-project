# Postmortem: /slow returning HTTP 500 in dev

## Summary and impact

On 2026-11-24, a version where `/slow` always returned HTTP 500 (image `v2-bad`) was deployed to the `dev` namespace with `kubectl set image`, outside of the pipeline. Every call to `/slow` failed until the rollback. `/health` kept working, so Kubernetes saw the pod as healthy. Only dev was affected.

## Timeline (UTC)

| Time | Event |
|---|---|
| 15:59:41 | `v2-bad` deployed in dev with `kubectl set image` |
| | `/slow` starts returning 500, error ratio goes above 10% on the dashboard |
| | Alert `HighErrorRate` pending, then firing 2 minutes later |
| | Runbook checks: only `/slow` fails, last revision is `deploy v2-bad` |
| 16:09:22 | Rollback with `kubectl rollout undo`, back to image `37bff70` |
| | Error ratio back under 10%, alert inactive, all-clear |

## Root cause (5 Whys)

1. Why 500 errors? The new version broke `/slow`.
2. Why was it in dev? It was deployed by hand, without a PR or the CI.
3. Why was that possible? Everyone has write access to the cluster, and the image was built locally.
4. Why did Kubernetes accept it? The probes only check `/health`, which still worked.
5. Why did no test catch it? No test checks `/slow`, and there is no smoke test after a deployment.

**Root cause:** a deployment path that skips review and tests, with health checks that do not cover the real routes.

## What went well / what went poorly

- **Well:** the alert fired on its own, the runbook led straight to the faulty route and revision, and we rolled back before looking at the code.
- **Poorly:** about 3 minutes between the first errors and the alert, no trace of the bad version in Git, and `rollout undo` also changes the cluster outside of Git.

## Action items

| Action | Owner | Deadline |
|---|---|---|
| Unit test on the status codes of `/slow` and `/error` | Laurent | 2026-11-27 |
| Smoke test job after each deployment, failing on 5xx | Cao | 2026-11-30 |
| Write access on `dev` for the pipeline only (RBAC) | Igor | 2026-11-30 |
| 2 replicas and a canary release for new versions | Léon | 2026-11-30 |

*AI helped write this postmortem from our notes.*