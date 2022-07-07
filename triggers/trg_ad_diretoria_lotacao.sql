CREATE OR REPLACE EDITIONABLE TRIGGER  "trg_ad_diretoria_lotacao" 
  before insert or update on AD_DIRETORIA_LOTACAO 
  referencing old as old new as new 
  for each row 
declare 
 
begin 
  if inserting then 
    select SEQ_AD_DIRETORIA_LOTACAO.nextval 
      into :new.ID_DIRETORIA_LOTACAO 
      from dual; 
  end if; 
end; 

/
ALTER TRIGGER  "TRG_AD_DIRETORIA_LOTACAO" ENABLE
/
