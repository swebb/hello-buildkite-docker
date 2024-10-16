FROM alpine

RUN date > date.txt
CMD ["echo", "Hello Buildkite!"]
