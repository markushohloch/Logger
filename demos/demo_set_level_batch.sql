-- Logger demo file
-- How does set_level work for batches / long running jobs?

create or replace procedure run_long_batch(
  p_client_id in varchar2,
  p_iterations in pls_integer)
as
  l_params logger.tab_param;
  l_scope logger_logs.scope%type := 'run_long_batch';
begin
  logger.append_param(l_params, 'p_client_id', p_client_id);
  logger.append_param(l_params, 'p_iterations', p_iterations);
  logger.log('START', l_scope, null, l_params);

  dbms_session.set_identifier(p_client_id);

  for i in 1..p_iterations loop
    logger.log('i: ' || i, l_scope);
    dbms_lock.sleep(1);
  end loop;

  logger.log('END');

end run_long_batch;
/


-- Setup
begin
  delete from logger_logs;
  logger.set_level(logger.g_error); -- Simulates Production
  logger.unset_client_level_all;
  commit;
end;
/

-- In SQL Plus
begin
  run_long_batch(p_client_id => 'in_sqlplus', p_iterations => 50);
end;
/


-- In SQL Dev
exec logger.set_level(logger.g_debug, 'in_sqlplus');

exec logger.unset_client_level('in_sqlplus');

exec logger.set_level(logger.g_debug, 'in_sqlplus');

exec logger.unset_client_level('in_sqlplus');

select logger_level, line_no, text, time_stamp, scope
from logger_logs
order by id
;

-- Reset Logging Level
exec logger.set_level(logger.g_debug);
