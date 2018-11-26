# Writing a blog with weird tools

We'll use [comrak](https://github.com/kivikakk/comrak) to render the markdown in html.

```
cargo install comrak
```

## use builtin `printf` to render templates

```
printf "$(cat template.html)" "$(head -n1 $1)" "$(comrak "$1")" > build/$(echo "$1" | sed -e 's/.md//').html

```

## build it

We iterate over every `.md` file in the public folder and create the corresponding file.

```
find post -type f -name '*.md' | xargs -n1 -P0 ./build.sh
```

## Ship it

Let's use a `Dockerfile` to generate the html and then populate a default nginx install.

```Dockerfile
FROM alpine:edge as build

RUN apk add --no-cache cargo

RUN cargo install comrak

ENV PATH=/root/.cargo/bin:$PATH

WORKDIR /code

COPY . .

RUN find public -type f -name '*.md' | xargs -n1 -P0 ./build.sh

FROM nginx:alpine

COPY --from=build /code/build/public /usr/share/nginx/html
```

## deploy it

Find whatever docker engine somewhere out here.
I'm currently using docker-machine to setup a gcloud compute instance, but you do as you wish.

    docker build -t blog .
    docker run -p 80:80 blog

Amazing.
