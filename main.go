package main

import (
	"fmt"
	"github.com/gorilla/mux"
	"io/ioutil"
	"launchpad.net/goyaml"
	"log"
	"net/http"
	"path"
	"strconv"
)

const PARAM_FILE string = "params.yml"
const STATIC_DIR string = "client"

type MongoServer struct {
	Name string `yaml:"name"`
	Url  string `yaml:"url"`
}

type MongoServers []*MongoServer

func (this MongoServers) GetServerUrl(name string) (url string, found bool) {
	for _, server := range this {
		if server.Name == name {
			return server.Url, true
		}
	}
	return "", false
}

type Params struct {
	Port           int          `yaml:"Port,omitempty"`
	ServingAddress string       `yaml:"ServingAddress,omitempty"`
	MongoServers   MongoServers `yaml:"MongoServers,omitempty"`
}

func (this *Params) LoadFromYamlFile(fileName string) error {
	data, err := ioutil.ReadFile(fileName)
	if err != nil {
		return err
	}
	return this.LoadFromYamlData(data)
}

func (this *Params) LoadFromYamlData(data []byte) error {
	var err error
	p := new(Params)
	if err = goyaml.Unmarshal(data, p); err != nil {
		return err
	}

	if p.ServingAddress != "" {
		this.ServingAddress = p.ServingAddress
	}
	if p.Port > 0 {
		this.Port = p.Port
	}
	if p.MongoServers != nil && len(p.MongoServers) > 0 {
		this.MongoServers = p.MongoServers
	}
	return nil
}

func GetDefaultParams() *Params {
	return &Params{8000, "localhost", MongoServers{&MongoServer{Name: "localhost", Url: "localhost:27017"}}}
}

var params = GetDefaultParams()

func init() {
	if err := params.LoadFromYamlFile(PARAM_FILE); err != nil {
		panic(err)
	}
}

func serveStatic(router *mux.Router) {
	handler := func(w http.ResponseWriter, request *http.Request) {
		vars := mux.Vars(request)
		filepath := "/" + vars["path"]
		w.Header().Set("Cache-Control", "public, max-age=43200")
		http.ServeFile(w, request, path.Join(STATIC_DIR, filepath))
	}
	router.HandleFunc("/{path:.*}", handler)
}

func serveApi(router *mux.Router) {
	router.Handle("/servers", ApiHandler(getAvailableServers))
	router.Handle("/{server}/databases", ApiHandler(getAvailableDataBases))
	router.Handle("/{server}/{database}/collections", ApiHandler(getAvailableCollections))
	router.Handle("/{server}/{database}/{collection}/idx/{index:[0-9]+}", ApiHandler(getDocumentByIndex))
	router.Handle("/{server}/{database}/{collection}/_id/{id}", ApiHandler(getDocumentById))
	router.Handle("/{server}/{database}/{collection}/stats/{key}", ApiHandler(getStats))
	router.Handle("/{server}/{database}/{collection}/all", ApiHandler(getAllDocuments))
	router.Handle("/{server}/{database}/{collection}/query/{query}/idx/{index:[0-9]+}", ApiHandler(getDocumentByQueryAndIndex))
	router.Handle("/{server}/{database}/{collection}/query/{query}/all", ApiHandler(getAllDocuments))

	// getAllDocuments
}

func createMuxRouter() http.Handler {
	r := mux.NewRouter()
	serveApi(r.PathPrefix("/api").Subrouter())
	serveStatic(r.PathPrefix("/").Subrouter())
	return r
}

func main() {
	address := params.ServingAddress + ":" + strconv.Itoa(params.Port)
	fmt.Println("serving ", address)
	if err := http.ListenAndServe(address, createMuxRouter()); err != nil {
		log.Fatal(err)
	}
}
