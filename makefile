prod:
	cd client; npm install
	cd client; grunt prod
	goxc
	cd client; npm install
	cd client; grunt

dev:
	go get
	go test
	go build
	cd client; npm install
	cd client; grunt
