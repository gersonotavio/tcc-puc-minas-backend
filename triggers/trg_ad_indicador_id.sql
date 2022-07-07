CREATE OR REPLACE EDITIONABLE TRIGGER  "trg_ad_indicador_id" 
  before insert or update on AD_INDICADOR 
  referencing old as old new as new 
  for each row 
declare 
 
begin 
  if inserting then 
    select MAX(ID)+1 
      into :new.ID 
      from AD_INDICADOR; 
  end if; 
end; 


/
ALTER TRIGGER  "TRG_AD_INDICADOR_ID" ENABLE
/
