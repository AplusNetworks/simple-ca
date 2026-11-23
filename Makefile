SHELL := /bin/bash

##
## Lista de comandos disponíveis:
## Uso: make [comando] [PARAMETRO=valor]
##
## -------------------------------------------------------------------------
## Notas Técnicas Importantes:
## 1. SAN (Subject Alternative Name): Navegadores modernos exigem a extensão
##    SAN e ignoram o CN. Os comandos já injetam o DNS automaticamente.
## 2. Safari/Apple: Sistemas Apple bloqueiam certificados de servidor com
##    mais de 825 dias. Usamos 825 dias para servidores e 1825 para a CA.
## 3. Wildcard: Caso queira emitir um certificado wildcard (ex:
##    make cert CN=*.empresa.local), esta versão funciona perfeitamente sem
##    precisar alterar nada.
## -------------------------------------------------------------------------
##

CA_DOMAIN ?= Root CA Local

help:
	@grep '^##' $(MAKEFILE_LIST) | cut -c 3-

## generate-ca  : Cria a chave privada (AES-256) e o certificado raiz (Root CA)
##              : [EXEMPLO - make generate-ca CA_DOMAIN=ca.empresa.local]
generate-ca:
	openssl genrsa -aes256 -out myCA.key 4096
	openssl req -x509 -new -nodes -key myCA.key -sha256 -days 1825 \
		-subj "/C=BR/ST=Bahia/L=Salvador/O=MinhaEmpresa/CN=$(CA_DOMAIN)" \
		-out myCA.pem

## csr          : Gera a chave privada (.key) e o pedido de assinatura (.csr)
##              : [EXEMPLO - make csr CN=app.empresa.local]
csr:
	openssl req -new -sha256 -nodes -newkey rsa:2048 \
		-keyout $(CN).key -out $(CN).csr \
		-subj "/C=BR/ST=Bahia/L=Salvador/O=MinhaEmpresa/OU=TI/CN=$(CN)" \
		-addext "subjectAltName=DNS:$(CN)"

## sign         : Assina o CSR e gera o certificado final (.crt) com SAN
##              : [EXEMPLO - make sign CN=app.empresa.local]
sign:
	openssl x509 -req -in $(CN).csr -CA myCA.pem -CAkey myCA.key -CAcreateserial \
		-out $(CN).crt -days 825 -sha256 \
		-extfile <(echo "subjectAltName=DNS:$(CN)")

## cert         : Atalho que gera o CSR e já assina o certificado de uma vez
##              : [EXEMPLO - make cert CN=app.empresa.local]
cert: csr sign

## renew        : Faz backup do certificado atual e gera um novo usando o mesmo CSR
##              : [EXEMPLO - make renew CN=app.empresa.local]
renew:
	cp -f $(CN).crt $(CN).crt.bak
	$(MAKE) sign CN=$(CN)
