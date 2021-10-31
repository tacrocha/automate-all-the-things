package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

const portNumber = ":8080"

func main() {
	r := chi.NewRouter()
	r.Use(middleware.Logger)

	// The / endpoint returns a JSON with a message and a timestamp
	r.Get("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write(buildMessage())
	})

	fmt.Printf("Starting application on port %s\n", portNumber)

	http.ListenAndServe(portNumber, r)
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
