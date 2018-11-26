# blog

```
find public -type f -name '*.md' | xargs -n1 -P0 ./build.sh
docker build -t blog .
docker run -p 80:80 blog
```

