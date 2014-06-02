package main

import (
	"encoding/json"
	"log"
	"net/http"
	"time"
)

type errorWrapper struct {
	Error string `json:"error"`
}

type ApiHandler func(w http.ResponseWriter, request *http.Request) (interface{}, error)

func (this ApiHandler) addEnlapsedTimeIfPossible(enlapsedTime time.Duration, obj interface{}) {
	if dict, ok := obj.(map[string]interface{}); ok {
		dict["enlapsed_time"] = enlapsedTime.Seconds()
	}

}
func (this ApiHandler) ServeHTTP(w http.ResponseWriter, request *http.Request) {
	log.Println("request for", request.URL)
	t := time.Now()
	ret, err := this(w, request)
	this.addEnlapsedTimeIfPossible(time.Since(t), ret)
	if err != nil {
		log.Println(err)
		ret = &errorWrapper{err.Error()}
		w.WriteHeader(500)
	} else {
		w.WriteHeader(200)
	}
	enc := json.NewEncoder(w)
	if err := enc.Encode(ret); err != nil {
		log.Println(err)
	}
}
