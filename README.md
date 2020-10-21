# How to update data from Centraal Museum Utrecht into Van Gogh World Wide

## run harvest_cmu.sh
Triggers adlibHarvester.py. This python3 script does a request on the Axiell webAPI retrieving a list of identifiers of all Van Gogh's and than retrieve the data per artwork. Stores AdlibXML in the adlibxml-directory for every artwork.

## run convert_cmu.sh
Triggers 
1. XSLT-transformation (xmllint with cmu_linked-art.xslt) for every adlibXML file and stores a RDF/XML file in the rdf-directory.
2. Serialization into turtle (rapper) for every RDF/XML file (mainly to check RDF/XML validity)
3. Creates the cmu.zip file with all the turtle files

## why XSLT?
This XSLT stylesheet can be used in the configuration of the webAPI, serverside. This means the clientside transformation is no longer needed and RDF/XML can be retrieved directly from the webAPI. You still need to do the two-step harvesting with the adlibHarvester.py (or simular technique), though.

