#!/bin/bash
ORACLE_SID=$1
# Check whether ORACLE_SID is passed on
if [ "$ORACLE_SID" == "" ]; then
  ORACLE_SID=ORCL
fi;
export ORACLE_SID

sqlplus / as sysdba << EOF
  exec dbms_lock.sleep(30);

--Kill sessions holding rollback segments
var kill_sess_holding_rollback varchar2(4000);

begin
  :kill_sess_holding_rollback := q'[
  begin
    for x in (
      select sid||','||serial# sid_serial, username, segment_name
        from v\$transaction,dba_rollback_segs,v\$session
       where saddr=ses_addr and xidusn=segment_id
    ) loop
      dbms_output.put_line('Session holding lock: '||x.sid_serial||','||x.username||','||x.segment_name);
      begin
        dbms_output.put_line('about to execute: '||'alter system kill session '''||x.sid_serial||'''');
        execute immediate 'alter system kill session '''||x.sid_serial||'''';
      exception when others then
        dbms_output.put_line('sqlerrm: '||sqlerrm);
      end;
    end loop;
  end;]';
end;
 /

    EXEC EXECUTE IMMEDIATE :kill_sess_holding_rollback;
    --minimize size of UNDO TS
    CREATE UNDO TABLESPACE undotbs0 DATAFILE '$ORACLE_BASE/oradata/$ORACLE_SID/undotbs00.dbf' SIZE 1M AUTOEXTEND ON NEXT 1M;
    ALTER SYSTEM SET UNDO_TABLESPACE=undotbs0;
    DROP TABLESPACE undotbs1 INCLUDING CONTENTS AND DATAFILES;
    --minimize size of TEMP
    ALTER TABLESPACE temp SHRINK SPACE;

    ALTER DATABASE ADD LOGFILE GROUP 4 ('$ORACLE_BASE/oradata/$ORACLE_SID/redo04.log') SIZE 5M;
    ALTER DATABASE ADD LOGFILE GROUP 5 ('$ORACLE_BASE/oradata/$ORACLE_SID/redo05.log') SIZE 5M;
    ALTER DATABASE ADD LOGFILE GROUP 6 ('$ORACLE_BASE/oradata/$ORACLE_SID/redo06.log') SIZE 5M;

--Force XDB initialization in DB
    CREATE TABLE TEMP_XDB_INIT(DUMMY XMLTYPE);
    DROP TABLE TEMP_XDB_INIT;

    declare
      current_log_group integer;
    begin
      loop
        select group# into current_log_group from v\$log where status = 'CURRENT';
        exit when current_log_group > 3;
        execute immediate 'ALTER SYSTEM SWITCH LOGFILE';
      end loop;
    end;
    /

    ALTER SYSTEM CHECKPOINT GLOBAL;

    ALTER DATABASE DROP LOGFILE GROUP 1;
    ALTER DATABASE DROP LOGFILE GROUP 2;
    ALTER DATABASE DROP LOGFILE GROUP 3;

  exit;
EOF

rm -f $ORACLE_BASE/oradata/$ORACLE_SID/redo01.log
rm -f $ORACLE_BASE/oradata/$ORACLE_SID/redo02.log
rm -f $ORACLE_BASE/oradata/$ORACLE_SID/redo03.log
