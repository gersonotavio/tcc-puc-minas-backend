CREATE OR REPLACE EDITIONABLE TRIGGER  "trg_ad_avaliacao" 
  before insert or update on ad_avaliacao 
  referencing old as old new as new 
  for each row 
declare 
   
begin 
  if inserting then 
    select seq_ad_avaliacao.nextval 
      into :new.id 
      from dual; 
  end if; 
end; 

/
ALTER TRIGGER  "TRG_AD_AVALIACAO" ENABLE
/
