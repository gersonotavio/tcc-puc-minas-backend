CREATE OR REPLACE EDITIONABLE TRIGGER  "trg_ad_alinhamento" 
  before insert on ad_alinhamento 
  referencing old as old new as new 
  for each row 
begin 
  select nvl(max(id_alinhamento), 0) + 1 
    into :new.id_alinhamento 
    from ad_alinhamento; 
end; 

/
ALTER TRIGGER  "TRG_AD_ALINHAMENTO" ENABLE
/
