CREATE OR REPLACE EDITIONABLE TRIGGER  "trg_ad_diretoria" 
  before insert or update on AD_DIRETORIA 
  referencing old as old new as new 
  for each row 
declare 
 
begin 
  if inserting then 
    select SEQ_AD_DIRETORIA.nextval 
      into :new.id_diretoria 
      from dual; 
  end if; 
end; 

/
ALTER TRIGGER  "TRG_AD_DIRETORIA" ENABLE
/
