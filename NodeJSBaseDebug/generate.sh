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
cat ./Dockerfile.txt >> ${FOLDER}/Dockerfile

cat ./README.template.md \
  | sed "s/##BASE##/$BASE/" \
  | sed "s/##FOLDER##/$1/" > ${FOLDER}/README.md

cp ./README-short.txt ${FOLDER}/README-short.txt
cp ./start-fluxbox.sh ${FOLDER}/start-fluxbox.sh
cp ./start-vnc.sh ${FOLDER}/start-vnc.sh
cp ./nodejs-debug.conf ${FOLDER}/nodejs-debug.conf
