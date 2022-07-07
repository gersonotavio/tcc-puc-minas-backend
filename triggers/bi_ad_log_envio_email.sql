CREATE OR REPLACE EDITIONABLE TRIGGER  "bi_ad_log_envio_email" 
  before insert on "AD_LOG_ENVIO_EMAIL"
  for each row
begin
  if :NEW."ID_LOG" is null then
    select MAX(nvl(:NEW."ID_LOG",0)) + 1
      into :NEW."ID_LOG"
      from dual;
  end if;
end;

/
ALTER TRIGGER  "BI_AD_LOG_ENVIO_EMAIL" ENABLE
/
