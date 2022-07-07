CREATE OR REPLACE EDITIONABLE TRIGGER  "trg_ad_avaliacao_item" 
  before insert or update on ad_avaliacao_item 
  referencing old as old new as new 
  for each row 
declare 
 
begin 
  if inserting then 
    select seq_ad_avaliacao_item.nextval 
      into :new.id_avaliacao 
      from dual; 
  end if; 
end; 

/
ALTER TRIGGER  "TRG_AD_AVALIACAO_ITEM" ENABLE
/