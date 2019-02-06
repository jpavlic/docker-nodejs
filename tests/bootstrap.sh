#!/usr/bin/env bash
cd tests

if [ "${TRAVIS:-false}" = "false" ]; then
  pip install virtualenv | grep -v 'Requirement already satisfied'
  virtualenv docker-nodejs-tests
  source docker-nodejs-tests/bin/activate
fi

python test.py $1 $2
ret_code=$?

if [ "${TRAVIS:-false}" = "false" ]; then
  deactivate
fi

exit $ret_code
