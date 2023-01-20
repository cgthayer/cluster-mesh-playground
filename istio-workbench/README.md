# Example cluster setup

This is a playground for trying out stuff. Try running `make`.

Make targets:
* install: install kind, kubectl, istio (mac)
* create: create a cluster and ingress
* list: see how it's doing
* test-app: test the ingress with a couple of apps: foo and bar
* install-istio: install istio including itsoctl
* test-istio-app: install istio bookinfo demo app
* istio-ui: launch the kiali dashboard
* clean: tear it all down
* help: this list

Pre-reqs:
* There's a `make install-mac`
* [Kubectl install](https://kubernetes.io/docs/reference/kubectl/)
* [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/)

# Kind

Useful commands
* `kind create cluster` # name "kind"
   * `kind create cluster --name cluster0`
* `kind get clusters`
* `kind delete cluster`

# k8s

Useful commands
* `kubectl cluster-info`
* `kubectl config get-clusters`
* `kubectl config set-cluster NAME`
* `kubectl get pods --show-labels`

# Istio

Useful commands
* `istioctl dashboard kiali &`  # launch the UI
* `istioctl analyze`  # smoke test

