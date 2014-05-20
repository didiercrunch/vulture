package main

import (
	"bitbucket.org/damyot/vulture/shared"
	"encoding/json"
	"errors"
	"github.com/gorilla/mux"
	"labix.org/v2/mgo"
	"labix.org/v2/mgo/bson"
	"net/http"
	"net/url"
	"strconv"
)

type VultureBackend struct {
	MongoURL   string
	Client     *mgo.Session
	Db         *mgo.Database
	Collection *mgo.Collection
}

func GetVultureBackend(req *http.Request) (*VultureBackend, error) {
	vars := mux.Vars(req)

	serverName, ok := vars["server"]
	if !ok {
		return nil, errors.New("server field not specified")
	}
	mongoURL, ok := params.MongoServers.GetServerUrl(serverName)
	if !ok {
		return nil, errors.New("no server for asked name.")
	}

	client, err := shared.GetMongoClient(mongoURL)
	if err != nil {
		return nil, err
	}
	vb := &VultureBackend{Client: client, MongoURL: mongoURL}
	vb.setDatabaseAndCollection(req)
	return vb, nil
}

func (this *VultureBackend) setDatabaseAndCollection(req *http.Request) {
	vars := mux.Vars(req)
	database, ok := vars["database"]
	if !ok {
		return
	}
	this.Db = this.Client.DB(database)
	collection, ok := vars["collection"]
	if !ok {
		return
	}
	this.Collection = this.Db.C(collection)

}

func (this *VultureBackend) GetDataBases() ([]string, error) {

	dbs, err := this.Client.DatabaseNames()
	if err == nil {
		return dbs, nil
	} else if err.Error() == "unauthorized" {
		return this.getDatabaseFromMongoURL()
	} else {
		return nil, err
	}
}

func (this *VultureBackend) getDatabaseFromMongoURL() ([]string, error) {
	u, e := url.Parse(this.MongoURL)
	if e != nil {
		return nil, errors.New("cannot extract database from url")
	}
	return []string{u.Path[1:len(u.Path)]}, nil
}

func (this *VultureBackend) GetCollections() ([]string, error) {
	if this.Db == nil {
		return nil, errors.New("no database set")
	}
	return this.Db.CollectionNames()
}

func (this *VultureBackend) getIndexes() (interface{}, error) {
	idxs, err := this.Collection.Indexes()
	if err != nil {
		return nil, err
	}
	ret := make([]map[string]interface{}, len(idxs))
	for i, idx := range idxs {
		ret[i] = map[string]interface{}{"name": idx.Name, "keys": idx.Key}
	}
	return ret, nil

}

func (this *VultureBackend) getMetaData(query *mgo.Query) (map[string]interface{}, error) {
	meta := make(map[string]interface{})
	if query == nil {
		return meta, nil
	}
	var err error
	if meta["count"], err = query.Count(); err != nil {
		return meta, err
	}
	if meta["indexes"], err = this.getIndexes(); err != nil {
		return meta, err
	}

	return meta, nil

}

func (this *VultureBackend) GetDocumentByIndex(index int, query interface{}) (map[string]interface{}, error) {
	doc := make(map[string]interface{})
	queryResult := this.Collection.Find(query)
	if err := queryResult.Skip(index).One(&doc); err != nil {
		return nil, err
	}
	return this.wrapDocumentWithMetadata(doc, queryResult)
}

func (this *VultureBackend) wrapDocumentWithMetadata(doc interface{}, query *mgo.Query) (map[string]interface{}, error) {
	ret := make(map[string]interface{})
	var err error
	ret["document"] = doc
	if ret["meta"], err = this.getMetaData(query); err != nil {
		return ret, err
	}
	return ret, nil
}

func (this *VultureBackend) GetStat(key string) (interface{}, error) {
	s := NewStatAggregator()
	query := bson.M{key: bson.M{"$exists": true}}
	iter := this.Collection.Find(query).Select(bson.M{key: 1}).Iter()
	result := make(map[string]interface{})

	in := make(chan float64)
	out := make(chan *Stats)
	go s.AddStats(in, out)

	for iter.Next(&result) {

		if val, ok := result[key]; ok {
			if fval, isFloat := val.(float64); isFloat {
				in <- fval
			} else if ival, isInt := val.(int); isInt {
				in <- float64(ival)
			}
		}
	}
	close(in)
	if err := iter.Close(); err != nil {
		return nil, err
	}
	return <-out, nil
}

func (this *VultureBackend) GetAllDocuments(query interface{}) (interface{}, error) {
	var result []map[string]interface{}

	iter := this.Collection.Find(query).Iter()
	iter.All(&result)
	if err := iter.Close(); err != nil {
		return nil, err
	}

	return this.wrapDocumentWithMetadata(result, nil)
}

func getAvailableServers(w http.ResponseWriter, request *http.Request) (interface{}, error) {
	ret := make([]string, len(params.MongoServers))
	for i, ms := range params.MongoServers {
		ret[i] = ms.Name
	}
	return ret, nil
}

func getAvailableDataBases(w http.ResponseWriter, request *http.Request) (interface{}, error) {
	vb, err := GetVultureBackend(request)
	if err != nil {
		return nil, err
	}
	return vb.GetDataBases()
}

func getAvailableCollections(w http.ResponseWriter, request *http.Request) (interface{}, error) {
	vb, err := GetVultureBackend(request)
	if err != nil {
		return nil, err
	}
	return vb.GetCollections()
}

func getDocumentByIndex(w http.ResponseWriter, request *http.Request) (interface{}, error) {
	vb, err := GetVultureBackend(request)
	if err != nil {
		return nil, err
	}
	vars := mux.Vars(request)
	indexAsString, ok := vars["index"]
	if !ok {
		return nil, errors.New("index field not specified")
	}
	index, err := strconv.Atoi(indexAsString)
	if err != nil {
		return nil, errors.New("index field is not an inteder ( " + indexAsString + ")")
	}
	return vb.GetDocumentByIndex(index, nil)
}

func getAllDocuments(w http.ResponseWriter, request *http.Request) (interface{}, error) {
	vb, err := GetVultureBackend(request)
	if err != nil {
		return nil, err
	}
	vars := mux.Vars(request)
	queryString, ok := vars["query"]
	if !ok || queryString == "" {
		return vb.GetAllDocuments(nil)
	}
	query := make(map[string]interface{})
	if err := json.Unmarshal([]byte(queryString), &query); err != nil {
		return nil, errors.New("invalid json")
	}
	return vb.GetAllDocuments(query)
}

func getDocumentById(w http.ResponseWriter, request *http.Request) (interface{}, error) {
	vb, err := GetVultureBackend(request)
	if err != nil {
		return nil, err
	}
	vars := mux.Vars(request)
	id, ok := vars["id"]
	if !ok {
		return nil, errors.New("id field not specified")
	}
	if !bson.IsObjectIdHex(id) {
		return nil, errors.New("id field is not an object id")
	}
	return vb.GetDocumentByIndex(0, bson.M{"_id": bson.ObjectIdHex(id)})
}

func getDocumentByQueryAndIndex(w http.ResponseWriter, request *http.Request) (interface{}, error) {
	vb, err := GetVultureBackend(request)
	if err != nil {
		return nil, err
	}
	vars := mux.Vars(request)
	indexAsString, ok := vars["index"]
	if !ok {
		return nil, errors.New("index field not specified")
	}
	index, err := strconv.Atoi(indexAsString)
	if err != nil {
		return nil, errors.New("index field is not an inteder ( " + indexAsString + ")")
	}
	queryString, ok := vars["query"]
	if !ok || queryString == "" {
		return vb.GetDocumentByIndex(index, nil)
	}
	query := make(map[string]interface{})
	if err := json.Unmarshal([]byte(queryString), &query); err != nil {
		return nil, errors.New("invalid json")
	}
	return vb.GetDocumentByIndex(index, query)
}

func getStats(w http.ResponseWriter, request *http.Request) (interface{}, error) {
	vb, err := GetVultureBackend(request)
	if err != nil {
		return nil, err
	}

	vars := mux.Vars(request)
	key, ok := vars["key"]
	if !ok {
		return nil, errors.New("key field not specified")
	}
	return vb.GetStat(key)
}
