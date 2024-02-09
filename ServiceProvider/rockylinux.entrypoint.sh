#!/bin/bash

httpd -k start
shibd start

exec "$@"
tail -f /dev/null