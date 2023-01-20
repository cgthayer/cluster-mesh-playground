
main: list help
	@echo
	@echo "If nothing is running try: make create. Here are the targets"

help:
	@echo "Make targets:"
	@echo "* install:        install kind, kubectl, istio (mac)"
	@echo "* create:         create a cluster and ingress"
	@echo "* list:           see how it's doing"
	@echo "* test-app:       test the ingress with a couple of apps: foo and bar"
	@echo "* install-istio:  install istio including itsoctl"
	@echo "* test-istio-app: install istio bookinfo demo app"
	@echo "* istio-ui:       launch the kiali dashboard"
	@echo "* clean:          tear it all down"
	@echo "* help:           this list"

install:
	# todo: check for max vs windows
	$(MAKE) install-mac

install-mac:
	@echo From https://kind.sigs.k8s.io/docs/user/quick-start/
	brew install kind
	@echo From https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
	# M1 curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl"
	$(MAKE) install-istio

# TODO: Untested
install-windows: 
	choco install kind

install-istio:
	# curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.16.1 sh - > istio-install.out
	-ln -s istio-1.16.1 istio
	./istio/bin/istioctl version
	@echo 'Run: export PATH=$$PWD/istio/bin:$$PATH'
	kubectl label namespace default istio-injection=enabled
	istioctl analyze
	kubectl -n istio-system get pods,services

ISTIOCTL=./istio/bin/istioctl

create:
	kind create cluster --name cluster-wb --config cluster-wb.yml
	kind get clusters
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s
	$(ISTIOCTL) install --set profile=demo -y

# untested
clusters:
	PORT_HTTP=81 PORT_HTTPS=444 envsubst < cluster-wb.yml.tmpl > cluster-wb2.yml
	kind create cluster --name cluster-wb2 --config cluster-wb2.yml
	PORT_HTTP=82 PORT_HTTPS=445 envsubst < cluster-wb.yml.tmpl > cluster-wb3.yml
	kind create cluster --name cluster-wb3 --config cluster-wb3.yml
	kind get clusters

list:
	@echo Kind clusters::
	@kind get clusters
	kubectl get --namespace ingress-nginx service
	kubectl get --namespace ingress-nginx pods
	kubectl get pods

test-app:
	kubectl apply -f http-echo.yml
	kubectl get pod foo-app
	curl -is localhost/foo/hostname
	kubectl get pod bar-app
	curl -is localhost/bar/hostname

test-istio-app:
	if [ ! -d istio ]; then $(MAKE) install=istio; fi
	kubectl apply -f istio/samples/bookinfo/platform/kube/bookinfo.yaml
	kubectl get services
	# open to the world
	kubectl apply -f istio/samples/bookinfo/networking/bookinfo-gateway.yaml
	kubectl get gateway
	./istio-gen-dummy-data.sh

istio-ui:
	kubectl apply -f istio/samples/addons
	kubectl rollout status deployment/kiali -n istio-system
	istioctl dashboard kiali &
	@echo "For kiali you may want to run ./istio-gen-dummy-data.sh"
	# export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
	# export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
	istioctl dashboard grafana &
	@echo "For grafana see something like: http://localhost:3000/d/LJ_uJAvmk/istio-service-dashboard?orgId=1&refresh=1m&from=now-1h&to=now"
	@echo "    There's a folder 'istio' with dashboards"

clean:
	kind delete clusters cluster-wb
# end