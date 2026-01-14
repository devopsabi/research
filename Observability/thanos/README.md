# Thanos is used in Kubernetes mainly to extend Prometheus.
# The core problem Thanos solves
# Prometheus alone has limitations:
# Single-node storage (not highly available by default)
# Local disk only (hard to scale, hard to back up)
# Limited long-term retention
# Difficult to query metrics across multiple clusters
# Kubernetes environments usually need HA, long-term storage, and global visibility — that’s where Thanos comes in.
-  I will install prometheus and thanos and use sidecar to ship logs to s3 bucket
