package main

import (
	"encoding/json"
	"net/http"
)

type errorWrapper struct {
	Error error `json:"error"`
}

type ApiHandler func(w http.ResponseWriter, request *http.Request) (interface{}, error)

func (this ApiHandler) ServeHTTP(w http.ResponseWriter, request *http.Request) {
	ret, err := this(w, request)
	if err != nil {
		ret = &errorWrapper{err}
		w.WriteHeader(500)
	} else {
		w.WriteHeader(200)
	}
	enc := json.NewEncoder(w)
	enc.Encode(ret)
}
