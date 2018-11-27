
.PHONY: build watch deploy

build:
	find public -type f -name '*.md' | xargs -n1 -P0 ./build.sh

watch:
	inotifywait -e create -e modify -e delete -m --format='%w%f' -r template.html public | xargs -L 1 -I{} \
		make build

deploy:
	docker-compose build
	docker-compose push
	eval $$(docker-machine env gcloud) && \
	docker stack deploy --with-registry-auth -c docker-compose.yml blog
