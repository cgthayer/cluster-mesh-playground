# Try "make help"

main:
	@echo
	@-$(MAKE) help
	@echo
	@-$(MAKE) list
	@echo "If nothing is running try: make install create"

help:
	@echo "Make targets:"
	@echo "* install:          install kind, kubectl, istio (mac)"
	@echo "  * install-kind:   install just kind and k8s"
	@echo "  * install-istio:  install istio including istioctl"
	@echo "* create:           create a cluster and ingress"
	@echo "* list:             see how it's doing"
	@echo "* test-app:         test the ingress with a couple of apps: foo and bar"
	@echo "* test-istio-app:   install istio bookinfo demo app"
	@echo "* istio-ui:         launch grafana, and the kiali dashboard"
	@echo "* clean:            tear it all down"
	@echo "* help:             this list"

# house keeping
.PHONY: main help install install-mac install-kind-mac isntall-windows \
	install-kind-windows install-istio-mac create create-kind \
	create-istio clusters list test-app test-istio-app istio-ui \
	clean

SHELL := /bin/bash
ISTIOCTL=./istio/bin/istioctl

# start here
install:
	# todo: check os
	$(MAKE) install-mac

install-mac: install-kind-mac install-istio-mac

# From https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/
install-kind-mac:
	@echo From https://kind.sigs.k8s.io/docs/user/quick-start/
	@kind --version || brew install kind
	@if ! kubectl help > /dev/null; then \
		stable=$$(curl -L -s https://dl.k8s.io/release/stable.txt); \
		echo Downloading kubectl version $${stable}; \
		curl -LO "https://dl.k8s.io/release/$${stable}/bin/darwin/amd64/kubectl"; \
	fi

# M1 curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl"

# TODO: Untested
install-windows: install-kind-windows
install-kind-windows:
	choco install kind

install-istio-mac:
	@if ! $(ISTIOCTL) version 2> /dev/null; then \
		curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.16.1 sh - > istio-install.out; \
		ln -s istio-1.16.1 istio; \
	fi
	@echo 'Run: export PATH=$$PWD/istio/bin:$$PATH'

create:
	if ! kind get clusters | grep cluster-wb; then $(MAKE) create-kind; else echo Kind already created; fi
	$(MAKE) test-app
	$(MAKE) create-istio
	$(MAKE) test-istio-app

create-kind:
	kind create cluster --name cluster-wb --config cluster-wb.yml
	kind get clusters
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s

create-istio:
	$(ISTIOCTL) install --set profile=demo -y
	kubectl label namespace default istio-injection=enabled
	kubectl -n istio-system get pods,services

# untested
clusters:
	PORT_HTTP=81 PORT_HTTPS=444 envsubst < cluster-wb.yml.tmpl > cluster-wb2.yml
	kind create cluster --name cluster-wb2 --config cluster-wb2.yml
	PORT_HTTP=82 PORT_HTTPS=445 envsubst < cluster-wb.yml.tmpl > cluster-wb3.yml
	kind create cluster --name cluster-wb3 --config cluster-wb3.yml
	kind get clusters
	kubectl config use-context kind-cluster-wb  # switch back to main

list:
	@echo Kind clusters::
	@kind get clusters
	kubectl get --namespace ingress-nginx service
	kubectl get --namespace ingress-nginx pods
	kubectl get pods

test-app:
	kubectl apply -f http-echo.yml
	kubectl get pod foo-app
	@ max=30; \
		for attempt in $$(seq 1 ${max}); do if [ "$$(curl -s localhost/foo/hostname)" != "foo-app" ]; then echo "waiting $${attempt}/$${max}"; sleep 1; fi; done; \
		echo "$${attempt} ge $${max}"; \
		if [ "$${attempt}" -ge "$${max}" ]; then echo FAILED; exit -1; fi
	curl -is localhost/foo/hostname; echo
	kubectl get pod bar-app
	curl -is localhost/bar/hostname; echo

test-istio-app:
	if [ ! -d istio ]; then $(MAKE) install-istio; fi
	kubectl apply -f istio/samples/bookinfo/platform/kube/bookinfo.yaml
	kubectl get services
	# open to the world
	kubectl apply -f istio/samples/bookinfo/networking/bookinfo-gateway.yaml
	kubectl get gateway
	kubectl wait --for=condition=ready pod -l app=ratings
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
	kind delete clusters cluster-wb cluster-wb2 cluster-wb3

# end
