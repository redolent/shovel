#!/bin/bash
curl 'http://localhost:8080/solr/update/json?commit=true' --data-binary @"$1"  -H 'Content-type:application/json'
