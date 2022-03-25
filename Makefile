#!/usr/bin/env make

SHELL = /usr/bin/env
.SHELLFLAGS = bash -eu -c

.ONESHELL:

.PHONY: deploy
deploy:
	k install -f /home/olivier/data-catalog/datahub-helm/charts/prerequisites/templates/datahub-mysql-secrets.yaml
	k install -f /home/olivier/data-catalog/datahub-helm/charts/prerequisites/templates/datahub-neo4js-secrets.yaml

	helm install prerequisites datahub/datahub-prerequisites --values /home/olivier/data-catalog/datahub-helm/charts/prerequisites/values.yaml
	helm install datahub datahub/datahub --values /home/olivier/data-catalog/datahub-helm/charts/datahub/values.yaml

.PHONY: undeploy
undeploy:
	helm uninstall prerequisites
	helm uninstall datahub
	k delete secrets datahub-mysql-secrets datahub-neo4js-secerts
