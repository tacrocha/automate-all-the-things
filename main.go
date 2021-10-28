package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func main() {
	r := chi.NewRouter()
	r.Use(middleware.Logger)

	// The /liatrio endpoint returns a JSON with a message and a timestamp
	r.Get("/liatrio", func(w http.ResponseWriter, r *http.Request) {
		w.Write(buildMessage())
	})

	portNumber := os.Getenv("HTTP_PORT")
	if portNumber == "" {
		portNumber = "3000"
	}
	fmt.Printf("Application started on port %s\n", portNumber)

	http.ListenAndServe(":"+portNumber, r)
}

type JSONPayload struct {
	Message   string `json:"message"`
	Timestamp int64  `json:"timestamp"`
}

// Builds the JSON payload to be written to the response
func buildMessage() []byte {

	msg := JSONPayload{
		Message:   "Automate all the things!",
		Timestamp: time.Now().Unix(),
	}

	json, err := json.MarshalIndent(msg, "", "  ")
	if err != nil {
		panic(err)
	}

	return json
}
