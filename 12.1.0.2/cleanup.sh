# Remove not needed components
rm -rf $ORACLE_HOME/apex
rm -rf $ORACLE_HOME/jdbc
# ZDLRA installer files
rm -rf $ORACLE_HOME/lib/ra*.zip
rm -rf $ORACLE_HOME/ords
rm -rf $ORACLE_HOME/sqldeveloper
rm -rf $ORACLE_HOME/ucp
# as we woun't install patches
rm -rf $ORACLE_HOME/lib/*.a
# OUI backup
rm -rf $ORACLE_HOME/inventory/backup/*
# Network tools help
rm -rf $ORACLE_HOME/network/tools/help/mgr/help_*
# Temp location
rm -rf /tmp/* 