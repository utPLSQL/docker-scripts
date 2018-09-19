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
--Resize SYSTEM and SYSAUX by 50MB to make room for installed code without forcing extend
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

    ALTER DATABASE DATAFILE '$ORACLE_BASE/oradata/$ORACLE_SID/undotbs00.dbf' RESIZE 250M;
    ALTER DATABASE TEMPFILE '$ORACLE_BASE/oradata/$ORACLE_SID/temp01.dbf' RESIZE 250M;
    ALTER DATABASE DATAFILE '$ORACLE_BASE/oradata/$ORACLE_SID/users01.dbf' RESIZE 50M;

    ALTER DATABASE ADD LOGFILE GROUP 1 ('$ORACLE_BASE/oradata/$ORACLE_SID/redo01.log') SIZE 250M;
    ALTER DATABASE ADD LOGFILE GROUP 2 ('$ORACLE_BASE/oradata/$ORACLE_SID/redo02.log') SIZE 250M;
    ALTER DATABASE ADD LOGFILE GROUP 3 ('$ORACLE_BASE/oradata/$ORACLE_SID/redo03.log') SIZE 250M;

    declare
      current_log_group integer;
    begin
      loop
        select group# into current_log_group from v\$log where status = 'CURRENT';
        exit when current_log_group <= 3;
        execute immediate 'ALTER SYSTEM SWITCH LOGFILE';
      end loop;
    end;
    /

    ALTER SYSTEM CHECKPOINT GLOBAL;

    ALTER DATABASE DROP LOGFILE GROUP 4;
    ALTER DATABASE DROP LOGFILE GROUP 5;
    ALTER DATABASE DROP LOGFILE GROUP 6;
exit;
EOF

rm -f $ORACLE_BASE/oradata/$ORACLE_SID/redo04.log
rm -f $ORACLE_BASE/oradata/$ORACLE_SID/redo05.log
rm -f $ORACLE_BASE/oradata/$ORACLE_SID/redo06.log
