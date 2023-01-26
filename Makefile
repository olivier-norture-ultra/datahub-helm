#!/usr/bin/env make

SHELL = /usr/bin/env
.SHELLFLAGS = bash -eu -c

.ONESHELL:

.PHONY: java-secrets
java-secrets:
	kafka_cert/convert-aiven-certificates --ca-cert=kafka_cert/ca.cert --access-key=kafka_cert/access.key --access-cert=kafka_cert/access.cert --truststore=kafka_cert/truststore.jks --truststore-password=azerty --keystore=kafka_cert/keystore.p12 --keystore-password=azerty
	base64 kafka_cert/keystore.p12 > kafka_cert/keystore_b64.txt
	base64 kafka_cert/truststore.jks > kafka_cert/truststore_b64.txt

.PHONY: deploy
deploy:
	kubectl apply -f /home/olivier/data-catalog/datahub-helm/charts/prerequisites/templates/datahub-postgresql-secrets.yaml
	kubectl apply -f /home/olivier/data-catalog/datahub-helm/charts/prerequisites/templates/datahub-neo4j-secrets.yaml
	kubectl apply -f /home/olivier/data-catalog/datahub-helm/charts/prerequisites/templates/datahub-kafka-secrets.yaml

	helm repo update datahub
	helm install datahub-prerequisites datahub/datahub-prerequisites --version=0.0.13 --values /home/olivier/data-catalog/datahub-helm/charts/prerequisites/values.yaml
	helm install datahub datahub/datahub --version=0.2.137 --values /home/olivier/data-catalog/datahub-helm/charts/datahub/values.yaml

.PHONY: undeploy
undeploy:
	helm uninstall datahub-prerequisites
	helm uninstall datahub
	kubectl delete secrets datahub-postgresql-secrets datahub-neo4j-secrets datahub-kafka-secrets


.PHONY: update
update:
	helm uninstall datahub
	helm install datahub datahub/datahub --version=0.2.137 --values /home/olivier/data-catalog/datahub-helm/charts/datahub/values.yaml

.PHONY: port-forward
port-forward:
	$(eval DATAHUB_FRONTEND_POD_NAME=$(shell kubectl get pods | grep datahub-frontend | awk '{print $1}'))
	kubectl port-forward $(DATAHUB_FRONTEND_POD_NAME) 9002:9002