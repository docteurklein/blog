build:
	find public -type f -name '*.md' | xargs -n1 -P0 ./build.sh
	cp -v public/style.css build/public/

watch:
	inotifywait -e create -e modify -e delete -m --format='%w%f' \
		-r template.html public | xargs -L1 \
		make build

deploy:
	docker-compose build
	docker-compose push
	eval $$(docker-machine env gcloud) && \
	docker stack deploy --with-registry-auth -c docker-compose.yml blog

.PHONY: build watch deploy
