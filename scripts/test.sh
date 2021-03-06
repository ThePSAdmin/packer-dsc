#!/bin/sh -e

# Get Test dependencies
go get github.com/axw/gocov/gocov
go get github.com/mattn/goveralls
go get golang.org/x/tools/cmd/cover
# go get code.google.com/p/go.tools/cmd/cover
go get github.com/modocache/gover

# Run test coverage on each subdirectories and merge the coverage profile.

echo "mode: count" > profile.cov

# Standard go tooling behavior is to ignore dirs with leading underscors
for dir in $(find . -maxdepth 10 -not -path './.git*' -not -path './vendor*' -not -path './examples/*' -not -path './pkg' -not -path './bin' -not -path './scripts' -not -path '*/_*' -type d); do
  if ls $dir/*.go &> /dev/null; then
    go test -covermode=count -coverprofile=$dir/profile.tmp $dir
    if [ $? = 1 ]; then
      echo "Test failure, exiting"
      exit 1
    fi
        
    if [ -f $dir/profile.tmp ]; then
    	cat $dir/profile.tmp | tail -n +2 >> profile.cov
    	rm $dir/profile.tmp
    fi
  fi
done

go tool cover -func profile.cov
