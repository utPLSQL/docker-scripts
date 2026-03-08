#!/bin/bash

echo "SELECT open_mode FROM v\$database;" | sqlplus -s / as sysdba | grep "READ WRITE"
