FROM alpine:edge as build

RUN apk add --no-cache cargo

RUN cargo install comrak

ENV PATH=/root/.cargo/bin:$PATH

WORKDIR /code

COPY . .

RUN find public -type f -name '*.md' | xargs -n1 -P0 ./build.sh

FROM nginx:alpine

COPY --from=build /code/build/public /usr/share/nginx/html
