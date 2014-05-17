package main

import (
	"encoding/json"
	"log"
	"net/http"
)

type errorWrapper struct {
	Error string `json:"error"`
}

type ApiHandler func(w http.ResponseWriter, request *http.Request) (interface{}, error)

func (this ApiHandler) ServeHTTP(w http.ResponseWriter, request *http.Request) {
	log.Println("request for", request.URL)
	ret, err := this(w, request)
	if err != nil {
		log.Println(err)
		ret = &errorWrapper{err.Error()}
		w.WriteHeader(500)
	} else {
		w.WriteHeader(200)
	}
	enc := json.NewEncoder(w)
	enc.Encode(ret)
}
