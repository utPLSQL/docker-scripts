#!/bin/bash
# LICENSE CDDL 1.0 + GPL 2.0
#
# Copyright (c) 1982-2016 Oracle and/or its affiliates. All rights reserved.
# 
# Since: November, 2016
# Author: gerald.venzl@oracle.com
# Description: Creates an Oracle Database based on following parameters:
#              $ORACLE_SID: The Oracle SID and CDB name
#              $ORACLE_PDB: The PDB name
# 
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
# 

sqlplus / as sysdba <<EOF
CREATE PLUGGABLE DATABASE $ORACLE_PDB ADMIN USER PDBADMIN IDENTIFIED BY "$ORACLE_PWD"
  FILE_NAME_CONVERT=('$ORACLE_BASE/oradata/ORCLCDB/pdbseed/','$PDB_BASE_DIR/$ORACLE_PDB/');
ALTER PLUGGABLE DATABASE $ORACLE_PDB SAVE STATE;  
ALTER PLUGGABLE DATABASE $ORACLE_PDB OPEN READ WRITE;
ALTER PLUGGABLE DATABASE $ORACLE_PDB SAVE STATE;

--In PDB
    ALTER SESSION SET CONTAINER = $ORACLE_PDB;

    CREATE TABLESPACE users DATAFILE '$PDB_BASE_DIR/$ORACLE_PDB/users01.dbf' SIZE 50M AUTOEXTEND ON NEXT 1M;

--Force XDB initialization in PDB
    CREATE TABLE TEMP_XDB_INIT(DUMMY XMLTYPE);
    DROP TABLE TEMP_XDB_INIT;

--Resize PDB SYSTEM and SYSAUX by 50MB to make room for installed code without forcing extend
    declare
      v_extra_space_MB integer := 50;
    begin
      for i in (
        select 'alter database datafile '''||file_name||''' resize '||( (bytes/1024/1024) + v_extra_space_MB )||'M' stmnt
        from dba_data_files df
        where tablespace_name in ('SYSTEM','SYSAUX')
          and not exists
          (select 1 from dba_free_space fs
            where fs.tablespace_name = df.tablespace_name
            having sum(bytes)/1024/1024 >= v_extra_space_MB
          )
      ) loop
        begin
          execute immediate i.stmnt;
          dbms_output.put_line('Executed: '||i.stmnt);
        exception when others then
          dbms_output.put_line('Failed to execute: '||i.stmnt);
          raise;
        end;
      end loop;
    end;
/

    ALTER DATABASE DATAFILE '$PDB_BASE_DIR/$ORACLE_PDB/undotbs00.dbf' RESIZE 250M;
    ALTER DATABASE TEMPFILE '$PDB_BASE_DIR/$ORACLE_PDB/temp01.dbf' RESIZE 250M;

exit;
EOF

# Fix issue with SQL tuning advisor auto-task getting invoked and failing on 18.3 SE2 DB.
# This task should not be executed (as it is licensed for EE only)
#   ORA-12012: error on auto execute of job "SYS"."ORA\$AT_SQ_SQL_SW_3"
#   ORA-38153: Software edition is incompatible with SQL plan management.
# Details: https://www.markusdba.net/?p=429
sqlplus / as sysdba <<EOF
    EXEC dbms_auto_task_admin.disable('sql tuning advisor', NULL, NULL);
    ALTER SESSION SET CONTAINER = $ORACLE_PDB;
    EXEC dbms_auto_task_admin.disable('sql tuning advisor', NULL, NULL);
exit;
EOF
