isuports: test go.mod go.sum *.go cmd/isuports/*
	go build -o isuports ./cmd/isuports

sqlite2mysql: test go.mod go.sum *.go cmd/sqlite2mysql/*
	go build -o sqlite2mysql ./cmd/sqlite2mysql

test:
	go test -v ./...
