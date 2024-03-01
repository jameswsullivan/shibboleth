#!/bin/bash

service apache2 start
service shibd start

exec "$@"
tail -f /dev/null