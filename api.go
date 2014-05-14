package main

import (
	"bitbucket.org/damyot/vulture/shared"
	"encoding/json"
	"errors"
	"github.com/gorilla/mux"
	"labix.org/v2/mgo"
	"labix.org/v2/mgo/bson"
	"net/http"
	"strconv"
)

type VultureBackend struct {
	Client     *mgo.Session
	Db         *mgo.Database
	Collection *mgo.Collection
}

func GetVultureBackend(req *http.Request) (*VultureBackend, error) {
	vars := mux.Vars(req)

	serverURL, ok := vars["server"]
	if !ok {
		return nil, errors.New("server field not specified")
	}
	client, err := shared.GetMongoClient(serverURL)
	if err != nil {
		return nil, err
	}
	vb := &VultureBackend{Client: client}
	vb.setDatabaseCollection(req)
	return vb, nil
}

func (this *VultureBackend) setDatabaseCollection(req *http.Request) {
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
	return this.Client.DatabaseNames()
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
	return params.MongoServers, nil
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
