#!/bin/bash

# transform Adlib XML into RDF/XML
for xml_file in adlibxml/*.adlib.xml
do
        rdf_file=$(basename -- "$xml_file")
        xsltproc -o rdf/${rdf_file%%.*}.rdf.xml cmu_linked-art.xslt $xml_file
done

# serialize RDF/XML into turtle for the ultimate test
for rdf_file in rdf/*.rdf.xml
do
        ttl_file=$(basename -- "$rdf_file")
        rapper -q -o turtle $rdf_file > rdf/${ttl_file%%.*}.ttl
done

zip cmu.zip rdf/*.ttl