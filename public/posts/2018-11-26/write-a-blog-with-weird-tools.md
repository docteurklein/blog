# Writing a blog with weird tools

This is a blog about having fun writing a blog, using the minimum amount of code.

We'll use:

- [comrak](https://github.com/kivikakk/comrak) to render the markdown in html.
- [docker-compose](https://github.com/docker/compose) and docker swarm
- [GNU-coreutils](https://www.gnu.org/software/coreutils/)! because it's fun

> As repeating other's readme is a bad idea, we'll let you RTFM to install any of these tools.


## use builtin `printf` to render templates

`printf` is shipped in coreutils and will serve as a basic template renderer.
We don't need anything fancier anyway!

```
# build.sh

printf "$(cat template.html)" "$(head -n1 $1)" "$(comrak "$1")" \
    > build/$(echo "$1" | sed -e 's/.md//').html
```

This renders the template `template.html` by replacing the title
with the first line of the passed file (`"$(head -n1 $1)"`) and
the html version of the markdown file in the body (`"$(comrak "$1")"`).

> Note: `$1` refers to the relative path of one markdown file (e.g `public/posts/an-article.md`).

## build it

We iterate over every `.md` file in the public folder and call `build.sh` for every file.

```
find post -type f -name '*.md' | xargs -n1 -P0 ./build.sh
```

## watch it

No need to use complicated gulp files requiring 500MB of dependencies!
`inotifywait` does the job perfectly well:

```
inotifywait -e create -e modify -e delete -m --format='%w%f' -r template.html public | xargs -L 1 \
    make build
```

- `inotifywait […]` will output one line per watched file
- `| xargs -L 1` will wait 1 incoming line before calling `make build`


## ship it

Let's use a `Dockerfile` to package the whole thing.

```Dockerfile
FROM alpine:edge as build
RUN apk add --no-cache cargo make
RUN cargo install comrak
ENV PATH=/root/.cargo/bin:$PATH
WORKDIR /code
COPY . .
RUN make

FROM nginx:alpine
COPY --from=build /code/build/public /usr/share/nginx/html
```

It's a multi-stage build:

- first install all the dependencies using alpine
- then call `make` (this will generate all the html files)
- finally copy those static html files in a default nginx install

## deploy it

Find whatever docker engine somewhere out here.
I'm currently using docker-machine to setup a gcloud compute instance, but you do as you wish.

    make deploy


## improve the user experience

I have sharp tools, so calling a command is a matter of 2 or 3 keystrokes for me.
But hiding this complexity behind a `Makefile` might be a good idea:

```Makefile
build:
	find public -type f -name '*.md' | xargs -n1 -P0 ./build.sh

watch:
	inotifywait -e create -e modify -e delete -m --format='%w%f' \
		-r template.html public | xargs -L 1 \
		make build

deploy:
	docker-compose build
	docker-compose push
	eval $$(docker-machine env gcloud) && \
	docker stack deploy --with-registry-auth -c docker-compose.yml blog

.PHONY: build watch deploy
```

Now all you have to do is either calling:

- `make` to generate the files locally
- `make watch` to continuously generate the files locally after a change
- `make deploy` to build, push and deploy a [docker swarm service](https://docs.docker.com/engine/swarm/swarm-tutorial/deploy-service/)

Amazing.
