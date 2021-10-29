# syntax=docker/dockerfile:1

# Build
FROM golang:1.17-alpine AS build

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY *.go ./

RUN go build -o /automate-all-the-things

# Deploy
FROM alpine:3.14.2

WORKDIR /

COPY --from=build /automate-all-the-things /automate-all-the-things

EXPOSE 8080

RUN adduser -D nonroot
USER nonroot

ENTRYPOINT ["/automate-all-the-things"]