FROM golang AS build
WORKDIR /go/src/github.com/qnib/k8s-cli
COPY ./ ./
RUN go build

FROM debian
RUN apt-get update \
 && apt-get install -y curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app/
COPY --from=build /go/src/github.com/qnib/k8s-cli/k8s-cli ./k8s-cli
CMD ["/app/k8s-cli"]