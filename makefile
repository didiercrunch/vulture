prod: dev
	rm -rf client/node_modules
	goxc
	goxc bintray

dev:
	go get
	go test
	go build
	cd client; npm install
	cd client; node_modules/.bin/gulp

clean:
	cd client; node_modules/.bin/gulp clean
	rm -rf client/node_modules
