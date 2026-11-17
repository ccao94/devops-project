# Lab 2: Kubernetes, Multi-environment Deployment and Audit

## Q1. What is the role of a namespace? Does it provide strong security isolation by itself?

A namespace splits one cluster into separate spaces, here dev, staging and prod. Names only have to be unique inside a namespace, and RBAC rules or quotas can be set per namespace.

It is not strong isolation. Pods from different namespaces run on the same nodes and can reach each other by default. We would need NetworkPolicies to block that.

## Q2. Why does Kubernetes recreate the deleted pod? Which component is responsible?

The Deployment asks for 3 replicas. When we deleted a pod, the ReplicaSet controller (in the controller manager) saw only 2 and created a new one.

We saw it in our test: the new pod was 111s old, the two others 3m25s (see `evidence/lab2/part2-dev.txt`).
