# automate-all-the-things

Automate All The Things is a Go application that exposes a REST endpoint a JSON with a message and the current timestamp:

```json
{
  "message": "Automate all the things!",
  "timestamp": 1635306480
}
```

Run application:
```
go run main.go
```

Then see it in action at [http://localhost:3000/liatrio](http://localhost:3000/liatrio).