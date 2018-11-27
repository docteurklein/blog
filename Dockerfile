FROM alpine:edge as build

RUN apk add --no-cache cargo

RUN cargo install comrak

RUN apk add --no-cache make

ENV PATH=/root/.cargo/bin:$PATH

WORKDIR /code

COPY . .

RUN make

FROM nginx:alpine

COPY --from=build /code/build/public /usr/share/nginx/html
