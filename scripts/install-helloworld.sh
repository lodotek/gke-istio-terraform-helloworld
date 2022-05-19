#!/usr/bin/env bash

DIR="$( cd "$( dirname "$0" )" && pwd )"
echo $DIR
kubectl apply -f $DIR/../helloworld/helloworld.yaml -n myapp
kubectl apply -f $DIR/../helloworld/helloworld-gateway.yaml -n myapp
