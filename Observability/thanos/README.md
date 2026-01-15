# Thanos is used in Kubernetes mainly to extend Prometheus.
# The core problem Thanos solves
# Prometheus alone has limitations:
# Single-node storage (not highly available by default)
# Local disk only (hard to scale, hard to back up)
# Limited long-term retention
# Difficult to query metrics across multiple clusters
# Kubernetes environments usually need HA, long-term storage, and global visibility — that’s where Thanos comes in.
-  I will install prometheus and thanos and use sidecar to ship TSDB blocks to s3 bucket

* caller=factory.go:53 level=info msg="loading bucket configuration"
- I will wait for the  first successful upload

```
☁  thanos-demo  kubectl logs -f prometheus-prometheus-kube-prometheus-prometheus-0 -c thanos-sidecar -n prometheus        
ts=2026-01-14T23:48:50.929328703Z caller=options.go:26 level=info protocol=gRPC msg="disabled TLS, key and cert must be set to enable"
ts=2026-01-14T23:48:50.930023529Z caller=factory.go:53 level=info msg="loading bucket configuration"
ts=2026-01-14T23:48:50.9306717Z caller=sidecar.go:383 level=info msg="starting sidecar"
ts=2026-01-14T23:48:50.931086569Z caller=reloader.go:238 level=info component=reloader msg="nothing to be watched"
ts=2026-01-14T23:48:50.931101791Z caller=intrumentation.go:56 level=info msg="changing probe status" status=ready
ts=2026-01-14T23:48:50.931550252Z caller=intrumentation.go:75 level=info msg="changing probe status" status=healthy
ts=2026-01-14T23:48:50.93163372Z caller=http.go:73 level=info service=http/server component=sidecar msg="listening for requests and metrics" address=:10902
ts=2026-01-14T23:48:50.931750754Z caller=grpc.go:131 level=info service=gRPC/server component=sidecar msg="listening for serving gRPC" address=:10901
ts=2026-01-14T23:48:50.931846364Z caller=tls_config.go:274 level=info service=http/server component=sidecar msg="Listening on" address=[::]:10902
ts=2026-01-14T23:48:50.931861531Z caller=tls_config.go:277 level=info service=http/server component=sidecar msg="TLS is disabled." http2=false address=[::]:10902
ts=2026-01-14T23:48:50.934210519Z caller=sidecar.go:195 level=info msg="successfully loaded prometheus version"
ts=2026-01-14T23:48:50.946783071Z caller=sidecar.go:217 level=info msg="successfully loaded prometheus external labels" external_labels="{prometheus=\"prometheus/prometheus-kube-prometheus-prometheus\", prometheus_replica=\"prometheus-prometheus-kube-prometheus-prometheus-0\"}"
ts=2026-01-14T23:48:52.933531415Z caller=shipper.go:263 level=warn msg="reading meta file failed, will override it" err="failed to read /prometheus/thanos.shipper.json: open /prometheus/thanos.shipper.json: no such file or directory"

```
