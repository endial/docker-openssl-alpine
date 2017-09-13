certs_dir := $(CURDIR)/cert

build:
	docker build -t endial/openssl-alpine .

push:
	docker push endial/openssl-alpine

clean:
	rm -rf ${certs_dir}; docker rm -f crt; true

run: build clean
	@mkdir -p ${certs_dir}
	docker run --name crt -v ${certs_dir}:/srv/cert endial/openssl-alpine

verify: run
	openssl x509 -in ${certs_dir}/public.crt -text -noout
	openssl x509 -in ${certs_dir}/ca.pem -text -noout

help:
	@echo "Usage: make build|push|clean|run|verify"
