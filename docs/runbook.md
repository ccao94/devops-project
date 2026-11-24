# Runbook: myapp

## HighErrorRate

**Alert:** more than 10% of requests to myapp (namespace `dev`) return HTTP 5xx for 2 minutes.
**Severity:** critical.
**Rule:** `monitoring/alerts/myapp-alerts.yaml`. **Dashboard:** `myapp golden signals` (Grafana).

### Symptoms

- Alert `HighErrorRate` is firing in Prometheus / Alertmanager.
- The "Error ratio" panel is above the red line at 10%.
- Users get HTTP 500 responses.

### Quick checks

1. Is the pod running, or restarting?
   ```
   kubectl get pods -n dev
   ```
2. Was there a recent deployment? Compare the current image with the previous revision.
   ```
   kubectl rollout history deployment/myapp -n dev
   kubectl get deploy myapp -n dev -o jsonpath="{.spec.template.spec.containers[0].image}"
   ```
3. Which route fails? In Prometheus:
   ```
   sum(rate(http_requests_total{namespace="dev", status=~"5.."}[5m])) by (route)
   ```
4. What do the logs say? Error lines have `"level":"error"`.
   ```
   kubectl logs deployment/myapp -n dev --tail=50
   ```

### Mitigation

- **Errors started after a deployment:** roll back first, investigate later.
  ```
  kubectl rollout undo deployment/myapp -n dev
  kubectl rollout status deployment/myapp -n dev
  ```
- **Pod restarting (CrashLoopBackOff, OOMKilled):** check `kubectl describe pod -n dev -l app=myapp`, then roll back or raise the memory limit through a pull request.
- **One route only, no recent deployment:** the problem is probably in the code or a dependency. Escalate to the team that owns the route.

### Verify

- The "Error ratio" panel goes back under 10%.
- The alert goes back to `inactive` (allow 2 to 3 minutes for the `[2m]` window to clear).

### Notes

- Do not generate load through `kubectl port-forward`: it drops under heavy traffic. Use a test pod inside the cluster instead:
  ```
  kubectl run error-load -n dev --image=curlimages/curl --restart=Never -- sh -c "while true; do curl -s -o /dev/null http://myapp/error; sleep 0.1; done"
  ```
- Never fix production with `kubectl edit`: every change goes through a pull request.