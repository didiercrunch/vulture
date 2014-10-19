package shared

import (
	"errors"
	"fmt"
	"net/url"
	"strings"

	"gopkg.in/mgo.v2"
)

var mongoClients = make(map[string]*mgo.Session)

func GetCanonicalMongoURL(u string) (string, error) {
	urlinfo, err := parseMongoURL(u)
	if err != nil {
		return "", err
	}
	return strings.Join(urlinfo.addrs, "/"), nil

}

func GetMongoClient(url string) (*mgo.Session, error) {
	murl, err := GetCanonicalMongoURL(url)
	if err != nil {
		return nil, err
	}
	client, ok := mongoClients[murl]
	if !ok {
		return getNewMongoClient(url)
	}
	if client.Ping() != nil {
		return getNewMongoClient(url)
	}
	return client, nil
}

func getNewMongoClient(url string) (*mgo.Session, error) {
	client, err := mgo.Dial(url)
	if err != nil {
		return nil, err
	}
	murl, err := GetCanonicalMongoURL(url)
	if err != nil {
		return nil, err
	}
	mongoClients[murl] = client
	return client, nil
}

type urlInfo struct {
	addrs   []string
	user    string
	pass    string
	db      string
	options map[string]string
}

func isOptSep(c rune) bool {
	return c == ';' || c == '&'
}

func parseMongoURL(s string) (*urlInfo, error) {
	if strings.HasPrefix(s, "mongodb://") {
		s = s[10:]
	}
	info := &urlInfo{options: make(map[string]string)}
	if c := strings.Index(s, "?"); c != -1 {
		for _, pair := range strings.FieldsFunc(s[c+1:], isOptSep) {
			l := strings.SplitN(pair, "=", 2)
			if len(l) != 2 || l[0] == "" || l[1] == "" {
				return nil, errors.New("connection option must be key=value: " + pair)
			}
			info.options[l[0]] = l[1]
		}
		s = s[:c]
	}
	if c := strings.Index(s, "@"); c != -1 {
		pair := strings.SplitN(s[:c], ":", 2)
		if len(pair) > 2 || pair[0] == "" {
			return nil, errors.New("credentials must be provided as user:pass@host")
		}
		var err error
		info.user, err = url.QueryUnescape(pair[0])
		if err != nil {
			return nil, fmt.Errorf("cannot unescape username in URL: %q", pair[0])
		}
		if len(pair) > 1 {
			info.pass, err = url.QueryUnescape(pair[1])
			if err != nil {
				return nil, fmt.Errorf("cannot unescape password in URL")
			}
		}
		s = s[c+1:]
	}
	if c := strings.Index(s, "/"); c != -1 {
		info.db = s[c+1:]
		s = s[:c]
	}
	info.addrs = strings.Split(s, ",")
	return info, nil
}
