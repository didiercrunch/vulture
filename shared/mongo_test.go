package shared

import (
	"testing"
)

func TestGetCanonicalMongoURL(t *testing.T) {
	tests := map[string]string{"localhost:8000": "localhost:8000",
		"mongodb://myuser:mypass@localhost:40001/mydb": "localhost:40001",
		"localhost": "localhost"}
	for u, exp := range tests {
		if s, err := GetCanonicalMongoURL(u); err != nil {
			t.Error(err)
		} else if s != exp {
			t.Error(s, " != ", exp)
		}
	}
}
