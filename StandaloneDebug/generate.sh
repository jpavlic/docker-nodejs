#!/usr/bin/env bash
FOLDER=../$1
BASE=$2
VERSION=$3
NAMESPACE=$4
AUTHORS=$5

echo "# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" > ${FOLDER}/Dockerfile
echo "# NOTE: DO *NOT* EDIT THIS FILE.  IT IS GENERATED." >> ${FOLDER}/Dockerfile
echo "# PLEASE UPDATE Dockerfile.txt INSTEAD OF THIS FILE" >> ${FOLDER}/Dockerfile
echo "# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >> ${FOLDER}/Dockerfile
echo FROM ${NAMESPACE}/${BASE}:${VERSION} >> ${FOLDER}/Dockerfile
echo LABEL authors="$AUTHORS" >> ${FOLDER}/Dockerfile
echo "" >> ${FOLDER}/Dockerfile
cat ../Standalone/Dockerfile.txt >> ${FOLDER}/Dockerfile
echo EXPOSE 5900 >> ${FOLDER}/Dockerfile

cat ./README.template.md \
  | sed "s/##BASE##/$BASE/" \
  | sed "s/##FOLDER##/$1/" > ${FOLDER}/README.md
