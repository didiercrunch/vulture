package main

import (
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"os"
	"path"
	"reflect"
	"testing"
)

func TestLoadFromYamlDataAndInitialParams(t *testing.T) {
	if params.Port != 8000 {
		t.Error("wrong port")
	}
	if params.ServingAddress != "localhost" {
		t.Error("wrong png dpi")
	}
	if !reflect.DeepEqual(params.MongoServers, []string{"localhost:27017"}) {
		t.Fail()
	}
}

func createMockStaticFile() (*os.File, error) {
	f, err := ioutil.TempFile(STATIC_DIR, "go_testing")
	if err != nil {
		return nil, err
	}
	return f, ioutil.WriteFile(f.Name(), []byte("hello world"), 0600)

}

func TestServingStaticFiles(t *testing.T) {
	ts := httptest.NewServer(createMuxRouter())
	defer ts.Close()

	f, err := createMockStaticFile()
	if err != nil {
		t.Error(err)
		return
	}
	defer os.Remove(f.Name())

	res, err := http.Get(ts.URL + "/" + path.Base(f.Name()))
	if err != nil {
		t.Error(err)
		return
	}
	body, err := ioutil.ReadAll(res.Body)
	res.Body.Close()
	if err != nil {
		t.Error(err)
		return
	}
	if string(body) != "hello world" {
		t.Error(f.Name())
	}

}
