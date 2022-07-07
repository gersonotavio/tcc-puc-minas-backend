CREATE OR REPLACE EDITIONABLE TRIGGER  "trg_ad_indicador_resultado" 
  before insert or update on ad_indicador_resultado 
  referencing old as old new as new 
  for each row 
declare 
 
begin 
  if inserting then 
    select seq_ad_indicador_resultado.nextval 
      into :new.id_indicador_resultado 
      from dual; 
  end if; 
end; 

/
ALTER TRIGGER  "TRG_AD_INDICADOR_RESULTADO" ENABLE
/
