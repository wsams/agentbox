.PHONY: wizard features build-core build-k8s build-terraform build-pulumi build-full build-proxy list

wizard:
	python3 wizard.py

features:
	./build.sh --list-features

build-core:
	./build.sh --flavor core

build-k8s:
	./build.sh --flavor k8s

build-terraform:
	./build.sh --flavor terraform

build-pulumi:
	./build.sh --flavor pulumi

build-full:
	./build.sh --flavor full

build-proxy:
	docker build -t wsams/agentbox-proxy:latest proxy

list:
	python3 wizard.py --list
