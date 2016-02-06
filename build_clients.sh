#!/usr/bin/env bash
# Updates the EigenMusik API clients with Swagger codegen.

echo "Prepare a temporary directory"
rm -rf tmp
mkdir tmp
cd tmp

echo "Fetching and building Swagger codegen"
git clone https://github.com/swagger-api/swagger-codegen.git
cd swagger-codegen
mvn package
cd ../

CLIENTS=( swift java ) 

for CLIENT in "${CLIENTS[@]}"
do
  
    REPO=eigenmusik-${CLIENT}-client
    echo "Building $REPO client"

    echo "Fetching library skeleton"
    git clone https://github.com/EigenMusik/${REPO}.git
    cd $REPO

    java -jar ../swagger-codegen/modules/swagger-codegen-cli/target/swagger-codegen-cli.jar generate   -i http://api.eigenmusik.com/v2/api-docs   -l $CLIENT   -o ./ -c ./config.json

    if [ $? -ne 0 ]; then
        echo "Swagger codegen failed!"
        exit
    fi

    echo "Checking in updated client"
    git add .
    dt=$(date '+%d/%m/%Y %H:%M:%S');
    git commit -m "Updated @ $dt"
    git push

    if [ $? -ne 0 ]; then
        echo "Failed to update client"
        exit
    fi
    echo "Client updated!"

    cd ../

done







